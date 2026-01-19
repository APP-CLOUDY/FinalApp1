import UIKit

// MARK: - Local Model for List Items
struct RewardDetailItem {
    let id: String
    let title: String
    let subtitle: String
    let points: Int
    let imageName: String?
    let isActive: Bool
    let claimLimit: String?
    let subType: String?
}

final class QuickRewardsViewController: UIViewController {

    // MARK: - Properties
    private var kids: [ChildModel] = []
    private var selectedKid: ChildModel?
    
    // Data
    private var activeItems: [RewardDetailItem] = []
    private var historyItems: [RewardDetailItem] = []
    private var currentBalance: Int = 0

    // MARK: - UI Components
    
    // 1. Header (Pass empty string to hide default title)
    private let header = HomeHeaderView(title: "Quick Rewards")
    private let gradient = CAGradientLayer()
 
    // Scroll Layout
    private let scrollView = UIScrollView()
    private let content = UIView()

    // Sections
    private let activeLabel = SectionLabel(text: "Active")
    private let activeScroll = UIScrollView()
    private let activeStack = UIStackView()

    private let historyLabel = SectionLabel(text: "Redemption History")
    private let historyStack = UIStackView()
    private let bottomSpacer = UIView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupGradient()
        setupHeader()

        header.childButton.isHidden = false    // allow header to show the kid dropdown

        setupScroll()
        setupContentLayout()

        // Actions
        header.showPlusButton(true)
        header.onPlusTapped = { [weak self] in self?.openNewReward() }
        
        fetchKidsAndLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataChange), name: NSNotification.Name("DataChanged"), object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSelectedKidChanged(_:)),
            name: .selectedKidChanged,
            object: nil
        )
        // header appearance & callbacks — match Approval / DreamIt behavior
        header.showNotificationButton(false)
        header.showProfileButton(false)
        header.showPlusButton(true)     // if you want + visible on this screen
        header.showBackButton(true)     // show chevron-only back button

        header.onChildTapped = { [weak self] in self?.showKidsMenu() }
        header.onBackTapped  = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        header.onPlusTapped  = { [weak self] in self?.openNewReward() }


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleDataChange() {
        if let kid = selectedKid {
            reloadForKid(kid)
        }
    }
    
    @objc private func didTapChildMenu() {
        showKidsMenu()
    }

    private func selectKid(_ kid: ChildModel) {
        self.selectedKid = kid
        self.header.setSelectedKid(Kid(id: kid.id.uuidString, name: kid.name))
        SelectedKidStore.shared.updateKid(Kid(id: kid.id.uuidString, name: kid.name))
        reloadForKid(kid)
    }

    // MARK: - Data Logic
    private func fetchKidsAndLoad() {
        _Concurrency.Task {
            do {
                let data = try await FamilyService.shared.fetchDashboard()
                await MainActor.run {
                    self.kids = data.children
                    let uiKids = self.kids.map { Kid(id: $0.id.uuidString, name: $0.name) }
                    self.header.setKids(uiKids)

                    // restore saved selected kid or pick first
                    if let saved = SelectedKidStore.shared.selectedKid,
                       let realKid = self.kids.first(where: { $0.id.uuidString == saved.id }) {
                        self.selectKid(realKid)
                    } else if let first = self.kids.first {
                        self.selectKid(first)
                    }

                }
            } catch { print("Error fetching kids: \(error)") }
        }
    }

    private func reloadForKid(_ kid: ChildModel) {
        self.selectedKid = kid
        self.header.setSelectedKid(Kid(id: kid.id.uuidString, name: kid.name))
        _Concurrency.Task {
            do {
                let stats = try await RewardService.shared.fetchRewardStats(for: kid.id)
                let lists = try await RewardService.shared.fetchRewards(for: kid.id, category: "Quick Rewards")
                
                await MainActor.run {
                    self.currentBalance = stats.total_stars
                    self.activeItems = lists.active.map { RewardDetailItem(id: $0.id.uuidString, title: $0.title, subtitle: $0.description ?? "Quick Treat", points: $0.points, imageName: $0.image_url, isActive: true, claimLimit: $0.claim_limit, subType: $0.reward_sub_type) }
                    self.historyItems = lists.history.map { RewardDetailItem(id: $0.id.uuidString, title: $0.title, subtitle: $0.description ?? "Redeemed", points: $0.points, imageName: $0.image_url, isActive: false, claimLimit: $0.claim_limit, subType: $0.reward_sub_type) }
                    self.populateActive(self.activeItems)
                    self.populateHistory(self.historyItems)
                }
            } catch { print("Error loading rewards: \(error)") }
        }
    }

    // MARK: - UI Population
    private func populateActive(_ list: [RewardDetailItem]) {
        activeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, item) in list.enumerated() {
            let card = RewardLargeCards(item: item, currentBalance: currentBalance)
            card.widthAnchor.constraint(equalToConstant: 130).isActive = true
            
            card.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
            card.tag = index
            card.addGestureRecognizer(tap)
            
            activeStack.addArrangedSubview(card)
        }
        
        if list.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No active rewards"
            emptyLabel.textColor = .white
            activeStack.addArrangedSubview(emptyLabel)
        }
    }

    private func populateHistory(_ list: [RewardDetailItem]) {
        historyStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in list {
            let row = RewardSmallCards(item: item)
            row.heightAnchor.constraint(equalToConstant: 70).isActive = true
            historyStack.addArrangedSubview(row)
        }
    }

    // MARK: - Actions
    @objc private func handleCardTap(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag, index < activeItems.count else { return }
        let item = activeItems[index]
        guard let uuid = UUID(uuidString: item.id) else { return }
        
        let model = RewardItemModel(
            id: uuid,
            title: item.title,
            description: item.subtitle,
            points: item.points,
            image_url: item.imageName,
            claim_limit: item.claimLimit,
            reward_sub_type: item.subType,
            object_3d_id: nil   // ✅ IMPORTANT
        )

        
        let vc = NewRewardViewController()
        vc.mode = .edit(model, category: "Quick Rewards")
        vc.hidesBottomBarWhenPushed = true // ✅ Hides bottom tab bar
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openNewReward() {
        let vc = NewRewardViewController()
        vc.mode = .create
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
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

    // MARK: - Visuals & Layout
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
        header.showNotificationButton(false)
        header.showProfileButton(false)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 110)  // match Approval
        ])

    }

    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(content)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupContentLayout() {
        
        activeScroll.showsHorizontalScrollIndicator = false;
        activeScroll.translatesAutoresizingMaskIntoConstraints = false;
        
        activeStack.axis = .horizontal; activeStack.spacing = 16;
        activeStack.translatesAutoresizingMaskIntoConstraints = false;
        activeScroll.addSubview(activeStack)
        historyStack.axis = .vertical;
        historyStack.spacing = 12;
        historyStack.translatesAutoresizingMaskIntoConstraints = false
        [activeLabel, activeScroll, historyLabel, historyStack, bottomSpacer].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; content.addSubview($0) }
        NSLayoutConstraint.activate([
            
            // ✅ STARTING ANCHOR (THIS WAS MISSING)
            activeLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
            activeLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            
            activeScroll.topAnchor.constraint(equalTo: activeLabel.bottomAnchor, constant: 12),
            activeScroll.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            activeScroll.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            activeScroll.heightAnchor.constraint(equalToConstant: 160),
            
            activeStack.leadingAnchor.constraint(equalTo: activeScroll.contentLayoutGuide.leadingAnchor),
            activeStack.trailingAnchor.constraint(equalTo: activeScroll.contentLayoutGuide.trailingAnchor, constant: -20),
            activeStack.heightAnchor.constraint(equalTo: activeScroll.frameLayoutGuide.heightAnchor),
            
            historyLabel.topAnchor.constraint(equalTo: activeScroll.bottomAnchor, constant: 30),
            historyLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            
            historyStack.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 12),
            historyStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            historyStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
            
            bottomSpacer.topAnchor.constraint(equalTo: historyStack.bottomAnchor, constant: 20),
            bottomSpacer.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            bottomSpacer.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            bottomSpacer.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            bottomSpacer.heightAnchor.constraint(equalToConstant: 80)
        ])
        
    }

    
    @objc private func handleSelectedKidChanged(_ notification: Notification) {
        guard let uiKid = notification.userInfo?["kid"] as? Kid else { return }
        if let realKid = kids.first(where: { $0.id.uuidString == uiKid.id }) {
            reloadForKid(realKid)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }


}

// ======================================================
// MARK: - Reward Large Card (For Active)
// ======================================================
final class RewardLargeCards: UIView {

    private let titleLabel = UILabel()
    private let costLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let progressLabel = UILabel()

    init(item: RewardDetailItem, currentBalance: Int) {
        super.init(frame: .zero)

        backgroundColor = UIColor.white.withAlphaComponent(0.08)
        layer.cornerRadius = 16
        clipsToBounds = true

        // Title
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        // Cost
        costLabel.text = "\(item.points) ⭐️"
        costLabel.font = .systemFont(ofSize: 13, weight: .medium)
        costLabel.textColor = UIColor.white.withAlphaComponent(0.6)

        // Progress
        let total = max(item.points, 1)
        let progress = Float(currentBalance) / Float(total)
        progressView.progress = min(progress, 1)
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.15)
        progressView.progressTintColor = .systemYellow
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true

        // Progress label
        if currentBalance >= item.points {
            progressLabel.text = "Ready to redeem"
            progressLabel.textColor = .systemYellow
        } else {
            progressLabel.text = "\(item.points - currentBalance) more stars"
            progressLabel.textColor = UIColor.white.withAlphaComponent(0.45)
        }
        progressLabel.font = .systemFont(ofSize: 11, weight: .medium)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            costLabel,
            progressLabel,
            progressView
        ])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

// ======================================================
// MARK: - Reward Small Card (History)
// ======================================================
final class RewardSmallCards: UIView {
    var onTap: (() -> Void)?; init(item: RewardDetailItem)
    {
        super.init(frame: .zero); backgroundColor = UIColor.white.withAlphaComponent(0.05);
        
        layer.cornerRadius = 12; let title = UILabel();
        title.text = item.title; title.font = .systemFont(ofSize: 15, weight: .medium);
        title.textColor = UIColor.white.withAlphaComponent(0.6); let cost = UILabel();
        
        cost.text = "Redeemed for \(item.points) ⭐️";
        cost.font = .systemFont(ofSize: 12);
        cost.textColor = UIColor.white.withAlphaComponent(0.4);
        
        
        let stack = UIStackView(arrangedSubviews: [title, cost]);
        stack.axis = .vertical; stack.spacing = 4;
        stack.translatesAutoresizingMaskIntoConstraints = false; addSubview(stack);
        
        let icon = UIImageView(image: UIImage(systemName: "checkmark.circle"));
        icon.tintColor = .systemGreen; icon.translatesAutoresizingMaskIntoConstraints = false; addSubview(icon); NSLayoutConstraint.activate([stack.centerYAnchor.constraint(equalTo: centerYAnchor), stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16), icon.centerYAnchor.constraint(equalTo: centerYAnchor), icon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)]); addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped))) }
    
    @objc private func tapped() { onTap?() }; required init?(coder: NSCoder) { fatalError() }
}
