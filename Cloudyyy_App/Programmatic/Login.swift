//
// Login.swift
// Cloudyyy_App
//

import UIKit

final class Login: UIViewController {

    // MARK: - UI Components
    private let headerView = GradientHeaderView(dottedImage: UIImage(named: "dots"))

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.keyboardDismissMode = .onDrag
        s.alwaysBounceVertical = true
        return s
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let card = CardView()

    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.backward", withConfiguration: config), for: .normal)
        b.tintColor = .white
        b.accessibilityLabel = "Back"
        return b
    }()

    // MARK: - Fields
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

    // Remember me
    private let rememberCheckbox: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "square"), for: .normal)
        b.tintColor = .darkGray
        return b
    }()

    private let rememberLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Remember me"
        l.font = .systemFont(ofSize: 14)
        l.textColor = .darkGray
        return l
    }()

    private let forgotPasswordButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Forgot Password ?", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        b.setTitleColor(CloudyyyColors.accentBlue, for: .normal)
        return b
    }()

    private let loginButton = GradientButton(title: "Log In")

    // Divider
    private let dividerLeft: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(white: 0.85, alpha: 1)
        return v
    }()

    private let dividerRight: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(white: 0.85, alpha: 1)
        return v
    }()

    private let dividerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Or"
        l.font = .systemFont(ofSize: 14)
        l.textColor = .darkGray
        return l
    }()

    // Social Buttons (use SF Symbol applelogo and a 'google' asset in Assets.xcassets)
    private let appleButton: GlassButton = {
        let img = UIImage(systemName: "applelogo")
        let b = GlassButton(title: "Continue with Apple", icon: img)
        b.tintColor = .label
        return b
    }()

    private let googleButton: GlassButton = {
        let googleImg = UIImage(named: "googleImg") // add a small google logo asset named "google"
        let b = GlassButton(title: "Continue with Google", icon: googleImg)
        return b
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupHeader()
        setupHierarchy()
        setupConstraints()
        setupActions()
    }

    // MARK: - Setup Header
    private func setupHeader() {
        headerView.screenTitleLabel.text = "Login to your\nAccount"
        headerView.screenTitleLabel.numberOfLines = 0

        headerView.smallInfoLabel.text = "Don’t have an account?"
        headerView.actionButton.setTitle("Sign Up", for: .normal)
    }

    // MARK: - Hierarchy
    private func setupHierarchy() {
        view.addSubview(headerView)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(card)

        [emailField, passwordField, rememberCheckbox, rememberLabel, forgotPasswordButton,
         loginButton, dividerLeft, dividerLabel, dividerRight,
         appleButton, googleButton]
            .forEach { card.addSubview($0) }
            
        view.addSubview(closeButton)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Back button constraints
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
        
            // Header constraints (dynamic height)
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: scrollView.topAnchor, constant: 28),

            // ScrollView constraints (pinned to label)
            scrollView.topAnchor.constraint(equalTo: headerView.screenTitleLabel.bottomAnchor, constant: 30),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Card constraints (landscape-safe)
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            card.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            card.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 500),
        ])

        // --- Constraints inside the card ---
        
        // <<< FIX: This line was moved outside the 'activate' block below >>>
        dividerLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            emailField.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            emailField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            emailField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),

            rememberCheckbox.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 16),
            rememberCheckbox.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            rememberCheckbox.widthAnchor.constraint(equalToConstant: 20),
            rememberCheckbox.heightAnchor.constraint(equalToConstant: 20),

            rememberLabel.centerYAnchor.constraint(equalTo: rememberCheckbox.centerYAnchor),
            rememberLabel.leadingAnchor.constraint(equalTo: rememberCheckbox.trailingAnchor, constant: 8),

            forgotPasswordButton.centerYAnchor.constraint(equalTo: rememberCheckbox.centerYAnchor),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),

            loginButton.topAnchor.constraint(equalTo: rememberCheckbox.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),

            // Robust divider constraints
            dividerLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            dividerLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 26),
            // <<< The buggy line was removed from here >>>

            dividerLeft.centerYAnchor.constraint(equalTo: dividerLabel.centerYAnchor),
            dividerLeft.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            dividerLeft.trailingAnchor.constraint(equalTo: dividerLabel.leadingAnchor, constant: -8),
            dividerLeft.heightAnchor.constraint(equalToConstant: 1),

            dividerRight.centerYAnchor.constraint(equalTo: dividerLabel.centerYAnchor),
            dividerRight.leadingAnchor.constraint(equalTo: dividerLabel.trailingAnchor, constant: 8),
            dividerRight.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            dividerRight.heightAnchor.constraint(equalToConstant: 1),

            appleButton.topAnchor.constraint(equalTo: dividerLabel.bottomAnchor, constant: 26),
            appleButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            appleButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),

            googleButton.topAnchor.constraint(equalTo: appleButton.bottomAnchor, constant: 14),
            googleButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            googleButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            googleButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        headerView.actionButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        rememberCheckbox.addTarget(self, action: #selector(toggleRemember), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(handleForgot), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(handleApple), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(handleGoogle), for: .touchUpInside)
    }
    
    @objc private func didTapClose() {
        // Check if we were pushed onto a navigation controller
        if let nav = self.navigationController {
            // If yes, pop this view controller
            nav.popViewController(animated: true)
        } else {
            // Otherwise, we were presented modally. Dismiss ourselves.
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc private func toggleRemember() {
        let checked = rememberCheckbox.image(for: .normal) == UIImage(systemName: "checkmark.square.fill")
        rememberCheckbox.setImage(UIImage(systemName: checked ? "square" : "checkmark.square.fill"), for: .normal)
    }

    @objc private func handleSignup() {
        let vc = Signup()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func handleForgot() {
        showAlert("Forgot", "Forgot password action")
    }

    @objc private func handleLogin() {
        showAlert("Login", "Perform login action")
    }

    @objc private func handleApple() {
        showAlert("Apple", "Apple sign-in")
    }

    @objc private func handleGoogle() {
        showAlert("Google", "Google sign-in")
    }

    // MARK: - Helper
    private func showAlert(_ title: String, _ msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
