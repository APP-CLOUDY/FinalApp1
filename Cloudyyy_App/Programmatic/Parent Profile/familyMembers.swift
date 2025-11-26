import UIKit

// MARK: - 1. Destination View Controller
// This is the screen you navigate to when clicking "Add Family Member"
//class AddFamilyMembersViewController: UIViewController {
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white // Set a background color so we can see the transition
//        title = "Add Family Members"
//        
//        // Simple label to confirm navigation worked
//        let label = UILabel()
//        label.text = "Add Members Screen"
//        label.center = view.center
//        label.sizeToFit()
//        view.addSubview(label)
//    }
//}

// MARK: - 2. Custom Gradient View (Card Background)
class GgradientCardView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    // Gradient colors: Top-left lighter -> Bottom-right darker
    private let startColor = UIColor(red: 50/255, green: 60/255, blue: 85/255, alpha: 1.0)
    private let endColor = UIColor(red: 35/255, green: 45/255, blue: 65/255, alpha: 1.0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Subtle border for definition
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
    }
}

// MARK: - 3. Main View Controller
class ParentProfileMembers: UIViewController {

    // MARK: - UI Components
    
    // 1. Background Gradient
    private let backgroundGradientLayer = CAGradientLayer()
    
    // 2. Custom Header Area
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
    
    // 3. ScrollView & Content
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
    
    // 4. Family Name Display
    private let familyDisplayLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter Family Name"
        label.textColor = UIColor.lightGray
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 5. Add Member Button
    private let addMemberButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add Family Member", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        // Custom Blue color matching the image
        btn.backgroundColor = UIColor(red: 55/255, green: 115/255, blue: 250/255, alpha: 1.0)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
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
        // 1. Family Name
        let familySection = createSection(title: "Family Name")
        let familyInputCard = createFamilyNameCard()
        familySection.addArrangedSubview(familyInputCard)
        stackView.addArrangedSubview(familySection)
        
        // 2. Parents
        let parentsSection = createSection(title: "Parents")
        let momCard = createMemberCard(
            avatarName: "person.crop.circle.badge.checkmark",
            name: "Ridu Mom",
            role: "Mom",
            code: nil
        )
        parentsSection.addArrangedSubview(momCard)
        stackView.addArrangedSubview(parentsSection)
        
        // 3. Children
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
        
        stackView.addArrangedSubview(childrenSection)
        
        // 4. Spacer
        let spacerView = UIView()
        spacerView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        stackView.addArrangedSubview(spacerView)
        
        // 5. Add Button
        stackView.addArrangedSubview(addMemberButton)
        addMemberButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        addMemberButton.addTarget(self, action: #selector(handleAddMember), for: .touchUpInside)
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
    
    private func createFamilyNameCard() -> UIView {
        let container = GgradientCardView()
        container.setCornerRadius(12)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        let pencilIcon = UIImageView(image: UIImage(systemName: "pencil"))
        pencilIcon.tintColor = .white
        pencilIcon.contentMode = .scaleAspectFit
        pencilIcon.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(familyDisplayLabel)
        container.addSubview(pencilIcon)
        
        NSLayoutConstraint.activate([
            familyDisplayLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            familyDisplayLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            familyDisplayLabel.trailingAnchor.constraint(equalTo: pencilIcon.leadingAnchor, constant: -10),
            
            pencilIcon.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            pencilIcon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            pencilIcon.widthAnchor.constraint(equalToConstant: 20),
            pencilIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleEditFamilyName))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        
        return container
    }
    
    private func createMemberCard(avatarName: String, name: String, role: String, code: String?) -> UIView {
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
    
    // --- UPDATED NAVIGATION LOGIC HERE ---
    @objc private func handleAddMember() {
        // 1. Create the new View Controller
        let addMemberVC = AddFamilyMembersViewController()
        
        // 2. Check if we are inside a Navigation Controller
        if let navigationController = navigationController {
            // Push (Slide)
            navigationController.pushViewController(addMemberVC, animated: true)
        } else {
            // Modal (Popup) - Use this if your App entry point isn't wrapped in a Nav Controller
            present(addMemberVC, animated: true, completion: nil)
        }
    }
    
    @objc private func handleEditFamilyName() {
        let alert = UIAlertController(title: "Edit Family Name", message: "Please enter your family name below.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Family Name"
            if self.familyDisplayLabel.text != "Enter Family Name" {
                textField.text = self.familyDisplayLabel.text
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let doneAction = UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                self.familyDisplayLabel.text = newName
                self.familyDisplayLabel.textColor = .white
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(doneAction)
        
        present(alert, animated: true, completion: nil)
    }
}
