//import UIKit
//
//final class Homelogin: UIViewController {
//    
//    // MARK: - UI Elements
//    
//    private let topContainer: UIView = {
//        let v = UIView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.clipsToBounds = true
//        return v
//    }()
//    
//    private let bottomCard: UIView = {
//        let v = UIView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.layer.cornerRadius = 28
//        v.layer.masksToBounds = true
//        if #available(iOS 11.0, *) {
//            v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        }
//        return v
//    }()
//    
//    private let appTitleLabel: UILabel = {
//        let l = UILabel()
//        l.translatesAutoresizingMaskIntoConstraints = false
//        l.text = "Cloudyyy"
//        l.font = UIFont.systemFont(ofSize: 56, weight: .black)
//        l.textColor = .white
//        l.textAlignment = .center
//        l.numberOfLines = 1
//        return l
//    }()
//    
//    private let subtitleLabel: UILabel = {
//        let l = UILabel()
//        l.translatesAutoresizingMaskIntoConstraints = false
//        l.text = "Organize tasks, Motivate Kids , Track Progress"
//        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        l.textColor = UIColor(white: 1.0, alpha: 0.95)
//        l.textAlignment = .center
//        l.numberOfLines = 2
//        return l
//    }()
//    
//    private let welcomeTitleLabel: UILabel = {
//        let l = UILabel()
//        l.translatesAutoresizingMaskIntoConstraints = false
//        l.text = "Welcome Family"
//        l.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
//        l.textColor = .white
//        l.textAlignment = .center
//        return l
//    }()
//    
//    private let welcomeSubtitleLabel: UILabel = {
//        let l = UILabel()
//        l.translatesAutoresizingMaskIntoConstraints = false
//        l.text = "Get Started With your Family"
//        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
//        l.textColor = UIColor(white: 1.0, alpha: 0.75)
//        l.textAlignment = .center
//        return l
//    }()
//    
//    private let backButton: UIButton = {
//        let b = UIButton(type: .system)
//        b.translatesAutoresizingMaskIntoConstraints = false
//        if #available(iOS 13.0, *) {
//            // Use a modern SF Symbol icon
//            let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
//            b.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
//        } else {
//            // Fallback for older iOS versions
//            b.setTitle("< Back", for: .normal)
//            b.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        }
//        b.tintColor = .white
//        // Set explicit size for a good tap target
//        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
//        b.widthAnchor.constraint(equalToConstant: 44).isActive = true
//        return b
//    }()
//    
//    private let loginButton: UIButton = {
//        let b = UIButton(type: .system)
//        b.translatesAutoresizingMaskIntoConstraints = false
//        b.setTitle("Log In", for: .normal)
//        b.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        b.setTitleColor(.white, for: .normal)
//        b.backgroundColor = UIColor(red: 0/255, green: 125/255, blue: 255/255, alpha: 1)
//        b.layer.cornerRadius = 12
//        b.layer.masksToBounds = true
//        b.heightAnchor.constraint(equalToConstant: 52).isActive = true
//        return b
//    }()
//    
//    private let signUpButton: UIButton = {
//        let b = UIButton(type: .system)
//        b.translatesAutoresizingMaskIntoConstraints = false
//        b.setTitle("Sign up", for: .normal)
//        b.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        b.setTitleColor(UIColor(white: 1.0, alpha: 0.95), for: .normal)
//        b.backgroundColor = .clear
//        b.layer.cornerRadius = 12
//        b.layer.borderWidth = 1
//        b.layer.borderColor = UIColor(white: 1.0, alpha: 0.12).cgColor
//        b.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        return b
//    }()
//    
//    // MARK: - Rotation/Centering Fix
//    // We create properties for the spacers so we can add
//    // a constraint to make them equal height.
//    private let topSpacer: UIView = {
//        let v = UIView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
//    
//    private let bottomSpacer: UIView = {
//        let v = UIView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
//    
//    // MARK: - Landscape Robustness Fix
//    // This scroll view will contain the bottomStack.
//    // This ensures that if the content is taller than the bottomCard (e.g., in landscape),
//    // it becomes scrollable instead of breaking the layout.
//    private let bottomScrollView: UIScrollView = {
//        let sv = UIScrollView()
//        sv.translatesAutoresizingMaskIntoConstraints = false
//        sv.showsVerticalScrollIndicator = false
//        sv.showsHorizontalScrollIndicator = false
//        return sv
//    }()
//    
//    private lazy var bottomStack: UIStackView = {
//        let sv = UIStackView(arrangedSubviews: [
//            topSpacer, // Use the property
//            welcomeTitleLabel,
//            welcomeSubtitleLabel,
//            spacer(height: 18),
//            loginButton,
//            spacer(height: 18),
//            signUpButton,
//            bottomSpacer // Use the property
//        ])
//        sv.translatesAutoresizingMaskIntoConstraints = false
//        sv.axis = .vertical
//        sv.alignment = .fill
//        sv.spacing = 12
//        return sv
//    }()
//    
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // match the top blue so tiny seams don't show the default white background
//        view.backgroundColor = UIColor(red: 21/255, green: 130/255, blue: 255/255, alpha: 1)
//        
//        setupLayout()
//        applyGradients()
//        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
//        signUpButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
//        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        // update gradient frames to current bounds
//        if let topGradient = topContainerGradient {
//            topGradient.frame = topContainer.bounds
//        }
//        if let bottomGradient = bottomCardGradient {
//            bottomGradient.frame = bottomCard.bounds
//            bottomGradient.cornerRadius = bottomCard.layer.cornerRadius
//        }
//    }
//    
//    // MARK: - Actions
//    
//    @objc private func backButtonTapped() {
//        print("Back button tapped")
//        // Add dismissal logic here, for example:
//         if let nav = navigationController {
//             nav.popViewController(animated: true)
//         } else {
//             dismiss(animated: true)
//         }
//    }
//    
//    @objc private func loginTapped() {
//        print("Login tapped")
//        let loginVC = Login()
//        navigationController?.pushViewController(loginVC, animated: true)
//    }
//    
//    @objc private func signupTapped() {
//        print("Signup tapped")
//        let signupVC = Signup()
//        navigationController?.pushViewController(signupVC, animated: true)
//    }
//    
//    // MARK: - Layout helpers
//    
//    private func spacer(height: CGFloat) -> UIView {
//        let v = UIView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.heightAnchor.constraint(equalToConstant: height).isActive = true
//        return v
//    }
//    
//    // Keep references to gradient layers so we can update frames on rotation
//    private var topContainerGradient: CAGradientLayer?
//    private var bottomCardGradient: CAGradientLayer?
//    
//    private func setupLayout() {
//        // add subviews
//        view.addSubview(topContainer)
//        view.addSubview(bottomCard)
//        
//        topContainer.addSubview(appTitleLabel)
//        topContainer.addSubview(subtitleLabel)
//        topContainer.addSubview(backButton) // Add back button
//        
//        // MARK: - Landscape Robustness Fix
//        // Add the scrollView to the card, and the stack to the scrollView.
//        bottomCard.addSubview(bottomScrollView)
//        bottomScrollView.addSubview(bottomStack)
//        
//        // enforce bottomCard = half screen height
//        let bottomCardHeightConstraint = bottomCard.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
//        bottomCardHeightConstraint.isActive = true
//        
//        
//        // MARK: - ScrollView Content Centering
//        // We need to make the stack view fill the scroll view's height
//        // so the flexible spacers can center the content.
//        // We give this a low priority so that if the content is *taller*
//        // than the scroll view, it's allowed to grow and scrolling enables.
//        let stackHeightConstraint = bottomStack.heightAnchor.constraint(equalTo: bottomScrollView.frameLayoutGuide.heightAnchor, constant: -40) // -40 for padding
//        stackHeightConstraint.priority = .defaultLow
//        
//        NSLayoutConstraint.activate([
//            // pin topContainer to top (no white gap)
//            topContainer.topAnchor.constraint(equalTo: view.topAnchor),
//            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            
//            // bottom card pinned to bottom
//            bottomCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            bottomCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            bottomCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            // tie topContainer bottom to bottomCard top but overlap 1pt to avoid seam
//            bottomCard.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -1),
//            
//            // Back button
//            backButton.leadingAnchor.constraint(equalTo: topContainer.safeAreaLayoutGuide.leadingAnchor, constant: 16),
//            // --- FIX: Constrain to the TOP of the safe area, not the title's center ---
//            backButton.topAnchor.constraint(equalTo: topContainer.safeAreaLayoutGuide.topAnchor, constant: 16),
//            
//            // title + subtitle in top container
//            appTitleLabel.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
//            appTitleLabel.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor, constant: -10),
//            
//            subtitleLabel.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor, constant: 8),
//            subtitleLabel.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
//            subtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: topContainer.leadingAnchor, constant: 28),
//            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: topContainer.trailingAnchor, constant: -28),
//            
//            // MARK: - Landscape Robustness Fix
//            // Pin the scrollView to the edges of the bottomCard
//            bottomScrollView.topAnchor.constraint(equalTo: bottomCard.topAnchor),
//            bottomScrollView.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor),
//            bottomScrollView.trailingAnchor.constraint(equalTo: bottomCard.trailingAnchor),
//            bottomScrollView.bottomAnchor.constraint(equalTo: bottomCard.bottomAnchor),
//            
//            // Pin the bottomStack to the scrollView's content area
//            bottomStack.topAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.topAnchor, constant: 20),
//            bottomStack.bottomAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.bottomAnchor, constant: -20),
//            bottomStack.leadingAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.leadingAnchor, constant: 28),
//            bottomStack.trailingAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.trailingAnchor, constant: -28),
//            
//            // Pin the stack's width to the scrollView's frame (to enable vertical scroll)
//            bottomStack.widthAnchor.constraint(equalTo: bottomScrollView.frameLayoutGuide.widthAnchor, constant: -56), // 28pt padding on each side
//            
//            // Activate the low-priority height constraint for centering
//            stackHeightConstraint,
//        ])
//        
//        // MARK: - Rotation/Centering Fix
//        // By constraining the top and bottom spacers to be equal height,
//        // we ensure the stack view distributes extra space evenly,
//        // which keeps the content centered vertically in portrait mode.
//        // This fixes the bug when rotating from landscape back to portrait.
//        topSpacer.heightAnchor.constraint(equalTo: bottomSpacer.heightAnchor).isActive = true
//        
//        // MARK: - AutoLayout Conflict Fixes
//        // (Conflicts removed in previous step)
//    }
//    
//    // MARK: - Gradients
//    
//    private func applyGradients() {
//        // Top blue gradient
//        let topGradient = CAGradientLayer()
//        topGradient.colors = [
//            UIColor(red: 21/255, green: 130/255, blue: 255/255, alpha: 1).cgColor,
//            UIColor(red: 54/255, green: 114/255, blue: 241/255, alpha: 1).cgColor
//        ]
//        topGradient.startPoint = CGPoint(x: 0.5, y: 0)
//        topGradient.endPoint = CGPoint(x: 0.5, y: 1)
//        
//        // Bottom gradient — uses the exact colors you requested (#0C0C0C -> #203B6F)
//        let bottomGradient = CAGradientLayer()
//        bottomGradient.colors = [
//            UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1).cgColor,  // #0C0C0C
//            UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1).cgColor  // #203B6F
//        ]
//        bottomGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
//        bottomGradient.endPoint   = CGPoint(x: 0.5, y: 1.0)
//        
//        // Remove any existing gradient layers first
//        topContainer.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
//        bottomCard.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
//        
//        // Insert new gradients and store references
//        topContainer.layer.insertSublayer(topGradient, at: 0)
//        bottomCard.layer.insertSublayer(bottomGradient, at: 0)
//        topContainerGradient = topGradient
//        bottomCardGradient = bottomGradient
//        
//        // Make the bottom gradient respect the rounded corners
//        bottomGradient.cornerRadius = bottomCard.layer.cornerRadius
//        bottomCard.layer.masksToBounds = true
//        
//        // set initial frames (will be updated in viewDidLayoutSubviews)
//        topGradient.frame = topContainer.bounds
//        bottomGradient.frame = bottomCard.bounds
//    }
//}
