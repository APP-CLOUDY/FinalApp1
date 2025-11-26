//
//  ParentDashboardViewController.swift
//  Cloudyyy_App
//

import UIKit
import SwiftUI
import Charts

final class ParentDashboardViewController: UIViewController {

    // MARK: - UI
    private let gradient = CAGradientLayer()
    private let header = HomeHeaderView(title: "Home")

    private let overviewCard = OverviewCardView()
    private let pendingLabel = UILabel()
    private let allocatedLabel = UILabel()

    private let segment = UISegmentedControl(items: ["Weekly", "Monthly"])
    private var chartContainer: UIView?

    private let contentScroll = UIScrollView()
    private let content = UIView()

    private var currentWeekly: [HomeChartItem] = []
    private var currentMonthly: [HomeChartItem] = []

    private var overviewHeight: NSLayoutConstraint?
    private var smallStackHeight: NSLayoutConstraint?
    private var segmentHeight: NSLayoutConstraint?
    private var chartHeight: NSLayoutConstraint?

    // First time empty screen
    private let firstTimeContainer = UIView()

    @available(iOS 16.0, *)
    private var chartHostingController: UIHostingController<DashboardChartView>?


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        setupGradient()
        setupHeader()
        setupContentLayout()

        header.onChildTapped = { [weak self] in
            self?.showKidsMenu()
        }

        // Listen for kid switching
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onKidChanged(_:)),
            name: ChildManager.kidChangedNotification,
            object: nil
        )

        // Listen for task/reward updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged(_:)),
            name: ChildManager.taskAddedNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged(_:)),
            name: ChildManager.taskUpdatedNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged(_:)),
            name: ChildManager.taskRemovedNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged(_:)),
            name: ChildManager.rewardAddedNotification,
            object: nil
        )

        // Initial Load
        if let kid = ChildManager.shared.selectedKid {
            header.childButton.setTitle("\(kid.name) ▾", for: .normal)
            loadHomeData(for: kid)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }


    // MARK: - Gradient
    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
                        UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
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


    // MARK: - Content Layout
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

        addDashboardUI()
        setupFirstTimeScreen()
        
        
        
        
    }


    // MARK: - Add Dashboard UI
    private func addDashboardUI() {

        overviewCard.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(overviewCard)

        overviewHeight = overviewCard.heightAnchor.constraint(equalToConstant: 140)

        // ---- Small stat cards ----
        let smallStack = UIStackView()
        smallStack.axis = .horizontal
        smallStack.distribution = .fillEqually
        smallStack.spacing = 14
        smallStack.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(smallStack)

        let pendingCard = makeSmallStatCard(title: "Pending approval", valueLabel: pendingLabel)
        let allocatedCard = makeSmallStatCard(title: "Allocated Rewards", valueLabel: allocatedLabel)

        smallStack.addArrangedSubview(pendingCard)
        smallStack.addArrangedSubview(allocatedCard)

        smallStackHeight = smallStack.heightAnchor.constraint(equalToConstant: 84)

        // ---- Segment ----
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        content.addSubview(segment)

        segmentHeight = segment.heightAnchor.constraint(equalToConstant: 40)

        // ---- Chart Container ----
        let chartHolder = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        chartHolder.layer.cornerRadius = 14
        chartHolder.clipsToBounds = true
        chartHolder.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(chartHolder)
        self.chartContainer = chartHolder

        chartHeight = chartHolder.heightAnchor.constraint(equalToConstant: 220)

        // Layout
        NSLayoutConstraint.activate([
            overviewCard.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            overviewCard.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
            overviewCard.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
            overviewHeight!,

            smallStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            smallStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
            smallStack.topAnchor.constraint(equalTo: overviewCard.bottomAnchor, constant: 18),
            smallStackHeight!,

            segment.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            segment.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
            segment.topAnchor.constraint(equalTo: smallStack.bottomAnchor, constant: 18),
            segmentHeight!,

            chartHolder.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            chartHolder.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
            chartHolder.topAnchor.constraint(equalTo: segment.bottomAnchor, constant: 12),
            chartHeight!,
            chartHolder.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -28)
        ])

        // Add Chart Hosting
        if #available(iOS 16.0, *) {
            let hosting = UIHostingController(rootView: DashboardChartView(points: []))
            chartHostingController = hosting
            hosting.view.backgroundColor = .clear

            addChild(hosting)
            chartHolder.contentView.addSubview(hosting.view)
            hosting.view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                hosting.view.leadingAnchor.constraint(equalTo: chartHolder.contentView.leadingAnchor),
                hosting.view.trailingAnchor.constraint(equalTo: chartHolder.contentView.trailingAnchor),
                hosting.view.topAnchor.constraint(equalTo: chartHolder.contentView.topAnchor),
                hosting.view.bottomAnchor.constraint(equalTo: chartHolder.contentView.bottomAnchor)
            ])

            hosting.didMove(toParent: self)
        }
        
        
        // ---------------------------------------------------------
        // ADD TAP OVERLAY BUTTONS (Overview / Pending / Allocated)
        // ---------------------------------------------------------

        // 1. OVERVIEW CARD TAP → Progress Page
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

        // 2. PENDING CARD TAP → Approval Page
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

        // 3. ALLOCATED REWARDS TAP → Rewards Page
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

    }


    // MARK: - First Time User Screen
    private func setupFirstTimeScreen() {

        firstTimeContainer.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(firstTimeContainer)

        // UI
        let img = UIImageView(image: UIImage(systemName: "checkmark.circle"))
        img.tintColor = .white
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "No tasks Assigned yet!"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let addButton = UIButton(type: .system)
        addButton.setTitle("Add New Task", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        addButton.backgroundColor = .systemBlue
        addButton.tintColor = .white
        addButton.layer.cornerRadius = 12
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(openNewTask), for: .touchUpInside)

        firstTimeContainer.addSubview(img)
        firstTimeContainer.addSubview(label)
        firstTimeContainer.addSubview(addButton)

        NSLayoutConstraint.activate([
            firstTimeContainer.topAnchor.constraint(equalTo: content.topAnchor, constant: 50),
            firstTimeContainer.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            firstTimeContainer.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),

            img.topAnchor.constraint(equalTo: firstTimeContainer.topAnchor, constant: 20),
            img.centerXAnchor.constraint(equalTo: firstTimeContainer.centerXAnchor),
            img.heightAnchor.constraint(equalToConstant: 260),
            img.widthAnchor.constraint(equalToConstant: 260),

            label.topAnchor.constraint(equalTo: img.bottomAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: firstTimeContainer.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: firstTimeContainer.trailingAnchor),

            addButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30),
            addButton.leadingAnchor.constraint(equalTo: firstTimeContainer.leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: firstTimeContainer.trailingAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 54),
            addButton.bottomAnchor.constraint(equalTo: firstTimeContainer.bottomAnchor)
        ])

        firstTimeContainer.isHidden = true
    }


    // MARK: - Load Data
    private func loadHomeData(for kid: Kid) {

        let runtimeTasks = ChildManager.shared.tasks(for: kid.id)
        let runtimeRewards = ChildManager.shared.allRewards(for: kid.id)

        let isEmpty = runtimeTasks.isEmpty && runtimeRewards.isEmpty

        // ---------- FIRST TIME MODE ----------
        if isEmpty {
            firstTimeContainer.isHidden = false
            firstTimeContainer.alpha = 1
            firstTimeContainer.isUserInteractionEnabled = true
            content.bringSubviewToFront(firstTimeContainer)

            // Hide dashboard UI
            for sub in content.subviews where sub !== firstTimeContainer {
                sub.isHidden = true
            }

            // Reset values
            pendingLabel.text = "0"
            allocatedLabel.text = "0"
            currentWeekly = []
            currentMonthly = []

            updateChartForSegment()
            return
        }

        // ---------- NORMAL DASHBOARD MODE ----------
        firstTimeContainer.isHidden = true
        firstTimeContainer.alpha = 0
        firstTimeContainer.isUserInteractionEnabled = false

        for sub in content.subviews {
            sub.isHidden = (sub == firstTimeContainer)
        }

        // Fetch real/mocked home data
        let data = ChildManager.shared.homeData(for: kid.id)

        // Overview
        let done = data.overview.missionsDone
        let total = data.overview.missionsTotal
        let redeemed = data.overview.redeemedText
        let progress = total == 0 ? 0 : CGFloat(done) / CGFloat(total)

        overviewCard.configure(
            missionsDone: done,
            missionsTotal: total,
            redeemedText: redeemed,
            progress: progress,
            animated: true
        )

        // Pending & allocated
        pendingLabel.text = "\(data.pending.pendingCount)"
        allocatedLabel.text = "\(data.allocated.allocatedCount)"

        // Chart data
        currentWeekly = data.weeklyChart
        currentMonthly = ChildManager.shared.monthlyChartAggregated(for: kid.id)

        updateChartForSegment()
    }


    // MARK: - Actions

    @objc private func openNewTask() {
        let vc = NewTaskViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    @objc private func onKidChanged(_ n: Notification) {
        if let kid = n.object as? Kid {
            header.childButton.setTitle("\(kid.name) ▾", for: .normal)
            loadHomeData(for: kid)
        }
    }

    @objc private func onDataChanged(_ n: Notification) {
        guard let kid = ChildManager.shared.selectedKid else { return }
        loadHomeData(for: kid)
    }


    // MARK: - Kids Menu
    private func showKidsMenu() {
        let kids = ChildManager.shared.kids
        guard !kids.isEmpty else { return }

        let menu = FloatingKidsMenu(kids: kids)
        menu.onKidSelected = { kid in
            ChildManager.shared.selectedKid = kid
        }
        menu.show(in: view, anchor: header.childButton)
    }


    // MARK: - Chart Segment
    @objc private func segmentChanged(_ s: UISegmentedControl) {
        updateChartForSegment()
    }

    private func updateChartForSegment() {
        guard #available(iOS 16.0, *) else { return }

        let items = (segment.selectedSegmentIndex == 0) ? currentWeekly : currentMonthly

        let points = items.map {
            DashboardChartPoint(label: $0.day, rewards: $0.rewards, tasks: $0.tasks)
        }

        chartHostingController?.rootView = DashboardChartView(points: points)
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


    // MARK: - Small stat card
    private func makeSmallStatCard(title: String, valueLabel: UILabel) -> UIVisualEffectView {

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.layer.cornerRadius = 14
        blur.clipsToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.font = .systemFont(ofSize: 32, weight: .bold)
        valueLabel.textColor = .white

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .white.withAlphaComponent(0.7)
        chevron.contentMode = .scaleAspectFit

        let row = UIStackView(arrangedSubviews: [titleLabel, chevron])
        row.axis = .horizontal
        row.spacing = 4

        let stack = UIStackView(arrangedSubviews: [valueLabel, row])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false

        blur.contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: blur.contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor, constant: -12)
        ])

        return blur
    }
}

