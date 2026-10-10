import UIKit

// MARK: - 1. Glass Card View (Reusable)
class FamGlassCardView: UIView {
    
    private let blurEffectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGlassDesign()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGlassDesign()
    }
    
    private func setupGlassDesign() {
        backgroundColor = .clear
        
        // Add Blur
        addSubview(blurEffectView)
        sendSubviewToBack(blurEffectView)
        
        // Glass Styling
        blurEffectView.contentView.backgroundColor = UIColor(white: 1, alpha: 0.08)
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 1, alpha: 0.18).cgColor
        layer.cornerRadius = 18
        blurEffectView.layer.cornerRadius = 18
        blurEffectView.clipsToBounds = true
        clipsToBounds = true
        
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
        blurEffectView.layer.cornerRadius = radius
        clipsToBounds = true
    }
}

// MARK: - 2. Family View Controller
class FamilyViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let backgroundGradientLayer = CAGradientLayer()
    
    // Header
    private let headerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let headerTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Family Dashboard"
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // Main Container Stack
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Sections (Parents/Children)
    private let parentsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        return sv
    }()
    
    private let childrenStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        return sv
    }()
    
    // Family Name Display (Read-only for dashboard)
    private let familyNameLabel: UILabel = {
        let l = UILabel()
        l.text = "HOUSEHOLD"
        l.textColor = UIColor.white.withAlphaComponent(0.60)
        l.font = .systemFont(ofSize: 11, weight: .bold)
        return l
    }()
    
    private let familyNameValueLabel: UILabel = {
        let l = UILabel()
        l.text = "Loading..."
        l.textColor = .white
        l.font = .systemFont(ofSize: 22, weight: .bold)
        return l
    }()
    
    // Buttons
    private let addChildButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("  Add Child", for: .normal)
        btn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        btn.tintColor = .white
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = UIColor(white: 1, alpha: 0.12)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor(white: 1, alpha: 0.22).cgColor
        btn.layer.cornerRadius = 14
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let doneButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Go to Dashboard  ", for: .normal)
        btn.setImage(UIImage(systemName: "arrow.right.circle.fill"), for: .normal)
        btn.semanticContentAttribute = .forceRightToLeft
        btn.tintColor = .white
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        btn.backgroundColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1.0)
        btn.layer.cornerRadius = 14
        btn.layer.shadowColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 0.45).cgColor
        btn.layer.shadowOpacity = 0.8
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        setupHeader()
        setupLayout()
        setupActions()
        
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 🛠️ FIX: This removes the empty space at the top
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Refresh data every time we show this screen
        fetchFamilyData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }
    
    // MARK: - Setup UI
    
    private func setupBackgroundGradient() {
        // Same Dark Blue Theme
        let topColor = UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1.0)
        let bottomColor = UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1.0)
        
        backgroundGradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }
    
    private func setupHeader() {
        view.addSubview(headerView)
        headerView.addSubview(headerTitleLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            headerTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerTitleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }
    
    private func setupLayout() {
        // Add Buttons to View (Fixed at bottom)
        view.addSubview(doneButton)
        view.addSubview(addChildButton)
        
        // Add Scroll View
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            // Done Button
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 52),
            
            // Add Child Button
            addChildButton.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -12),
            addChildButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addChildButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addChildButton.heightAnchor.constraint(equalToConstant: 52),
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: addChildButton.topAnchor, constant: -16),
            
            // Stack View
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
        
        // 1. Add Family Name Section
        let nameSection = createSectionHeader(title: "Family Name", iconName: "house.fill")
        let nameCard = createGlassContainer()
        nameCard.heightAnchor.constraint(equalToConstant: 76).isActive = true
        
        let iconBadge = UIView()
        iconBadge.translatesAutoresizingMaskIntoConstraints = false
        iconBadge.backgroundColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 0.20)
        iconBadge.layer.cornerRadius = 22
        iconBadge.layer.borderWidth = 1
        iconBadge.layer.borderColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 0.35).cgColor
        
        let homeIcon = UIImageView(image: UIImage(systemName: "house.fill"))
        homeIcon.translatesAutoresizingMaskIntoConstraints = false
        homeIcon.tintColor = UIColor(red: 90/255, green: 165/255, blue: 255/255, alpha: 1.0)
        homeIcon.contentMode = .scaleAspectFit
        iconBadge.addSubview(homeIcon)
        
        let nameStack = UIStackView(arrangedSubviews: [familyNameLabel, familyNameValueLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2
        nameStack.translatesAutoresizingMaskIntoConstraints = false
        
        nameCard.addSubview(iconBadge)
        nameCard.addSubview(nameStack)
        
        NSLayoutConstraint.activate([
            iconBadge.leadingAnchor.constraint(equalTo: nameCard.leadingAnchor, constant: 16),
            iconBadge.centerYAnchor.constraint(equalTo: nameCard.centerYAnchor),
            iconBadge.widthAnchor.constraint(equalToConstant: 44),
            iconBadge.heightAnchor.constraint(equalToConstant: 44),
            
            homeIcon.centerXAnchor.constraint(equalTo: iconBadge.centerXAnchor),
            homeIcon.centerYAnchor.constraint(equalTo: iconBadge.centerYAnchor),
            homeIcon.widthAnchor.constraint(equalToConstant: 22),
            homeIcon.heightAnchor.constraint(equalToConstant: 22),
            
            nameStack.centerYAnchor.constraint(equalTo: nameCard.centerYAnchor),
            nameStack.leadingAnchor.constraint(equalTo: iconBadge.trailingAnchor, constant: 14),
            nameStack.trailingAnchor.constraint(equalTo: nameCard.trailingAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(nameSection)
        stackView.addArrangedSubview(nameCard)
        
        // 2. Add Parents Section
        let parentsHeader = createSectionHeader(title: "Parents", iconName: "person.2.fill")
        stackView.addArrangedSubview(parentsHeader)
        stackView.addArrangedSubview(parentsStack)
        
        // 3. Add Children Section
        let childrenHeader = createSectionHeader(title: "Children", iconName: "figure.and.child.holdinghands")
        stackView.addArrangedSubview(childrenHeader)
        stackView.addArrangedSubview(childrenStack)
    }
    
    private func setupActions() {
        addChildButton.addTarget(self, action: #selector(handleAddChild), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
    }
    
    // MARK: - Data Fetching & UI Update
    
    private func fetchFamilyData() {
        _Concurrency.Task {
            do {
                let data = try await FamilyService.shared.fetchDashboard()
                await MainActor.run {
                    self.updateUI(with: data)
                }
            } catch {
                print("Error fetching dashboard: \(error)")
            }
        }
    }
    
    private func updateUI(with data: DashboardData) {
        // Update Name
        familyNameValueLabel.text = data.family_name
        
        // Update Parents
        parentsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if data.parents.isEmpty {
            let emptyCard = createGlassContainer()
            emptyCard.heightAnchor.constraint(equalToConstant: 60).isActive = true
            let emptyLabel = UILabel()
            emptyLabel.text = "No parents listed"
            emptyLabel.textColor = UIColor.white.withAlphaComponent(0.60)
            emptyLabel.font = .systemFont(ofSize: 14, weight: .medium)
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyCard.addSubview(emptyLabel)
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: emptyCard.centerXAnchor),
                emptyLabel.centerYAnchor.constraint(equalTo: emptyCard.centerYAnchor)
            ])
            parentsStack.addArrangedSubview(emptyCard)
        } else {
            for parent in data.parents {
                let card = createMemberCard(
                    iconName: "person.crop.circle.badge.checkmark",
                    name: parent.first_name,
                    role: parent.role.capitalized,
                    code: nil
                )
                parentsStack.addArrangedSubview(card)
            }
        }
        
        // Update Children
        childrenStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if data.children.isEmpty {
            let emptyCard = createGlassContainer()
            emptyCard.heightAnchor.constraint(equalToConstant: 64).isActive = true
            let emptyLabel = UILabel()
            emptyLabel.text = "No children added yet. Tap Add Child below."
            emptyLabel.textColor = UIColor.white.withAlphaComponent(0.60)
            emptyLabel.font = .systemFont(ofSize: 14, weight: .medium)
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyCard.addSubview(emptyLabel)
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: emptyCard.centerXAnchor),
                emptyLabel.centerYAnchor.constraint(equalTo: emptyCard.centerYAnchor)
            ])
            childrenStack.addArrangedSubview(emptyCard)
        } else {
            for child in data.children {
                let displayRole = (child.nickname?.isEmpty == false) ? child.nickname! : "Child"
                let card = createMemberCard(
                    iconName: "person.crop.circle.fill",
                    name: child.name,
                    role: displayRole,
                    code: "Code: \(child.join_code)"
                )
                childrenStack.addArrangedSubview(card)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createSectionHeader(title: String, iconName: String) -> UIView {
        let v = UIView()
        v.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = UIColor(red: 90/255, green: 165/255, blue: 255/255, alpha: 1.0)
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let l = UILabel()
        l.text = title
        l.textColor = .white
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        
        v.addSubview(icon)
        v.addSubview(l)
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 4),
            icon.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),
            
            l.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            l.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            l.trailingAnchor.constraint(lessThanOrEqualTo: v.trailingAnchor, constant: -4)
        ])
        return v
    }
    
    private func createGlassContainer() -> FamGlassCardView {
        let card = FamGlassCardView()
        card.setCornerRadius(18)
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }
    
    private func createMemberCard(iconName: String, name: String, role: String, code: String?) -> UIView {
        let card = createGlassContainer()
        card.heightAnchor.constraint(equalToConstant: 82).isActive = true
        
        // Avatar circle container
        let avatarBg = UIView()
        avatarBg.translatesAutoresizingMaskIntoConstraints = false
        let isChild = (code != nil)
        let badgeColor = isChild
            ? UIColor(red: 50/255, green: 215/255, blue: 200/255, alpha: 0.18)
            : UIColor(red: 255/255, green: 180/255, blue: 90/255, alpha: 0.18)
        let badgeBorder = isChild
            ? UIColor(red: 50/255, green: 215/255, blue: 200/255, alpha: 0.35).cgColor
            : UIColor(red: 255/255, green: 180/255, blue: 90/255, alpha: 0.35).cgColor
        let iconTint = isChild
            ? UIColor(red: 90/255, green: 225/255, blue: 215/255, alpha: 1.0)
            : UIColor(red: 255/255, green: 205/255, blue: 130/255, alpha: 1.0)
        
        avatarBg.backgroundColor = badgeColor
        avatarBg.layer.borderColor = badgeBorder
        avatarBg.layer.borderWidth = 1
        avatarBg.layer.cornerRadius = 24
        
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = iconTint
        iconView.translatesAutoresizingMaskIntoConstraints = false
        avatarBg.addSubview(iconView)
        
        // Text Stack
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 17, weight: .bold)
        
        let roleLabel = UILabel()
        roleLabel.text = role
        roleLabel.textColor = UIColor.white.withAlphaComponent(0.65)
        roleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, roleLabel])
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(avatarBg)
        card.addSubview(textStack)
        
        var trailingRef = card.trailingAnchor
        var trailingConst: CGFloat = -16
        
        // Add Code pill badge if code exists
        if let codeText = code {
            let codePill = UIView()
            codePill.translatesAutoresizingMaskIntoConstraints = false
            codePill.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.16)
            codePill.layer.borderColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.35).cgColor
            codePill.layer.borderWidth = 1
            codePill.layer.cornerRadius = 10
            
            let codeLabel = UILabel()
            codeLabel.translatesAutoresizingMaskIntoConstraints = false
            codeLabel.text = codeText
            codeLabel.textColor = UIColor(red: 100/255, green: 190/255, blue: 255/255, alpha: 1.0)
            codeLabel.font = .monospacedSystemFont(ofSize: 12, weight: .semibold)
            codePill.addSubview(codeLabel)
            card.addSubview(codePill)
            
            NSLayoutConstraint.activate([
                codePill.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                codePill.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                codePill.heightAnchor.constraint(equalToConstant: 28),
                
                codeLabel.leadingAnchor.constraint(equalTo: codePill.leadingAnchor, constant: 10),
                codeLabel.trailingAnchor.constraint(equalTo: codePill.trailingAnchor, constant: -10),
                codeLabel.centerYAnchor.constraint(equalTo: codePill.centerYAnchor)
            ])
            
            trailingRef = codePill.leadingAnchor
            trailingConst = -12
        }
        
        NSLayoutConstraint.activate([
            avatarBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            avatarBg.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatarBg.widthAnchor.constraint(equalToConstant: 48),
            avatarBg.heightAnchor.constraint(equalToConstant: 48),
            
            iconView.centerXAnchor.constraint(equalTo: avatarBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: avatarBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            textStack.leadingAnchor.constraint(equalTo: avatarBg.trailingAnchor, constant: 14),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingRef, constant: trailingConst)
        ])
        
        return card
    }
    
    // MARK: - Button Actions
    
    @objc private func handleAddChild() {
        let vc = Addchildform() // Ensure this class exists
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func handleDone() {
        // 1. Get the Window Scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        // 2. Create your Main Tab Bar Controller
        let mainTabBar = AppTabBarController()// Or AppTabBarController()
        
        // 3. Swap the Root View Controller with an animation
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = mainTabBar
        }, completion: nil)
        
        print("Done Tapped - Root Swapped to Dashboard")
    }
}

// AppTabBarController()
