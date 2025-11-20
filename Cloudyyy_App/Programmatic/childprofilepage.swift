import UIKit

class ProfileViewController: UIViewController {

    // MARK: - UI Components

    // 1. Fixed Blue Header Background (Sits behind ScrollView for the "Bounce" effect)
    private let fixedBlueBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 2. ScrollView
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.backgroundColor = .clear // Transparent so we see the backgrounds behind it
        return sv
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    // 3. Header Content (Title & Back Button)
    private let headerContentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear // Transparent, lets fixedBlueBackground show through
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let headerTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Happy Home"
        lbl.font = .systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // 4. White Sheet (The main background for the profile)
    private let whiteSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    // 5. Avatar Components
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "ridu_mom_avatar") ?? UIImage(systemName: "person.fill")
        iv.tintColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 60
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        // Thicker border to match reference
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 6
        return iv
    }()

    private let editAvatarButton: UIButton = {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        button.setImage(UIImage(systemName: "pencil", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.9)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 18
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3
        return button
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Ridu"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Chore Champion"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 6. Menu Card Container (The "Floating" Card effect)
    private let menuCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white // Or very light gray like .systemGray6 if preferred
        view.layer.cornerRadius = 24
        
        // Add Shadow to create the card look
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08 // Soft shadow
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()

    private let menuStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fill
        return stack
    }()

    // MARK: - Lifecycle & Init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        hidesBottomBarWhenPushed = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set MAIN view to white. This fixes the bottom area being blue.
        view.backgroundColor = .white
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupLayout()
        addMenuItems()
        
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Layout Setup
    private func setupLayout() {
        // 1. Add Fixed Blue Header (Pinned to View, not ScrollView)
        view.addSubview(fixedBlueBackground)
        
        // 2. Add ScrollView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 3. Content View Hierarchy
        contentView.addSubview(headerContentContainer)
        headerContentContainer.addSubview(backButton)
        headerContentContainer.addSubview(headerTitle)
        
        contentView.addSubview(whiteSheetView)
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(editAvatarButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(subtitleLabel)
        
        contentView.addSubview(menuCardView)       // Add Card
        menuCardView.addSubview(menuStackView)     // Add Stack INSIDE Card
        
        NSLayoutConstraint.activate([
            // --- 1. Fixed Blue Background ---
            // Pinned to top, left, right. Height covers the top area + bounce.
            fixedBlueBackground.topAnchor.constraint(equalTo: view.topAnchor),
            fixedBlueBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fixedBlueBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fixedBlueBackground.heightAnchor.constraint(equalToConstant: 300), // Enough to cover header
            
            // --- 2. ScrollView ---
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // --- 3. ContentView ---
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            // IMPORTANT: Ensure contentView is at least as tall as the screen to prevent blue background showing at bottom
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),
            
            // --- 4. Header Content ---
            headerContentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerContentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerContentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerContentContainer.heightAnchor.constraint(equalToConstant: 180),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: headerContentContainer.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            headerTitle.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            headerTitle.centerXAnchor.constraint(equalTo: headerContentContainer.centerXAnchor),
            
            // --- 5. White Sheet ---
            whiteSheetView.topAnchor.constraint(equalTo: headerContentContainer.bottomAnchor, constant: -50),
            whiteSheetView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            whiteSheetView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            // This extends the white sheet all the way to the bottom of the content
            whiteSheetView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // --- 6. Avatar ---
            avatarImageView.centerYAnchor.constraint(equalTo: whiteSheetView.topAnchor),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            
            editAvatarButton.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 0),
            editAvatarButton.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: -4),
            editAvatarButton.widthAnchor.constraint(equalToConstant: 36),
            editAvatarButton.heightAnchor.constraint(equalToConstant: 36),
            
            // --- 7. Labels ---
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // --- 8. Menu Card ---
            menuCardView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            menuCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            menuCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            // No bottom constraint to ContentView here; content view grows with stack
            
            // Stack inside Card
            menuStackView.topAnchor.constraint(equalTo: menuCardView.topAnchor, constant: 20),
            menuStackView.leadingAnchor.constraint(equalTo: menuCardView.leadingAnchor, constant: 20),
            menuStackView.trailingAnchor.constraint(equalTo: menuCardView.trailingAnchor, constant: -20),
            menuStackView.bottomAnchor.constraint(equalTo: menuCardView.bottomAnchor, constant: -20),
            
            // Final Vertical Constraint
            // This ensures the content view stretches to fit the menu card, plus some bottom padding
            menuCardView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -50)
        ])
    }

    // MARK: - Menu Setup
    private func addMenuItems() {
        let items = ["Family Members", "Account", "Privacy and Policy"]
        
        for title in items {
            let row = createMenuRow(title: title, isDestructive: false)
            menuStackView.addArrangedSubview(row)
        }
        
        let logoutRow = createMenuRow(title: "Logout", isDestructive: true)
        logoutRow.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLogout))
        logoutRow.addGestureRecognizer(tapGesture)
        
        menuStackView.addArrangedSubview(logoutRow)
    }
    
    private func createMenuRow(title: String, isDestructive: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 56).isActive = true // Slightly shorter rows for card look
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = isDestructive ? .systemRed : .black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let chevron = UIImageView()
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        chevron.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        chevron.tintColor = UIColor(white: 0.8, alpha: 1.0)
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        container.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 14),
            chevron.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        return container
    }
    
    // MARK: - Actions
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleLogout() {
        let selectUserVC = SelectUserViewController()
        let newNavController = UINavigationController(rootViewController: selectUserVC)
        newNavController.isNavigationBarHidden = true
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = newNavController
            }, completion: nil)
        }
    }
}
