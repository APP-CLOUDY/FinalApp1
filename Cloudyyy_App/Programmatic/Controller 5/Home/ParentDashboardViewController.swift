import UIKit
import SwiftUI
import Charts // Requires iOS 16+

// MARK: - Local Chart Model
// ✅ RENAMED to prevent conflict with other files
struct HomeChartDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let completed: Int
    let pending: Int
}
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
        
        // ✅ FIXED: Unique model name used here
        private var weeklyPoints: [HomeChartDataPoint] = []
        private var monthlyPoints: [HomeChartDataPoint] = []
        

    // MARK: - UI Elements
        private let gradient = CAGradientLayer()
        private let header = HomeHeaderView(title: "Home")
        private let overviewCard = OverviewCardGlassView()
        private let pendingLabel = UILabel()
        private let allocatedLabel = UILabel()
        private let segment = UISegmentedControl(items: ["Weekly", "Monthly"])
        private let contentScroll = UIScrollView()
        private let content = UIView()
        private var chartHostingController: UIHostingController<AnyView>?
        
        
        
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
            _Concurrency.Task {
                do {
                    let wData = try await HomeService.shared.fetchChartData(for: kid.id, range: "weekly")
                    let mData = try await HomeService.shared.fetchChartData(for: kid.id, range: "monthly")
                    
                    await MainActor.run {
                        // ✅ Map to our LOCAL unique struct
                        self.weeklyPoints = wData.map {
                            HomeChartDataPoint(day: $0.day, completed: $0.completed_count, pending: $0.pending_count)
                        }
                        self.monthlyPoints = mData.map {
                            HomeChartDataPoint(day: $0.day, completed: $0.completed_count, pending: $0.pending_count)
                        }
                        self.refreshChartDisplay()
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
        
        @objc private func segmentChanged(_ s: UISegmentedControl) {
            refreshChartDisplay()
        }
        
        private func refreshChartDisplay() {
            let isWeekly = segment.selectedSegmentIndex == 0
            let dataToShow = isWeekly ? weeklyPoints : monthlyPoints
            
            if #available(iOS 16.0, *), let host = chartHostingController {
                // ✅ Use the unique local chart view
                host.rootView = AnyView(HomeChartView(points: dataToShow))
            }
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
            
            overviewCard.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview(overviewCard)
            
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
            
            segment.selectedSegmentIndex = 0
            segment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
            segment.translatesAutoresizingMaskIntoConstraints = false
            segment.selectedSegmentTintColor = .white
            segment.backgroundColor = UIColor.white.withAlphaComponent(0.10)
            segment.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.7)], for: .normal)
            segment.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
            segment.layer.cornerRadius = 20
            segment.layer.masksToBounds = true
            content.addSubview(segment)
            
            let chartHolder = GlassView(style: .card, cornerRadius: 14)
            chartHolder.layer.cornerRadius = 14
            chartHolder.layer.masksToBounds = true
            chartHolder.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview(chartHolder)
            
            NSLayoutConstraint.activate([
                overviewCard.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
                overviewCard.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
                overviewCard.topAnchor.constraint(equalTo: content.topAnchor, constant: 28),
                overviewCard.heightAnchor.constraint(equalToConstant: 140),
                
                smallStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
                smallStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
                smallStack.topAnchor.constraint(equalTo: overviewCard.bottomAnchor, constant: 18),
                smallStack.heightAnchor.constraint(equalToConstant: 84),
                
                segment.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
                segment.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
                segment.topAnchor.constraint(equalTo: smallStack.bottomAnchor, constant: 18),
                segment.heightAnchor.constraint(equalToConstant: 40),
                
                chartHolder.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
                chartHolder.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
                chartHolder.topAnchor.constraint(equalTo: segment.bottomAnchor, constant: 12),
                chartHolder.heightAnchor.constraint(equalToConstant: 220),
                
                chartHolder.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -28)
            ])
            
            setupChartEmbed(in: chartHolder)
            setupTaps(pendingCard: pendingCard, allocatedCard: allocatedCard)
        }
        
        private func setupChartEmbed(in holder: UIView) {
            if #available(iOS 16.0, *) {
                let hosting = UIHostingController(rootView: AnyView(HomeChartView(points: [])))
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
                chartHostingController = hosting
            }
        }
        
        private func setupTaps(pendingCard: UIView, allocatedCard: UIView) {
            let rewardButton = UIButton(type: .system)
            rewardButton.addTarget(self, action: #selector(openRewardsPage), for: .touchUpInside)
            rewardButton.translatesAutoresizingMaskIntoConstraints = false
            allocatedCard.addSubview(rewardButton)
            NSLayoutConstraint.activate([
                rewardButton.leadingAnchor.constraint(equalTo: allocatedCard.leadingAnchor),
                rewardButton.trailingAnchor.constraint(equalTo: allocatedCard.trailingAnchor),
                rewardButton.topAnchor.constraint(equalTo: allocatedCard.topAnchor),
                rewardButton.bottomAnchor.constraint(equalTo: allocatedCard.bottomAnchor)
            ])
            
            let overviewButton = UIButton(type: .system)
            overviewButton.addTarget(self, action: #selector(openProgressPage), for: .touchUpInside)
            overviewButton.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview(overviewButton)
            NSLayoutConstraint.activate([
                overviewButton.leadingAnchor.constraint(equalTo: overviewCard.leadingAnchor),
                overviewButton.trailingAnchor.constraint(equalTo: overviewCard.trailingAnchor),
                overviewButton.topAnchor.constraint(equalTo: overviewCard.topAnchor),
                overviewButton.bottomAnchor.constraint(equalTo: overviewCard.bottomAnchor)
            ])
            
            let pendingButton = UIButton(type: .system)
            pendingButton.addTarget(self, action: #selector(openApprovalPage), for: .touchUpInside)
            pendingButton.translatesAutoresizingMaskIntoConstraints = false
            pendingCard.addSubview(pendingButton)
            NSLayoutConstraint.activate([
                pendingButton.leadingAnchor.constraint(equalTo: pendingCard.leadingAnchor),
                pendingButton.trailingAnchor.constraint(equalTo: pendingCard.trailingAnchor),
                pendingButton.topAnchor.constraint(equalTo: pendingCard.topAnchor),
                pendingButton.bottomAnchor.constraint(equalTo: pendingCard.bottomAnchor)
            ])
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

            valueLabel.font = .systemFont(ofSize: 32, weight: .bold)
            valueLabel.textColor = .white
            valueLabel.translatesAutoresizingMaskIntoConstraints = false

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 13)
            titleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
            chevron.tintColor = .white.withAlphaComponent(0.45)
            chevron.translatesAutoresizingMaskIntoConstraints = false

            let bottomRow = UIStackView(arrangedSubviews: [titleLabel, chevron])
            bottomRow.axis = .horizontal
            bottomRow.spacing = 4
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
                mainStack.bottomAnchor.constraint(equalTo: glass.bottomAnchor, constant: -12),
                chevron.widthAnchor.constraint(equalToConstant: 13)
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

    }
    
    // MARK: - FIXED CHART VIEW (With Manual Legend)
    @available(iOS 16.0, *)
    struct HomeChartView: View {
        var points: [HomeChartDataPoint]
        
        // Custom Colors
        private let assignedColor = Color(hex: "0080FF")
        private let completedColor = Color(hex: "8A4FFF")
        
        var body: some View {
            VStack(spacing: 12) {
                
                // 1. CUSTOM LEGEND
                HStack(spacing: 16) {
                    Spacer()
                    
                    // Assigned Item
                    HStack(spacing: 6) {
                        Circle().fill(assignedColor).frame(width: 8, height: 8)
                        Text("Assigned")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                    
                    // Completed Item
                    HStack(spacing: 6) {
                        Circle().fill(completedColor).frame(width: 8, height: 8)
                        Text("Completed")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 10)
                
                // 2. THE CHART
                Chart(points) { point in
                    BarMark(
                        x: .value("Day", point.day),
                        y: .value("Completed", point.completed)
                    )
                    .foregroundStyle(completedColor)
                    .cornerRadius(4)
                    
                    BarMark(
                        x: .value("Day", point.day),
                        y: .value("Assigned", point.pending)
                    )
                    .foregroundStyle(assignedColor)
                    .cornerRadius(4)
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic) { _ in
                        AxisGridLine().foregroundStyle(Color.white.opacity(0.15))
                        AxisValueLabel().foregroundStyle(Color.white)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine().foregroundStyle(Color.white.opacity(0.15))
                        AxisValueLabel().foregroundStyle(Color.white)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            }
            .environment(\.colorScheme, .dark)
        }
        
        
        
        
    }
