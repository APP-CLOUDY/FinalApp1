import UIKit

final class Homejoin: UIViewController {

    // MARK: - UI Elements

    private let topContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        return v
    }()

    private let bottomCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 28
        // clip to keep rounded corners clean
        v.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
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

    private let welcomeTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Welcome Family"
        l.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let welcomeSubtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Get Started With your Family"
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(white: 1.0, alpha: 0.75)
        l.textAlignment = .center
        return l
    }()

    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            // Use a modern SF Symbol icon
            let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
            b.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        } else {
            // Fallback for older iOS versions
            b.setTitle("< Back", for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        }
        b.tintColor = .white
        // Set explicit size for a good tap target
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        b.widthAnchor.constraint(equalToConstant: 44).isActive = true
        return b
    }()

    private let joinWithCodeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Join with Code", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        b.backgroundColor = UIColor(red: 40/255, green: 125/255, blue: 255/255, alpha: 1)
        b.layer.cornerRadius = 14
        b.layer.masksToBounds = true
        b.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return b
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

    // MARK: - Landscape Robustness Fix
    private let bottomScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()

    private lazy var bottomStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            topSpacer, // Use the property
            welcomeTitleLabel,
            welcomeSubtitleLabel,
            spacer(height: 18),
            joinWithCodeButton,
            bottomSpacer // Use the property
        ])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .fill
        sv.spacing = 12
        return sv
    }()

    // MARK: - Gradient refs

    private var topContainerGradient: CAGradientLayer?
    private var bottomCardGradient: CAGradientLayer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // match the top blue so tiny seams don't show the default white background
        view.backgroundColor = UIColor(red: 21/255, green: 130/255, blue: 255/255, alpha: 1)

        setupLayout()
        applyGradients()

        joinWithCodeButton.addTarget(self, action: #selector(joinWithCodeTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // update gradient frames to current bounds
        topContainerGradient?.frame = topContainer.bounds
        
        // MARK: - Layout Fix
        // Update frame AND corner radius on the gradient layer itself
        if let bottomGradient = bottomCardGradient {
            bottomGradient.frame = bottomCard.bounds
            bottomGradient.cornerRadius = bottomCard.layer.cornerRadius
        }
        
        // The bringSubviewToFront call was removed as it's not
        // necessary and pointed to the wrong view (button is in the scrollview).
    }

    // MARK: - Actions

    @objc private func backButtonTapped() {
        print("Back button tapped")
         //Add dismissal logic here, for example:
         if let nav = navigationController {
             nav.popViewController(animated: true)
         } else {
             dismiss(animated: true)
         }
    }

    @objc private func joinWithCodeTapped() {
        print("Join With Code tapped")
        
        // 1. Create an instance of the view controller you want to show
        let joinVC = JoinWithCode()
        
        // 2. Push it onto the navigation controller's stack
        // (This assumes the current view controller is already inside a UINavigationController)
        navigationController?.pushViewController(joinVC, animated: true)
    }

    // MARK: - Layout helpers

    private func spacer(height: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }

    private func setupLayout() {
        view.addSubview(topContainer)
        view.addSubview(bottomCard)

        topContainer.addSubview(appTitleLabel)
        topContainer.addSubview(subtitleLabel)
        topContainer.addSubview(backButton) // Add back button to top container
        
        // MARK: - Landscape Robustness Fix
        // Add scrollView to card, stack to scrollView
        bottomCard.addSubview(bottomScrollView)
        bottomScrollView.addSubview(bottomStack)

        // bottom card height - using half screen like your original design
        let bottomCardHeightConstraint = bottomCard.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        bottomCardHeightConstraint.isActive = true

        // MARK: - ScrollView Content Centering
        let stackHeightConstraint = bottomStack.heightAnchor.constraint(equalTo: bottomScrollView.frameLayoutGuide.heightAnchor, constant: -40) // -40 for padding
        stackHeightConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            // pin topContainer to top (no white gap)
            topContainer.topAnchor.constraint(equalTo: view.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // bottom card pinned to bottom
            bottomCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // tie topContainer bottom to bottomCard top but overlap 1pt to avoid seam
            bottomCard.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -1),

            // Back button
            backButton.leadingAnchor.constraint(equalTo: topContainer.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            // --- FIX: Constrain to the TOP of the safe area, not the title's center ---
            backButton.topAnchor.constraint(equalTo: topContainer.safeAreaLayoutGuide.topAnchor, constant: 16),

            // title + subtitle in top container
            appTitleLabel.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            appTitleLabel.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor, constant: -10),

            subtitleLabel.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: topContainer.leadingAnchor, constant: 28),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: topContainer.trailingAnchor, constant: -28),

            // MARK: - Landscape Robustness Fix
            // Pin the scrollView to the edges of the bottomCard
            bottomScrollView.topAnchor.constraint(equalTo: bottomCard.topAnchor),
            bottomScrollView.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor),
            bottomScrollView.trailingAnchor.constraint(equalTo: bottomCard.trailingAnchor),
            bottomScrollView.bottomAnchor.constraint(equalTo: bottomCard.bottomAnchor),
            
            // Pin the bottomStack to the scrollView's content area
            bottomStack.topAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.topAnchor, constant: 20),
            bottomStack.bottomAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            bottomStack.leadingAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.leadingAnchor, constant: 28),
            bottomStack.trailingAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.trailingAnchor, constant: -28),
            
            // Pin the stack's width to the scrollView's frame (to enable vertical scroll)
            bottomStack.widthAnchor.constraint(equalTo: bottomScrollView.frameLayoutGuide.widthAnchor, constant: -56), // 28pt padding on each side
            
            // Activate the low-priority height constraint for centering
            stackHeightConstraint,
        ])

        // MARK: - Rotation/Centering Fix
        // Force spacers to be equal height
        topSpacer.heightAnchor.constraint(equalTo: bottomSpacer.heightAnchor).isActive = true
        
        // MARK: - AutoLayout Conflict Fixes
        // Removed conflicting constraints that were fighting the stack view
        // 1. welcomeTitleLabel.centerXAnchor...
        // 2. welcomeSubtitleLabel.centerXAnchor...
        // 3. joinWithCodeButton.leadingAnchor...
        // 4. joinWithCodeButton.trailingAnchor...
    }

    // MARK: - Gradients

    private func applyGradients() {
        // Top blue gradient
        let topGradient = CAGradientLayer()
        topGradient.colors = [
            UIColor(red: 21/255, green: 130/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 54/255, green: 114/255, blue: 241/255, alpha: 1).cgColor
        ]
        topGradient.startPoint = CGPoint(x: 0.5, y: 0)
        topGradient.endPoint = CGPoint(x: 0.5, y: 1)
        topContainer.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        topContainer.layer.insertSublayer(topGradient, at: 0)
        topContainerGradient = topGradient
        topGradient.frame = topContainer.bounds // Set initial frame

        // Bottom gradient — dark to blueish (improved contrast)
        let bottomGradient = CAGradientLayer()
        bottomGradient.colors = [
            UIColor(red: 6/255, green: 6/255, blue: 6/255, alpha: 1).cgColor,
            UIColor(red: 20/255, green: 46/255, blue: 86/255, alpha: 1).cgColor
        ]
        bottomGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        bottomGradient.endPoint   = CGPoint(x: 0.5, y: 1.0)
        bottomCard.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        bottomCard.layer.insertSublayer(bottomGradient, at: 0)
        bottomCardGradient = bottomGradient

        // Make the gradient respect corner radius
        bottomGradient.cornerRadius = bottomCard.layer.cornerRadius
        bottomGradient.frame = bottomCard.bounds // Set initial frame
    }
}
