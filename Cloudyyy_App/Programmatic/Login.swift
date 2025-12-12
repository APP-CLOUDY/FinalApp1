//
// Login.swift
// Cloudyyy_App
//

import UIKit
import Supabase

private struct LoginUserProfile: Decodable {
    let id: UUID
    let first_name: String
    let email: String
    let role: String
    let date_of_birth: String?
}

final class Login: UIViewController {

    // MARK: - UI Components
    
    // 1. BACKGROUND CONTAINER
    private let backgroundContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // 2. PREMIUM DARK GRADIENT
    private let gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor, // Dark Obsidian
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor  // Deep Steel Blue
        ]
        l.startPoint = CGPoint(x: 0, y: 0)
        l.endPoint = CGPoint(x: 1, y: 1)
        return l
    }()

    // MARK: - App Logo (Increased Size)
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "app_logo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - Main Title (Better Placement)
    private let mainTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Log in"
        // Slightly larger to balance with the bigger logo
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.keyboardDismissMode = .onDrag
        s.alwaysBounceVertical = true
        s.showsVerticalScrollIndicator = false
        return s
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let card = CardView()

    // MARK: - Navigation
    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        b.setImage(UIImage(systemName: "chevron.backward", withConfiguration: config), for: .normal)
        b.tintColor = .white
        b.accessibilityLabel = "Back"
        b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return b
    }()

    // MARK: - Card Fields
    private let emailField: CustomTextField = {
        let t = CustomTextField(placeholder: "Email")
        t.keyboardType = .emailAddress
        t.autocapitalizationType = .none
        return t
    }()

    private let passwordField: PasswordField = {
        let p = PasswordField(placeholder: "Password")
        p.disableAutoFill = true
        return p
    }()

    private let rememberCheckbox: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        b.setImage(UIImage(systemName: "square", withConfiguration: config), for: .normal)
        b.tintColor = .systemGray
        return b
    }()

    private let rememberLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Remember me"
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .secondaryLabel
        return l
    }()

    private let forgotPasswordButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Forgot Password?", for: .normal)
        b.setTitleColor(.systemBlue, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        return b
    }()

    private let loginButton = GradientButton(title: "Log In")

    private let dividerLeft: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemGray5
        return v
    }()

    private let dividerRight: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemGray5
        return v
    }()

    private let dividerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Or"
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .tertiaryLabel
        return l
    }()

    // Social Buttons
    private let appleButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        // Standard SF Symbol size
        config.image = UIImage(systemName: "applelogo")
        config.title = "Continue with Apple"
        config.imagePadding = 10
        config.baseForegroundColor = .label
        config.background.backgroundColor = .systemBackground
        config.background.strokeColor = .systemGray4
        config.background.strokeWidth = 1
        config.cornerStyle = .medium
        
        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let googleButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        
        // 1. Load Image
        if let originalImage = UIImage(named: "googleImg") {
            // 2. Resize to match Apple logo (approx 20x20)
            let targetSize = CGSize(width: 18, height: 18)
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            let resized = renderer.image { _ in
                originalImage.draw(in: CGRect(origin: .zero, size: targetSize))
            }
            config.image = resized.withRenderingMode(.alwaysOriginal)
        }
        
        config.title = "Continue with Google"
        config.imagePadding = 10
        config.baseForegroundColor = .label
        config.background.backgroundColor = .systemBackground
        config.background.strokeColor = .systemGray4
        config.background.strokeWidth = 1
        config.cornerStyle = .medium

        let b = UIButton(configuration: config)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let noAccountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Don’t have an account?"
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        return l
    }()
    
    private let signUpButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Sign Up", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        b.setTitleColor(.systemBlue, for: .normal)
        return b
    }()
    
    private lazy var footerStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [noAccountLabel, signUpButton])
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.spacing = 4
        s.alignment = .center
        return s
    }()

    private let activity = UIActivityIndicatorView(style: .large)

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupStyling()
        setupHierarchy()
        setupConstraints()
        setupActions()
        loadRememberedEmail()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = backgroundContainer.bounds
    }

    // MARK: - Styling
    private func setupStyling() {
        card.layer.cornerRadius = 24
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.15
        card.layer.shadowOffset = CGSize(width: 0, height: 10)
        card.layer.shadowRadius = 20
        card.backgroundColor = .white
    }

    // MARK: - Hierarchy
    private func setupHierarchy() {
        view.addSubview(backgroundContainer)
        backgroundContainer.layer.addSublayer(gradientLayer)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(card)

        [emailField, passwordField, rememberCheckbox, rememberLabel, forgotPasswordButton,
         loginButton, dividerLeft, dividerLabel, dividerRight,
         appleButton, googleButton, footerStack]
            .forEach { card.addSubview($0) }

        view.addSubview(closeButton)
        view.addSubview(logoImageView)
        view.addSubview(mainTitleLabel)
        view.addSubview(activity)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background
            backgroundContainer.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Back Button
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),

            // Logo (Increased Size: 100)
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            logoImageView.widthAnchor.constraint(equalToConstant: 100), // Enforce square if applicable
            
            // Main Title (Tight spacing to logo)
            mainTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            mainTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Scroll View
            scrollView.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Card Placement (Closer to title)
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            card.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            card.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 500),

            // Activity
            activity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // --- Card Constraints ---
        dividerLabel.setContentHuggingPriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            emailField.topAnchor.constraint(equalTo: card.topAnchor, constant: 32),
            emailField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            emailField.heightAnchor.constraint(equalToConstant: 50),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 50),

            rememberCheckbox.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
            rememberCheckbox.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            rememberCheckbox.widthAnchor.constraint(equalToConstant: 24),
            rememberCheckbox.heightAnchor.constraint(equalToConstant: 24),

            rememberLabel.centerYAnchor.constraint(equalTo: rememberCheckbox.centerYAnchor),
            rememberLabel.leadingAnchor.constraint(equalTo: rememberCheckbox.trailingAnchor, constant: 8),

            forgotPasswordButton.centerYAnchor.constraint(equalTo: rememberCheckbox.centerYAnchor),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),

            loginButton.topAnchor.constraint(equalTo: rememberCheckbox.bottomAnchor, constant: 28),
            loginButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 52),

            dividerLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            dividerLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 30),

            dividerLeft.centerYAnchor.constraint(equalTo: dividerLabel.centerYAnchor),
            dividerLeft.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            dividerLeft.trailingAnchor.constraint(equalTo: dividerLabel.leadingAnchor, constant: -12),
            dividerLeft.heightAnchor.constraint(equalToConstant: 1),

            dividerRight.centerYAnchor.constraint(equalTo: dividerLabel.centerYAnchor),
            dividerRight.leadingAnchor.constraint(equalTo: dividerLabel.trailingAnchor, constant: 12),
            dividerRight.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            dividerRight.heightAnchor.constraint(equalToConstant: 1),

            appleButton.topAnchor.constraint(equalTo: dividerLabel.bottomAnchor, constant: 20),
            appleButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            appleButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            appleButton.heightAnchor.constraint(equalToConstant: 50),

            googleButton.topAnchor.constraint(equalTo: appleButton.bottomAnchor, constant: 12),
            googleButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            googleButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            googleButton.heightAnchor.constraint(equalToConstant: 50),
            
            footerStack.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 30),
            footerStack.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            footerStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -30)
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        rememberCheckbox.addTarget(self, action: #selector(toggleRemember), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(handleForgot), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(handleApple), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(handleGoogle), for: .touchUpInside)
    }

    @objc private func didTapClose() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc private func toggleRemember() {
        let checked = rememberCheckbox.image(for: .normal) == UIImage(systemName: "checkmark.square.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22))
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        
        if checked {
            rememberCheckbox.setImage(UIImage(systemName: "square", withConfiguration: config), for: .normal)
            rememberCheckbox.tintColor = .systemGray
        } else {
            rememberCheckbox.setImage(UIImage(systemName: "checkmark.square.fill", withConfiguration: config), for: .normal)
            rememberCheckbox.tintColor = .systemBlue
        }
    }

    @objc private func handleSignup() {
        let vc = Signup()
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func handleForgot() {
            // Navigate to the Forgot Password Screen
            let vc = ForgotPassword()
            navigationController?.pushViewController(vc, animated: true)
        }
    @objc private func handleLogin() {
        view.endEditing(true)
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text ?? ""

        guard !email.isEmpty, !password.isEmpty else {
            showAlert("Missing fields", "Please fill both email and password.")
            return
        }

        setLoading(true)

        _Concurrency.Task {
            do {
                let session = try await SupabaseManager.shared.client.auth.signIn(
                    email: email,
                    password: password
                )
                let userId = session.user.id

                let profile: LoginUserProfile = try await SupabaseManager.shared.client
                    .from("users")
                    .select()
                    .eq("id", value: userId)
                    .single()
                    .execute()
                    .value

                await MainActor.run {
                    let isChecked = self.rememberCheckbox.image(for: .normal) == UIImage(systemName: "checkmark.square.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22))
                    
                    if isChecked {
                        UserDefaults.standard.set(email, forKey: "Cloudyyy_RememberedEmail")
                    } else {
                        UserDefaults.standard.removeObject(forKey: "Cloudyyy_RememberedEmail")
                    }
                }

                await MainActor.run {
                    self.setLoading(false)
                    let mainTabBarController = CustomTabBarController()
                    if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate,
                       let window = sceneDelegate.window {
                        window.rootViewController = mainTabBarController
                        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
                    } else {
                        self.navigationController?.pushViewController(mainTabBarController, animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    self.setLoading(false)
                    self.showAlert("Login failed", error.localizedDescription)
                }
            }
        }
    }

    @objc private func handleApple() {
        showAlert("Apple", "Apple sign-in")
    }

    @objc private func handleGoogle() {
        showAlert("Google", "Google sign-in")
    }

    private func showAlert(_ title: String, _ msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            if loading {
                self.activity.startAnimating()
                self.loginButton.isEnabled = false
                self.loginButton.alpha = 0.6
            } else {
                self.activity.stopAnimating()
                self.loginButton.isEnabled = true
                self.loginButton.alpha = 1.0
            }
        }
    }

    private func loadRememberedEmail() {
        if let saved = UserDefaults.standard.string(forKey: "Cloudyyy_RememberedEmail") {
            emailField.text = saved
            let config = UIImage.SymbolConfiguration(pointSize: 22)
            rememberCheckbox.setImage(UIImage(systemName: "checkmark.square.fill", withConfiguration: config), for: .normal)
            rememberCheckbox.tintColor = .systemBlue
        }
    }
}
