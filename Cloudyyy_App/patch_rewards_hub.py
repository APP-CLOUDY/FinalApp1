import sys

file_path = "Programmatic 2/Child  2/Rewrads 2/RewardsHubViewController.swift"
with open(file_path, 'r') as f:
    content = f.read()

# Add profileAvatarButton
target1 = """    private let headerTitle: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Rewards Hub"
        l.font = .systemFont(ofSize: 30, weight: .bold)
        l.textColor = .white
        return l
    }()"""

replacement1 = """    private let headerTitle: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Rewards Hub"
        l.font = .systemFont(ofSize: 30, weight: .bold)
        l.textColor = .white
        return l
    }()
    
    private let profileAvatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        button.setImage(UIImage(systemName: "person.circle.fill", withConfiguration: config), for: .normal)
        return button
    }()"""

content = content.replace(target1, replacement1)

# Add didTapProfileButton
target2 = """    @objc private func refreshRewards() {
        Task {
            await loadRewardsHomeData()
        }
    }"""

replacement2 = """    @objc private func refreshRewards() {
        Task {
            await loadRewardsHomeData()
        }
    }
    
    @objc private func didTapProfileButton() {
        let profileVC = ProfileViewController()
        profileVC.hidesBottomBarWhenPushed = true
        if let nav = navigationController {
            nav.pushViewController(profileVC, animated: true)
        } else {
            present(profileVC, animated: true)
        }
    }"""

content = content.replace(target2, replacement2)

# Add to view hierarchy
target3 = """        view.addSubview(headerContainer)
        
        headerContainer.addSubview(headerTitle)
        headerContainer.addSubview(coinBadgeView)"""

replacement3 = """        view.addSubview(headerContainer)
        
        headerContainer.addSubview(headerTitle)
        headerContainer.addSubview(coinBadgeView)
        headerContainer.addSubview(profileAvatarButton)"""

content = content.replace(target3, replacement3)

# Update constraints
target4 = """            // TITLE
            headerTitle.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            headerTitle.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 16),
            
            // COIN BADGE
            coinBadgeView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
            coinBadgeView.centerYAnchor.constraint(equalTo: headerTitle.centerYAnchor),
            coinBadgeView.heightAnchor.constraint(equalToConstant: 25),
            coinBadgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),"""

replacement4 = """            // TITLE
            headerTitle.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            headerTitle.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 16),
            
            // PROFILE BUTTON
            profileAvatarButton.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
            profileAvatarButton.centerYAnchor.constraint(equalTo: headerTitle.centerYAnchor),
            profileAvatarButton.widthAnchor.constraint(equalToConstant: 44),
            profileAvatarButton.heightAnchor.constraint(equalToConstant: 44),
            
            // COIN BADGE
            coinBadgeView.trailingAnchor.constraint(equalTo: profileAvatarButton.leadingAnchor, constant: -16),
            coinBadgeView.centerYAnchor.constraint(equalTo: headerTitle.centerYAnchor),
            coinBadgeView.heightAnchor.constraint(equalToConstant: 25),
            coinBadgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),"""

content = content.replace(target4, replacement4)

# Setup Actions
target5 = """    private func setupActions() {
        leftSegment.addTarget(self, action: #selector(selectLeft), for: .touchUpInside)
        rightSegment.addTarget(self, action: #selector(selectRight), for: .touchUpInside)
    }"""

replacement5 = """    private func setupActions() {
        leftSegment.addTarget(self, action: #selector(selectLeft), for: .touchUpInside)
        rightSegment.addTarget(self, action: #selector(selectRight), for: .touchUpInside)
        profileAvatarButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)
    }"""

content = content.replace(target5, replacement5)

with open(file_path, 'w') as f:
    f.write(content)
