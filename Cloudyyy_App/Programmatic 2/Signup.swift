//
// Signup.swift
// Cloudyyy_App
//

import UIKit
import Supabase

// Encodable struct used for inserting into `public.users`
private struct ProfileInsert: Encodable {
    let id: String
    let first_name: String
    let email: String
    let role: String
    let date_of_birth: String?
}

final class Signup: UIViewController {

    // MARK: - UI Components
    
    // 1. BACKGROUND CONTAINER
    private let backgroundContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // 2. PREMIUM DARK GRADIENT (Matches Login.swift)
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

    // MARK: - App Logo (Centered)
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        // ⚠️ Ensure "app_logo" exists in your Assets
        iv.image = UIImage(named: "app_logo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - Main Title
    private let mainTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Sign up"
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()
    
    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.alwaysBounceVertical = true
        s.keyboardDismissMode = .interactive
        s.showsVerticalScrollIndicator = false
        return s
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let card = CardView()

    // MARK: - Fields
        private let nameField: CustomTextField = {
            let f = CustomTextField(placeholder: "Name")
            f.accessibilityLabel = "Full name"
            
            // FIX: Make placeholder visible
            f.attributedPlaceholder = NSAttributedString(
                string: "Name",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
            )
            return f
        }()
        
        private let roleSegmented: UISegmentedControl = {
            let sc = UISegmentedControl(items: ["Mom", "Dad", "Guardian"])
            sc.translatesAutoresizingMaskIntoConstraints = false
            sc.selectedSegmentIndex = 0
            return sc
        }()
        
        private let emailField: CustomTextField = {
            let f = CustomTextField(placeholder: "Email")
            f.keyboardType = .emailAddress
            f.autocapitalizationType = .none
            f.accessibilityIdentifier = "emailField"
            
            // FIX: Make placeholder visible
            f.attributedPlaceholder = NSAttributedString(
                string: "Email",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
            )
            return f
        }()
        
        private let passwordField: PasswordField = {
            let p = PasswordField(placeholder: "Set Password")
            p.disableAutoFill = true
            p.accessibilityLabel = "Password"
            
            // FIX: Make placeholder visible
            p.attributedPlaceholder = NSAttributedString(
                string: "Set Password",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
            )
            return p
        }()

    private let signUpButton = GradientButton(title: "Sign Up")

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
    
    // MARK: - Footer (Moved to bottom)
    private let haveAccountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Already have an account?"
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        return l
    }()
    
    private let loginButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Log in", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        b.setTitleColor(.systemBlue, for: .normal)
        b.accessibilityIdentifier = "loginButton"
        return b
    }()
    
    private lazy var footerStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [haveAccountLabel, loginButton])
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
        configureBehaviors()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = backgroundContainer.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
        // Background
        view.addSubview(backgroundContainer)
        backgroundContainer.layer.addSublayer(gradientLayer)
        
        // Content
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(card)

        // Card Subviews (New Order: Name -> Role -> Email -> Password)
        [nameField, roleSegmented, emailField, passwordField, signUpButton, footerStack].forEach {
            card.addSubview($0)
        }
        
        // Overlays
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

            // Close Button
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            
            // Logo (Centered, bigger)
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),

            // Title
            mainTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            mainTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // ScrollView
            scrollView.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Card
            card.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            card.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 500),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            // Activity
            activity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        let spacing: CGFloat = 20
        NSLayoutConstraint.activate([
            // 1. Name
            nameField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            nameField.topAnchor.constraint(equalTo: card.topAnchor, constant: 32),
            nameField.heightAnchor.constraint(equalToConstant: 50),
            
            // 2. Role (Mom / Dad / Guardian)
            roleSegmented.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            roleSegmented.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            roleSegmented.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: spacing),
            roleSegmented.heightAnchor.constraint(equalToConstant: 36),

            // 3. Email
            emailField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            emailField.topAnchor.constraint(equalTo: roleSegmented.bottomAnchor, constant: spacing),
            emailField.heightAnchor.constraint(equalToConstant: 50),

            // 4. Password
            passwordField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: spacing),
            passwordField.heightAnchor.constraint(equalToConstant: 50),

            // Sign Up Button
            signUpButton.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            signUpButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 32),
            signUpButton.heightAnchor.constraint(equalToConstant: 52),
            
            // Footer Stack
            footerStack.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 24),
            footerStack.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            footerStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -32)
        ])
    }

    // MARK: - Behaviors
    private func configureBehaviors() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Segment Styling
        roleSegmented.layer.cornerRadius = 18
        roleSegmented.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Actions
    
    @objc private func didTapClose() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func didTapLogin() {
        // Since we might have pushed Signup from Login, popping is safer than pushing new Login
        if let nav = self.navigationController, let _ = nav.viewControllers.first(where: { $0 is Login }) {
            nav.popViewController(animated: true)
        } else {
            let vc = Login()
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // In Signup.swift

    @objc private func didTapSignUp() {
        view.endEditing(true)

        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let pass = passwordField.text ?? ""

        guard !name.isEmpty, !email.isEmpty, !pass.isEmpty else {
            showAlert(title: "Missing fields", message: "Please complete all fields.")
            return
        }

        // --- FIX START: Explicit Role Mapping ---
        // We map the index directly to the database string value.
        // Index 0 = "mom", Index 1 = "dad", Index 2 = "guardian"
        let selectedRole: String
        switch roleSegmented.selectedSegmentIndex {
        case 0: selectedRole = "mom"
        case 1: selectedRole = "dad"
        case 2: selectedRole = "guardian"
        default: selectedRole = "mom" // Fallback
        }
        // --- FIX END ---
        
        // DOB removed from UI, so we pass nil
        let dobISO: String? = nil

        setLoading(true)

        _Concurrency.Task {
            do {
                // 1) Sign up
                let result = try await SupabaseManager.shared.client.auth.signUp(
                    email: email,
                    password: pass,
                    data: [
                        "first_name": .string(name),
                        "role": .string(selectedRole) // Use the mapped role
                    ]
                )

                let user = result.user
                let userId = user.id.uuidString

                // 2) Insert Profile
                let profile = ProfileInsert(
                    id: userId,
                    first_name: name,
                    email: email,
                    role: selectedRole, // Use the mapped role
                    date_of_birth: dobISO
                )

                try await SupabaseManager.shared.client
                    .from("users")
                    .insert(profile)
                    .execute()

                // 3) Navigate
                await MainActor.run {
                    self.setLoading(false)
                     
                     let vc = FamilyName()
                     self.navigationController?.pushViewController(vc, animated: true)
                    print("Sign up successful as \(selectedRole)")
                }

            } catch {
                await MainActor.run {
                    self.setLoading(false)
                    self.showAlert(title: "Sign up failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            if loading {
                self.activity.startAnimating()
                self.signUpButton.isEnabled = false
                self.signUpButton.alpha = 0.6
            } else {
                self.activity.stopAnimating()
                self.signUpButton.isEnabled = true
                self.signUpButton.alpha = 1.0
            }
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Keyboard handling
    @objc private func keyboardWillShow(notification: Notification) {
        guard let info = notification.userInfo,
              let kbFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let bottomInset = kbFrame.height - view.safeAreaInsets.bottom
        scrollView.contentInset.bottom = bottomInset + 12
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset + 12

        if let firstResponder = view.currentFirstResponder() as? UIView {
            let converted = firstResponder.convert(firstResponder.bounds, to: scrollView)
            scrollView.scrollRectToVisible(converted.insetBy(dx: 0, dy: -20), animated: true)
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - UIView extension
private extension UIView {
    func currentFirstResponder() -> UIResponder? {
        if self.isFirstResponder { return self }
        for sub in subviews {
            if let r = sub.currentFirstResponder() { return r }
        }
        return nil
    }
}

