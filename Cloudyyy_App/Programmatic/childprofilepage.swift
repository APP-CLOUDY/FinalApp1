import UIKit

class ProfileViewController: UIViewController {

    // MARK: - UI Components
    
    // The blue header
    private let blueHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Avatar and Name
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "ridu_mom_avatar") ?? UIImage(systemName: "person.fill")
        iv.tintColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 60 // Half of 120
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 4
        return iv
    }()
    
    private let editAvatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .darkGray.withAlphaComponent(0.8)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15 // Half of 30
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Ridu Mom" // Kept as "Ridu Mom"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black // On white background
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        // --- UPDATED: Text changed ---
        label.text = "Chore Champion"
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Main Card
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top-left and Top-right
        
        view.clipsToBounds = true
        // Add shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowRadius = 10
        view.layer.masksToBounds = false // Allow shadow to show
        return view
    }()
    
    // This view holds the stack view to enforce the corner radius
    private let cardContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white

        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        view.clipsToBounds = true
        return view
    }()
    
    // Menu
    private let menuStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 40 // More space between items
        stack.distribution = .fill // Let items size naturally
        return stack
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupLayout()
        addMenuItems()
    }
    
    // Set status bar to light
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Setup Functions

    private func setupNavigationBar() {
        self.title = "Happy Home"
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        let backItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backItem

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBlue // Match the header
        
        // Title font size
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 24, weight: .bold)]
        
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupLayout() {
        view.addSubview(blueHeaderView)
        view.addSubview(avatarImageView)
        view.addSubview(editAvatarButton)
        view.addSubview(nameLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(cardView)
        cardView.addSubview(cardContentView) // Add content view inside card
        cardContentView.addSubview(menuStackView)

        NSLayoutConstraint.activate([
            // Blue Header
            blueHeaderView.topAnchor.constraint(equalTo: view.topAnchor), // To very top
            blueHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blueHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blueHeaderView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3), // 30% of screen
            
            // Avatar
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: blueHeaderView.bottomAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Edit Button
            editAvatarButton.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: -5),
            editAvatarButton.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: -5),
            editAvatarButton.widthAnchor.constraint(equalToConstant: 30),
            editAvatarButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Labels (below avatar)
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Card
            cardView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Card Content View (for clipping)
            cardContentView.topAnchor.constraint(equalTo: cardView.topAnchor),
            cardContentView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            cardContentView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            cardContentView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            
            // Menu Stack inside Card
            menuStackView.topAnchor.constraint(equalTo: cardContentView.topAnchor, constant: 30),
            menuStackView.leadingAnchor.constraint(equalTo: cardContentView.leadingAnchor, constant: 24),
            menuStackView.trailingAnchor.constraint(equalTo: cardContentView.trailingAnchor, constant: -24),
        ])
    }
    
    private func addMenuItems() {
        // --- UPDATED: Text changed ---
        let familyRow = createMenuRow(title: "Family Members", isDestructive: false)
        let accountRow = createMenuRow(title: "Account", isDestructive: false)
        let policyRow = createMenuRow(title: "Privacy and Policy", isDestructive: false)
        let logoutRow = createMenuRow(title: "Logout", isDestructive: true)
        
        menuStackView.addArrangedSubview(familyRow)
        menuStackView.addArrangedSubview(accountRow)
        menuStackView.addArrangedSubview(policyRow)
        menuStackView.addArrangedSubview(logoutRow)
    }

    // MARK: - Helper Function
    
    private func createMenuRow(title: String, isDestructive: Bool) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 19, weight: .medium) // Using medium weight
        label.textColor = isDestructive ? .systemRed : .black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let chevron = UIImageView()
        let chevronConfig = UIImage.SymbolConfiguration(weight: .medium) // Lighter chevron
        chevron.image = UIImage(systemName: "chevron.right", withConfiguration: chevronConfig)
        chevron.tintColor = .systemGray
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        view.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            chevron.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chevron.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 14),
            chevron.heightAnchor.constraint(equalToConstant: 14),
            
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
