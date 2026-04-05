import UIKit

final class AddFamilyMembersViewController: UIViewController {

    // MARK: - UI Elements

    private let topContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // NEW: Back Button
    private let backButton: UIButton = {
        ParentBackButtonFactory.make(target: nil, action: #selector(handleBack))
    }()

    private let appTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Cloudyyy"
        l.font = UIFont.systemFont(ofSize: 56, weight: .black)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Expand your family circle"
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(white: 1.0, alpha: 0.95)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()
    
    // MARK: - Bottom card (dark gradient)
    private let bottomCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()
    
    // MARK: - Bottom Card Content
    
    private let bottomScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()

    private let sectionTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Add Child"
        l.textColor = UIColor(red: 92/255, green: 160/255, blue: 1, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    private lazy var parentButtonContainer = makeCircleButtonContainer(title: "Parent", imageName: "parents")
    private lazy var childButtonContainer  = makeCircleButtonContainer(title: "Child",  imageName: "child")
    
    // Horizontal stack for the Child button (Centered)
    private let buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    // MARK: - Rotation/Centering Fix
    private let topSpacer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let bottomSpacer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var bottomStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            topSpacer,
            sectionTitleLabel,
            spacer(height: 30),
            buttonStackView,
            bottomSpacer
        ])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .fill
        sv.spacing = 0
        return sv
    }()

    // gradient layers
    private var topGradient: CAGradientLayer?
    private var cardGradient: CAGradientLayer?
    private var viewGradient: CAGradientLayer?

    private let topBlue = UIColor(red: 21/255, green: 130/255, blue: 255/255, alpha: 1)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = topBlue
        setupHierarchy()
        setupConstraints()
        configureCardShadow()
        
        // Add target for back button
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
        topContainer.layoutIfNeeded()
        bottomCard.layoutIfNeeded()
        applyGradients()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        applyGradients()
    }

    // MARK: - Setup
    private func setupHierarchy() {
        view.addSubview(topContainer)
        view.addSubview(bottomCard)
        view.addSubview(backButton) // Add back button to main view

        topContainer.addSubview(appTitleLabel)
        topContainer.addSubview(subtitleLabel)

        bottomCard.addSubview(bottomScrollView)
        bottomScrollView.addSubview(bottomStack)
        
        buttonStackView.addArrangedSubview(childButtonContainer)
    }
    
    private func spacer(height: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }

    private func setupConstraints() {
        // Top Container: 50% height
        NSLayoutConstraint.activate([
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topContainer.topAnchor.constraint(equalTo: view.topAnchor),
            topContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            // Back Button Constraints
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // Bottom Card: 50% height + overlap
            bottomCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomCard.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -40),
            bottomCard.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5, constant: 40)
        ])

        // Title & subtitle
        NSLayoutConstraint.activate([
            appTitleLabel.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            appTitleLabel.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor, constant: -10),

            subtitleLabel.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 30),
            subtitleLabel.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -30)
        ])

        // ScrollView & Stack
        let stackHeightConstraint = bottomStack.heightAnchor.constraint(equalTo: bottomScrollView.frameLayoutGuide.heightAnchor, constant: -40)
        stackHeightConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            bottomScrollView.topAnchor.constraint(equalTo: bottomCard.topAnchor),
            bottomScrollView.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor),
            bottomScrollView.trailingAnchor.constraint(equalTo: bottomCard.trailingAnchor),
            bottomScrollView.bottomAnchor.constraint(equalTo: bottomCard.bottomAnchor),
            
            bottomStack.topAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.topAnchor, constant: 20),
            bottomStack.bottomAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            bottomStack.leadingAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.leadingAnchor, constant: 40),
            bottomStack.trailingAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.trailingAnchor, constant: -40),
            
            bottomStack.widthAnchor.constraint(equalTo: bottomScrollView.frameLayoutGuide.widthAnchor, constant: -80),
            
            stackHeightConstraint,
        ])
        
        topSpacer.heightAnchor.constraint(equalTo: bottomSpacer.heightAnchor).isActive = true
        
        NSLayoutConstraint.activate([
            childButtonContainer.heightAnchor.constraint(equalToConstant: 150),
            childButtonContainer.widthAnchor.constraint(equalToConstant: 150)
        ])
    }

    private func configureCardShadow() {
        bottomCard.layer.shadowColor = UIColor.black.cgColor
        bottomCard.layer.shadowOpacity = 0.25
        bottomCard.layer.shadowRadius = 12
        bottomCard.layer.shadowOffset = CGSize(width: 0, height: -4)
    }

    // MARK: - Gradients
    private func applyGradients() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        topContainer.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        bottomCard.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        view.layoutIfNeeded()
        topContainer.layoutIfNeeded()
        bottomCard.layoutIfNeeded()

        let topG = CAGradientLayer()
        topG.colors = [
            UIColor(red: 21/255, green: 130/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 54/255, green: 114/255, blue: 241/255, alpha: 1).cgColor
        ]
        topG.startPoint = CGPoint(x: 0.5, y: 0.0)
        topG.endPoint   = CGPoint(x: 0.5, y: 1.0)
        
        topG.frame = topContainer.bounds.integral
        topContainer.layer.insertSublayer(topG, at: 0)
        topGradient = topG

        // View background gradient (matching topG)
        let viewG = CAGradientLayer()
        viewG.colors = topG.colors
        viewG.startPoint = topG.startPoint
        viewG.endPoint = topG.endPoint
        viewG.frame = view.bounds.integral
        view.layer.insertSublayer(viewG, at: 0)
        viewGradient = viewG

        // Bottom Card Gradient
        let cardG = CAGradientLayer()
        cardG.colors = [
            UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1).cgColor,
            UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1).cgColor
        ]
        cardG.startPoint = CGPoint(x: 0.5, y: 0)
        cardG.endPoint = CGPoint(x: 0.5, y: 1)
        cardG.frame = bottomCard.bounds.integral
        bottomCard.layer.insertSublayer(cardG, at: 0)
        cardGradient = cardG

        CATransaction.commit()
    }

    // MARK: - Button builder
    private func makeCircleButtonContainer(title: String, imageName: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let ring = UIView()
        ring.translatesAutoresizingMaskIntoConstraints = false
        ring.backgroundColor = UIColor.white.withAlphaComponent(0.02)
        ring.layer.cornerRadius = 72
        ring.isUserInteractionEnabled = false

        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.layer.cornerRadius = 60
        circle.clipsToBounds = true
        circle.backgroundColor = UIColor(white: 1.0, alpha: 0.04)
        circle.layer.borderWidth = 1.2
        circle.layer.borderColor = UIColor(white: 1.0, alpha: 0.08).cgColor

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(blur)

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if let img = UIImage(named: imageName) {
            imageView.image = img
            imageView.tintColor = nil
        } else {
            imageView.image = UIImage(systemName: "person.fill")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .white
        }

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center

        container.addSubview(ring)
        container.addSubview(circle)
        circle.addSubview(imageView)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            circle.topAnchor.constraint(equalTo: container.topAnchor),
            circle.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            circle.widthAnchor.constraint(equalToConstant: 120),
            circle.heightAnchor.constraint(equalToConstant: 120),

            ring.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            ring.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            ring.widthAnchor.constraint(equalToConstant: 144),
            ring.heightAnchor.constraint(equalToConstant: 144),

            blur.leadingAnchor.constraint(equalTo: circle.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: circle.trailingAnchor),
            blur.topAnchor.constraint(equalTo: circle.topAnchor),
            blur.bottomAnchor.constraint(equalTo: circle.bottomAnchor),

            imageView.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: circle.widthAnchor, multiplier: 0.6),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            label.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 10),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        container.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(circleTapped(_:)))
        container.addGestureRecognizer(tap)
        container.accessibilityIdentifier = title.lowercased()

        return container
    }

    // MARK: - Actions

    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func circleTapped(_ sender: UITapGestureRecognizer) {
        guard let id = sender.view?.accessibilityIdentifier else { return }
        if id == "parent" {
            handleAddParent()
        } else if id == "child" {
            handleAddChild()
        }
    }

    private func handleAddParent() {
        print("Add Parent selected")
        // Logic to add a parent or navigate to the relevant controller
        // Example: navigationController?.pushViewController(AddParentViewController(), animated: true)
        
        let vc = LoginAddParent()
        
        // 2. Push onto the navigation stack
        navigationController?.pushViewController(vc, animated: true)
    }

    private func handleAddChild() {
        print("Add Child selected")
        // 1. Create an instance of the view controller
            let vc = LoginAddChild()
            
            // 2. Push onto the navigation stack
            navigationController?.pushViewController(vc, animated: true)
    }
}
