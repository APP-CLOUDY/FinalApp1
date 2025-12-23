import UIKit

// MARK: - Model
struct AssignedQuickReward {
    let id: UUID
    let title: String
    let cost: Int
    let imageName: String
    let approvalRequired: Bool
}

// MARK: - View Controller
final class AssignedQuickRewardViewController: UIViewController {

    // MARK: - Data (SET BEFORE PUSH)
    var rewardTypeTitle: String = ""
    var rewardIconName: String = ""
    var assignedRewards: [AssignedQuickReward] = []
    var currentStars: Int = 0

    // MARK: - UI
    private let gradient = CAGradientLayer()

    // Header
    private let backButton = UIButton(type: .system)
    private let headerTitle = UILabel()

    // Top Info
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let starsLabel = UILabel()

    // Mascot
    private let mascotImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "cloudyy_guitar")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // Table
    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true

        setupGradient()
        setupHeader()
        setupTopInfo()
        setupMascot()
        setupTable()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
}

// MARK: - Header
private extension AssignedQuickRewardViewController {

    func setupHeader() {
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        headerTitle.text = rewardTypeTitle
        headerTitle.font = .systemFont(ofSize: 20, weight: .semibold)
        headerTitle.textColor = .white

        [backButton, headerTitle].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),

            headerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerTitle.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])
    }

    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Top Info
private extension AssignedQuickRewardViewController {

    func setupTopInfo() {
        iconImageView.image = UIImage(named: rewardIconName)
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.text = rewardTypeTitle
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white

        starsLabel.text = "⭐ Your Stars: \(currentStars)"
        starsLabel.font = .systemFont(ofSize: 14)
        starsLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        [iconImageView, titleLabel, starsLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 6),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            starsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            starsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - Mascot
private extension AssignedQuickRewardViewController {

    func setupMascot() {
        view.addSubview(mascotImageView)

        NSLayoutConstraint.activate([
            mascotImageView.topAnchor.constraint(equalTo: starsLabel.bottomAnchor, constant: 8),
            mascotImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mascotImageView.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
}

// MARK: - Table
extension AssignedQuickRewardViewController: UITableViewDataSource, UITableViewDelegate {

    func setupTable() {
        tableView.register(AssignedQuickRewardCell.self,
                           forCellReuseIdentifier: AssignedQuickRewardCell.id)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: mascotImageView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assignedRewards.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: AssignedQuickRewardCell.id,
            for: indexPath
        ) as! AssignedQuickRewardCell

        cell.configure(assignedRewards[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let reward = assignedRewards[indexPath.row]

        if reward.approvalRequired {
            let lockedVC = LockedRewardPopupViewController()
            lockedVC.modalPresentationStyle = .overFullScreen
            present(lockedVC, animated: false)
            return
        }

        let claimVC = QuickRewardClaimPopupViewController()
        claimVC.reward = reward
        claimVC.modalPresentationStyle = .overFullScreen
        present(claimVC, animated: false)
    }
}

// MARK: - Gradient
private extension AssignedQuickRewardViewController {

    func setupGradient() {
        gradient.colors = [
            UIColor(red: 20/255, green: 24/255, blue: 40/255, alpha: 1).cgColor,
            UIColor(red: 90/255, green: 70/255, blue: 160/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }
}

// MARK: - Reward Cell
final class AssignedQuickRewardCell: UITableViewCell {

    static let id = "AssignedQuickRewardCell"

    private let card = UIView()
    private let icon = UIImageView()
    private let title = UILabel()
    private let cost = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none

        card.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        card.layer.cornerRadius = 20
        card.translatesAutoresizingMaskIntoConstraints = false

        icon.image = UIImage(systemName: "star.circle.fill")
        icon.tintColor = .systemYellow

        title.textColor = .white
        title.font = .systemFont(ofSize: 16, weight: .medium)

        cost.textColor = UIColor.white.withAlphaComponent(0.6)
        cost.font = .systemFont(ofSize: 13)

        let vStack = UIStackView(arrangedSubviews: [title, cost])
        vStack.axis = .vertical
        vStack.spacing = 2

        let hStack = UIStackView(arrangedSubviews: [icon, vStack])
        hStack.spacing = 12
        hStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(hStack)
        contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            hStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            hStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16)
        ])
    }

    func configure(_ reward: AssignedQuickReward) {
        title.text = reward.title
        cost.text = "⭐ \(reward.cost)"
    }

    required init?(coder: NSCoder) { fatalError() }
}

