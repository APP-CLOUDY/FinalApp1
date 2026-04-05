import UIKit

final class NetworkAlertViewController: UIViewController {

    private var mascotImageView: UIImageView?
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var mainStack: UIStackView?
    private var buttonsStack: UIStackView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupUI()
    }
    
    private func setupUI() {
        // Dimmed background
        let dimView = UIView()
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.addSubview(dimView)
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Activity Indicator (Hidden by default)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Context aware view based on role
        let isChild = SessionManager.shared.currentRole == .child
        
        if isChild {
            setupChildUI()
        } else {
            setupParentUI()
        }
    }
    
    private func setupChildUI() {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 24
        blurView.clipsToBounds = true
        view.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blurView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            blurView.widthAnchor.constraint(equalToConstant: 290)
        ])
        
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "cloudyy_please")
        iv.contentMode = .scaleAspectFit
        self.mascotImageView = iv
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Oops! No Internet ☁️"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        let msgLabel = UILabel()
        msgLabel.translatesAutoresizingMaskIntoConstraints = false
        msgLabel.text = "We lost connection to the cloud. Please check your internet setup!"
        msgLabel.font = .systemFont(ofSize: 15, weight: .medium)
        msgLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        msgLabel.textAlignment = .center
        msgLabel.numberOfLines = 0
        
        let retryBtn = UIButton(type: .system)
        retryBtn.setTitle("Retry ☁️", for: .normal)
        retryBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        retryBtn.backgroundColor = .white
        retryBtn.setTitleColor(.systemBlue, for: .normal)
        retryBtn.layer.cornerRadius = 18
        retryBtn.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        
        let okayBtn = UIButton(type: .system)
        okayBtn.setTitle("Okay", for: .normal)
        okayBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        okayBtn.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        okayBtn.setTitleColor(.white, for: .normal)
        okayBtn.layer.cornerRadius = 18
        okayBtn.addTarget(self, action: #selector(handleOkay), for: .touchUpInside)
        
        let bStack = UIStackView(arrangedSubviews: [okayBtn, retryBtn])
        bStack.axis = .horizontal
        bStack.spacing = 12
        bStack.distribution = .fillEqually
        self.buttonsStack = bStack
        
        let stack = UIStackView(arrangedSubviews: [iv, titleLabel, msgLabel, bStack])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.mainStack = stack
        
        stack.setCustomSpacing(8, after: titleLabel)
        
        blurView.contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -20),
            
            iv.heightAnchor.constraint(equalToConstant: 90),
            bStack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupParentUI() {
        let blurEffect = UIBlurEffect(style: .systemThinMaterialLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 16
        blurView.clipsToBounds = true
        view.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blurView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            blurView.widthAnchor.constraint(equalToConstant: 280)
        ])
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: "wifi.slash")
        iconView.tintColor = .systemRed
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "No Internet Connection"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        let msgLabel = UILabel()
        msgLabel.text = "Please check your network setup."
        msgLabel.font = .systemFont(ofSize: 15, weight: .regular)
        msgLabel.textColor = .secondaryLabel
        msgLabel.textAlignment = .center
        msgLabel.numberOfLines = 0
        
        let retryBtn = UIButton(type: .system)
        retryBtn.setTitle("Retry", for: .normal)
        retryBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        retryBtn.setTitleColor(.systemBlue, for: .normal)
        retryBtn.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        
        let okayBtn = UIButton(type: .system)
        okayBtn.setTitle("Dismiss", for: .normal)
        okayBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        okayBtn.setTitleColor(.label, for: .normal)
        okayBtn.addTarget(self, action: #selector(handleOkay), for: .touchUpInside)
        
        let bStack = UIStackView(arrangedSubviews: [okayBtn, retryBtn])
        bStack.axis = .horizontal
        bStack.spacing = 15
        bStack.distribution = .fillEqually
        self.buttonsStack = bStack
        
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, msgLabel, bStack])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.mainStack = stack
        
        blurView.contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -20),
            
            iconView.heightAnchor.constraint(equalToConstant: 30),
            bStack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Actions
    @objc private func handleOkay() {
        NetworkMonitor.shared.forceDismiss()
    }
    
    @objc private func handleRetry() {
        // Haptics for Parent
        if SessionManager.shared.currentRole == .parent {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        
        // Animate Mascot if Child
        if let iv = mascotImageView {
            UIView.animate(withDuration: 0.3, animations: {
                iv.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { _ in
                UIView.animate(withDuration: 0.3) {
                    iv.transform = .identity
                }
            }
        }
        
        // Show Loading State
        mainStack?.alpha = 0
        activityIndicator.startAnimating()
        
        // Disable buttons (already in stack so they are hidden via alpha)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            if NetworkMonitor.shared.isCurrentConnectionSatisfied {
                NetworkMonitor.shared.forceDismiss()
            } else {
                // Return to original state
                self.activityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.3) {
                    self.mainStack?.alpha = 1
                }
            }
        }
    }
}


