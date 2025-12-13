import UIKit

// MARK: - 1. Glass Card View (Reusable)
class GlassCardView: UIView {
    
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
        blurEffectView.contentView.backgroundColor = UIColor(white: 1, alpha: 0.05)
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 1, alpha: 0.15).cgColor
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
        // Fix for blur bleeding at corners
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
        l.font = .systemFont(ofSize: 20, weight: .bold)
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
        sv.spacing = 10
        return sv
    }()
    
    private let childrenStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        return sv
    }()
    
    // Family Name Display (Read-only for dashboard)
    private let familyNameLabel: UILabel = {
        let l = UILabel()
        l.text = "Family Name"
        l.textColor = .lightGray
        l.font = .systemFont(ofSize: 14, weight: .medium)
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
        btn.setTitle("Add Child", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        // Secondary dark glass style
        btn.backgroundColor = UIColor(white: 1, alpha: 0.1)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor(white: 1, alpha: 0.2).cgColor
        btn.layer.cornerRadius = 14
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let doneButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Go to Dashboard", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        // Primary Blue
        btn.backgroundColor = UIColor(red: 55/255, green: 115/255, blue: 250/255, alpha: 1.0)
        btn.layer.cornerRadius = 14
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
        let nameSection = createSectionHeader(title: "Family Name")
        let nameCard = createGlassContainer()
        nameCard.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let nameStack = UIStackView(arrangedSubviews: [familyNameLabel, familyNameValueLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 4
        nameStack.translatesAutoresizingMaskIntoConstraints = false
        nameCard.addSubview(nameStack)
        
        NSLayoutConstraint.activate([
            nameStack.centerYAnchor.constraint(equalTo: nameCard.centerYAnchor),
            nameStack.leadingAnchor.constraint(equalTo: nameCard.leadingAnchor, constant: 16)
        ])
        
        stackView.addArrangedSubview(nameSection)
        stackView.addArrangedSubview(nameCard)
        
        // 2. Add Parents Section
        let parentsHeader = createSectionHeader(title: "Parents")
        stackView.addArrangedSubview(parentsHeader)
        stackView.addArrangedSubview(parentsStack)
        
        // 3. Add Children Section
        let childrenHeader = createSectionHeader(title: "Children")
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
        for parent in data.parents {
            let card = createMemberCard(
                iconName: "person.crop.circle.badge.checkmark",
                name: parent.first_name,
                role: parent.role.capitalized,
                code: nil
            )
            parentsStack.addArrangedSubview(card)
        }
        
        // Update Children
        childrenStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
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
    
    // MARK: - Helper Methods
    
    private func createSectionHeader(title: String) -> UIView {
        let v = UIView()
        v.heightAnchor.constraint(equalToConstant: 30).isActive = true
        let l = UILabel()
        l.text = title
        l.textColor = .white
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(l)
        l.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 4).isActive = true
        l.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        return v
    }
    
    private func createGlassContainer() -> GlassCardView {
        let card = GlassCardView()
        card.setCornerRadius(16)
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }
    
    private func createMemberCard(iconName: String, name: String, role: String, code: String?) -> UIView {
        let card = createGlassContainer()
        card.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // Icon
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: iconName)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor(red: 255/255, green: 200/255, blue: 150/255, alpha: 1.0) // Gold/Peach tint
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        // Shadow for icon
        iconView.layer.shadowColor = UIColor.black.cgColor
        iconView.layer.shadowOpacity = 0.3
        iconView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        // Text
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 17, weight: .bold)
        
        let roleLabel = UILabel()
        roleLabel.text = role
        roleLabel.textColor = .lightGray
        roleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, roleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(iconView)
        card.addSubview(textStack)
        
        // Add Code if exists
        if let codeText = code {
            let codeLabel = UILabel()
            codeLabel.text = codeText
            codeLabel.textColor = UIColor(red: 100/255, green: 180/255, blue: 255/255, alpha: 1.0) // Light Blue
            codeLabel.font = .systemFont(ofSize: 13, weight: .medium)
            textStack.addArrangedSubview(codeLabel)
        }
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            
            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
        ])
        
        return card
    }

    // MARK: - Button Actions
    
    @objc private func handleAddChild() {
        let vc = Addchildform() // Ensure this class exists
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func handleDone() {
//         Logic to switch to Tab Bar
         let mainTabBar = CustomTabBarController()
         navigationController?.setViewControllers([mainTabBar], animated: true)
        print("Done Tapped - Go to Dashboard")
    }
}
