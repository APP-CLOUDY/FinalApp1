import UIKit

class ChildMembersView: UIViewController {

    // MARK: - UI Components
    
    private let backgroundGradientLayer = CAGradientLayer()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        btn.setImage(image, for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let headerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Family"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        
        setupHeader()
        setupLayout()
        setupContent()
        setupActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }
    
    // MARK: - Setup UI
    
    private func setupBackgroundGradient() {
        let topColor = UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1.0)
        let bottomColor = UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1.0)
        
        backgroundGradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        backgroundGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }
    
    private func setupHeader() {
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(headerTitleLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            headerTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerTitleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -40),
            
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }
    
    private func setupContent() {
        // 1. Parents
        let parentsSection = createSection(title: "Parents")
        let momCard = createMemberCard(
            avatarName: "person.crop.circle.badge.checkmark",
            name: "Ridu Mom",
            role: "Mom",
            code: nil
        )
        parentsSection.addArrangedSubview(momCard)
        stackView.addArrangedSubview(parentsSection)
        
        // 2. Children
        let childrenSection = createSection(title: "Children")
        
        let child1 = createMemberCard(
            avatarName: "person.crop.circle.fill",
            name: "Jonesh",
            role: "Chore Captain",
            code: "Code: 32456"
        )
        
        let child2 = createMemberCard(
            avatarName: "person.crop.circle",
            name: "Riduvarshini",
            role: "Chore champion",
            code: "Code: 33501"
        )
        
        childrenSection.addArrangedSubview(child1)
        childrenSection.addArrangedSubview(child2)
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
    }
    
    // MARK: - Helper Methods
    
    private func createSection(title: String) -> UIStackView {
        let sectionStack = UIStackView()
        sectionStack.axis = .vertical
        sectionStack.spacing = 10
        
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        
        sectionStack.addArrangedSubview(label)
        return sectionStack
    }
    
    private func createMemberCard(avatarName: String, name: String, role: String, code: String?) -> UIView {
        // NOTE: Ensure your existing class is named 'GradientCardView'.
        // If your previous file uses 'GgradientCardView' (with two G's), change this line below to match it.
        let card = GgradientCardView()
        card.setCornerRadius(16)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        let avatarView = UIImageView()
        avatarView.image = UIImage(named: avatarName) ?? UIImage(systemName: avatarName)
        avatarView.contentMode = .scaleAspectFit
        avatarView.tintColor = UIColor(red: 255/255, green: 200/255, blue: 150/255, alpha: 1.0)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.layer.shadowColor = UIColor.black.cgColor
        avatarView.layer.shadowOpacity = 0.3
        avatarView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 17, weight: .bold)
        
        let roleLabel = UILabel()
        roleLabel.text = role
        roleLabel.textColor = UIColor.lightGray
        roleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, roleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        if let codeText = code {
            let codeLabel = UILabel()
            codeLabel.text = codeText
            codeLabel.textColor = UIColor(red: 80/255, green: 150/255, blue: 255/255, alpha: 1.0)
            codeLabel.font = .systemFont(ofSize: 13, weight: .medium)
            textStack.addArrangedSubview(codeLabel)
        }
        
        card.addSubview(avatarView)
        card.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            
            textStack.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
        ])
        
        return card
    }
    
    // MARK: - Actions
    
    @objc private func handleBack() {
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
