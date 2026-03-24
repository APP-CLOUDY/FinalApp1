import UIKit
import ImagePlayground // 👈 Required for the new feature

// Local model for the category list rows
struct RewardCategoryData {
    let title: String
    let subtitle: String
    let icon: String
}

// ✅ Added ImagePlaygroundViewController.Delegate conformance
final class RewardHomeViewController: UIViewController, ImagePlaygroundViewController.Delegate {

    // MARK: - Properties
    private var kids: [ChildModel] = []
    private var selectedKid: ChildModel?
    
    // Static list of categories that map to our specific ViewControllers
    private let categories: [RewardCategoryData] = [
        RewardCategoryData(title: "Quick Rewards", subtitle: "Small instant treats (e.g., cartoon, snack)", icon: "gift"),
        RewardCategoryData(title: "Dream it", subtitle: "Long-term goals (e.g., cycle, art kit)", icon: "sparkles"),
        RewardCategoryData(title: "Spring On", subtitle: "Experience-based goal (e.g., zoo trip)", icon: "leaf")
    ]

    // MARK: - UI Elements
    private let header = HomeHeaderView(title: "Rewards")
    private let gradient = CAGradientLayer()

    private let smallLeft  = GlassView(style: .card, cornerRadius: 22)
    private let smallRight = GlassView(style: .card, cornerRadius: 22)
    private let largeCard  = GlassView(style: .card, cornerRadius: 24)
    
    private let activeLabel = UILabel()
    private let activeTitle = UILabel()

    private let weekLabel = UILabel()
    private let weekTitle = UILabel()

    private let totalLabel = UILabel()
    private let totalTitle = UILabel()

    // Category List Container
    private let categoryStack = UIStackView()

    // 👇 NEW: Image Playground Button
    private lazy var playgroundButton: UIButton = {
        let btn = UIButton(type: .system)
        
        // Native Button Configuration
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(red: 40/255, green: 45/255, blue: 65/255, alpha: 1) // Dark blue theme
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        
        // Icon
        config.image = UIImage(systemName: "sparkles.rectangle.stack.fill")
        config.imagePadding = 0 // Icon only for a clean circle/capsule look
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
        
        btn.configuration = config
        
        // Shadow/Glow
        btn.layer.shadowColor = UIColor.systemIndigo.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 10
        btn.layer.shadowOpacity = 0.5
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addAction(UIAction { [weak self] _ in self?.openImagePlayground() }, for: .touchUpInside)
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupGradient()
        setupHeader()
        setupStatsCards()
        setupCategorySection()
        
        // Setup fixed categories immediately
        setupCategoryRows()
        
        // 👇 Setup the new button
        setupPlaygroundButton()

        header.showPlusButton(true)
        header.onPlusTapped = { [weak self] in self?.openNewRewardPage() }
        header.onChildTapped = { [weak self] in self?.showKidsMenu() }
        header.onProfileTapped = { [weak self] in
             let vc = ParentProfileViewController()
             vc.hidesBottomBarWhenPushed = true
             self?.navigationController?.pushViewController(vc, animated: true)
        }

        // Listen for updates (e.g. points spent)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataChange), name: NSNotification.Name("DataChanged"), object: nil)
        
        // Load Real Data
        fetchKidsAndLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSelectedKidChanged(_:)),
            name: .selectedKidChanged,
            object: nil
        )

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Refresh stats when returning
        if let kid = selectedKid {
            fetchStats(for: kid)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    @objc private func handleDataChange() {
        if let kid = selectedKid {
            fetchStats(for: kid)
        }
    }

    // MARK: - Data Logic (Supabase)
    
    private func fetchKidsAndLoad() {
        _Concurrency.Task {
            do {
                let data = try await FamilyService.shared.fetchDashboard()

                await MainActor.run {
                    self.kids = data.children

                    let uiKids = kids.map { Kid(id: $0.id.uuidString, name: $0.name) }
                    header.setKids(uiKids)

                    if let saved = SelectedKidStore.shared.selectedKid {
                        if let realKid = kids.first(where: { $0.id.uuidString == saved.id }) {
                            selectKid(realKid)
                            return
                        }
                    }

                    if let first = kids.first {
                        selectKid(first)
                    }
                }
            } catch {
                print(error)
            }
        }
    }

    
    private func selectKid(_ kid: ChildModel) {
        self.selectedKid = kid

        let uiKid = Kid(id: kid.id.uuidString, name: kid.name)
        header.setSelectedKid(uiKid)     // 🔥 UPDATE HEADER + GLOBAL STORE

        fetchStats(for: kid)
    }

    
    private func fetchStats(for kid: ChildModel) {
        _Concurrency.Task {
            do {
                // Call RewardService to get real numbers
                let stats = try await RewardService.shared.fetchRewardStats(for: kid.id)
                
                await MainActor.run {
                    self.activeLabel.text = "\(stats.active_rewards)"
                    self.weekLabel.text = "\(stats.stars_this_week)"
                    self.totalLabel.text = "\(stats.total_stars)"
                }
            } catch {
                print("Error fetching reward stats: \(error)")
            }
        }
    }
    
    private func showKidsMenu() {
        guard !kids.isEmpty else { return }

        let uiKids = kids.map { Kid(id: $0.id.uuidString, name: $0.name) }

        let menu = FloatingKidsMenu(kids: uiKids)
        menu.manager = FloatingMenuManager.shared

        menu.onKidSelected = { selectedUiKid in
            SelectedKidStore.shared.updateKid(selectedUiKid)  // 🔥 Trigger global update
        }

        menu.show(in: view, anchor: header.childButton)
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
            header.heightAnchor.constraint(equalToConstant: 98)
        ])
    }
    
    // MARK: - Playground Setup
    private func setupPlaygroundButton() {
        view.addSubview(playgroundButton)
        
        NSLayoutConstraint.activate([
            // Bottom Left Corner
            playgroundButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playgroundButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            playgroundButton.widthAnchor.constraint(equalToConstant: 60),
            playgroundButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Actions (Playground)
    private func openImagePlayground() {
        if #available(iOS 18.2, *) {
            let playgroundVC = ImagePlaygroundViewController()
            playgroundVC.delegate = self
            playgroundVC.modalPresentationStyle = .fullScreen
            present(playgroundVC, animated: true)
        } else {
            // Fallback for older iOS
            let alert = UIAlertController(title: "Not Available", message: "Image Playground requires iOS 18.2 or later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    // MARK: - ImagePlaygroundViewControllerDelegate
    func imagePlaygroundViewController(_ viewController: ImagePlaygroundViewController, didCreateImageAt url: URL) {
        // 1. Dismiss Playground
        viewController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            // 2. Load the image from the URL
            do {
                let data = try Data(contentsOf: url)
                if let generatedImage = UIImage(data: data) {
                    
                    // 3. Open New Reward Screen with the image
                    // Note: Ensure NewRewardViewController has 'var initialImage: UIImage?' added to it.
                    let vc = NewRewardViewController()
                    vc.mode = .create
                    vc.initialImage = generatedImage
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } catch {
                print("Failed to load generated image: \(error)")
            }
        }
    }
    
    func imagePlaygroundViewControllerDidCancel(_ viewController: ImagePlaygroundViewController) {
        viewController.dismiss(animated: true)
    }

    // MARK: - Stats Cards
    private func setupStatsCards() {
        smallLeft.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(smallLeft)
     

        smallRight.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(smallRight)
        
        largeCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(largeCard)
        
        // ACTIVE rewards
        activeLabel.font = .systemFont(ofSize: 28, weight: .bold)
        activeLabel.textColor = .white
        activeLabel.text = "-"
        activeLabel.translatesAutoresizingMaskIntoConstraints = false

        activeTitle.font = .systemFont(ofSize: 13)
        activeTitle.text = "Active Rewards"
        activeTitle.textColor = UIColor.white.withAlphaComponent(0.85)
        activeTitle.translatesAutoresizingMaskIntoConstraints = false

        // STARS THIS WEEK
        weekLabel.font = .systemFont(ofSize: 28, weight: .bold)
        weekLabel.textColor = .white
        weekLabel.text = "-"
        weekLabel.translatesAutoresizingMaskIntoConstraints = false

        weekTitle.font = .systemFont(ofSize: 13)
        weekTitle.text = "Stars this week"
        weekTitle.textColor = UIColor.white.withAlphaComponent(0.85)
        weekTitle.translatesAutoresizingMaskIntoConstraints = false

        // TOTAL stars
        totalLabel.font = .systemFont(ofSize: 32, weight: .bold)
        totalLabel.textColor = .white
        totalLabel.text = "-"
        totalLabel.translatesAutoresizingMaskIntoConstraints = false

        totalTitle.font = .systemFont(ofSize: 13)
        totalTitle.text = "Total Stars"
        totalTitle.textColor = UIColor.white.withAlphaComponent(0.85)
        totalTitle.translatesAutoresizingMaskIntoConstraints = false

        // Build stacks
        let leftStack = UIStackView(arrangedSubviews: [activeLabel, activeTitle])
        leftStack.axis = .vertical
        leftStack.alignment = .center
        leftStack.spacing = 4
        leftStack.translatesAutoresizingMaskIntoConstraints = false

        let rightStack = UIStackView(arrangedSubviews: [weekLabel, weekTitle])
        rightStack.axis = .vertical
        rightStack.alignment = .center
        rightStack.spacing = 4
        rightStack.translatesAutoresizingMaskIntoConstraints = false

        let centerStack = UIStackView(arrangedSubviews: [totalLabel, totalTitle])
        centerStack.axis = .vertical
        centerStack.alignment = .center
        centerStack.spacing = 4
        centerStack.translatesAutoresizingMaskIntoConstraints = false

        smallLeft.addSubview(leftStack)
        smallRight.addSubview(rightStack)
        largeCard.addSubview(centerStack)


        NSLayoutConstraint.activate([
            smallLeft.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            smallLeft.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
            smallLeft.heightAnchor.constraint(equalToConstant: 90),
            smallLeft.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -8),

            smallRight.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            smallRight.topAnchor.constraint(equalTo: smallLeft.topAnchor),
            smallRight.heightAnchor.constraint(equalToConstant: 90),
            smallRight.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 8),

            largeCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            largeCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            largeCard.topAnchor.constraint(equalTo: smallLeft.bottomAnchor, constant: 14),
            largeCard.heightAnchor.constraint(equalToConstant: 78),

            leftStack.centerXAnchor.constraint(equalTo: smallLeft.centerXAnchor),
            leftStack.centerYAnchor.constraint(equalTo: smallLeft.centerYAnchor),

            rightStack.centerXAnchor.constraint(equalTo: smallRight.centerXAnchor),
            rightStack.centerYAnchor.constraint(equalTo: smallRight.centerYAnchor),

            centerStack.centerXAnchor.constraint(equalTo: largeCard.centerXAnchor),
            centerStack.centerYAnchor.constraint(equalTo: largeCard.centerYAnchor)
        ])
    }

    // MARK: - Category Section
    private func setupCategorySection() {
        categoryStack.axis = .vertical
        categoryStack.spacing = 14
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryStack)

        NSLayoutConstraint.activate([
            categoryStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            categoryStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            categoryStack.topAnchor.constraint(equalTo: largeCard.bottomAnchor, constant: 22)
        ])
    }

    private func setupCategoryRows() {
        categoryStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for item in categories {
            let row = makeCategoryRow(item: item)
            categoryStack.addArrangedSubview(row)
        }
    }

    // MARK: - Build Category Row
    private func makeCategoryRow(item: RewardCategoryData) -> UIControl {
        let row = UIControl()
        row.layer.cornerRadius = 18
        row.clipsToBounds = true
        row.heightAnchor.constraint(equalToConstant: 76).isActive = true
        
        let glass = GlassView(style: .card, cornerRadius: 18)
        row.addSubview(glass)
        glass.translatesAutoresizingMaskIntoConstraints = false


        let iconView = UIImageView(image: UIImage(systemName: item.icon))
        iconView.tintColor = .white
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = item.title
        title.font = .systemFont(ofSize: 16, weight: .semibold)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false

        let subtitle = UILabel()
        subtitle.text = item.subtitle
        subtitle.font = .systemFont(ofSize: 12)
        subtitle.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [title, subtitle])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor.white.withAlphaComponent(0.7)
        chevron.translatesAutoresizingMaskIntoConstraints = false

        let hStack = UIStackView(arrangedSubviews: [iconView, textStack, chevron])
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = 14
        hStack.translatesAutoresizingMaskIntoConstraints = false

        glass.addSubview(hStack)

        NSLayoutConstraint.activate([
            glass.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            glass.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            glass.topAnchor.constraint(equalTo: row.topAnchor),
            glass.bottomAnchor.constraint(equalTo: row.bottomAnchor),

            hStack.leadingAnchor.constraint(equalTo: glass.leadingAnchor, constant: 14),
            hStack.trailingAnchor.constraint(equalTo: glass.trailingAnchor, constant: -14),
            hStack.centerYAnchor.constraint(equalTo: glass.centerYAnchor),

            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            chevron.widthAnchor.constraint(equalToConstant: 12)
        ])

        // navigation based on title
        row.addAction(UIAction { [weak self] _ in
            self?.openCategoryPage(title: item.title)
        }, for: .touchUpInside)

        return row
    }

    // MARK: - Navigation
    private func openCategoryPage(title: String) {
        switch title {
        case "Quick Rewards":
            navigationController?.pushViewController(QuickRewardsViewController(), animated: true)
        case "Dream it":
            navigationController?.pushViewController(DreamItViewController(), animated: true)
        case "Spring On":
            navigationController?.pushViewController(SpringOnViewController(), animated: true)
        default:
            break
        }
    }

    @objc private func openNewRewardPage() {
        navigationController?.pushViewController(NewRewardViewController(), animated: true)
    }
    
    @objc private func handleSelectedKidChanged(_ notification: Notification) {
        guard let uiKid = notification.userInfo?["kid"] as? Kid else { return }

        if let realKid = kids.first(where: { $0.id.uuidString == uiKid.id }) {
            selectKid(realKid)
        }
    }

}
