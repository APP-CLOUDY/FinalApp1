import UIKit

// MARK: - Models
enum QuickRewardLockReason {
    case notAssigned
    case alreadyClaimed
}

struct AssignedQuickReward {
    let id: UUID
    let claimId: UUID?
    let title: String
    let cost: Int
    let imageName: String
    let isLocked: Bool
    let lockReason: QuickRewardLockReason?
}

// MARK: - View Controller
final class AssignedQuickRewardViewController: UIViewController {

    // MARK: - Data
    var rewardTypeTitle: String = "" // Header Title (e.g. "Snacks")
    var categoryKey: String = ""     // 🔑 REQUIRED: Backend category key (e.g. "snacks")
    var assignedRewards: [AssignedQuickReward] = []
    
    // MARK: - UI
    private let gradient = CAGradientLayer()
    private let backButton = UIButton(type: .system)
    private let headerTitle = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private let mascotImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "cloudyy_market")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true

        setupGradient()
        setupHeader()
        setupMascot()
        setupTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 🔥 REFRESH DATA EVERY TIME SCREEN APPEARS
        // This ensures locks update immediately after a claim
        fetchRewards()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Data Fetching
    private func fetchRewards() {
        guard let childId = SessionManager.shared.childId else { return }
        
        // If no category key is set, rely on whatever data was passed in (fallback)
        if categoryKey.isEmpty {
            tableView.reloadData()
            return
        }

        activityIndicator.startAnimating()
        
        Task {
            do {
                // 1. Fetch fresh data
                let response = try await ChildRewardsService.shared.getChildRewards(
                    childId: childId,
                    category: categoryKey
                )
                
                // 2. Map to UI Models
                let newRewards: [AssignedQuickReward] = response.active.compactMap { item in
                    let imageName = self.getImageName(for: item.reward_sub_type)
                    
                    // Determine Lock Reason
                    var reason: QuickRewardLockReason? = nil
                    if item.is_locked == true {
                        if (item.claimed_count ?? 0) > 0 {
                            reason = .alreadyClaimed
                        } else {
                            reason = .notAssigned
                        }
                    }

                    return AssignedQuickReward(
                        id: item.id,
                        claimId: item.claim_id,
                        title: item.title,
                        cost: item.points,
                        imageName: imageName,
                        isLocked: item.is_locked ?? false,
                        lockReason: reason
                    )
                }

                // 3. Update UI
                await MainActor.run {
                    self.assignedRewards = newRewards
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
                
            } catch {
                print("❌ Failed to refresh rewards:", error)
                await MainActor.run { self.activityIndicator.stopAnimating() }
            }
        }
    }
    
    // Helper to map backend types to images
    private func getImageName(for subType: String?) -> String {
        switch subType {
        case "ice_cream": return "reward_icecream"
        case "chocolate": return "reward_chocolate"
        case "snacks": return "reward_treat"
        case "takeaway": return "reward_takeaway"
        case "tv_time": return "reward_tv"
        case "gadget_time": return "reward_gadget"
        case "outdoor_play": return "reward_park"
        case "toys": return "reward_toy"
        case "surprise": return "reward_gift"
        default: return "cloudyy_logo"
        }
    }
}

// MARK: - Header & UI Setup
private extension AssignedQuickRewardViewController {

    func setupHeader() {
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        headerTitle.text = rewardTypeTitle
        headerTitle.font = .systemFont(ofSize: 20, weight: .semibold)
        headerTitle.textColor = .white
        
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true

        [backButton, headerTitle, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),

            headerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerTitle.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            
            activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            activityIndicator.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])
    }
}

// MARK: - Mascot
private extension AssignedQuickRewardViewController {
    func setupMascot() {
        view.addSubview(mascotImageView)
        NSLayoutConstraint.activate([
            mascotImageView.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 16),
            mascotImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mascotImageView.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
}

// MARK: - Table
extension AssignedQuickRewardViewController: UITableViewDataSource, UITableViewDelegate {
    
    func setupTable() {
        tableView.register(AssignedQuickRewardCell.self, forCellReuseIdentifier: AssignedQuickRewardCell.id)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: mascotImageView.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assignedRewards.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AssignedQuickRewardCell.id, for: indexPath) as! AssignedQuickRewardCell
        cell.configure(assignedRewards[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        // Animation
        UIView.animate(withDuration: 0.12, animations: {
            cell?.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                cell?.transform = .identity
            }
        }
        
        let reward = assignedRewards[indexPath.row]
        
        // 🔒 Locked
        if reward.isLocked {
            presentLockedPopup(reason: reward.lockReason)
            return
        }
        
        // ⭐ Unlocked
        presentClaimPopup(for: reward)
    }
    
    private func presentClaimPopup(for reward: AssignedQuickReward) {
        let vc = QuickRewardClaimPopupViewController()
        vc.reward = reward
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    private func presentLockedPopup(reason: QuickRewardLockReason?) {
        let vc = LockedRewardPopupViewController()
        
        switch reason {
        case .alreadyClaimed:
            vc.overrideMessage(
                title: "Already Claimed",
                message: "You’ve already claimed this reward 😊"
            )
        case .notAssigned:
            vc.overrideMessage(
                title: "Locked",
                message: "This reward is not assigned to you yet."
            )
        case .none:
            vc.overrideMessage(
                title: "Locked",
                message: "This reward is currently unavailable."
            )
        }
        
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}

// MARK: - Gradient
private extension AssignedQuickRewardViewController {
    func setupGradient() {
        gradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }
}

// MARK: - Card Cell
final class AssignedQuickRewardCell: UITableViewCell {

    static let id = "AssignedQuickRewardCell"

    private let card = UIView()
    private let rewardImage = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let starsLabel = UILabel()
    private let badge = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none

        card.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        card.layer.cornerRadius = 26
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.3
        card.layer.shadowRadius = 14
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.translatesAutoresizingMaskIntoConstraints = false

        rewardImage.contentMode = .scaleAspectFit
        rewardImage.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white

        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        starsLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        starsLabel.textColor = .systemYellow

        badge.font = .systemFont(ofSize: 12, weight: .semibold)
        badge.textColor = .white
        badge.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        badge.layer.cornerRadius = 10
        badge.clipsToBounds = true
        badge.textAlignment = .center

        let textStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            starsLabel
        ])
        textStack.axis = .vertical
        textStack.spacing = 6

        let mainStack = UIStackView(arrangedSubviews: [
            rewardImage,
            textStack
        ])
        mainStack.axis = .horizontal
        mainStack.spacing = 16
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(mainStack)
        card.addSubview(badge)
        contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            rewardImage.widthAnchor.constraint(equalToConstant: 90),
            rewardImage.heightAnchor.constraint(equalToConstant: 90),

            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            mainStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            badge.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            badge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            badge.heightAnchor.constraint(equalToConstant: 24),
            badge.widthAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])
    }

    func configure(_ reward: AssignedQuickReward) {
        rewardImage.image = UIImage(named: reward.imageName)
        titleLabel.text = reward.title
        starsLabel.text = "⭐ \(reward.cost) Stars"

        if reward.isLocked {
            #if DEBUG
            switch reward.lockReason {
            case .alreadyClaimed:
                badge.text = "CLAIMED"
            case .notAssigned:
                badge.text = "NOT ASSIGNED"
            case .none:
                badge.text = "LOCKED"
            }
            #else
            badge.text = "Locked"
            #endif
            
            badge.backgroundColor = UIColor.systemGray.withAlphaComponent(0.4)
            subtitleLabel.text = "Not available"
            card.alpha = 0.5
        } else {
            badge.text = "Instant"
            badge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.35)
            subtitleLabel.text = "Redeem this reward"
            card.alpha = 1.0
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}
