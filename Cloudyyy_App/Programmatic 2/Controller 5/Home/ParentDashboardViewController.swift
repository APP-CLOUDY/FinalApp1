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
                    let stats = try await HomeService.shared.fetchHomeStats(for: kid.id)
                    await MainActor.run { self.updateUI(with: stats) }
                } catch {
                    print("Error stats: \(error)")
                }
            }
        }
        
        private func fetchCharts(for kid: ChildModel) {
                    Task {
                        do {
                            // Fetch Data
                            let wData = try await HomeService.shared.fetchChartData(for: kid.id, range: "weekly")
                            let mData = try await HomeService.shared.fetchChartData(for: kid.id, range: "monthly")

                            await MainActor.run {
                                
                                // 1. WEEKLY CHART (Standard Logic)
                                // Ensures Mon-Sun order and fills empty days
                                let allDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                                let dataDict = Dictionary(uniqueKeysWithValues: wData.map { ($0.day, $0) })
                                
                                self.weeklyChartPoints = allDays.map { dayStr in
                                    if let foundData = dataDict[dayStr] {
                                        return DashboardChartPoint(
                                            label: dayStr,
                                            completed: foundData.completed_count,
                                            assigned: foundData.pending_count
                                        )
                                    } else {
                                        return DashboardChartPoint(label: dayStr, completed: 0, assigned: 0)
                                    }
                                }
                                
                                // 2. MONTHLY CHART (✅ FIXED: Use Backend Labels Directly)
                                // The backend sends "Week 1", "Week 2", etc. Use them directly.
                                
                                // A. Create a dictionary for quick lookup
                                let monthlyDict = Dictionary(uniqueKeysWithValues: mData.map { ($0.day, $0) })
                                
                                // B. Force "Week 1" to "Week 4" (or 5) order
                                // This ensures the chart always shows 4 weeks, even if Week 2 is missing.
                                var finalMonthlyPoints: [DashboardChartPoint] = []
                                
                                // Dynamic way (shows 4 or 5 depending on data)
                                let maxWeeks = monthlyDict.keys.compactMap { Int($0.replacingOccurrences(of: "Week ", with: "")) }.max() ?? 4
                                for i in 1...maxWeeks {
                                    let label = "Week \(i)"
                                    
                                    if let foundData = monthlyDict[label] {
                                        finalMonthlyPoints.append(DashboardChartPoint(
                                            label: label,
                                            completed: foundData.completed_count,
                                            assigned: foundData.pending_count
                                        ))
                                    } else {
                                        // Create empty bar if backend didn't send this week
                                        finalMonthlyPoints.append(DashboardChartPoint(
                                            label: label,
                                            completed: 0,
                                            assigned: 0
                                        ))
                                    }
                                }
                                
                                self.monthlyChartPoints = finalMonthlyPoints

                                // 3. Update Chart UI
                                self.updateChart()
                                
                                // 4. Update Overview Card (using Weekly data for today)
                                let dayFormatter = DateFormatter()
                                dayFormatter.dateFormat = "E"
                                let todayString = dayFormatter.string(from: Date())
                                
                                if let todayData = self.weeklyChartPoints.first(where: { $0.label == todayString }) {
                                    let correctDone = todayData.completed
                                    let correctPending = todayData.assigned
                                    let correctTotal = correctDone + correctPending
                                    let progress = correctTotal > 0 ? CGFloat(correctDone) / CGFloat(correctTotal) : 0.0
                                    
                                    self.overviewCard.configure(
                                        missionsDone: correctDone,
                                        missionsTotal: correctTotal,
                                        redeemedText: "",
                                        progress: progress,
                                        animated: true
                                    )
                                }
                            }

                        } catch {
                            print("Error chart: \(error)")
                        }
                    }
                }
        
        private func updateUI(with stats: HomeStats) {
            let progress = stats.missions_total > 0
            ? CGFloat(stats.missions_done) / CGFloat(stats.missions_total)
            : 0.0
            
            overviewCard.configure(
                missionsDone: stats.missions_done,
                missionsTotal: stats.missions_total,
                redeemedText: stats.redeemed_count > 0 ? "\(stats.redeemed_count) Rewards" : "",
                progress: progress,
                animated: true
            )
            pendingLabel.text = "\(stats.pending_count)"
            allocatedLabel.text = "\(stats.allocated_count)"
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
