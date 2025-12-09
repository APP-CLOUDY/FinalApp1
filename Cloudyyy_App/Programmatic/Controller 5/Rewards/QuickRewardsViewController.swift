import UIKit

// MARK: - Local Model for List Items
struct RewardDetailItem {
    let id: String
    let title: String
    let subtitle: String
    let points: Int
    let imageName: String?
    let isActive: Bool
    // ✅ Added to support Edit Mode
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
    private let header = HomeHeaderView(title: "Quick Rewards")
    private let gradient = CAGradientLayer()
    private let searchBar = SimpleSearchBar()

    // BACK BUTTON
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

    // 1. Categories Filter
    private let categoryScroll = UIScrollView()
    private let categoryStack = UIStackView()
    private let categories = ["All", "Snacks", "Screen Time", "Outdoors", "Toys"]
    private var selectedCategoryIndex = 0

    // 2. Active Section (Horizontal Scroll)
    private let activeLabel = SectionLabel(text: "Active")
    private let activeScroll = UIScrollView()
    private let activeStack = UIStackView()

    // 3. History Section
    private let historyLabel = SectionLabel(text: "Redemption History")
    private let historyStack = UIStackView()

    private let bottomSpacer = UIView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupGradient()
        setupHeader()
        setupScroll()
        setupContentLayout()
        
        // Add Back Button
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        view.bringSubviewToFront(backButton)
        
        header.onChildTapped = { [weak self] in self?.showKidsMenu() }
        setupCategoryChips()
        
        header.showPlusButton(true)
        header.onPlusTapped = { [weak self] in self?.openNewReward() }
        
        // Fetch Kids, then load data
        fetchKidsAndLoad()
        
        // Listen for updates
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

    // MARK: - Data Logic (Supabase)
    
    private func fetchKidsAndLoad() {
        _Concurrency.Task {
            do {
                let data = try await FamilyService.shared.fetchDashboard()
                await MainActor.run {
                    self.kids = data.children
                    if let first = self.kids.first {
                        self.selectedKid = first
                        self.header.childButton.setTitle("\(first.name) ▾", for: .normal)
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
        header.childButton.setTitle("\(kid.name) ▾", for: .normal)
        
        _Concurrency.Task {
            do {
                // 1. Get Balance
                let stats = try await RewardService.shared.fetchRewardStats(for: kid.id)
                
                // 2. Get Rewards List (Category: "Quick Rewards")
                let lists = try await RewardService.shared.fetchRewards(for: kid.id, category: "Quick Rewards")
                
                await MainActor.run {
                    self.currentBalance = stats.total_stars
                    
                    // Map Active Items
                    self.activeItems = lists.active.map { item in
                        RewardDetailItem(
                            id: item.id.uuidString,
                            title: item.title,
                            subtitle: item.description ?? "Quick Treat",
                            points: item.points,
                            imageName: item.image_url,
                            isActive: true,
                            // ✅ Map new fields
                            claimLimit: item.claim_limit,
                            subType: item.reward_sub_type
                        )
                    }
                    
                    // Map History Items
                    self.historyItems = lists.history.map { item in
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
                    self.populateHistory(self.historyItems)
                }
            } catch {
                print("Error loading rewards: \(error)")
            }
        }
    }

    // MARK: - UI Population
    private func populateActive(_ list: [RewardDetailItem]) {
        activeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, item) in list.enumerated() {
            // Use RewardLargeCards
            let card = RewardLargeCards(item: item, currentBalance: currentBalance)
            card.widthAnchor.constraint(equalToConstant: 160).isActive = true
            
            // ✅ Add Tap Gesture for Editing
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
        
        // Convert to Service Model
        guard let uuid = UUID(uuidString: item.id) else { return }
        
        // ✅ Pass 'subType' here so the dropdown shows the correct value!
        let model = RewardItemModel(
            id: uuid,
            title: item.title,
            description: item.subtitle,
            points: item.points,
            image_url: item.imageName,
            claim_limit: item.claimLimit,
            reward_sub_type: item.subType // Passed!
        )
        
        // Navigate to Edit Screen
        let vc = NewRewardViewController()
        vc.mode = .edit(model, category: "Quick Rewards") // Fixed category for this screen
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openNewReward() {
        let vc = NewRewardViewController()
        vc.mode = .create
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
            header.heightAnchor.constraint(equalToConstant: 98)
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

        historyStack.axis = .vertical
        historyStack.spacing = 12
        historyStack.translatesAutoresizingMaskIntoConstraints = false
        
        [activeLabel, activeScroll, historyLabel, historyStack, bottomSpacer].forEach {
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
            activeScroll.heightAnchor.constraint(equalToConstant: 220),

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
// MARK: - Reward Large Card (For Active)
// ======================================================
final class RewardLargeCards: UIView {
    
    private let titleLabel = UILabel()
    private let costLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let progressLabel = UILabel()
    private let iconView = UILabel()
    
    init(item: RewardDetailItem, currentBalance: Int) {
        super.init(frame: .zero)
        
        backgroundColor = UIColor(red: 40/255, green: 45/255, blue: 65/255, alpha: 1)
        layer.cornerRadius = 20
        clipsToBounds = true
        
        iconView.text = "🎁"
        iconView.font = .systemFont(ofSize: 80)
        iconView.alpha = 0.05
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        costLabel.text = "\(item.points) ⭐️"
        costLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        costLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(costLabel)
        
        let totalCost = Float(item.points > 0 ? item.points : 1)
        let progress = Float(currentBalance) / totalCost
        
        progressView.progress = min(progress, 1.0)
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.1)
        progressView.progressTintColor = UIColor(red: 255/255, green: 140/255, blue: 100/255, alpha: 1)
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        
        if currentBalance >= item.points {
            progressLabel.text = "Ready!"
            progressLabel.textColor = .systemYellow
        } else {
            let needed = item.points - currentBalance
            progressLabel.text = "\(needed) more stars"
            progressLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        }
        progressLabel.font = .systemFont(ofSize: 11, weight: .medium)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressLabel)
        
        NSLayoutConstraint.activate([
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            iconView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            costLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            costLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            progressLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -6),
            progressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// ======================================================
// MARK: - Reward Small Card (History)
// ======================================================
final class RewardSmallCards: UIView {
    
    var onTap: (() -> Void)?
    
    init(item: RewardDetailItem) {
        super.init(frame: .zero)
        backgroundColor = UIColor.white.withAlphaComponent(0.05)
        layer.cornerRadius = 12
        
        let title = UILabel()
        title.text = item.title
        title.font = .systemFont(ofSize: 15, weight: .medium)
        title.textColor = UIColor.white.withAlphaComponent(0.6)
        
        let cost = UILabel()
        cost.text = "Redeemed for \(item.points) ⭐️"
        cost.font = .systemFont(ofSize: 12)
        cost.textColor = UIColor.white.withAlphaComponent(0.4)
        
        let stack = UIStackView(arrangedSubviews: [title, cost])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        let icon = UIImageView(image: UIImage(systemName: "checkmark.circle"))
        icon.tintColor = .systemGreen
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    @objc private func tapped() { onTap?() }
    required init?(coder: NSCoder) { fatalError() }
}
