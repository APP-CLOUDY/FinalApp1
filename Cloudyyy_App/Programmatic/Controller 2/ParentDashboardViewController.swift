import SwiftUI
import Charts

final class ParentDashboardViewController: UIViewController {
    
    // MARK: - UI
    private let gradient = CAGradientLayer()
    private let header = HomeHeaderView(title: "Home")
    
    // Overview card
    private let overviewCard = OverviewCardView()
    private let missionsLabel = UILabel()
    private let redeemedLabel = UILabel()
    private let circleArc = HomeProgressArcView()
    
    // Small stats (pending / allocated)
    private let pendingLabel = UILabel()
    private let allocatedLabel = UILabel()
    
    // Segmented control and chart container
    private let segment = UISegmentedControl(items: ["Weekly", "Monthly"])
    private var chartContainer: UIView?
    
    // Layout container
    private let contentScroll = UIScrollView()
    private let content = UIView()
    
    // keep current chart data for updates
    private var currentWeekly: [HomeChartItem] = []
    private var currentMonthly: [HomeChartItem] = []
    
    // store the hosting controller so we can update its rootView later
    @available(iOS 16.0, *)
    private var chartHostingController: UIHostingController<DashboardChartView>?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
         
        view.backgroundColor = .clear
        setupGradient()
        setupHeader()
        setupContentLayout()
        
        // --- HEADER ACTIONS ---
        
        // 1. Dropdown Logic
        header.onChildTapped = { [weak self] in self?.showKidsMenu() }
        
        // 2. 🔥 Profile Navigation Logic (Added)
        header.onProfileTapped = { [weak self] in
            let profileVC = ParentProfileViewController()
            // profileVC.hidesBottomBarWhenPushed = true // This is already set inside ParentProfileViewController
            self?.navigationController?.pushViewController(profileVC, animated: true)
        }
        
        // 3. Notification Logic (Optional placeholder)
        header.onBellTapped = {
            print("Notifications tapped")
        }
        
        // --- DATA LOADING ---
        
        // listen for kid changes
        NotificationCenter.default.addObserver(self, selector: #selector(onKidChanged(_:)), name: ChildManager.kidChangedNotification, object: nil)
        
        // default selection
        if let kid = ChildManager.shared.selectedKid {
            header.childButton.setTitle("\(kid.name) ▾", for: .normal)
            loadHomeData(for: kid)
        } else if let first = ChildManager.shared.kids.first {
            ChildManager.shared.selectedKid = first
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentScroll.contentInsetAdjustmentBehavior = .never
        navigationController?.setNavigationBarHidden(true, animated: animated) // Ensure nav bar is hidden on dashboard
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentScroll.setContentOffset(.zero, animated: false)
        view.layoutIfNeeded()
    }

    // MARK: - Gradient
    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 8/255, green: 12/255, blue: 48/255, alpha: 1).cgColor,
            UIColor(red: 10/255, green: 18/255, blue: 60/255, alpha: 1).cgColor,
            UIColor(red: 17/255, green: 41/255, blue: 87/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    // MARK: - Header
    private func setupHeader() {
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
    
    // MARK: - Content layout
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
        
        // add overview card & chart section
        overviewCard.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(overviewCard)
        
        // pending + allocated
        let smallStack = UIStackView()
        smallStack.axis = .horizontal
        smallStack.spacing = 14
        smallStack.distribution = .fillEqually
        smallStack.translatesAutoresizingMaskIntoConstraints = false
        
        // small card views
        let pendingCard = makeSmallStatCard(title: "Pending approval", valueLabel: pendingLabel)
        let allocatedCard = makeSmallStatCard(title: "Allocated Rewards", valueLabel: allocatedLabel)
        smallStack.addArrangedSubview(pendingCard)
        smallStack.addArrangedSubview(allocatedCard)
        content.addSubview(smallStack)
        
        // segmented control + chart container placeholder
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segment.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(segment)
        
        
        segment.selectedSegmentTintColor = .white
        segment.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        segment.setTitleTextAttributes([
            .foregroundColor: UIColor.white.withAlphaComponent(0.7)
        ], for: .normal)

        segment.setTitleTextAttributes([
            .foregroundColor: UIColor.black
        ], for: .selected)

        segment.layer.cornerRadius = 20
        segment.layer.masksToBounds = true

        
        // chart holder (glass)
        let chartHolder = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        chartHolder.layer.cornerRadius = 14
        chartHolder.layer.masksToBounds = true
        chartHolder.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(chartHolder)
        
        // layout constraints
        NSLayoutConstraint.activate([
            overviewCard.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            overviewCard.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
            overviewCard.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
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
        
        // embed SwiftUI chart if available
        if #available(iOS 16.0, *) {
            let placeholderPoints: [DashboardChartPoint] = []
            let hosting = UIHostingController(rootView: DashboardChartView(points: placeholderPoints))
            hosting.view.backgroundColor = .clear

            addChild(hosting)
            chartHolder.contentView.addSubview(hosting.view)
            hosting.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hosting.view.leadingAnchor.constraint(equalTo: chartHolder.contentView.leadingAnchor, constant: 8),
                hosting.view.trailingAnchor.constraint(equalTo: chartHolder.contentView.trailingAnchor, constant: -8),
                hosting.view.topAnchor.constraint(equalTo: chartHolder.contentView.topAnchor, constant: 8),
                hosting.view.bottomAnchor.constraint(equalTo: chartHolder.contentView.bottomAnchor, constant: -8)
            ])
            hosting.didMove(toParent: self)
            chartContainer = hosting.view
            chartHostingController = hosting

        } else {
            let lbl = UILabel()
            lbl.text = "Chart (iOS 16+ required)"
            lbl.textColor = .white
            lbl.translatesAutoresizingMaskIntoConstraints = false
            chartHolder.contentView.addSubview(lbl)
            NSLayoutConstraint.activate([
                lbl.centerXAnchor.constraint(equalTo: chartHolder.contentView.centerXAnchor),
                lbl.centerYAnchor.constraint(equalTo: chartHolder.contentView.centerYAnchor)
            ])
        }
        
        // --- REWARD TAP ---
        let rewardButton = UIButton(type: .system)
        rewardButton.backgroundColor = .clear
        rewardButton.addTarget(self, action: #selector(openRewardsPage), for: .touchUpInside)
        rewardButton.translatesAutoresizingMaskIntoConstraints = false
        allocatedCard.contentView.addSubview(rewardButton)

        NSLayoutConstraint.activate([
            rewardButton.leadingAnchor.constraint(equalTo: allocatedCard.contentView.leadingAnchor),
            rewardButton.trailingAnchor.constraint(equalTo: allocatedCard.contentView.trailingAnchor),
            rewardButton.topAnchor.constraint(equalTo: allocatedCard.contentView.topAnchor),
            rewardButton.bottomAnchor.constraint(equalTo: allocatedCard.contentView.bottomAnchor)
        ])


        // --- OVERVIEW CARD TAP ---
        let overviewButton = UIButton(type: .system)
        overviewButton.backgroundColor = .clear
        overviewButton.addTarget(self, action: #selector(openProgressPage), for: .touchUpInside)
        overviewButton.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(overviewButton)

        NSLayoutConstraint.activate([
            overviewButton.leadingAnchor.constraint(equalTo: overviewCard.leadingAnchor),
            overviewButton.trailingAnchor.constraint(equalTo: overviewCard.trailingAnchor),
            overviewButton.topAnchor.constraint(equalTo: overviewCard.topAnchor),
            overviewButton.bottomAnchor.constraint(equalTo: overviewCard.bottomAnchor)
        ])

        // --- PENDING APPROVAL TAP ---
        let pendingButton = UIButton(type: .system)
        pendingButton.backgroundColor = .clear
        pendingButton.addTarget(self, action: #selector(openApprovalPage), for: .touchUpInside)
        pendingButton.translatesAutoresizingMaskIntoConstraints = false
        pendingCard.contentView.addSubview(pendingButton)

        NSLayoutConstraint.activate([
            pendingButton.leadingAnchor.constraint(equalTo: pendingCard.contentView.leadingAnchor),
            pendingButton.trailingAnchor.constraint(equalTo: pendingCard.contentView.trailingAnchor),
            pendingButton.topAnchor.constraint(equalTo: pendingCard.contentView.topAnchor),
            pendingButton.bottomAnchor.constraint(equalTo: pendingCard.contentView.bottomAnchor)
        ])
    }
    
    @objc private func openProgressPage() {
        DispatchQueue.main.async {
            self.tabBarController?.selectedIndex = 1
        }
    }
    
    @objc private func openApprovalPage() {
        let vc = ApprovalViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openRewardsPage() {
        DispatchQueue.main.async {
            self.tabBarController?.selectedIndex = 4
        }
    }

    private func makeSmallStatCard(title: String, valueLabel: UILabel) -> UIVisualEffectView {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.layer.cornerRadius = 14
        blur.layer.masksToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false

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
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false

        let bottomRow = UIStackView(arrangedSubviews: [titleLabel, chevron])
        bottomRow.axis = .horizontal
        bottomRow.spacing = 4
        bottomRow.alignment = .center
        bottomRow.distribution = .fill
        bottomRow.translatesAutoresizingMaskIntoConstraints = false

        let mainStack = UIStackView(arrangedSubviews: [valueLabel, bottomRow])
        mainStack.axis = .vertical
        mainStack.spacing = 6
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        blur.contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor, constant: 14),
            mainStack.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -14),
            mainStack.topAnchor.constraint(equalTo: blur.contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor, constant: -12),

            chevron.widthAnchor.constraint(equalToConstant: 13),
            chevron.heightAnchor.constraint(equalToConstant: 13)
        ])

        return blur
    }

    // MARK: - Show Floating Dropdown
    private func showKidsMenu() {
        let kids = ChildManager.shared.kids
        guard !kids.isEmpty else { return }
        let menu = FloatingKidsMenu(kids: kids)
        menu.onKidSelected = { kid in
            ChildManager.shared.selectedKid = kid
        }
        menu.show(in: view, anchor: header.childButton)
    }
    
    // MARK: - Notification Listener
    @objc private func onKidChanged(_ n: Notification) {
        guard let kid = n.object as? Kid else { return }
        header.childButton.setTitle("\(kid.name) ▾", for: .normal)
        loadHomeData(for: kid)
    }
    
    // MARK: - Load home mock data
    private func loadHomeData(for kid: Kid) {
        let data = ChildManager.shared.homeData(for: kid.id)

        let done = data.overview.missionsDone
        let total = data.overview.missionsTotal
        let redeemed = data.overview.redeemedText
        
        let progress: CGFloat = total == 0 ? 0 : CGFloat(done) / CGFloat(total)

        overviewCard.configure(
            missionsDone: done,
            missionsTotal: total,
            redeemedText: redeemed,
            progress: progress,
            animated: true
        )

        pendingLabel.text = "\(data.pending.pendingCount)"
        allocatedLabel.text = "\(data.allocated.allocatedCount)"

        currentWeekly = data.weeklyChart
        currentMonthly = ChildManager.shared.monthlyChartAggregated(for: kid.id)

        updateChartForSegment()
    }

    // MARK: - Segment changed
    @objc private func segmentChanged(_ s: UISegmentedControl) {
        updateChartForSegment()
    }
    
    private func updateChartForSegment() {
        guard #available(iOS 16.0, *) else { return }

        let isWeekly = (segment.selectedSegmentIndex == 0)
        let source = isWeekly ? currentWeekly : currentMonthly

        let points = source.map { item in
            DashboardChartPoint(label: item.day, rewards: item.rewards, tasks: item.tasks)
        }

        if let hosting = chartHostingController {
            hosting.rootView = DashboardChartView(points: points)
        }
    }
}
