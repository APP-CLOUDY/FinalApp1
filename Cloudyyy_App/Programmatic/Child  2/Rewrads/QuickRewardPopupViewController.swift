import UIKit

final class QuickRewardPopupViewController: UIViewController {
    
    // Data
    var rewardName: String?
    var rewardImage: UIImage?
    var cost: Int = 100
    
    // MARK: - UI Elements
    
    // 1. Semi-transparent background
    private lazy var dimmedBackgroundView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .black
        v.alpha = 0
        return v
    }()
    
    // 2. The White Card
    private let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 30 // Higher radius as per screenshot
        v.layer.cornerCurve = .continuous
        v.clipsToBounds = true
        return v
    }()
    
    // 3. Content
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Quick Rewards"
        lb.font = .systemFont(ofSize: 18, weight: .bold)
        lb.textColor = .black
        lb.textAlignment = .center
        return lb
    }()
    
    private let mascotImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "cloudyy_logo") ?? UIImage(systemName: "gift.fill")
        return iv
    }()
    
    private lazy var actionButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        // Cyan blue color from screenshot
        b.backgroundColor = UIColor(red: 76/255, green: 218/255, blue: 254/255, alpha: 1.0)
        b.layer.cornerRadius = 25 // Pill shape
        
        // Add shadow for "3D" button effect
        b.layer.shadowColor = UIColor(red: 90/255, green: 210/255, blue: 255/255, alpha: 1.0).cgColor
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.layer.shadowOpacity = 0.3
        b.layer.shadowRadius = 4
        
        b.addTarget(self, action: #selector(handleSpend), for: .touchUpInside)
        return b
    }()
    
    private let balanceLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        // Text is now set in configureData using attributed string
        lb.textAlignment = .center
        return lb
    }()
    
    // Constraint to animate bottom position
    private var containerBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        configureData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShow()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(dimmedBackgroundView)
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(mascotImageView)
        containerView.addSubview(actionButton)
        containerView.addSubview(balanceLabel)
        
        // Initial layout
        NSLayoutConstraint.activate([
            // Background fills screen
            dimmedBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Container Card Width (with padding)
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Internal Layout
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            mascotImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            mascotImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            mascotImageView.heightAnchor.constraint(equalToConstant: 160),
            mascotImageView.widthAnchor.constraint(equalToConstant: 180),
            
            actionButton.topAnchor.constraint(equalTo: mascotImageView.bottomAnchor, constant: 30),
            actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
            
            balanceLabel.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 20),
            balanceLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            balanceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30) // Important for auto-height
        ])
        
        // Start Position (Off-screen bottom)
        containerBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 500)
        containerBottomConstraint?.isActive = true
        
        view.layoutIfNeeded()
    }
    
    private func configureData() {
        // 1. Configure Action Button Title with Gold Star
        let buttonPrefix = "Spend \(cost) "
        let buttonSuffix = rewardName != nil ? " for \(rewardName!)" : ""
        let buttonAttributedTitle = createGoldStarString(prefix: buttonPrefix, suffix: buttonSuffix, fontSize: 18, textColor: .white, weight: .bold)
        
        actionButton.setAttributedTitle(buttonAttributedTitle, for: .normal)
        
        // 2. Configure Balance Label with Gold Star
        let balanceAttributedText = createGoldStarString(prefix: "Balance : 300 ", suffix: "", fontSize: 15, textColor: .black, weight: .semibold)
        balanceLabel.attributedText = balanceAttributedText
    }
    
    // MARK: - Helpers
    
    private func createGoldStarString(prefix: String, suffix: String, fontSize: CGFloat, textColor: UIColor, weight: UIFont.Weight) -> NSAttributedString {
        // Define Gold Color
        let goldColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1.0)
        
        // Create the mutable string
        let fullString = NSMutableAttributedString()
        
        // 1. Add Prefix
        let prefixAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: weight),
            .foregroundColor: textColor
        ]
        fullString.append(NSAttributedString(string: prefix, attributes: prefixAttributes))
        
        // 2. Add Gold Star Icon
        let config = UIImage.SymbolConfiguration(pointSize: fontSize, weight: .regular)
        if let starImage = UIImage(systemName: "star.fill", withConfiguration: config)?.withTintColor(goldColor, renderingMode: .alwaysOriginal) {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = starImage
            // Adjust bounds to align vertically with text
            let yOffset = (fontSize - starImage.size.height) / 2.0 - 2.0
            imageAttachment.bounds = CGRect(x: 0, y: yOffset, width: starImage.size.width, height: starImage.size.height)
            
            fullString.append(NSAttributedString(attachment: imageAttachment))
        }
        
        // 3. Add Suffix
        if !suffix.isEmpty {
            let suffixAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize, weight: weight),
                .foregroundColor: textColor
            ]
            fullString.append(NSAttributedString(string: suffix, attributes: suffixAttributes))
        }
        
        return fullString
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        dimmedBackgroundView.addGestureRecognizer(tap)
    }
    
    // MARK: - Animations
    
    private func animateShow() {
        // Slide Up Animation
        // 1. Fade in background
        UIView.animate(withDuration: 0.3) {
            self.dimmedBackgroundView.alpha = 0.5
        }
        
        // 2. Slide card up
        // We set the bottom constant to a negative value to give it that "floating" look above bottom safe area
        self.containerBottomConstraint?.constant = -40 // Floating margin from bottom
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleDismiss() {
        // Slide Down Animation
        UIView.animate(withDuration: 0.3) {
            self.dimmedBackgroundView.alpha = 0
        }
        
        self.containerBottomConstraint?.constant = 500 // Push off screen
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
    @objc private func handleSpend() {
        print("Spending stars...")
        handleDismiss()
    }
}
