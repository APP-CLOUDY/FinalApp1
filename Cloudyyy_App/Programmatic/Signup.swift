//
// Signup.swift
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
    private let headerView = GradientHeaderView(dottedImage: UIImage(named: "dots"))
    
    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.alwaysBounceVertical = true
        s.keyboardDismissMode = .interactive
        return s
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let card = CardView()

    // Fields
    private let nameField = CustomTextField(placeholder: "Name")
    
    private let emailField: CustomTextField = {
        let f = CustomTextField(placeholder: "Email")
        f.keyboardType = .emailAddress
        f.autocapitalizationType = .none
        f.accessibilityIdentifier = "emailField"
        return f
    }()
    
    private let dobField = DateTextField(placeholder: "Date of birth")
    
    private let roleSegmented: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Mom", "Dad"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        return sc
    }()

    private let passwordField: PasswordField = {
        let p = PasswordField(placeholder: "Set Password")
        p.disableAutoFill = true
        return p
    }()

    private let signUpButton = GradientButton(title: "Sign Up")

    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.backward", withConfiguration: config), for: .normal)
        b.tintColor = .white
        b.accessibilityLabel = "Back"
        return b
    }()

    private let activity = UIActivityIndicatorView(style: .large)

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupHeader()
        setupHierarchy()
        setupConstraints()
        configureBehaviors()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup Header
    private func setupHeader() {
        headerView.screenTitleLabel.text = "Sign up"
        headerView.smallInfoLabel.text = "Already have an account ?"
        headerView.actionButton.setTitle("Log in", for: .normal)
        headerView.actionButton.accessibilityIdentifier = "loginButton"
    }

    // MARK: - Hierarchy
    private func setupHierarchy() {
        view.addSubview(headerView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(card)

        [nameField, emailField, dobField, roleSegmented, passwordField, signUpButton].forEach {
            card.addSubview($0)
        }
        
        view.addSubview(closeButton)
        view.addSubview(activity)

        // Accessibility
        nameField.accessibilityLabel = "Full name"
        dobField.accessibilityLabel = "Date of birth"
        passwordField.accessibilityLabel = "Password"
        signUpButton.accessibilityLabel = "Sign up"
    }

    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Close Button
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
       
            // Header
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.bottomAnchor.constraint(equalTo: scrollView.topAnchor, constant: 28),

            // ScrollView
            scrollView.topAnchor.constraint(equalTo: headerView.screenTitleLabel.bottomAnchor, constant: 30),
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
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            // Activity
            activity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        let spacing: CGFloat = 14
        NSLayoutConstraint.activate([
            nameField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            nameField.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),

            emailField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            emailField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: spacing),

            dobField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            dobField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            dobField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: spacing),

            roleSegmented.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            roleSegmented.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            roleSegmented.topAnchor.constraint(equalTo: dobField.bottomAnchor, constant: spacing),

            passwordField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            passwordField.topAnchor.constraint(equalTo: roleSegmented.bottomAnchor, constant: spacing),

            signUpButton.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            signUpButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24),
            signUpButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24)
        ])
    }

    // MARK: - Behaviors
    private func configureBehaviors() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        headerView.actionButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        roleSegmented.layer.cornerRadius = 18
        roleSegmented.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)

        let calImage = UIImageView(image: UIImage(systemName: "calendar")?.withRenderingMode(.alwaysTemplate))
        calImage.tintColor = .systemGray
        calImage.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        calImage.contentMode = .center
        dobField.rightView = calImage
        dobField.rightViewMode = .always

        dobField.selectedDate = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()

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
        let vc = Login()
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Sign Up Logic (Direct Login / No Confirmation)
    @objc private func didTapSignUp() {
        view.endEditing(true)

        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let pass = passwordField.text ?? ""

        guard !name.isEmpty, !email.isEmpty, !pass.isEmpty else {
            showAlert(title: "Missing fields", message: "Please complete all fields.")
            return
        }

        let role = roleSegmented.titleForSegment(at: roleSegmented.selectedSegmentIndex)?.lowercased() ?? "mom"

        let dobISO: String? = {
            let date = dobField.selectedDate
            let fmt = DateFormatter()
            fmt.timeZone = TimeZone(secondsFromGMT: 0)
            fmt.dateFormat = "yyyy-MM-dd"
            return fmt.string(from: date)
        }()

        setLoading(true)

        // Use _Concurrency.Task to avoid name conflict with your 'Task' model
        _Concurrency.Task {
            do {
                // 1) Sign up
                // With "Confirm Email" OFF in Supabase, this logs the user in immediately.
                let result = try await SupabaseManager.shared.client.auth.signUp(
                    email: email,
                    password: pass,
                    data: [
                        "first_name": .string(name),
                        "role": .string(role)
                    ]
                )

                // 2) Get User ID
                // Note: result.user is non-optional in new SDKs, so we assign directly.
                let user = result.user
                let userId = user.id.uuidString

                // 3) Insert Profile
                let profile = ProfileInsert(
                    id: userId,
                    first_name: name,
                    email: email,
                    role: role,
                    date_of_birth: dobISO
                )

                // Insert into public.users
                // This will succeed because the user is now authenticated (logged in).
                try await SupabaseManager.shared.client
                    .from("users")
                    .insert(profile)
                    .execute()

                // 4) Navigate to Family Name (Main Thread)
                await MainActor.run {
                    self.setLoading(false)
                    // DIRECT NAVIGATION - No OTP, No Alert
                    let vc = FamilyName()
                    self.navigationController?.pushViewController(vc, animated: true)
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
