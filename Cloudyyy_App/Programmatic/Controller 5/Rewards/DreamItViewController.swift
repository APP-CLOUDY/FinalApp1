import UIKit

final class DreamItViewController: UIViewController {

    // MARK: - Properties
    private var kids: [ChildModel] = []
    private var selectedKid: ChildModel?
    
    // Data
    private var activeItems: [RewardDetailItem] = []
    private var completedItems: [RewardDetailItem] = []
    private var currentBalance: Int = 0

    // MARK: - UI Components
    
    // 1. Header (Pass empty string to hide default title)
    private let header = HomeHeaderView(title: "")
    private let gradient = CAGradientLayer()
    private let searchBar = SimpleSearchBar()

    // 2. Custom Title Label
    private let screenTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Dream It"
        l.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // 3. Custom Child Button (To align with Title)
    private let customChildButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Child ▾", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium) // Adjusted font size
        btn.setTitleColor(.white, for: .normal)
        btn.contentHorizontalAlignment = .left // Align text to left
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // 4. Back Button
    private lazy var backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return b
    }()

    // Scroll Layout
    private let scrollView = UIScrollView()
    private let content = UIView()

    // Categories
    private let categoryScroll = UIScrollView()
    private let categoryStack = UIStackView()
    private let categories = ["All", "Gadgets", "Toys", "Experiences", "Bicycles"]
    private var selectedCategoryIndex = 0

    // Sections
    private let activeLabel = SectionLabel(text: "My Dream List")
    private let activeScroll = UIScrollView()
    private let activeStack = UIStackView()
    private let completedLabel = SectionLabel(text: "Redemption History")
    private let completedStack = UIStackView()

    private let bottomSpacer = UIView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupGradient()
        setupHeader()
        
        // ✅ Hide default header child button so we can use our aligned one
        header.childButton.isHidden = true
        
        setupCustomNavigation() // Sets up Back, Title, AND Child Button
        setupScroll()
        setupContentLayout()
        setupCategoryChips()
        
        // Actions
        customChildButton.addTarget(self, action: #selector(didTapChildMenu), for: .touchUpInside)
        header.showPlusButton(true)
        header.onPlusTapped = { [weak self] in self?.openNewReward() }

        fetchKidsAndLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataChange), name: NSNotification.Name("DataChanged"), object: nil)
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

    // MARK: - Data Logic
    private func fetchKidsAndLoad() {
        _Concurrency.Task {
            do {
                let data = try await FamilyService.shared.fetchDashboard()
                await MainActor.run {
                    self.kids = data.children
                    if let first = self.kids.first {
                        self.selectedKid = first
                        // ✅ Update our Custom Button
                        self.customChildButton.setTitle("\(first.name) ▾", for: .normal)
                        self.reloadForKid(first)
                    }
                }
            } catch {
                print("Error fetching kids: \(error)")
            }
        }
    }

    private func reloadForKid(_ kid: ChildModel) {
        self.selectedKid = kid
        // ✅ Update Custom Button
        self.customChildButton.setTitle("\(kid.name) ▾", for: .normal)
        
        _Concurrency.Task {
            do {
                let stats = try await RewardService.shared.fetchRewardStats(for: kid.id)
                let lists = try await RewardService.shared.fetchRewards(for: kid.id, category: "Dream it")
                
                await MainActor.run {
                    self.currentBalance = stats.total_stars
                    
                    self.activeItems = lists.active.map { item in
                        RewardDetailItem(
                            id: item.id.uuidString,
                            title: item.title,
                            subtitle: item.description ?? "Dream Reward",
                            points: item.points,
                            imageName: item.image_url,
                            isActive: true,
                            claimLimit: item.claim_limit,
                            subType: item.reward_sub_type
                        )
                    }
                    
                    self.completedItems = lists.history.map { item in
                        RewardDetailItem(
                            id: item.id.uuidString,
                            title: item.title,
                            subtitle: item.description ?? "Redeemed",
                            points: item.points,
                            imageName: item.image_url,
                            isActive: false,
                            claimLimit: item.claim_limit,
                            subType: item.reward_sub_type
                        )
                    }
                    
                    self.populateActive(self.activeItems)
                    self.populateCompleted(self.completedItems)
                }
            } catch {
                print("Error loading rewards: \(error)")
            }
        }
    }

    // MARK: - UI Population
    private func populateActive(_ arr: [RewardDetailItem]) {
        activeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, item) in arr.enumerated() {
            let card = DreamCard(item: item, currentBalance: currentBalance)
            card.widthAnchor.constraint(equalToConstant: 200).isActive = true
            
            card.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
            card.tag = index
            card.addGestureRecognizer(tap)
            
            activeStack.addArrangedSubview(card)
        }
        
        if arr.isEmpty {
            let lbl = UILabel()
            lbl.text = "No dreams yet! ✨"; lbl.textColor = .white
            activeStack.addArrangedSubview(lbl)
        }
    }

    private func populateCompleted(_ arr: [RewardDetailItem]) {
        completedStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in arr {
            let row = RewardSmallCards(item: item)
            row.heightAnchor.constraint(equalToConstant: 70).isActive = true
            completedStack.addArrangedSubview(row)
        }
    }

    // MARK: - Actions
    @objc private func handleCardTap(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag, index < activeItems.count else { return }
        let item = activeItems[index]
        
        guard let uuid = UUID(uuidString: item.id) else { return }
        let model = RewardItemModel(
            id: uuid, title: item.title, description: item.subtitle, points: item.points, image_url: item.imageName,
            claim_limit: item.claimLimit, reward_sub_type: item.subType
        )
        
        let vc = NewRewardViewController()
        vc.mode = .edit(model, category: "Dream it")
        vc.hidesBottomBarWhenPushed = true
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
        menu.onKidSelected = { [weak self] selectedUiKid in
            if let realKid = self?.kids.first(where: { $0.id.uuidString == selectedUiKid.id }) {
                self?.reloadForKid(realKid)
            }
        }
        // ✅ Anchor to our Custom Button
        menu.show(in: view, anchor: customChildButton)
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
            header.heightAnchor.constraint(equalToConstant: 98)
        ])
    }

    // ✅ FIXED: Custom Title, Back Button, and Child Button Alignment
    private func setupCustomNavigation() {
        view.addSubview(backButton)
        view.addSubview(screenTitleLabel)
        view.addSubview(customChildButton)
        
        NSLayoutConstraint.activate([
            // 1. Back Button
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),
            
            // 2. Title Label (Pinned right next to Back Button)
            screenTitleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            screenTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            
            // 3. Custom Child Button (Pinned below Title, aligned to Title's leading edge)
            customChildButton.topAnchor.constraint(equalTo: screenTitleLabel.bottomAnchor, constant: 2),
            customChildButton.leadingAnchor.constraint(equalTo: screenTitleLabel.leadingAnchor),
            customChildButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Ensure they appear above the header background
        backButton.layer.zPosition = 100
        screenTitleLabel.layer.zPosition = 100
        customChildButton.layer.zPosition = 100
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
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(searchBar)

        categoryScroll.showsHorizontalScrollIndicator = false
        categoryScroll.translatesAutoresizingMaskIntoConstraints = false
        categoryStack.axis = .horizontal
        categoryStack.spacing = 10
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        categoryScroll.addSubview(categoryStack)
        content.addSubview(categoryScroll)

        activeScroll.showsHorizontalScrollIndicator = false
        activeScroll.translatesAutoresizingMaskIntoConstraints = false
        activeStack.axis = .horizontal
        activeStack.spacing = 16
        activeStack.translatesAutoresizingMaskIntoConstraints = false
        activeScroll.addSubview(activeStack)

        completedStack.axis = .vertical
        completedStack.spacing = 12
        completedStack.translatesAutoresizingMaskIntoConstraints = false
        
        [activeLabel, activeScroll, completedLabel, completedStack, bottomSpacer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview($0)
        }

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

            categoryScroll.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            categoryScroll.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            categoryScroll.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            categoryScroll.heightAnchor.constraint(equalToConstant: 36),
            
            categoryStack.leadingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.leadingAnchor),
            categoryStack.trailingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.trailingAnchor, constant: -20),
            categoryStack.heightAnchor.constraint(equalTo: categoryScroll.frameLayoutGuide.heightAnchor),

            activeLabel.topAnchor.constraint(equalTo: categoryScroll.bottomAnchor, constant: 24),
            activeLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),

            activeScroll.topAnchor.constraint(equalTo: activeLabel.bottomAnchor, constant: 12),
            activeScroll.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            activeScroll.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            activeScroll.heightAnchor.constraint(equalToConstant: 240),

            activeStack.leadingAnchor.constraint(equalTo: activeScroll.contentLayoutGuide.leadingAnchor),
            activeStack.trailingAnchor.constraint(equalTo: activeScroll.contentLayoutGuide.trailingAnchor, constant: -20),
            activeStack.heightAnchor.constraint(equalTo: activeScroll.frameLayoutGuide.heightAnchor),

            completedLabel.topAnchor.constraint(equalTo: activeScroll.bottomAnchor, constant: 30),
            completedLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),

            completedStack.topAnchor.constraint(equalTo: completedLabel.bottomAnchor, constant: 12),
            completedStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            completedStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),

            bottomSpacer.topAnchor.constraint(equalTo: completedStack.bottomAnchor, constant: 20),
            bottomSpacer.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            bottomSpacer.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            bottomSpacer.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            bottomSpacer.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupCategoryChips() {
        categoryStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, title) in categories.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            btn.layer.cornerRadius = 18
            btn.tag = index
            btn.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
            
            if index == selectedCategoryIndex {
                btn.backgroundColor = .white
                btn.setTitleColor(.black, for: .normal)
            } else {
                btn.backgroundColor = UIColor.white.withAlphaComponent(0.1)
                btn.setTitleColor(.white, for: .normal)
            }
            categoryStack.addArrangedSubview(btn)
        }
    }
    
    @objc private func categoryTapped(_ sender: UIButton) {
        selectedCategoryIndex = sender.tag
        setupCategoryChips()
    }
}

// ======================================================
// MARK: - Dream Card (Gamified for Big Goals)
// ======================================================
final class DreamCard: UIView {
    
    private let titleLabel = UILabel()
    private let costLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let progressLabel = UILabel()
    private let iconView = UILabel()
    private let bgImageView = UIImageView()
    private let dimOverlay = UIView()
    
    init(item: RewardDetailItem, currentBalance: Int) {
        super.init(frame: .zero)
        
        backgroundColor = UIColor(red: 40/255, green: 45/255, blue: 65/255, alpha: 1)
        layer.cornerRadius = 24
        clipsToBounds = true
        
        // Background Image
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.clipsToBounds = true
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bgImageView)
        
        dimOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimOverlay.translatesAutoresizingMaskIntoConstraints = false
        dimOverlay.isHidden = true
        addSubview(dimOverlay)
        
        if let urlString = item.imageName, let url = URL(string: urlString) {
            dimOverlay.isHidden = false
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                    DispatchQueue.main.async { self.bgImageView.image = img }
                }
            }
        }
        
        // Icon
        iconView.text = "🚲"
        if item.title.contains("Console") { iconView.text = "🎮" }
        if item.title.contains("Phone") { iconView.text = "📱" }
        iconView.font = .systemFont(ofSize: 100)
        iconView.alpha = 0.05
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        if let url = item.imageName, !url.isEmpty { iconView.isHidden = true }
        
        addSubview(iconView)
        
        // Title
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        // Cost
        costLabel.text = "\(item.points) ⭐️"
        costLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        costLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(costLabel)
        
        // Progress Bar
        let totalCost = Float(item.points > 0 ? item.points : 1)
        let progress = Float(currentBalance) / totalCost
        
        progressView.progress = min(progress, 1.0)
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.2)
        progressView.progressTintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        progressView.layer.cornerRadius = 3
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        
        // Progress Text
        if currentBalance >= item.points {
            progressLabel.text = "Goal Reached! 🎉"
            progressLabel.textColor = .systemGreen
        } else {
            let percent = Int(progress * 100)
            progressLabel.text = "\(percent)% saved"
            progressLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        }
        progressLabel.font = .systemFont(ofSize: 12, weight: .medium)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            dimOverlay.topAnchor.constraint(equalTo: topAnchor),
            dimOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            iconView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            costLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            costLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 6),
            
            progressLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -8),
            progressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
