import UIKit

final class QuickRewardClaimPopupViewController: UIViewController {

    // MARK: - Data
    var reward: AssignedQuickReward!
    var currentBalance: Int = 0
    var onClaim: (() -> Void)?

    // MARK: - Gradient
    private let gradientLayer = CAGradientLayer()

    // MARK: - UI

    // ☁️ Mascot
    private let mascotImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "cloudyy_logo")
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
        setupGestures()
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
        view.addSubview(mascotImageView)
        view.addSubview(titleLabel)
        view.addSubview(rewardImageView)
        view.addSubview(costLabel)
        view.addSubview(claimButton)
        view.addSubview(tapHintLabel)

        claimButton.addTarget(self, action: #selector(claimTapped), for: .touchUpInside)
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

    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(claimTapped))
        view.addGestureRecognizer(tap)
    }
    private func showConfetti() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)

        let colors: [UIColor] = [
            .systemYellow,
            .systemPink,
            .systemBlue,
            .systemGreen,
            .systemOrange
        ]

        emitter.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 6
            cell.lifetime = 4.0
            cell.velocity = 180
            cell.velocityRange = 80
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 3
            cell.spinRange = 4
            cell.scale = 0.6
            cell.scaleRange = 0.3
            cell.color = color.cgColor
            cell.contents = UIImage(systemName: "star.fill")?.cgImage
            return cell
        }

        view.layer.addSublayer(emitter)

        // 🧹 Remove after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            emitter.birthRate = 0
            emitter.removeFromSuperlayer()
        }
    }


    // MARK: - Actions
    @objc private func claimTapped() {
        showConfetti()

        // ⏱️ Let confetti play before dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.dismiss(animated: true) {
                self.onClaim?()
            }
        }
    }

}

