import UIKit

class ParentProfileMembers: UIViewController {

    // MARK: - Data
    private var currentFamilyId: UUID?
    private var members: [FamilyMemberDisplay] = []

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
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // ✅ Specific Stacks for Sections
    private let parentsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 12
        return s
    }()
    
    private let childrenStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 12
        return s
    }()
    
    private let familyNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.textColor = UIColor.lightGray
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addMemberButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add Family Member", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        btn.backgroundColor = UIColor(red: 55/255, green: 115/255, blue: 250/255, alpha: 1.0)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        setupHeader()
        setupLayout()
        setupStaticContent() // IMPORTANT: This adds the stacks to the view
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFamilyData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }
    
    // MARK: - Data Loading
    
    private func loadFamilyData() {
        loadingIndicator.startAnimating()
        
        _Concurrency.Task {
            do {
                let family = try await FamilyService.shared.fetchCurrentFamily()
                self.currentFamilyId = family.id
                
                let fetchedMembers = try await FamilyService.shared.fetchFamilyMembers(familyId: family.id)
                self.members = fetchedMembers
                
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.familyNameLabel.text = family.family_name
                    self.familyNameLabel.textColor = .white
                    
                    // Trigger UI Update
                    self.renderMembers()
                }
            } catch {
                print("❌ ERROR in VC: \(error)")
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.familyNameLabel.text = "Error loading"
                }
            }
        }
    }
    
    private func renderMembers() {
        print("🎨 UI RENDER: Starting to render members...")
        
        // 1. Clear existing views
        parentsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        childrenStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 2. Filter
        let parents = members.filter { $0.type == .parent }
        let children = members.filter { $0.type == .child }
        
        print("🎨 UI RENDER: Adding \(parents.count) parents and \(children.count) children")
        
        // 3. Add Parent Cards
        for p in parents {
            let card = createMemberCard(member: p)
            parentsStack.addArrangedSubview(card)
        }
        
        // 4. Add Child Cards
        for c in children {
            let card = createMemberCard(member: c)
            childrenStack.addArrangedSubview(card)
        }
        
        // 5. Force layout update
        self.view.layoutIfNeeded()
    }

    // MARK: - Setup Methods
    
    private func setupStaticContent() {
        // Family Name
        let famSection = createSectionLabel(title: "Family Name")
        mainStackView.addArrangedSubview(famSection)
        let famCard = createFamilyNameCard()
        mainStackView.addArrangedSubview(famCard)
        
        // Parents
        let pSection = createSectionLabel(title: "Parents")
        mainStackView.addArrangedSubview(pSection)
        mainStackView.addArrangedSubview(parentsStack) // ✅ Ensuring stack is added
        
        // Children
        let cSection = createSectionLabel(title: "Children")
        mainStackView.addArrangedSubview(cSection)
        mainStackView.addArrangedSubview(childrenStack) // ✅ Ensuring stack is added
        
        // Spacer & Button
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        mainStackView.addArrangedSubview(spacer)
        
        mainStackView.addArrangedSubview(addMemberButton)
        addMemberButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }
    
    private func setupBackgroundGradient() {
        let topColor = UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1.0)
        let bottomColor = UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1.0)
        backgroundGradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        backgroundGradientLayer.frame = view.bounds
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
        scrollView.addSubview(mainStackView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -40),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        addMemberButton.addTarget(self, action: #selector(handleAddMember), for: .touchUpInside)
    }
    
    // MARK: - Helpers
    
    private func createSectionLabel(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }
    
    private func createFamilyNameCard() -> UIView {
        let container = GlassCardView()
        container.setCornerRadius(12)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        let pencilIcon = UIImageView(image: UIImage(systemName: "pencil"))
        pencilIcon.tintColor = .white
        pencilIcon.contentMode = .scaleAspectFit
        pencilIcon.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(familyNameLabel)
        container.addSubview(pencilIcon)
        
        NSLayoutConstraint.activate([
            familyNameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            familyNameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            familyNameLabel.trailingAnchor.constraint(equalTo: pencilIcon.leadingAnchor, constant: -10),
            pencilIcon.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            pencilIcon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            pencilIcon.widthAnchor.constraint(equalToConstant: 20),
            pencilIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleEditFamilyName))
        container.addGestureRecognizer(tap)
        return container
    }
    
    private func createMemberCard(member: FamilyMemberDisplay) -> UIView {
        let card = GlassCardView()
        card.setCornerRadius(16)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        // Avatar
        let avatarView = UIImageView()
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 25
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        if let url = member.avatarUrl, !url.isEmpty {
            avatarView.loadImage(from: url)
        } else {
            avatarView.image = UIImage(systemName: "person.crop.circle.fill")
            avatarView.tintColor = .lightGray
        }
        
        // Text
        let nameLabel = UILabel()
        nameLabel.text = member.name
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 17, weight: .bold)
        
        let roleLabel = UILabel()
        roleLabel.text = member.role
        roleLabel.textColor = UIColor.lightGray
        roleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, roleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(avatarView)
        card.addSubview(textStack)
        
        // Code Logic
        if let code = member.joinCode {
            let codeLabel = UILabel()
            codeLabel.text = code
            codeLabel.textColor = UIColor(red: 100/255, green: 180/255, blue: 255/255, alpha: 1.0)
            codeLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            codeLabel.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(codeLabel)
            
            NSLayoutConstraint.activate([
                codeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
                codeLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                textStack.trailingAnchor.constraint(lessThanOrEqualTo: codeLabel.leadingAnchor, constant: -10)
            ])
        } else {
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16).isActive = true
        }
        
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            
            textStack.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        
        return card
    }
    
    // MARK: - Handlers
    
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleAddMember() {
        let vc = AddFamilyMembersViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func handleEditFamilyName() {
        let alert = UIAlertController(title: "Edit Family Name", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.text = self.familyNameLabel.text
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            guard let newName = alert.textFields?.first?.text, !newName.isEmpty, let id = self.currentFamilyId else { return }
            _Concurrency.Task {
                do {
                    try await FamilyService.shared.updateFamilyName(id: id, newName: newName)
                    await MainActor.run { self.familyNameLabel.text = newName }
                } catch { print("Update failed: \(error)") }
            }
        }))
        present(alert, animated: true)
    }
}
