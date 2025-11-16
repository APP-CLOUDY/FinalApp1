import UIKit

final class SplashViewController: UIViewController {

    private let familyImageView = UIImageView()
    private let titleLabel = UILabel()
    private let feature1 = UILabel()
    private let feature2 = UILabel()
    private let feature3 = UILabel()

    private let infoStack = UIStackView()
    private let continueContainer = UIView()
    private let continueButton = UIButton(type: .system)

    private let bgGradient = CAGradientLayer()

    // Constraints that will switch for portrait/landscape
    private var imageHeightPortrait: NSLayoutConstraint!
    private var imageWidthPortrait: NSLayoutConstraint!
    private var imageWidthLandscape: NSLayoutConstraint!
    private var imageHeightLandscape: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradient.frame = view.bounds
        continueContainer.layer.cornerRadius = 28
    }

    // MARK: Setup
    private func setupBackground() {
        bgGradient.colors = [
            UIColor(red: 0/255, green: 135/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 0/255, green: 110/255, blue: 230/255, alpha: 1).cgColor
        ]
        bgGradient.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(bgGradient, at: 0)
    }

    private func setupUI() {
        let safe = view.safeAreaLayoutGuide

        // ========= FAMILY IMAGE =========
        familyImageView.translatesAutoresizingMaskIntoConstraints = false
        familyImageView.contentMode = .scaleAspectFit
        familyImageView.image = UIImage(named: "family")
        view.addSubview(familyImageView)

        // -------- Portrait Constraints --------
        imageHeightPortrait = familyImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.48)
        imageWidthPortrait = familyImageView.widthAnchor.constraint(equalTo: view.widthAnchor)

        // -------- Landscape Constraints --------
        imageWidthLandscape = familyImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.50)
        imageHeightLandscape = familyImageView.heightAnchor.constraint(equalTo: view.heightAnchor)

        NSLayoutConstraint.activate([
            familyImageView.topAnchor.constraint(equalTo: safe.topAnchor),
            familyImageView.centerXAnchor.constraint(equalTo: safe.centerXAnchor)
        ])

        // Activate portrait by default
        imageHeightPortrait.isActive = true
        imageWidthPortrait.isActive = true

        // ========= INFO STACK =========
        infoStack.axis = .vertical
        infoStack.spacing = 10
        infoStack.alignment = .center
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoStack)

        // Title
        titleLabel.text = "Cloudyyy"
        titleLabel.font = UIFont.systemFont(ofSize: 44, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center

        // Description lines
        configureLabel(feature1, text: "Conversational bot that guides kids.")
        configureLabel(feature2, text: "Track progress with simple daily & weekly charts.")
        configureLabel(feature3, text: "Rewards and fun animations to celebrate growth.")

        infoStack.addArrangedSubview(titleLabel)
        infoStack.setCustomSpacing(18, after: titleLabel)
        infoStack.addArrangedSubview(feature1)
        infoStack.addArrangedSubview(feature2)
        infoStack.addArrangedSubview(feature3)

        NSLayoutConstraint.activate([
            infoStack.topAnchor.constraint(equalTo: familyImageView.bottomAnchor, constant: 12),
            infoStack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 25),
            infoStack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -25)
        ])

        // ========= CONTINUE BUTTON =========
        continueContainer.translatesAutoresizingMaskIntoConstraints = false
        continueContainer.backgroundColor = .white
        continueContainer.layer.shadowColor = UIColor.black.cgColor
        continueContainer.layer.shadowOpacity = 0.15
        continueContainer.layer.shadowOffset = CGSize(width: 0, height: 5)
        continueContainer.layer.shadowRadius = 10
        view.addSubview(continueContainer)

        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle("CONTINUE", for: .normal)
        continueButton.setTitleColor(.black, for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        continueContainer.addSubview(continueButton)

        NSLayoutConstraint.activate([
            continueContainer.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 22),
            continueContainer.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -22),
            continueContainer.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -24),
            continueContainer.heightAnchor.constraint(equalToConstant: 58),

            continueButton.leadingAnchor.constraint(equalTo: continueContainer.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: continueContainer.trailingAnchor),
            continueButton.topAnchor.constraint(equalTo: continueContainer.topAnchor),
            continueButton.bottomAnchor.constraint(equalTo: continueContainer.bottomAnchor)
        ])
    }

    private func configureLabel(_ label: UILabel, text: String) {
        label.text = text
        label.textColor = UIColor.white.withAlphaComponent(0.95)
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
    }

    // MARK: Rotation Adaptation
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateForOrientation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateForOrientation()
    }

    private func updateForOrientation() {
        let isLandscape = view.bounds.width > view.bounds.height

        if isLandscape {
            // Landscape layout
            imageHeightPortrait.isActive = false
            imageWidthPortrait.isActive = false
            imageWidthLandscape.isActive = true
            imageHeightLandscape.isActive = true

            titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        } else {
            // Portrait layout
            imageWidthLandscape.isActive = false
            imageHeightLandscape.isActive = false
            imageHeightPortrait.isActive = true
            imageWidthPortrait.isActive = true

            titleLabel.font = UIFont.systemFont(ofSize: 44, weight: .heavy)
        }

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: Navigation
    @objc private func didTapContinue() {
        let next = SelectUserViewController()
        if let nav = navigationController {
            nav.pushViewController(next, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: next)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
}
