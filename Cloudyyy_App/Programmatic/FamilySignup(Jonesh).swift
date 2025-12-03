import UIKit

// --- Custom Gradient View (For Cards) ---
class GradientCardView: UIView {
    private let gradientLayer = CAGradientLayer()
    private let startColor = UIColor(red: 50/255, green: 60/255, blue: 85/255, alpha: 1.0)
    private let endColor = UIColor(red: 40/255, green: 50/255, blue: 75/255, alpha: 1.0)

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

// --- Main Controller ---
class FamilyViewController: UIViewController {

    private let darkBlueBackground = UIColor(red: 20/255, green: 25/255, blue: 40/255, alpha: 1.0)

    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search"
        sb.backgroundImage = UIImage()
        sb.searchTextField.backgroundColor = UIColor(red: 40/255, green: 50/255, blue: 75/255, alpha: 1.0)
        sb.searchTextField.textColor = .white
        sb.searchTextField.layer.cornerRadius = 18
        sb.searchTextField.layer.masksToBounds = true
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    private let familyNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Family Name"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let familyNameContainer: GradientCardView = {
        let view = GradientCardView()
        view.setCornerRadius(10)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let familyNameTextField: UITextField = {
        let tf = UITextField()
        tf.text = "Loading..."
        tf.textColor = .white
        tf.borderStyle = .none
        tf.backgroundColor = .clear
        tf.isUserInteractionEnabled = false
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let parentsLabel: UILabel = {
        let label = UILabel()
        label.text = "Parents"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let parentsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let childrenLabel: UILabel = {
        let label = UILabel()
        label.text = "Children"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let childrenStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // BUTTON 1: Add Child
    private let addChildButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Child", for: .normal)
        button.setTitleColor(.white, for: .normal)
        // A slightly lighter blue/gray to differentiate from the primary "Done" button
        button.backgroundColor = UIColor(red: 60/255, green: 70/255, blue: 95/255, alpha: 1.0)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // BUTTON 2: Done (Primary Action)
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Gradient for the primary button
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0).cgColor,
            UIColor(red: 0/255, green: 180/255, blue: 255/255, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.name = "buttonGradient"
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        return button
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = darkBlueBackground
        setupUI()
        
        navigationItem.hidesBackButton = true
        
        addChildButton.addTarget(self, action: #selector(handleAddChild), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFamilyData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Resize gradient frame
        if let gradientLayer = doneButton.layer.sublayers?.first(where: { $0.name == "buttonGradient" }) as? CAGradientLayer {
            gradientLayer.frame = doneButton.bounds
        }
    }

    // MARK: - Data Fetching
    
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
        familyNameTextField.text = data.family_name
        
        parentsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for parent in data.parents {
            let card = createMemberCard(
                avatarImage: UIImage(systemName: "person.circle.fill")!,
                name: parent.first_name,
                subtitle1: parent.role.capitalized,
                subtitle2: nil
            )
            parentsStack.addArrangedSubview(card)
        }
        
        childrenStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for child in data.children {
            // Check for optional nickname safely
            let displaySubtitle = (child.nickname?.isEmpty == false) ? child.nickname! : "Child"
            
            let card = createMemberCard(
                avatarImage: UIImage(systemName: "face.smiling.fill")!,
                name: child.name,
                subtitle1: displaySubtitle,
                subtitle2: "Code: \(child.join_code)"
            )
            childrenStack.addArrangedSubview(card)
        }
    }

    // MARK: - Actions
    
    @objc private func handleAddChild() {
        // Navigate back to Add Child Form
        let vc = Addchildform()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func handleDone() {
        // Finish setup -> Go to Parent Dashboard
        // NOTE: Ensure 'ParentDashboardViewController' is defined in your project
        let dashboardVC = ParentDashboardViewController()
        
        // Use setViewControllers to reset the stack so they can't go back to setup screens
        navigationController?.setViewControllers([dashboardVC], animated: true)
    }

    // MARK: - UI Setup
    
    private func createMemberCard(avatarImage: UIImage, name: String, subtitle1: String, subtitle2: String?) -> UIView {
        let card = GradientCardView()
        card.setCornerRadius(16)
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let avatarView = UIImageView(image: avatarImage)
        avatarView.tintColor = .systemGray4
        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.cornerRadius = 30
        avatarView.clipsToBounds = true
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        let subtitle1Label = UILabel()
        subtitle1Label.text = subtitle1
        subtitle1Label.textColor = .systemGray
        subtitle1Label.font = .systemFont(ofSize: 14)
        
        let textStackView = UIStackView(arrangedSubviews: [nameLabel, subtitle1Label])
        textStackView.axis = .vertical
        textStackView.spacing = 4
        
        if let subtitle2 = subtitle2 {
            let subtitle2Label = UILabel()
            subtitle2Label.text = subtitle2
            subtitle2Label.textColor = UIColor(red: 100/255, green: 200/255, blue: 255/255, alpha: 1)
            subtitle2Label.font = .systemFont(ofSize: 14, weight: .bold)
            textStackView.addArrangedSubview(subtitle2Label)
        }
        
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(avatarView)
        card.addSubview(textStackView)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 92),
            
            avatarView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 60),
            avatarView.heightAnchor.constraint(equalToConstant: 60),
            
            textStackView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            textStackView.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        
        return card
    }

    private func setupUI() {
        view.addSubview(doneButton)
        view.addSubview(addChildButton)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(searchBar)
        contentView.addSubview(familyNameLabel)
        contentView.addSubview(familyNameContainer)
        familyNameContainer.addSubview(familyNameTextField)
        
        contentView.addSubview(parentsLabel)
        contentView.addSubview(parentsStack)
        
        contentView.addSubview(childrenLabel)
        contentView.addSubview(childrenStack)
        
        NSLayoutConstraint.activate([
            // 1. Done Button (Bottom)
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 2. Add Child Button (Above Done)
            addChildButton.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),
            addChildButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addChildButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addChildButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 3. ScrollView (Fills rest)
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: addChildButton.topAnchor, constant: -16),
            
            // 4. Content View
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Inner Content
            searchBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            familyNameLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            familyNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            familyNameContainer.topAnchor.constraint(equalTo: familyNameLabel.bottomAnchor, constant: 12),
            familyNameContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            familyNameContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            familyNameContainer.heightAnchor.constraint(equalToConstant: 50),
            
            familyNameTextField.centerYAnchor.constraint(equalTo: familyNameContainer.centerYAnchor),
            familyNameTextField.leadingAnchor.constraint(equalTo: familyNameContainer.leadingAnchor, constant: 16),
            familyNameTextField.trailingAnchor.constraint(equalTo: familyNameContainer.trailingAnchor, constant: -16),
            
            parentsLabel.topAnchor.constraint(equalTo: familyNameContainer.bottomAnchor, constant: 30),
            parentsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            parentsStack.topAnchor.constraint(equalTo: parentsLabel.bottomAnchor, constant: 12),
            parentsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            parentsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            childrenLabel.topAnchor.constraint(equalTo: parentsStack.bottomAnchor, constant: 30),
            childrenLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            childrenStack.topAnchor.constraint(equalTo: childrenLabel.bottomAnchor, constant: 12),
            childrenStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            childrenStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            childrenStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}
