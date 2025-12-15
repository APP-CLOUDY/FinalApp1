import UIKit

// MARK: - Parent Profile View Controller
class ParentProfileViewController: UIViewController {

    // MARK: - Properties
    
    // Background Gradient Layer
    private let backgroundGradientLayer = CAGradientLayer()
    
    // MARK: - UI Components

    // 1. Full Screen Background View
    private let fullBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 2. ScrollView
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.backgroundColor = .clear
        return sv
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    // 3. Header
    private let headerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor(white: 1, alpha: 0.1)
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor(white: 1, alpha: 0.15).cgColor
        
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let headerTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "My Profile"
        lbl.font = .systemFont(ofSize: 20, weight: .semibold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // 4. Profile Glass Card
    private let profileGlassView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.contentView.backgroundColor = UIColor(white: 1, alpha: 0.05)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 1, alpha: 0.1).cgColor
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "avatar_placeholder") ?? UIImage(systemName: "person.crop.circle.fill")
        iv.tintColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 35
        iv.clipsToBounds = true
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        return iv
    }()

    // Family Name (Top)
    private let familyLabel: UILabel = {
        let label = UILabel()
        label.text = "Happy Home"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0) // Light Blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "David Johnson"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Role Label
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.text = "Parent"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let editProfileButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor(white: 1, alpha: 0.1)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // 5. Menu Stack
    private let menuStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 15
        stack.distribution = .fill
        return stack
    }()

    // MARK: - Init & Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupLayout()
        addMenuItems()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // Ensure Tab Bar is VISIBLE
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Gradient Setup
    private func setupGradient() {
        let colorTop = UIColor(red: 0x0C/255.0, green: 0x0C/255.0, blue: 0x0C/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 0x20/255.0, green: 0x3B/255.0, blue: 0x6F/255.0, alpha: 1.0).cgColor
        
        backgroundGradientLayer.colors = [colorTop, colorBottom]
        backgroundGradientLayer.locations = [0.0, 1.0]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        fullBackgroundView.layer.addSublayer(backgroundGradientLayer)
    }

    // MARK: - Layout Setup
    private func setupLayout() {
        view.addSubview(fullBackgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerContainer)
        headerContainer.addSubview(backButton)
        headerContainer.addSubview(headerTitle)
        
        // Profile Section
        contentView.addSubview(profileGlassView)
        profileGlassView.contentView.addSubview(avatarImageView)
        profileGlassView.contentView.addSubview(familyLabel)
        profileGlassView.contentView.addSubview(nameLabel)
        profileGlassView.contentView.addSubview(roleLabel)
        profileGlassView.contentView.addSubview(editProfileButton)
        
        contentView.addSubview(menuStackView)
        
        NSLayoutConstraint.activate([
            // Background
            fullBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            fullBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fullBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fullBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Header
            headerContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            headerContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            headerContainer.heightAnchor.constraint(equalToConstant: 50),
            
            backButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            headerTitle.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            headerTitle.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            
            // Profile Glass Card
            profileGlassView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 30),
            profileGlassView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileGlassView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            profileGlassView.heightAnchor.constraint(equalToConstant: 110),
            
            // Avatar
            avatarImageView.leadingAnchor.constraint(equalTo: profileGlassView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: profileGlassView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Family Name (Top)
            familyLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            familyLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 4),
            
            // Name (Middle)
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: familyLabel.bottomAnchor, constant: 2),
            nameLabel.trailingAnchor.constraint(equalTo: editProfileButton.leadingAnchor, constant: -8),
            
            // Role (Bottom)
            roleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            
            // Edit Button
            editProfileButton.trailingAnchor.constraint(equalTo: profileGlassView.trailingAnchor, constant: -16),
            editProfileButton.centerYAnchor.constraint(equalTo: profileGlassView.centerYAnchor),
            editProfileButton.widthAnchor.constraint(equalToConstant: 34),
            editProfileButton.heightAnchor.constraint(equalToConstant: 34),
            
            // Menu Stack
            menuStackView.topAnchor.constraint(equalTo: profileGlassView.bottomAnchor, constant: 30),
            menuStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            menuStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            menuStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    // MARK: - Menu Setup
    private func addMenuItems() {
        let items: [(title: String, icon: String)] = [
            ("Family", "person.2"),
            ("Account", "person.circle"),
            ("Password & Security", "lock.fill"), // FIXED: Changed to "lock.fill"
            ("Privacy & Policy", "hand.raised")
        ]
        
        for item in items {
            let row = createGlassMenuRow(title: item.title, icon: item.icon, isDestructive: false)
            menuStackView.addArrangedSubview(row)
            
            row.isUserInteractionEnabled = true
            if item.title == "Family" {
                let tap = UITapGestureRecognizer(target: self, action: #selector(familyTapped))
                row.addGestureRecognizer(tap)
            } else if item.title == "Account" {
                let tap = UITapGestureRecognizer(target: self, action: #selector(accountTapped))
                row.addGestureRecognizer(tap)
            }
        }
        
        // Logout
        let logoutRow = createGlassMenuRow(title: "Logout", icon: "rectangle.portrait.and.arrow.right", isDestructive: true)
        logoutRow.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLogout))
        logoutRow.addGestureRecognizer(tapGesture)
        menuStackView.addArrangedSubview(logoutRow)
    }
    
    // Glassmorphism Row Builder
    private func createGlassMenuRow(title: String, icon: String, isDestructive: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true
        container.backgroundColor = UIColor(white: 1, alpha: 0.05)
        container.layer.cornerRadius = 20
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(white: 1, alpha: 0.1).cgColor
        
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = UIColor(white: 1, alpha: 0.1)
        iconContainer.layer.cornerRadius = 18
        
        let iconImg = UIImageView()
        iconImg.translatesAutoresizingMaskIntoConstraints = false
        iconImg.image = UIImage(systemName: icon)
        iconImg.tintColor = isDestructive ? .systemRed : .white
        iconImg.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = isDestructive ? .systemRed : .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let chevron = UIImageView()
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        chevron.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        chevron.tintColor = UIColor(white: 0.6, alpha: 1.0)
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconContainer)
        iconContainer.addSubview(iconImg)
        container.addSubview(label)
        container.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 36),
            iconContainer.heightAnchor.constraint(equalToConstant: 36),
            
            iconImg.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImg.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImg.widthAnchor.constraint(equalToConstant: 18),
            iconImg.heightAnchor.constraint(equalToConstant: 18),
            
            label.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        return container
    }
    
    // MARK: - Actions Setup
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        editProfileButton.addTarget(self, action: #selector(editAvatarTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editAvatarTapped))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Action Handlers
    
    @objc private func backButtonTapped() {
        if let navigationController = navigationController,
           navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func familyTapped() {
        let vc = ParentProfileMembers()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func accountTapped() {
        let vc = AccountViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func editAvatarTapped() {
        print("Edit Avatar Tapped")
    }
    
    @objc private func handleLogout() {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
    }
}
