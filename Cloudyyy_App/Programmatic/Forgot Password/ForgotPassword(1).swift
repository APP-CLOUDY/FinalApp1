//
//  ForgotPassword.swift
//  Cloudyyy_App
//

import UIKit

// MARK: - SHARED COMPONENTS (Include this to fix the "Cannot find" error)

// 1. Premium Gradient Button
final class PremiumLoginButton: UIButton {
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayer() {
        // Gradient: Left #0B67FF -> Right #3AA1FF
        gradientLayer.colors = [
            UIColor(red: 11/255, green: 103/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 58/255, green: 161/255, blue: 255/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 18
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
            }
        }
    }
}

// 2. Base View Controller (Handles the Dark Gradient Background & Logo)
class PremiumBaseViewController: UIViewController {
    
    // Background
    private let backgroundContainer = UIView()
    private let gradientLayer = CAGradientLayer()
    
    // Logo & Glow
    private let logoContainer = UIView()
    private let logoGlow = UIView()
    private let logoImageView = UIImageView()
    
    // Header Title
    let headerTitleLabel = UILabel()
    let headerSubtitleLabel = UILabel()
    
    // Back Button
    let backButton = UIButton(type: .system)
    
    // Card Container
    let cardView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupBaseUI() {
        // 1. Background
        view.addSubview(backgroundContainer)
        backgroundContainer.translatesAutoresizingMaskIntoConstraints = false
        
        gradientLayer.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor, // Dark Obsidian
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor  // Deep Steel Blue
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        backgroundContainer.layer.addSublayer(gradientLayer)
        
        // 2. Back Button
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        // 3. Logo
        view.addSubview(logoContainer)
        logoContainer.addSubview(logoGlow)
        logoContainer.addSubview(logoImageView)
        logoContainer.translatesAutoresizingMaskIntoConstraints = false
        logoGlow.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Logo Styling
        logoImageView.image = UIImage(named: "app_logo")
        logoImageView.contentMode = .scaleAspectFit
        
        logoGlow.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        logoGlow.layer.cornerRadius = 50
        logoGlow.layer.shadowColor = UIColor.white.cgColor
        logoGlow.layer.shadowOpacity = 0.5
        logoGlow.layer.shadowOffset = .zero
        logoGlow.layer.shadowRadius = 20
        
        // 4. Header Text
        view.addSubview(headerTitleLabel)
        view.addSubview(headerSubtitleLabel)
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerTitleLabel.textColor = .white
        headerTitleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        headerTitleLabel.textAlignment = .center
        
        headerSubtitleLabel.textColor = UIColor(white: 0.85, alpha: 1)
        headerSubtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        headerSubtitleLabel.textAlignment = .center
        headerSubtitleLabel.numberOfLines = 0
        
        // 5. Card
        view.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 252/255, alpha: 0.97)
        cardView.layer.cornerRadius = 30
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 20
        cardView.layer.shadowOffset = CGSize(width: 0, height: 10)
        
        // Base Constraints
        NSLayoutConstraint.activate([
            backgroundContainer.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            logoContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoContainer.widthAnchor.constraint(equalToConstant: 100),
            logoContainer.heightAnchor.constraint(equalToConstant: 100),
            
            logoGlow.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            logoGlow.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor),
            logoGlow.widthAnchor.constraint(equalToConstant: 100),
            logoGlow.heightAnchor.constraint(equalToConstant: 100),
            
            logoImageView.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            headerTitleLabel.topAnchor.constraint(equalTo: logoContainer.bottomAnchor, constant: 24),
            headerTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            headerSubtitleLabel.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 12),
            headerSubtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            headerSubtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            cardView.topAnchor.constraint(equalTo: headerSubtitleLabel.bottomAnchor, constant: 32),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            // Card height will be determined by its content in subclasses
        ])
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // Helper to create consistent text fields
    func makeTextField(placeholder: String, icon: String? = nil) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor(red: 242/255, green: 243/255, blue: 245/255, alpha: 1)
        tf.layer.cornerRadius = 18
        tf.font = .systemFont(ofSize: 16)
        tf.textColor = .black
        
        let placeholderColor = UIColor(red: 184/255, green: 189/255, blue: 201/255, alpha: 1)
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: placeholderColor])
        
        let pad = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 56))
        tf.leftView = pad
        tf.leftViewMode = .always
        
        tf.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return tf
    }
}

// MARK: - 1. FORGOT PASSWORD SCREEN (Enter Email)
final class ForgotPassword: PremiumBaseViewController {

    private let emailLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Email Address"
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }()
    
    private lazy var emailField = makeTextField(placeholder: "example@gmail.com")
    
    private let sendButton: PremiumLoginButton = {
        let b = PremiumLoginButton(frame: .zero)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Send Code", for: .normal)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Titles
        headerTitleLabel.text = "Forgot Password?"
        headerSubtitleLabel.text = "Don't worry! It happens. Please enter the email associated with your account."
        
        setupContent()
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
    }
    
    private func setupContent() {
        cardView.addSubview(emailLabel)
        cardView.addSubview(emailField)
        cardView.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            emailLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            
            emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            sendButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 32),
            sendButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 56),
            sendButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -30)
        ])
    }
    
    @objc private func didTapSend() {
        // Navigate to Next Step
        let vc = VerifyOTP()
        vc.emailAddress = emailField.text
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - 2. VERIFY OTP SCREEN
final class VerifyOTP: PremiumBaseViewController {
    
    var emailAddress: String?
    
    private let otpStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.distribution = .fillEqually
        s.spacing = 12
        return s
    }()
    
    private let verifyButton: PremiumLoginButton = {
        let b = PremiumLoginButton(frame: .zero)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Verify", for: .normal)
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerTitleLabel.text = "Verify Email"
        headerSubtitleLabel.text = "We have sent a code to\n\(emailAddress ?? "your email")"
        
        setupContent()
        setupOTPFields()
        verifyButton.addTarget(self, action: #selector(didTapVerify), for: .touchUpInside)
    }
    
    private func setupContent() {
        cardView.addSubview(otpStack)
        cardView.addSubview(verifyButton)
        
        NSLayoutConstraint.activate([
            otpStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 40),
            otpStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            otpStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            otpStack.heightAnchor.constraint(equalToConstant: 60),
            
            verifyButton.topAnchor.constraint(equalTo: otpStack.bottomAnchor, constant: 32),
            verifyButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            verifyButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            verifyButton.heightAnchor.constraint(equalToConstant: 56),
            verifyButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupOTPFields() {
        for _ in 0..<4 {
            let tf = UITextField()
            tf.backgroundColor = UIColor(red: 242/255, green: 243/255, blue: 245/255, alpha: 1)
            tf.layer.cornerRadius = 12
            tf.textAlignment = .center
            tf.font = .systemFont(ofSize: 24, weight: .bold)
            tf.textColor = .black
            tf.keyboardType = .numberPad
            otpStack.addArrangedSubview(tf)
        }
    }
    
    @objc private func didTapVerify() {
        let vc = ResetPassword()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - 3. RESET PASSWORD SCREEN
final class ResetPassword: PremiumBaseViewController {
    
    private let newPassLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "New Password"
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }()
    
    private let confirmPassLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Confirm Password"
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }()
    
    private lazy var newPassField = makeTextField(placeholder: "Enter new password")
    private lazy var confirmPassField = makeTextField(placeholder: "Re-enter password")
    
    private let updateButton: PremiumLoginButton = {
        let b = PremiumLoginButton(frame: .zero)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Update Password", for: .normal)
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerTitleLabel.text = "New Password"
        headerSubtitleLabel.text = "Your new password must be different from previously used passwords."
        
        setupContent()
        updateButton.addTarget(self, action: #selector(didTapUpdate), for: .touchUpInside)
        
        newPassField.isSecureTextEntry = true
        confirmPassField.isSecureTextEntry = true
    }
    
    private func setupContent() {
        cardView.addSubview(newPassLabel)
        cardView.addSubview(newPassField)
        cardView.addSubview(confirmPassLabel)
        cardView.addSubview(confirmPassField)
        cardView.addSubview(updateButton)
        
        NSLayoutConstraint.activate([
            newPassLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            newPassLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            
            newPassField.topAnchor.constraint(equalTo: newPassLabel.bottomAnchor, constant: 8),
            newPassField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            newPassField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            confirmPassLabel.topAnchor.constraint(equalTo: newPassField.bottomAnchor, constant: 20),
            confirmPassLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            
            confirmPassField.topAnchor.constraint(equalTo: confirmPassLabel.bottomAnchor, constant: 8),
            confirmPassField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            confirmPassField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            updateButton.topAnchor.constraint(equalTo: confirmPassField.bottomAnchor, constant: 32),
            updateButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            updateButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            updateButton.heightAnchor.constraint(equalToConstant: 56),
            updateButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -30)
        ])
    }
    
    @objc private func didTapUpdate() {
        // Simulate Success & Return to Login
        navigationController?.popToRootViewController(animated: true)
    }
}
