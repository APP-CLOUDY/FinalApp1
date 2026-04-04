import UIKit
import SwiftUI
import Charts // Requires iOS 16+

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        
        self.init(red: r, green: g, blue: b)
    }
}
    final class ParentDashboardViewController: UIViewController {
        
        // MARK: - Properties
        private var kids: [ChildModel] = []
        private var selectedKid: ChildModel?
        
        private var dashboardPoints: [DashboardChartPoint] = []
        private var dashboardChartHostingController: UIHostingController<AnyView>?
        private let chartSegment = UISegmentedControl(items: ["Weekly", "Monthly"])
        private var weeklyChartPoints: [DashboardChartPoint] = []
        private var monthlyChartPoints: [DashboardChartPoint] = []



    // MARK: - UI Elements
        private let gradient = CAGradientLayer()
        private let header = HomeHeaderView(title: "Home")
        private let overviewCard = OverviewCardGlassView()
        private let pendingLabel = UILabel()
        private let allocatedLabel = UILabel()

        private let contentScroll = UIScrollView()
        private let content = UIView()
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .clear
            setupGradient()
            setupHeader()
            setupContentLayout()
            
          
            header.onChildTapped = { [weak self] in self?.showKidsMenu() }
            header.onProfileTapped = { [weak self] in
                let vc = ParentProfileViewController()
                vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
            // 1. Initial Load
            fetchKidsAndLoad()
            
            // 2. Instant Update Listener
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleDataChange),
                name: NSNotification.Name("DataChanged"),
                object: nil
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleSelectedKidChanged(_:)),
                name: .selectedKidChanged,
                object: nil
            )

        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            gradient.frame = view.bounds
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(true, animated: animated)
            contentScroll.contentInsetAdjustmentBehavior = .never
            
            if let kid = selectedKid {
                fetchStats(for: kid)
                fetchCharts(for: kid)
            }
        }
        
        @objc private func handleDataChange() {
            if let kid = selectedKid {
                fetchStats(for: kid)
                fetchCharts(for: kid)
            }
        }
        
        // MARK: - Data Logic
        
        private func fetchKidsAndLoad() {
            _Concurrency.Task {
                do {
                    let dashboardData = try await FamilyService.shared.fetchDashboard()

                    await MainActor.run {
                        self.kids = dashboardData.children

                        let uiKids = kids.map { Kid(id: $0.id.uuidString, name: $0.name) }
                        header.setKids(uiKids)

                        if let first = kids.first {
                            let uiKid = Kid(id: first.id.uuidString, name: first.name)
                            header.setSelectedKid(uiKid)
                            selectKid(first)
                        }
                    }
                } catch {
                    print("Error fetching kids: \(error)")
                }
            }
        }

        private func selectKid(_ kid: ChildModel) {
            self.selectedKid = kid

            // Convert to UI model
            let uiKid = Kid(id: kid.id.uuidString, name: kid.name)
            header.setSelectedKid(uiKid)

            fetchStats(for: kid)
            fetchCharts(for: kid)
        }

        
        private func fetchStats(for kid: ChildModel) {
            _Concurrency.Task {
                do {
                    async let statsTask = HomeService.shared.fetchHomeStats(for: kid.id)
                    async let todayScheduleTask = TaskService.shared.fetchSchedule(for: kid.id, date: Date())
                    async let activeAllocatedRewardsTask = HomeService.shared.fetchActiveAllocatedRewardCount(for: kid.id)
                    let stats = try await statsTask
                    let todaySchedule = try await todayScheduleTask
                    let activeAllocatedRewards = try await activeAllocatedRewardsTask
                    await MainActor.run {
                        self.updateUI(
                            with: stats,
                            todaySchedule: todaySchedule,
                            activeAllocatedRewards: activeAllocatedRewards
                        )
                    }
                } catch {
                    print("Error stats: \(error)")
                }
            }
        }
        
        private func fetchCharts(for kid: ChildModel) {
                    Task {
                        do {
                            let weeklyDates = self.currentWeekDates()
                            let monthWeekBuckets = self.currentMonthWeekBuckets()
                            let flatMonthDates = Array(Set(monthWeekBuckets.flatMap(\.dates))).sorted()

                            async let weeklyMetricsTask = self.fetchScheduleMetrics(for: kid, dates: weeklyDates)
                            async let monthlyMetricsTask = self.fetchScheduleMetrics(for: kid, dates: flatMonthDates)
                            let weeklyMetrics = try await weeklyMetricsTask
                            let monthlyMetrics = try await monthlyMetricsTask

                            await MainActor.run {
                                let formatter = DateFormatter()
                                formatter.locale = Locale(identifier: "en_US_POSIX")
                                formatter.dateFormat = "E"

                                self.weeklyChartPoints = weeklyDates.map { date in
                                    let metrics = weeklyMetrics[self.normalizedDay(date)] ?? (pending: 0, completed: 0)
                                    return DashboardChartPoint(
                                        label: formatter.string(from: date),
                                        completed: metrics.completed,
                                        assigned: metrics.pending
                                    )
                                }

                                self.monthlyChartPoints = monthWeekBuckets.enumerated().map { index, bucket in
                                    let aggregate = bucket.dates.reduce(into: (pending: 0, completed: 0)) { partial, date in
                                        let metrics = monthlyMetrics[self.normalizedDay(date)] ?? (pending: 0, completed: 0)
                                        partial.pending += metrics.pending
                                        partial.completed += metrics.completed
                                    }

                                    return DashboardChartPoint(
                                        label: "Week \(index + 1)",
                                        completed: aggregate.completed,
                                        assigned: aggregate.pending
                                    )
                                }

                                // 3. Update Chart UI
                                self.updateChart()
                            }

                        } catch {
                            print("Error chart: \(error)")
                        }
                    }
                }
        
        private func updateUI(
            with stats: HomeStats,
            todaySchedule: [ScheduleTaskModel],
            activeAllocatedRewards: Int
        ) {
            let completedToday = todaySchedule.filter { $0.submission_status?.lowercased() == "approved" }.count
            let totalToday = todaySchedule.count
            let progress = totalToday > 0
            ? CGFloat(completedToday) / CGFloat(totalToday)
            : 0.0
            
            overviewCard.configure(
                missionsDone: completedToday,
                missionsTotal: totalToday,
                redeemedText: stats.redeemed_count > 0 ? "\(stats.redeemed_count) Rewards" : "",
                progress: progress,
                animated: true
            )
            pendingLabel.text = "\(stats.pending_count)"
            allocatedLabel.text = "\(activeAllocatedRewards)"
        }

        private func fetchScheduleMetrics(
            for kid: ChildModel,
            dates: [Date]
        ) async throws -> [Date: (pending: Int, completed: Int)] {
            try await withThrowingTaskGroup(of: (Date, [ScheduleTaskModel]).self) { group in
                for date in dates {
                    group.addTask {
                        let tasks = try await TaskService.shared.fetchSchedule(for: kid.id, date: date)
                        return (date, tasks)
                    }
                }

                var result: [Date: (pending: Int, completed: Int)] = [:]
                for try await (date, tasks) in group {
                    let completed = tasks.filter { $0.submission_status?.lowercased() == "approved" }.count
                    let pending = max(tasks.count - completed, 0)
                    result[self.normalizedDay(date)] = (pending: pending, completed: completed)
                }
                return result
            }
        }

        private func currentWeekDates() -> [Date] {
            let calendar = mondayFirstCalendar()
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekInterval.start) }
        }

        private func currentMonthWeekBuckets() -> [(start: Date, dates: [Date])] {
            let calendar = mondayFirstCalendar()
            guard let monthInterval = calendar.dateInterval(of: .month, for: Date()),
                  let firstWeekStart = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start)?.start,
                  let lastWeekStart = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end.addingTimeInterval(-1))?.start else {
                return []
            }

            var buckets: [(start: Date, dates: [Date])] = []
            var weekStart = firstWeekStart

            while weekStart <= lastWeekStart {
                let weekDates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
                    .filter { monthInterval.contains($0) }
                buckets.append((start: weekStart, dates: weekDates))
                guard let nextWeek = calendar.date(byAdding: .day, value: 7, to: weekStart) else { break }
                weekStart = nextWeek
            }

            return buckets
        }

        private func normalizedDay(_ date: Date) -> Date {
            mondayFirstCalendar().startOfDay(for: date)
        }

        private func mondayFirstCalendar() -> Calendar {
            var calendar = Calendar(identifier: .gregorian)
            calendar.firstWeekday = 2
            return calendar
        }
        
        // MARK: - Kids Menu Logic
        private func showKidsMenu() {
            guard !kids.isEmpty else { return }
            let uiKids = kids.map { Kid(id: $0.id.uuidString, name: $0.name) }
            let menu = FloatingKidsMenu(kids: uiKids)
            menu.manager = FloatingMenuManager.shared
            menu.onKidSelected = { selectedUiKid in
                SelectedKidStore.shared.updateKid(selectedUiKid)
            }

            menu.show(in: view, anchor: header.childButton)
        }
        
        // MARK: - Setup UI
        private func setupGradient() {
            gradient.colors = [
                UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
                UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
            ]
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
            view.layer.insertSublayer(gradient, at: 0)
        }
        
        private func setupHeader() {
            view.addSubview(header)
            header.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                header.heightAnchor.constraint(equalToConstant: 98)
            ])
        }
        
        private func setupContentLayout() {
            contentScroll.translatesAutoresizingMaskIntoConstraints = false
            content.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(contentScroll)
            contentScroll.addSubview(content)

            NSLayoutConstraint.activate([
                contentScroll.topAnchor.constraint(equalTo: header.bottomAnchor),
                contentScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                contentScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                contentScroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                content.topAnchor.constraint(equalTo: contentScroll.contentLayoutGuide.topAnchor),
                content.leadingAnchor.constraint(equalTo: contentScroll.contentLayoutGuide.leadingAnchor),
                content.trailingAnchor.constraint(equalTo: contentScroll.contentLayoutGuide.trailingAnchor),
                content.bottomAnchor.constraint(equalTo: contentScroll.contentLayoutGuide.bottomAnchor),
                content.widthAnchor.constraint(equalTo: contentScroll.frameLayoutGuide.widthAnchor)
            ])

            // MARK: Overview
            content.addSubview(overviewCard)
            overviewCard.translatesAutoresizingMaskIntoConstraints = false

            // MARK: Small cards
            let smallStack = UIStackView()
            smallStack.axis = .horizontal
            smallStack.spacing = 14
            smallStack.distribution = .fillEqually
            smallStack.translatesAutoresizingMaskIntoConstraints = false

            let pendingCard = makeSmallStatCard(title: "Pending approval", valueLabel: pendingLabel)
            let allocatedCard = makeSmallStatCard(title: "Allocated Rewards", valueLabel: allocatedLabel)

            smallStack.addArrangedSubview(pendingCard)
            smallStack.addArrangedSubview(allocatedCard)
            content.addSubview(smallStack)

            // MARK: Chart Segment
            chartSegment.selectedSegmentIndex = 0
            chartSegment.translatesAutoresizingMaskIntoConstraints = false
            chartSegment.selectedSegmentTintColor = .white
            chartSegment.backgroundColor = UIColor.white.withAlphaComponent(0.12)

            chartSegment.setTitleTextAttributes(
                [.foregroundColor: UIColor.white.withAlphaComponent(0.7)],
                for: .normal
            )
            chartSegment.setTitleTextAttributes(
                [.foregroundColor: UIColor.black],
                for: .selected
            )

            chartSegment.addTarget(
                self,
                action: #selector(chartSegmentChanged(_:)),
                for: .valueChanged
            )

            content.addSubview(chartSegment)

            // MARK: Chart Holder
            let chartHolder = GlassView(style: .card, cornerRadius: 14)
            chartHolder.translatesAutoresizingMaskIntoConstraints = false
            chartHolder.layer.cornerRadius = 14
            chartHolder.layer.masksToBounds = true
            content.addSubview(chartHolder)

            // MARK: Constraints
            NSLayoutConstraint.activate([
                overviewCard.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
                overviewCard.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
                overviewCard.topAnchor.constraint(equalTo: content.topAnchor, constant: 28),
                overviewCard.heightAnchor.constraint(equalToConstant: 140),

                smallStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
                smallStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
                smallStack.topAnchor.constraint(equalTo: overviewCard.bottomAnchor, constant: 18),
                smallStack.heightAnchor.constraint(equalToConstant: 84),

                chartSegment.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
                chartSegment.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
                chartSegment.topAnchor.constraint(equalTo: smallStack.bottomAnchor, constant: 18),
                chartSegment.heightAnchor.constraint(equalToConstant: 36),

                chartHolder.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
                chartHolder.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
                chartHolder.topAnchor.constraint(equalTo: chartSegment.bottomAnchor, constant: 12),
                chartHolder.heightAnchor.constraint(equalToConstant: 220),

                chartHolder.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -28)
            ])

            setupChartEmbed(in: chartHolder)
            setupTaps(pendingCard: pendingCard, allocatedCard: allocatedCard)
        }


        private func setupChartEmbed(in holder: UIView) {
            if #available(iOS 16.0, *) {
                let hosting = UIHostingController(
                    rootView: AnyView(DashboardChartView(points: []))
                )
                hosting.view.backgroundColor = .clear
                addChild(hosting)
                holder.addSubview(hosting.view)
                hosting.view.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    hosting.view.leadingAnchor.constraint(equalTo: holder.leadingAnchor, constant: 8),
                    hosting.view.trailingAnchor.constraint(equalTo: holder.trailingAnchor, constant: -8),
                    hosting.view.topAnchor.constraint(equalTo: holder.topAnchor, constant: 8),
                    hosting.view.bottomAnchor.constraint(equalTo: holder.bottomAnchor, constant: -8)
                ])

                hosting.didMove(toParent: self)
                dashboardChartHostingController = hosting   // ✅ USE THIS
            }
        }
        
        

        private func setupTaps(pendingCard: UIView, allocatedCard: UIView) {

            func attachTap(to view: UIView, action: Selector) {
                let button = UIButton(type: .custom) // ✅ IMPORTANT
                button.backgroundColor = .clear
                button.addTarget(self, action: action, for: .touchUpInside)
                button.translatesAutoresizingMaskIntoConstraints = false

                view.addSubview(button)
                view.bringSubviewToFront(button) // ✅ CRITICAL

                NSLayoutConstraint.activate([
                    button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    button.topAnchor.constraint(equalTo: view.topAnchor),
                    button.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
            }

            // Pending Approval → Approval Page
            attachTap(to: pendingCard, action: #selector(openApprovalPage))

            // Allocated Rewards → Rewards Tab
            attachTap(to: allocatedCard, action: #selector(openRewardsPage))

            // Overview Card → Progress Tab
            attachTap(to: overviewCard, action: #selector(openProgressPage))
        }

        
        @objc private func openProgressPage() { DispatchQueue.main.async { self.tabBarController?.selectedIndex = 1 } }
        @objc private func openApprovalPage() {
            let vc = ApprovalViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
        @objc private func openRewardsPage() { DispatchQueue.main.async { self.tabBarController?.selectedIndex = 4 } }
        
        private func makeSmallStatCard(title: String, valueLabel: UILabel) -> GlassView {

            let glass = GlassView(style: .card, cornerRadius: 14)
            glass.translatesAutoresizingMaskIntoConstraints = false

            // IMPORTANT
            glass.isUserInteractionEnabled = true

            valueLabel.font = .systemFont(ofSize: 32, weight: .bold)
            valueLabel.textColor = .white
            valueLabel.translatesAutoresizingMaskIntoConstraints = false

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 13)
            titleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            let chevron = UIImageView(
                image: UIImage(systemName: "chevron.right", withConfiguration: config)
            )
            chevron.tintColor = UIColor.white.withAlphaComponent(0.45)
            chevron.contentMode = .center

            let bottomRow = UIStackView(arrangedSubviews: [titleLabel, chevron])
            bottomRow.axis = .horizontal
            bottomRow.spacing = 6
            bottomRow.alignment = .center

            let mainStack = UIStackView(arrangedSubviews: [valueLabel, bottomRow])
            mainStack.axis = .vertical
            mainStack.spacing = 6
            mainStack.translatesAutoresizingMaskIntoConstraints = false

            glass.addSubview(mainStack)

            NSLayoutConstraint.activate([
                mainStack.leadingAnchor.constraint(equalTo: glass.leadingAnchor, constant: 14),
                mainStack.trailingAnchor.constraint(equalTo: glass.trailingAnchor, constant: -14),
                mainStack.topAnchor.constraint(equalTo: glass.topAnchor, constant: 12),
                mainStack.bottomAnchor.constraint(equalTo: glass.bottomAnchor, constant: -12)
            ])

            return glass
        }

        @objc private func handleSelectedKidChanged(_ notification: Notification) {
            guard let uiKid = notification.userInfo?["kid"] as? Kid else { return }
            
            // Convert UI → real model
            if let realKid = kids.first(where: { $0.id.uuidString == uiKid.id }) {
                selectKid(realKid)     // 🔥 UPDATES stats + charts + header
            }
        }
        @objc private func chartSegmentChanged(_ sender: UISegmentedControl) {
            updateChart()
        }
        private func updateChart() {
            let isWeekly = chartSegment.selectedSegmentIndex == 0
            let points = isWeekly ? weeklyChartPoints : monthlyChartPoints

            dashboardChartHostingController?.rootView = AnyView(
                DashboardChartView(points: points)
            )
        }


    }
