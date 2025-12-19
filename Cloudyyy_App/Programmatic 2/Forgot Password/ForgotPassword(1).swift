//
//  ForgotPassword.swift
//  Cloudyyy_App
//

import UIKit

// MARK: - SHARED COMPONENTS

// 1. Premium Gradient Button (Unchanged)
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
        // Gradient: Blue Theme
        gradientLayer.colors = [
            UIColor(red: 11/255, green: 103/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 58/255, green: 161/255, blue: 255/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 18
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Shadow for depth
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

// 2. Base View Controller (Handles Styling & Layout)
class PremiumBaseViewController: UIViewController {
    
    private let backgroundContainer = UIView()
    private let gradientLayer = CAGradientLayer()
    
    private let logoContainer = UIView()
    private let logoGlow = UIView()
    private let logoImageView = UIImageView()
    
    let headerTitleLabel = UILabel()
    let headerSubtitleLabel = UILabel()
    
    let backButton = UIButton(type: .system)
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
        // Make the card slightly off-white so the white input fields stand out
        cardView.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 253/255, alpha: 1)
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
        ])
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // --- THIS IS THE FUNCTION THAT CONTROLS TEXT FIELD LOOK ---
    func makeTextField(placeholder: String, icon: String? = nil) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        // 1. Background White
        tf.backgroundColor = .white
        
        // 2. Visible Outline (Grey Border)
        tf.layer.borderWidth = 1.0
        tf.layer.borderColor = UIColor.systemGray4.cgColor // Visible Light Grey
        
        // 3. Smooth Corner Radius
        tf.layer.cornerRadius = 14
        
        tf.font = .systemFont(ofSize: 16)
        tf.textColor = .black
        
        // Placeholder Styling
        let placeholderColor = UIColor.systemGray
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: placeholderColor])
        
        // Padding
        let pad = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 56))
        tf.leftView = pad
        tf.leftViewMode = .always
        
        tf.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return tf
    }
}

// MARK: - 1. FORGOT PASSWORD SCREEN
final class ForgotPassword: PremiumBaseViewController {
    
    private lazy var emailField = makeTextField(placeholder: "Enter your email address")
    
    private let sendButton: PremiumLoginButton = {
        let b = PremiumLoginButton(frame: .zero)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Send Code", for: .normal)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerTitleLabel.text = "Forgot Password?"
        headerSubtitleLabel.text = "Please enter the email associated with your account."
        
        setupContent()
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
    }
    
    private func setupContent() {
        cardView.addSubview(emailField)
        cardView.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            emailField.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
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
        let vc = VerifyOTP()
        vc.emailAddress = emailField.text
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - 2. VERIFY OTP SCREEN (5 Digit Layout)
final class VerifyOTP: PremiumBaseViewController, UITextFieldDelegate {
    
    var emailAddress: String?
    
    private var otpFields: [UITextField] = []
    
    private let otpStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.distribution = .fillEqually
        s.spacing = 10 // Smooth spacing for 5 items
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
        
        otpFields.first?.becomeFirstResponder()
    }
    
    private func setupContent() {
        cardView.addSubview(otpStack)
        cardView.addSubview(verifyButton)
        
        NSLayoutConstraint.activate([
            otpStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 40),
            otpStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            otpStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            otpStack.heightAnchor.constraint(equalToConstant: 60),
            
            verifyButton.topAnchor.constraint(equalTo: otpStack.bottomAnchor, constant: 32),
            verifyButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            verifyButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            verifyButton.heightAnchor.constraint(equalToConstant: 56),
            verifyButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupOTPFields() {
        // --- 5 SPACES AS REQUESTED ---
        for index in 0..<5 {
            let tf = UITextField()
            
            // STYLE: White BG with Grey Outline
            tf.backgroundColor = .white
            tf.layer.borderWidth = 1.0
            tf.layer.borderColor = UIColor.systemGray4.cgColor
            tf.layer.cornerRadius = 14
            
            tf.textAlignment = .center
            tf.font = .systemFont(ofSize: 24, weight: .bold)
            tf.textColor = .black
            tf.keyboardType = .numberPad
            tf.tintColor = .systemBlue
            
            tf.tag = index
            tf.delegate = self
            tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
            
            otpStack.addArrangedSubview(tf)
            otpFields.append(tf)
        }
    }
    
    // Auto-advance logic for 5 digits
    @objc private func textDidChange(_ textField: UITextField) {
        let text = textField.text
        
        if text?.count == 1 {
            switch textField.tag {
            case 0: otpFields[1].becomeFirstResponder()
            case 1: otpFields[2].becomeFirstResponder()
            case 2: otpFields[3].becomeFirstResponder()
            case 3: otpFields[4].becomeFirstResponder()
            case 4: otpFields[4].resignFirstResponder() // Done
            default: break
            }
        } else if let text = text, text.count > 1 {
            textField.text = String(text.prefix(1))
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            if textField.text?.isEmpty == true {
                switch textField.tag {
                case 1: otpFields[0].becomeFirstResponder()
                case 2: otpFields[1].becomeFirstResponder()
                case 3: otpFields[2].becomeFirstResponder()
                case 4: otpFields[3].becomeFirstResponder()
                default: break
                }
            }
        }
        return true
    }
    
    @objc private func didTapVerify() {
        let code = otpFields.compactMap { $0.text }.joined()
        print("Verifying Code: \(code)")
        let vc = ResetPassword()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - 3. RESET PASSWORD SCREEN
final class ResetPassword: PremiumBaseViewController {
    
    private lazy var newPassField = makeTextField(placeholder: "New Password")
    private lazy var confirmPassField = makeTextField(placeholder: "Confirm Password")
    
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
        cardView.addSubview(newPassField)
        cardView.addSubview(confirmPassField)
        cardView.addSubview(updateButton)
        
        NSLayoutConstraint.activate([
            newPassField.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            newPassField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            newPassField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            confirmPassField.topAnchor.constraint(equalTo: newPassField.bottomAnchor, constant: 16),
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
        navigationController?.popToRootViewController(animated: true)
    }
}

