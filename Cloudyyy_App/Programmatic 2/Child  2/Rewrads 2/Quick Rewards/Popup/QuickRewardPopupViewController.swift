import UIKit

final class QuickRewardClaimPopupViewController: UIViewController {

    // MARK: - Data
    var reward: AssignedQuickReward!
    var onClaim: (() -> Void)?
    private var isSubmitting = false
    
    // MARK: - Gradient
    private let gradientLayer = CAGradientLayer()

    // MARK: - UI
    
    // 🔙 Back / Close Button
    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        // Option A: "xmark.circle.fill" (Best for Modals)
        // Option B: "chevron.left.circle.fill" (Best for Navigation feel)
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
        b.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        b.tintColor = .white.withAlphaComponent(0.6)
        return b
    }()

    // ☁️ Mascot
    private let mascotImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "cloudyy_gift")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // 🎉 Title
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Congratulations!"
        lb.font = .systemFont(ofSize: 34, weight: .heavy)
        lb.textColor = .systemYellow
        lb.textAlignment = .center
        return lb
    }()

    // 🎁 Reward Image
    private let rewardImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // ⭐ Cost
    private let costLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = .systemFont(ofSize: 22, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()

    // 🔘 Claim Button
    private let claimButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = UIColor(red: 76/255, green: 218/255, blue: 254/255, alpha: 1)
        b.layer.cornerRadius = 26
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.25
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.layer.shadowRadius = 6
        return b
    }()

    // 👆 Hint
    private let tapHintLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Tap to claim"
        lb.font = .systemFont(ofSize: 16, weight: .medium)
        lb.textColor = .white.withAlphaComponent(0.85)
        lb.textAlignment = .center
        return lb
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen

        setupGradient()
        setupViews()
        setupLayout()
        setupData()
        addMascotFloatAnimation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Setup

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 10/255, green: 12/255, blue: 20/255, alpha: 1).cgColor,
            UIColor(red: 25/255, green: 40/255, blue: 70/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupViews() {
        view.addSubview(closeButton) // Added
        view.addSubview(mascotImageView)
        view.addSubview(titleLabel)
        view.addSubview(rewardImageView)
        view.addSubview(costLabel)
        view.addSubview(claimButton)
        view.addSubview(tapHintLabel)

        claimButton.addTarget(self, action: #selector(claimTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside) // Added
    }

    private func setupData() {
        rewardImageView.image = UIImage(named: reward.imageName)
        costLabel.text = "⭐ \(reward.cost)"

        let title = createGoldStarString(
            prefix: "Spend \(reward.cost) ",
            suffix: " for \(reward.title)",
            fontSize: 18,
            textColor: .white,
            weight: .bold
        )
        claimButton.setAttributedTitle(title, for: .normal)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            // Close Button Constraints
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            mascotImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            mascotImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mascotImageView.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.topAnchor.constraint(equalTo: mascotImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            rewardImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            rewardImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rewardImageView.heightAnchor.constraint(equalToConstant: 180),

            costLabel.topAnchor.constraint(equalTo: rewardImageView.bottomAnchor, constant: 16),
            costLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            claimButton.topAnchor.constraint(equalTo: costLabel.bottomAnchor, constant: 30),
            claimButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            claimButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            claimButton.heightAnchor.constraint(equalToConstant: 52),

            tapHintLabel.topAnchor.constraint(equalTo: claimButton.bottomAnchor, constant: 14),
            tapHintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func claimTapped() {
        guard !isSubmitting else { return }
        redeemInstantReward()
    }

    // MARK: - Helpers

    private func createGoldStarString(
        prefix: String,
        suffix: String,
        fontSize: CGFloat,
        textColor: UIColor,
        weight: UIFont.Weight
    ) -> NSAttributedString {

        let gold = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1)
        let full = NSMutableAttributedString()

        full.append(NSAttributedString(
            string: prefix,
            attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: weight),
                         .foregroundColor: textColor]
        ))

        let config = UIImage.SymbolConfiguration(pointSize: fontSize, weight: .regular)
        if let star = UIImage(systemName: "star.fill", withConfiguration: config)?
            .withTintColor(gold, renderingMode: .alwaysOriginal) {

            let attach = NSTextAttachment()
            attach.image = star
            attach.bounds = CGRect(x: 0, y: -2, width: star.size.width, height: star.size.height)
            full.append(NSAttributedString(attachment: attach))
        }

        full.append(NSAttributedString(
            string: suffix,
            attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: weight),
                         .foregroundColor: textColor]
        ))

        return full
    }

    // MARK: - Animations

    private func addMascotFloatAnimation() {
        let float = CABasicAnimation(keyPath: "transform.translation.y")
        float.fromValue = 0
        float.toValue = -6
        float.duration = 1.8
        float.autoreverses = true
        float.repeatCount = .infinity
        mascotImageView.layer.add(float, forKey: "float")
    }

    // MARK: - Logic
    
    private func redeemInstantReward() {
        guard !isSubmitting else { return }
        isSubmitting = true

        guard let childId = SessionManager.shared.childId else {
            isSubmitting = false
            return
        }

        Task {
            do {
                _ = try await ChildRewardsService.shared
                    .claimQuickReward(
                        childId: childId,
                        rewardId: reward.id
                    )

                await MainActor.run {
                    self.onClaim?()
                    NotificationCenter.default.post(name: .rewardRedeemed, object: nil)
                    NotificationCenter.default.post(name: .taskDidComplete, object: nil)
                    self.dismiss(animated: true)
                }

            } catch {
                await MainActor.run {
                    self.isSubmitting = false
                    let message = (error as NSError).localizedDescription.lowercased()

                    if message.contains("not enough") {
                        self.showNotEnoughStarsPopup()
                    } else if message.contains("already") {
                        self.showAlreadyClaimedPopup()
                    } else if message.contains("assigned") {
                        self.showLockedPopup()
                    } else {
                        self.showGenericErrorPopup(message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // MARK: - Error Popups
    
    private func showAlreadyClaimedPopup() {
        let vc = LockedRewardPopupViewController()
        vc.overrideMessage(
            title: "Already Claimed",
            message: "You’ve already claimed this reward 😊"
        )
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }

    private func showLockedPopup() {
        let vc = LockedRewardPopupViewController()
        vc.overrideMessage(
            title: "Locked",
            message: "This reward is not assigned to you yet."
        )
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }

    private func showGenericErrorPopup(message: String) {
        let alert = UIAlertController(
            title: "Something went wrong",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showNotEnoughStarsPopup() {
        let popup = UIViewController()
        popup.modalPresentationStyle = .overFullScreen
        popup.view.backgroundColor = .clear

        let dimView = UIView()
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        popup.view.addSubview(dimView)

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 24
        blur.clipsToBounds = true
        popup.view.addSubview(blur)

        let mascot = UIImageView(image: UIImage(named: "cloudyy_upset"))
        mascot.translatesAutoresizingMaskIntoConstraints = false
        mascot.contentMode = .scaleAspectFit

        let title = UILabel()
        title.text = "Oops!"
        title.font = .systemFont(ofSize: 22, weight: .bold)
        title.textColor = .white
        title.textAlignment = .center

        let message = UILabel()
        message.text = """
    You don’t have enough stars ⭐

    Complete some tasks
    to earn more!
    """
        message.font = .systemFont(ofSize: 15, weight: .medium)
        message.textColor = UIColor.white.withAlphaComponent(0.85)
        message.textAlignment = .center
        message.numberOfLines = 0

        let okButton = UIButton(type: .system)
        okButton.setTitle("Okay 😊", for: .normal)
        okButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        okButton.backgroundColor = .white
        okButton.setTitleColor(.black, for: .normal)
        okButton.layer.cornerRadius = 16
        okButton.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [mascot, title, message, okButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        blur.contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: popup.view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: popup.view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: popup.view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: popup.view.trailingAnchor),

            blur.centerXAnchor.constraint(equalTo: popup.view.centerXAnchor),
            blur.centerYAnchor.constraint(equalTo: popup.view.centerYAnchor),
            blur.widthAnchor.constraint(equalToConstant: 280),

            stack.topAnchor.constraint(equalTo: blur.contentView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -20),

            mascot.heightAnchor.constraint(equalToConstant: 90),
            mascot.widthAnchor.constraint(equalToConstant: 120),

            okButton.widthAnchor.constraint(equalToConstant: 140),
            okButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        okButton.addAction(UIAction { _ in
            popup.dismiss(animated: true)
            self.dismiss(animated: true)
        }, for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: popup, action: #selector(UIViewController.dismiss))
        dimView.addGestureRecognizer(tap)

        present(popup, animated: true)
    }
}
