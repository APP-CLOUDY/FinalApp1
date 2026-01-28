import UIKit
import Supabase

class ChildMembersView: UIViewController {

    // MARK: - Local Models
    struct FamilyMemberDisplay {
        let id: String
        let name: String
        let role: String
        let avatarUrl: String?
        let type: MemberType
        
        enum MemberType { case parent, child }
    }

    // MARK: - Data (THIS WAS MISSING)
    private var members: [FamilyMemberDisplay] = []

    // MARK: - UI Components
    private let backgroundGradientLayer = CAGradientLayer()
    private let headerView = UIView()
    private let backButton = UIButton(type: .system)
    private let headerTitleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let mainStackView = UIStackView()
    private let parentsStack = UIStackView()
    private let childrenStack = UIStackView()
    private let familyNameLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchFamilyData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }
    
    // MARK: - Data Fetching
    private func fetchFamilyData() {
        loadingIndicator.startAnimating()
        
        Task {
            do {
                let client = SupabaseManager.shared.client
                
                // 1. Get Current Child ID
                guard let childIdString = UserDefaults.standard.string(forKey: "current_child_id"),
                      let currentChildId = UUID(uuidString: childIdString) else {
                    throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No Child ID"])
                }

                // 2. Find Family ID via 'family_members' table
                struct MemberRow: Decodable { let family_id: UUID }
                
                let memberRes = try await client.database
                    .from("family_members")
                    .select("family_id")
                    .eq("child_id", value: currentChildId)
                    .limit(1)
                    .execute()
                
                let memberList = try JSONDecoder().decode([MemberRow].self, from: memberRes.data)
                guard let familyId = memberList.first?.family_id else {
                    print("❌ Child not found in family_members")
                    await MainActor.run {
                        self.familyNameLabel.text = "No Family Linked"
                        self.loadingIndicator.stopAnimating()
                    }
                    return
                }

                // 3. Fetch Family Name
                struct FamilyRes: Decodable { let family_name: String }
                let famRes = try await client.database
                    .from("families")
                    .select("family_name")
                    .eq("id", value: familyId)
                    .single()
                    .execute()
                let familyName = try JSONDecoder().decode(FamilyRes.self, from: famRes.data).family_name
                
                // 4. Fetch Members
                var displayMembers: [FamilyMemberDisplay] = []

                // A. Fetch Parents
                struct ParentJoinRow: Decodable {
                    struct UserProfile: Decodable {
                        let id: UUID
                        let first_name: String?
                        let role: String?
                        let avatar_id: String?
                    }
                    let users: UserProfile?
                }
                
                let parentRes = try await client.database
                    .from("family_members")
                    .select("users:users(*)")
                    .eq("family_id", value: familyId)
                    .not("user_id", operator: .is, value: "null")
                    .execute()
                
                let parentRows = try JSONDecoder().decode([ParentJoinRow].self, from: parentRes.data)
                
                for row in parentRows {
                    if let u = row.users {
                        displayMembers.append(FamilyMemberDisplay(
                            id: u.id.uuidString,
                            name: u.first_name ?? "Parent",
                            role: (u.role ?? "Parent").capitalized,
                            avatarUrl: u.avatar_id,
                            type: .parent
                        ))
                    }
                }
                
                // B. Fetch Children
                struct ChildJoinRow: Decodable {
                    struct ChildData: Decodable {
                        let id: UUID
                        let name: String
                        let nickname: String?
                        let avatar_url: String?
                    }
                    let children: ChildData?
                }
                
                let childRes = try await client.database
                    .from("family_members")
                    .select("children:children(*)")
                    .eq("family_id", value: familyId)
                    .not("child_id", operator: .is, value: "null")
                    .execute()
                    
                let childRows = try JSONDecoder().decode([ChildJoinRow].self, from: childRes.data)
                
                for row in childRows {
                    if let c = row.children {
                        displayMembers.append(FamilyMemberDisplay(
                            id: c.id.uuidString,
                            name: c.name,
                            role: (c.nickname?.isEmpty ?? true) ? "Chore Champion" : c.nickname!,
                            avatarUrl: c.avatar_url,
                            type: .child
                        ))
                    }
                }

                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.familyNameLabel.text = familyName
                    self.members = displayMembers
                    self.renderMembers()
                }
                
            } catch {
                print("❌ Fetch Error: \(error)")
                await MainActor.run { self.loadingIndicator.stopAnimating() }
            }
        }
    }
    
    private func renderMembers() {
        parentsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        childrenStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let parents = members.filter { $0.type == .parent }
        let children = members.filter { $0.type == .child }
        
        for p in parents {
            parentsStack.addArrangedSubview(createMemberCard(member: p))
        }
        for c in children {
            childrenStack.addArrangedSubview(createMemberCard(member: c))
        }
    }

    // MARK: - Setup UI
    private func setupUI() {
        // Gradient
        let topColor = UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1.0)
        let bottomColor = UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1.0)
        backgroundGradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
        
        // Header
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(backButton)
        headerView.addSubview(headerTitleLabel)
        
        headerTitleLabel.text = "Family"
        headerTitleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        headerTitleLabel.textColor = .white
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor(white: 1, alpha: 0.1)
        backButton.layer.cornerRadius = 20
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor(white: 1, alpha: 0.15).cgColor
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        // Scroll & Stack
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 24
        
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .white
        
        // Stacks
        parentsStack.axis = .vertical; parentsStack.spacing = 12
        childrenStack.axis = .vertical; childrenStack.spacing = 12
        
        // Static Content
        let famSection = createSectionLabel(title: "Family Name")
        mainStackView.addArrangedSubview(famSection)
        let famCard = createFamilyNameCard()
        mainStackView.addArrangedSubview(famCard)
        
        let pSection = createSectionLabel(title: "Parents")
        mainStackView.addArrangedSubview(pSection)
        mainStackView.addArrangedSubview(parentsStack)
        
        let cSection = createSectionLabel(title: "Children")
        mainStackView.addArrangedSubview(cSection)
        mainStackView.addArrangedSubview(childrenStack)
        
        // Constraints
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
            headerTitleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
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
    
    // MARK: - Helpers
    private func createSectionLabel(title: String) -> UILabel {
        let l = UILabel()
        l.text = title
        l.textColor = .white
        l.font = .systemFont(ofSize: 18, weight: .bold)
        return l
    }
    
    private func createFamilyNameCard() -> UIView {
        let c = GlassCardView()
        c.setCornerRadius(12)
        c.translatesAutoresizingMaskIntoConstraints = false
        c.heightAnchor.constraint(equalToConstant: 56).isActive = true
        c.addSubview(familyNameLabel)
        familyNameLabel.textColor = .white
        familyNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        familyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            familyNameLabel.leadingAnchor.constraint(equalTo: c.leadingAnchor, constant: 16),
            familyNameLabel.centerYAnchor.constraint(equalTo: c.centerYAnchor),
            familyNameLabel.trailingAnchor.constraint(equalTo: c.trailingAnchor, constant: -16)
        ])
        return c
    }
    
    private func createMemberCard(member: FamilyMemberDisplay) -> UIView {
        let card = GlassCardView()
        card.setCornerRadius(16)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        let avatarView = UIImageView()
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 25
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        // Smart Avatar Loading
        if let avatarName = member.avatarUrl, !avatarName.isEmpty {
            let fullUrl: String
            if member.type == .parent {
                fullUrl = ProfileService.shared.getAvatarURL(fileName: avatarName)
            } else {
                fullUrl = ProfileService.shared.getChildAvatarURL(fileName: avatarName)
            }
            if let url = URL(string: fullUrl) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let d = data, let img = UIImage(data: d) {
                        DispatchQueue.main.async { avatarView.image = img }
                    }
                }.resume()
            }
        } else {
            avatarView.image = UIImage(systemName: "person.crop.circle.fill")
            avatarView.tintColor = .lightGray
        }
        
        let nameLabel = UILabel()
        nameLabel.text = member.name
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 17, weight: .bold)
        
        let roleLabel = UILabel()
        roleLabel.text = member.role
        roleLabel.textColor = UIColor.lightGray
        roleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        
        let stack = UIStackView(arrangedSubviews: [nameLabel, roleLabel])
        stack.axis = .vertical; stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(avatarView)
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            stack.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            stack.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        return card
    }

    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
}
