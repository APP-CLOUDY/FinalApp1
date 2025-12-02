import UIKit

final class SpringOnViewController: UIViewController {

    // MARK: - UI Components
    private let header = HomeHeaderView(title: "Spring On")
    private let gradient = CAGradientLayer()
    private let searchBar = SimpleSearchBar()

    // Scroll Layout
    private let scrollView = UIScrollView()
    private let content = UIView()

    // 1. Categories
    private let categoryScroll = UIScrollView()
    private let categoryStack = UIStackView()
    private let categories = ["All", "Outdoor", "Events", "Trips", "Classes"]
    private var selectedCategoryIndex = 0

    // 2. Active Experiences (Horizontal Scroll)
    private let activeLabel = SectionLabel(text: "Upcoming Adventures")
    private let activeScroll = UIScrollView()
    private let activeStack = UIStackView()

    // 3. Past Experiences (History)
    private let completedLabel = SectionLabel(text: "Memories")
    private let completedStack = UIStackView()

    private let bottomSpacer = UIView()

    // Data
    private var activeItems: [RewardDetailItem] = []
    private var completedItems: [RewardDetailItem] = []
    
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
        setupCategoryChips()
        
        header.onChildTapped = { [weak self] in self?.showKidsMenu() }
        header.showPlusButton(true)
        header.onPlusTapped = { [weak self] in self?.openNewReward() }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onKidChanged(_:)),
            name: ChildManager.kidChangedNotification,
            object: nil
        )

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

    // MARK: - Visuals
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
        // 1. Search Bar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(searchBar)
        
        // 2. Categories
        categoryScroll.showsHorizontalScrollIndicator = false
        categoryScroll.translatesAutoresizingMaskIntoConstraints = false
        categoryStack.axis = .horizontal
        categoryStack.spacing = 10
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        categoryScroll.addSubview(categoryStack)
        content.addSubview(categoryScroll)

        // 3. Active Experiences (Horizontal)
        activeScroll.showsHorizontalScrollIndicator = false
        activeScroll.translatesAutoresizingMaskIntoConstraints = false
        activeStack.axis = .horizontal
        activeStack.spacing = 16
        activeStack.translatesAutoresizingMaskIntoConstraints = false
        activeScroll.addSubview(activeStack)

        // 4. Completed
        completedStack.axis = .vertical
        completedStack.spacing = 12
        completedStack.translatesAutoresizingMaskIntoConstraints = false

        [activeLabel, activeScroll, completedLabel, completedStack, bottomSpacer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview($0)
        }

        NSLayoutConstraint.activate([
            // Search
            searchBar.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
            
            // Categories
            categoryScroll.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            categoryScroll.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            categoryScroll.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            categoryScroll.heightAnchor.constraint(equalToConstant: 36),
            
            categoryStack.leadingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.leadingAnchor),
            categoryStack.trailingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.trailingAnchor, constant: -20),
            categoryStack.heightAnchor.constraint(equalTo: categoryScroll.frameLayoutGuide.heightAnchor),

            // Active Label
            activeLabel.topAnchor.constraint(equalTo: categoryScroll.bottomAnchor, constant: 24),
            activeLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),

            // Active Scroll
            activeScroll.topAnchor.constraint(equalTo: activeLabel.bottomAnchor, constant: 12),
            activeScroll.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            activeScroll.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            activeScroll.heightAnchor.constraint(equalToConstant: 240), // Tall for Experience Cards

            activeStack.leadingAnchor.constraint(equalTo: activeScroll.contentLayoutGuide.leadingAnchor),
            activeStack.trailingAnchor.constraint(equalTo: activeScroll.contentLayoutGuide.trailingAnchor, constant: -20),
            activeStack.heightAnchor.constraint(equalTo: activeScroll.frameLayoutGuide.heightAnchor),

            // Completed
            completedLabel.topAnchor.constraint(equalTo: activeScroll.bottomAnchor, constant: 30),
            completedLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),

            completedStack.topAnchor.constraint(equalTo: completedLabel.bottomAnchor, constant: 12),
            completedStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            completedStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),

            // Bottom
            bottomSpacer.topAnchor.constraint(equalTo: completedStack.bottomAnchor, constant: 20),
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

    // MARK: - Data Logic
    @objc private func onKidChanged(_ n: Notification) {
        guard let kid = n.object as? Kid else { return }
        header.childButton.setTitle("\(kid.name) ▾", for: .normal)
        reloadForKid(kid)
    }

    private func reloadForKid(_ kid: Kid) {
        let all = ChildManager.shared.springOnRewards(for: kid.id) ?? []
        activeItems = all.filter { $0.isActive }
        
        // Dummy Data for Visualization
        if !activeItems.isEmpty {
            activeItems.append(RewardDetailItem(id: "88", title: "Zoo Trip", subtitle: "Family", points: 1500, imageName: "", isActive: true))
            activeItems.append(RewardDetailItem(id: "87", title: "Movie Night", subtitle: "Fun", points: 800, imageName: "", isActive: true))
        }
        
        completedItems = all.filter { !$0.isActive }

        populateActive(activeItems)
        populateCompleted(completedItems)
    }

    private func populateActive(_ arr: [RewardDetailItem]) {
        activeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for item in arr {
            // Use ExperienceCard (Fresh Colors)
            let card = ExperienceCard(item: item, currentBalance: currentBalance)
            
            // Size for Horizontal Scroll
            card.widthAnchor.constraint(equalToConstant: 200).isActive = true
            
            card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped)))
            activeStack.addArrangedSubview(card)
        }
        
        if arr.isEmpty {
            let lbl = UILabel()
            lbl.text = "No upcoming adventures! 🏕️"
            lbl.textColor = .white
            activeStack.addArrangedSubview(lbl)
        }
    }

    private func populateCompleted(_ arr: [RewardDetailItem]) {
        completedStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for item in arr {
            // Reuse Small Card
            let row = RewardSmallCard(item: item)
            row.heightAnchor.constraint(equalToConstant: 70).isActive = true
            row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped)))
            completedStack.addArrangedSubview(row)
        }
    }

    @objc private func openNewReward() {
        navigationController?.pushViewController(NewRewardViewController(), animated: true)
    }
    
    @objc private func cardTapped() {
        // Open Detail
    }

    private func showKidsMenu() {
        let kids = ChildManager.shared.kids
        guard !kids.isEmpty else { return }
        let menu = FloatingKidsMenu(kids: kids)
        menu.onKidSelected = { ChildManager.shared.selectedKid = $0 }
        menu.show(in: view, anchor: header.childButton)
    }
}

// ======================================================
// MARK: - Experience Card (Green/Nature Theme)
final class ExperienceCard: UIView {
    
    private let titleLabel = UILabel()
    private let costLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let progressLabel = UILabel()
    private let iconView = UILabel()
    
    init(item: RewardDetailItem, currentBalance: Int) {
        super.init(frame: .zero)
        
        // 1. SOLID DARK BACKGROUND
        backgroundColor = UIColor(red: 40/255, green: 45/255, blue: 65/255, alpha: 1)
        layer.cornerRadius = 24
        clipsToBounds = true
        
        // 2. Big Icon
        iconView.text = "🎟️"
        if item.title.contains("Zoo") { iconView.text = "🦁" }
        if item.title.contains("Camping") { iconView.text = "⛺️" }
        
        iconView.font = .systemFont(ofSize: 100)
        iconView.alpha = 0.05 // Very Subtle
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        
        // 3. Title
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        // 4. Cost
        costLabel.text = "\(item.points) ⭐️"
        costLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        costLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(costLabel)
        
        // 5. Progress Bar
        let totalCost = Float(item.points > 0 ? item.points : 1)
        let progress = Float(currentBalance) / totalCost
        
        progressView.progress = min(progress, 1.0)
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.1)
        progressView.progressTintColor = UIColor(red: 76/255, green: 209/255, blue: 55/255, alpha: 1) // Soft Green for Spring On
        progressView.layer.cornerRadius = 3
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        
        // 6. Progress Text
        if currentBalance >= item.points {
            progressLabel.text = "Let's Go! 🚀"
            progressLabel.textColor = .systemGreen
        } else {
            let percent = Int(progress * 100)
            progressLabel.text = "\(percent)% saved"
            progressLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        }
        progressLabel.font = .systemFont(ofSize: 12, weight: .medium)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressLabel)
        
        // Layout
        NSLayoutConstraint.activate([
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
