
import UIKit
//AssignedQuickrewardVC
// MARK: - Model
struct AssignedQuickReward {
 let id: UUID
 let claimId: UUID?
 let title: String
 let cost: Int
 let imageName: String
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

 private let backButton = UIButton(type: .system)
 private let headerTitle = UILabel()

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

        // 🔄 Refresh list when screen appears
        tableView.reloadData()
    }

 override func viewDidLayoutSubviews() {
     super.viewDidLayoutSubviews()
     gradient.frame = view.bounds
 }

 @objc private func backTapped() {
     navigationController?.popViewController(animated: true)
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
         backButton.widthAnchor.constraint(equalToConstant: 32),
         backButton.heightAnchor.constraint(equalToConstant: 32),

         headerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         headerTitle.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
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
     tableView.register(AssignedQuickRewardCell.self,
                        forCellReuseIdentifier: AssignedQuickRewardCell.id)
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

 func tableView(_ tableView: UITableView,
                heightForRowAt indexPath: IndexPath) -> CGFloat {
     return 160
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

     let cell = tableView.cellForRow(at: indexPath)
     UIView.animate(withDuration: 0.12, animations: {
         cell?.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
     }) { _ in
         UIView.animate(withDuration: 0.12) {
             cell?.transform = .identity
         }
     }

     let reward = assignedRewards[indexPath.row]
     presentClaimPopup(for: reward)

 }

 private func presentClaimPopup(for reward: AssignedQuickReward) {
     let vc = QuickRewardClaimPopupViewController()
     vc.reward = reward
     vc.modalPresentationStyle = .overFullScreen
     present(vc, animated: false)
 }

 private func presentPendingApprovalPopup() {
     let vc = LockedRewardPopupViewController()
     vc.modalPresentationStyle = .overFullScreen
     present(vc, animated: false)
 }

 private func presentDeclinedPopup() {
     let alert = UIAlertController(
         title: "Not Approved",
         message: "Your parent didn’t approve this reward yet 😊",
         preferredStyle: .alert
     )
     alert.addAction(UIAlertAction(title: "Okay", style: .default))
     present(alert, animated: true)
 }
}

// MARK: - Gradient
private extension AssignedQuickRewardViewController {

 func setupGradient() {
     gradient.colors = [
             UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,  // dark charcoal
             UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor   // deep blue
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
     subtitleLabel.text = "Redeem this reward"
     badge.text = "Instant"
     badge.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.35)

 }

 required init?(coder: NSCoder) { fatalError() }
}
