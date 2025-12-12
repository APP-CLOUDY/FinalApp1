//
//  AddChild.swift
//  Cloudyyy_App
//

import UIKit

final class AddChild: UIViewController {

    // MARK: - UI Elements (Identical to other screens)

    private let topContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let appTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Cloudyyy"
        l.font = UIFont.systemFont(ofSize: 56, weight: .black)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Organize tasks, Motivate Kids , Track Progress"
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(white: 1.0, alpha: 0.95)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()
    
    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
            b.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        } else {
            b.setTitle("< Back", for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        }
        b.tintColor = .white
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        b.widthAnchor.constraint(equalToConstant: 44).isActive = true
        return b
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

    private let joinLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Add Child"
        l.textColor = UIColor(red: 92/255, green: 160/255, blue: 1, alpha: 1)
        l.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    private lazy var childButtonContainer = makeCircleButtonContainer(imageName: "child")
    
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
            joinLabel,
            spacer(height: 30),
            childButtonContainer,
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

    private let topBlue = UIColor(red: 0.00, green: 0.55, blue: 1.00, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = topBlue
        setupHierarchy()
        setupConstraints()
        configureCardShadow()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
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

        topContainer.addSubview(appTitleLabel)
        topContainer.addSubview(subtitleLabel)
        topContainer.addSubview(backButton)

        bottomCard.addSubview(bottomScrollView)
        bottomScrollView.addSubview(bottomStack)
    }
    
    private func spacer(height: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topContainer.topAnchor.constraint(equalTo: view.topAnchor),
            topContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            bottomCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomCard.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -40),
            bottomCard.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5, constant: 40)
        ])

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: topContainer.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: topContainer.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])

        NSLayoutConstraint.activate([
            appTitleLabel.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            appTitleLabel.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor, constant: -10),

            subtitleLabel.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 30),
            subtitleLabel.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -30)
        ])

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
            // Increased container height to accommodate the ring (140 + 12 for ring offset)
            childButtonContainer.heightAnchor.constraint(equalToConstant: 152)
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

        // Top blue gradient
        let topG = CAGradientLayer()
        topG.colors = [
            UIColor(red: 21/255, green: 130/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 54/255, green: 114/255, blue: 241/255, alpha: 1).cgColor
        ]
        topG.startPoint = CGPoint(x: 0.5, y: 0)
        topG.endPoint = CGPoint(x: 0.5, y: 1)
        topG.frame = topContainer.bounds.integral
        topContainer.layer.insertSublayer(topG, at: 0)
        topGradient = topG

        let viewG = CAGradientLayer()
        viewG.colors = topG.colors
        viewG.startPoint = topG.startPoint
        viewG.endPoint = topG.endPoint
        viewG.locations = topG.locations
        viewG.frame = view.bounds.integral
        view.layer.insertSublayer(viewG, at: 0)
        viewGradient = viewG

        // Bottom card gradient (UPDATED to match your other screens)
        let cardG = CAGradientLayer()
        cardG.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor, // Dark Obsidian
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor  // Deep Steel Blue
        ]
        cardG.startPoint = CGPoint(x: 0.5, y: 0.0)
        cardG.endPoint   = CGPoint(x: 0.5, y: 1.0)
        cardG.frame = bottomCard.bounds.integral
        bottomCard.layer.insertSublayer(cardG, at: 0)
        cardGradient = cardG

        CATransaction.commit()
    }

    // MARK: - Button builder (Updated to remove text)
    private func makeCircleButtonContainer(imageName: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let ring = UIView()
        ring.translatesAutoresizingMaskIntoConstraints = false
        ring.backgroundColor = UIColor.white.withAlphaComponent(0.02)
        ring.layer.cornerRadius = 82
        ring.isUserInteractionEnabled = false

        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.layer.cornerRadius = 70
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

        //Removed the label

        container.addSubview(ring)
        container.addSubview(circle)
        circle.addSubview(imageView)
        //Removed label from container

        // constraints
        NSLayoutConstraint.activate([
            // Pin circle to top and center
            circle.topAnchor.constraint(equalTo: container.topAnchor, constant: 12), // Offset for ring
            circle.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            circle.widthAnchor.constraint(equalToConstant: 140),
            circle.heightAnchor.constraint(equalToConstant: 140),

            ring.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            ring.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            ring.widthAnchor.constraint(equalToConstant: 164),
            ring.heightAnchor.constraint(equalToConstant: 164),

            blur.leadingAnchor.constraint(equalTo: circle.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: circle.trailingAnchor),
            blur.topAnchor.constraint(equalTo: circle.topAnchor),
            blur.bottomAnchor.constraint(equalTo: circle.bottomAnchor),

            imageView.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: circle.widthAnchor, multiplier: 0.65),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            // Pin bottom of container to bottom of the RING (which is larger than the circle)
            container.bottomAnchor.constraint(equalTo: ring.bottomAnchor)
        ])

        container.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(circleTapped(_:)))
        container.addGestureRecognizer(tap)
        // Removed accessibilityIdentifier based on title

        return container
    }

    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func circleTapped(_ sender: UITapGestureRecognizer) {
        childSelected()
    }

    private func childSelected() {
        let vc = Addchildform()
        navigationController?.pushViewController(vc, animated: true)
    }
}
