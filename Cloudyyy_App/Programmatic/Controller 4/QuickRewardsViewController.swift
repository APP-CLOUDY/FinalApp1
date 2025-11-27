import UIKit

final class QuickRewardsViewController: UIViewController {

    // MARK: - UI Components
    private let header = HomeHeaderView(title: "Quick Rewards") // Changed Title
    private let gradient = CAGradientLayer()
    
    private let searchBar = SimpleSearchBar()

    // Scroll Layout
    private let scrollView = UIScrollView()
    private let content = UIView()

    // 1. Categories Filter
    private let categoryScroll = UIScrollView()
    private let categoryStack = UIStackView()
    private let categories = ["All", "Snacks", "Screen Time", "Outdoors", "Toys"]
    private var selectedCategoryIndex = 0

    // 2. Active Section (Horizontal Scroll)
    private let activeLabel = SectionLabel(text: "Active") // Renamed to Active
    private let activeScroll = UIScrollView()
    private let activeStack = UIStackView()

    // 3. History Section
    private let historyLabel = SectionLabel(text: "Redemption History")
    private let historyStack = UIStackView()

    private let bottomSpacer = UIView()

    // Data
    private var activeItems: [RewardDetailItem] = []
    private var historyItems: [RewardDetailItem] = []
    
    // Mock Balance for progress bars
    private var currentBalance: Int = 350

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupGradient()
        setupHeader()
        setupScroll()
        setupContentLayout()
        
        header.onChildTapped = { [weak self] in self?.showKidsMenu() }
        setupCategoryChips()
        
        if let kid = ChildManager.shared.selectedKid {
            header.childButton.setTitle("\(kid.name) ▾", for: .normal)
            reloadForKid(kid)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    // MARK: - Setup Visuals
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
        header.showPlusButton(true)
        header.onPlusTapped = { [weak self] in self?.openNewReward() }

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

        // Categories
        categoryScroll.showsHorizontalScrollIndicator = false
        categoryScroll.translatesAutoresizingMaskIntoConstraints = false
        categoryStack.axis = .horizontal
        categoryStack.spacing = 10
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        categoryScroll.addSubview(categoryStack)
        content.addSubview(categoryScroll)

        // Active (Horizontal Scroll)
        activeScroll.showsHorizontalScrollIndicator = false
        activeScroll.translatesAutoresizingMaskIntoConstraints = false
        activeStack.axis = .horizontal
        activeStack.spacing = 16
        activeStack.translatesAutoresizingMaskIntoConstraints = false
        activeScroll.addSubview(activeStack)
        
        // History (Vertical)
        historyStack.axis = .vertical
        historyStack.spacing = 12
        historyStack.translatesAutoresizingMaskIntoConstraints = false
        
        [activeLabel, activeScroll, historyLabel, historyStack, bottomSpacer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview($0)
        }

        NSLayoutConstraint.activate([
            // 1. Search Bar (Top)
            searchBar.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

            // 2. Category Chips
            categoryScroll.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            categoryScroll.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            categoryScroll.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            categoryScroll.heightAnchor.constraint(equalToConstant: 36),
            
            categoryStack.leadingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.leadingAnchor),
            categoryStack.trailingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.trailingAnchor, constant: -20),
            categoryStack.heightAnchor.constraint(equalTo: categoryScroll.frameLayoutGuide.heightAnchor),

            // 3. Active Section (Horizontal)
            activeLabel.topAnchor.constraint(equalTo: categoryScroll.bottomAnchor, constant: 24),
            activeLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),

            activeScroll.topAnchor.constraint(equalTo: activeLabel.bottomAnchor, constant: 12),
            activeScroll.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            activeScroll.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            activeScroll.heightAnchor.constraint(equalToConstant: 220), // Height for Cards

            activeStack.leadingAnchor.constraint(equalTo: activeScroll.contentLayoutGuide.leadingAnchor),
            activeStack.trailingAnchor.constraint(equalTo: activeScroll.contentLayoutGuide.trailingAnchor, constant: -20),
            activeStack.heightAnchor.constraint(equalTo: activeScroll.frameLayoutGuide.heightAnchor),

            // 4. History Section
            historyLabel.topAnchor.constraint(equalTo: activeScroll.bottomAnchor, constant: 30),
            historyLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),

            historyStack.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 12),
            historyStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            historyStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),

            // Spacer
            bottomSpacer.topAnchor.constraint(equalTo: historyStack.bottomAnchor, constant: 20),
            bottomSpacer.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            bottomSpacer.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            bottomSpacer.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            bottomSpacer.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    // MARK: - Category Logic
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

    // MARK: - Data Reloading
    private func reloadForKid(_ kid: Kid) {
        // Mock Data fetching
        let allItems = ChildManager.shared.quickRewards(for: kid.id) ?? []
        
        activeItems = allItems.filter { $0.isActive }
        
        // !!! DUMMY DATA FOR SCROLL DEMO !!!
        // Duplicating items so you can see horizontal scrolling immediately
        if !activeItems.isEmpty {
            let item = activeItems[0]
            activeItems.append(RewardDetailItem(id: "2", title: "Ice Cream", subtitle: "Treat", points: 80, imageName: "Cycle", isActive: true))
            activeItems.append(RewardDetailItem(id: "3", title: "Video Game", subtitle: "1 Hour", points: 120, imageName: "Cycle", isActive: true))
        }
        
        historyItems = allItems.filter { !$0.isActive }

        populateActive(activeItems)
        populateHistory(historyItems)
    }

    private func populateActive(_ list: [RewardDetailItem]) {
        activeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for item in list {
            // Use the Card
            let card = RewardLargeCards(item: item, currentBalance: currentBalance)
            
            // Width constraint for horizontal scroll cards
            card.widthAnchor.constraint(equalToConstant: 160).isActive = true
            
            card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:))))
            card.tag = item.id.hashValue
            
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
            let row = RewardSmallCard(item: item)
            row.heightAnchor.constraint(equalToConstant: 70).isActive = true
            historyStack.addArrangedSubview(row)
        }
    }

    // MARK: - Actions
    @objc private func cardTapped(_ sender: UITapGestureRecognizer) {
        print("Card tapped")
    }
    
    @objc private func openNewReward() {
        navigationController?.pushViewController(NewRewardViewController(), animated: true)
    }
    
    private func showKidsMenu() { }
    
    @objc private func onKidChanged(_ n: Notification) {
        guard let kid = n.object as? Kid else { return }
        header.childButton.setTitle("\(kid.name) ▾", for: .normal)
        reloadForKid(kid)
    }
}

final class RewardLargeCards: UIView {
    
    private let titleLabel = UILabel()
    private let costLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let progressLabel = UILabel()
    private let iconView = UILabel()
    
    init(item: RewardDetailItem, currentBalance: Int) {
        super.init(frame: .zero)
        
        // 1. SOLID DARK BACKGROUND
        backgroundColor = UIColor(red: 40/255, green: 45/255, blue: 65/255, alpha: 1)
        layer.cornerRadius = 20
        clipsToBounds = true
        
        // 2. Icon
        iconView.text = "🎁"
        iconView.font = .systemFont(ofSize: 80)
        iconView.alpha = 0.05 // Very Subtle
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        
        // 3. Title
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        // 4. Cost
        costLabel.text = "\(item.points) ⭐️"
        costLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        costLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(costLabel)
        
        // 5. Progress Bar
        let totalCost = Float(item.points > 0 ? item.points : 1)
        let progress = Float(currentBalance) / totalCost
        
        progressView.progress = min(progress, 1.0)
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.1)
        progressView.progressTintColor = UIColor(red: 255/255, green: 140/255, blue: 100/255, alpha: 1) // Soft Orange for Quick Rewards
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        
        // 6. Progress Text
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
        
        // Layout
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
// MARK: - 3. Reward Small Card (History)
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
