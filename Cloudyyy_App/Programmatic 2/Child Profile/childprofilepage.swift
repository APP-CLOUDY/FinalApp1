import UIKit

class ProfileViewController: UIViewController {

    // MARK: - Properties
    private let backgroundGradientLayer = CAGradientLayer()
    
    // MARK: - UI Components

    // 1. Full Screen Background
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
    
    private lazy var backButton: UIButton = {
        ChildBackButtonFactory.make(target: self, action: #selector(handleBack))
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
        iv.image = UIImage(systemName: "person.crop.circle.fill")
        iv.tintColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 35
        iv.clipsToBounds = true
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0) // Gold Color
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
        
        // Initial Fetch
        fetchProfileData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
        
        // Fetch every time we appear to keep data fresh
        fetchProfileData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    // MARK: - Backend Logic (✅ UPDATED FOR CHILD)
    
    // In ProfileViewController.swift

        private func fetchProfileData() {
            _Concurrency.Task {
                do {
                    let child = try await ProfileService.shared.fetchChildProfile()
                    
                    await MainActor.run {
                        // 1. Name (Always show the real name)
                        self.nameLabel.text = child.name
                        
                        // 2. Role (Show Nickname as the Fun Title)
                        // If nickname is empty, default to "Chore Champion"
                        if let roleTitle = child.nickname, !roleTitle.isEmpty {
                            self.roleLabel.text = roleTitle
                        } else {
                            self.roleLabel.text = "Chore Champion"
                        }
                        
                        // 3. Avatar (From Child Bucket)
                        let avatarName = child.avatar_url ?? "tiger.png"
                        let urlString = ProfileService.shared.getChildAvatarURL(fileName: avatarName)
                        
                        if let url = URL(string: urlString) {
                            self.downloadImage(from: url)
                        }
                    }
                } catch {
                    print("❌ Error fetching child profile: \(error)")
                    await MainActor.run {
                        self.nameLabel.text = "Kid"
                        self.roleLabel.text = "..."
                        self.avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
                    }
                }
            }
        }
    // Internal Image Downloader
    private func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
            }
        }.resume()
    }

    // MARK: - UI Setup
    private func setupGradient() {
        let colorTop = UIColor(red: 0x0C/255.0, green: 0x0C/255.0, blue: 0x0C/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 0x20/255.0, green: 0x3B/255.0, blue: 0x6F/255.0, alpha: 1.0).cgColor
        backgroundGradientLayer.colors = [colorTop, colorBottom]
        backgroundGradientLayer.locations = [0.0, 1.0]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        fullBackgroundView.layer.addSublayer(backgroundGradientLayer)
    }

    private func setupLayout() {
        view.addSubview(fullBackgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerContainer)
        headerContainer.addSubview(backButton)
        headerContainer.addSubview(headerTitle)
        
        contentView.addSubview(profileGlassView)
        profileGlassView.contentView.addSubview(avatarImageView)
        
        profileGlassView.contentView.addSubview(nameLabel)
        profileGlassView.contentView.addSubview(roleLabel)
        profileGlassView.contentView.addSubview(editProfileButton)
        
        contentView.addSubview(menuStackView)
        
        NSLayoutConstraint.activate([
            fullBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            fullBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fullBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fullBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            headerContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            headerContainer.heightAnchor.constraint(equalToConstant: 50),
            
            backButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            headerTitle.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            headerTitle.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            
            // Profile Card
            profileGlassView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 30),
            profileGlassView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileGlassView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            profileGlassView.heightAnchor.constraint(equalToConstant: 110),
            
            avatarImageView.leadingAnchor.constraint(equalTo: profileGlassView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: profileGlassView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: editProfileButton.leadingAnchor, constant: -8),
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor, constant: -12),
            
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            
            editProfileButton.trailingAnchor.constraint(equalTo: profileGlassView.trailingAnchor, constant: -16),
            editProfileButton.centerYAnchor.constraint(equalTo: profileGlassView.centerYAnchor),
            editProfileButton.widthAnchor.constraint(equalToConstant: 34),
            editProfileButton.heightAnchor.constraint(equalToConstant: 34),
            
            menuStackView.topAnchor.constraint(equalTo: profileGlassView.bottomAnchor, constant: 30),
            menuStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            menuStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            menuStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    // MARK: - Menu Setup
    private func addMenuItems() {
        let items: [(title: String, icon: String)] = [
            ("Family Members", "person.2.fill"),
            ("Account", "person.crop.circle"),
            ("Privacy Policy & Terms", "hand.raised.fill")
        ]
        
        for item in items {
            let row = createGlassMenuRow(title: item.title, icon: item.icon, isDestructive: false)
            menuStackView.addArrangedSubview(row)
            
            row.isUserInteractionEnabled = true
            if item.title == "Family Members" {
                row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFamilyMembers)))
            } else if item.title == "Account" {
                row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAccount)))
            } else if item.title == "Privacy Policy & Terms" {
                row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePrivacy)))
            }
        }
        
        let logoutRow = createGlassMenuRow(title: "Logout", icon: "rectangle.portrait.and.arrow.right", isDestructive: true)
        logoutRow.isUserInteractionEnabled = true
        logoutRow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogout)))
        menuStackView.addArrangedSubview(logoutRow)
    }
    
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
        chevron.image = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
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
    
    // MARK: - Actions
    private func setupActions() {
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        editProfileButton.addTarget(self, action: #selector(editAvatarTapped), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(editAvatarTapped))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tap)
    }
    
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func editAvatarTapped() {
        // ✅ Uses the new Child-specific avatar picker
        let vc = ChildAvatarSelectViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func handleFamilyMembers() {
        let childMembersVC = ChildMembersView()
        navigationController?.pushViewController(childMembersVC, animated: true)
    }
    
    @objc private func handleAccount() {
        let accountVC = ChildAccountViewController()
        navigationController?.pushViewController(accountVC, animated: true)
    }

    @objc private func handlePrivacy() {
        showLegalDocuments(initialDocument: .privacyPolicy)
    }
    
    @objc private func handleLogout() {
        let popup = ChildLogoutPopupViewController()
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        
        popup.onLogoutConfirmed = { [weak self] in
            guard let self = self else { return }
            _Concurrency.Task {
                do {
                    try await ProfileService.shared.signOut()
                    
                    await MainActor.run {
                        if let window = self.view.window {
                            let authVC = SelectUserViewController()
                            let nav = UINavigationController(rootViewController: authVC)
                            nav.isNavigationBarHidden = true
                            window.rootViewController = nav
                            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
                        }
                    }
                } catch {
                    print("Logout Failed: \(error)")
                }
            }
        }
        
        present(popup, animated: true)
    }
}
