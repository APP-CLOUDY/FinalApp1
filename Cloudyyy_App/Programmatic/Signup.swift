//
// Signup.swift
// Uses CommonUI.swift components
//

import UIKit

final class Signup: UIViewController {

    // MARK: - UI (from CommonUI.swift)
    private let headerView = GradientHeaderView(dottedImage: UIImage(named: "dots")) // optional dotted overlay image
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

    // Fields (using common UI)
    private let nameField = CustomTextField(placeholder: "Name") // Using single "Name" field
    private let emailField: CustomTextField = {
        let f = CustomTextField(placeholder: "Email")
        f.keyboardType = .emailAddress
        f.autocapitalizationType = .none
        f.accessibilityIdentifier = "emailField"
        return f
    }()
    private let dobField = DateTextField(placeholder: "Birth of date")
    
    // --- THIS IS THE FIXED LINE ---
    private let roleSegmented = makeRoleSegmentedControl(items: ["Mom", "Dad"])

    // <-- Password field: autofill disabled to remove the yellow cover -->
    private let passwordField: PasswordField = {
        let p = PasswordField(placeholder: "Set Password")
        // disable the autofill cover so user can always see typed characters
        p.disableAutoFill = true
        return p
    }()

    private let signUpButton = GradientButton(title: "Sign Up")
    
    // Changed to a chevron 'Back' button
    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        // Use a chevron for a standard 'back' look
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.backward", withConfiguration: config), for: .normal)
        b.tintColor = .white
        b.accessibilityLabel = "Back"
        return b
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupHeader()
        setupHierarchy()
        setupConstraints() // Using the corrected constraints
        configureBehaviors()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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

        // add fields to card
        [nameField, emailField, dobField, roleSegmented, passwordField, signUpButton].forEach {
            card.addSubview($0)
        }
        
        // Add close button to the main view, on top of other elements
        view.addSubview(closeButton)

        // Accessibility hints
        nameField.accessibilityLabel = "Full name"
        dobField.accessibilityLabel = "Date of birth"
        passwordField.accessibilityLabel = "Password"
        signUpButton.accessibilityLabel = "Sign up"
    }

    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Close Button Constraints (pinned to view safe area)
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
        
            // --- 1. Header Constraints (Dynamic Height) ---
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            
            // Instead of height=360, we pin the header bottom relative to the ScrollView content
            // This ensures the header shrinks if the screen is short (landscape)
            headerView.bottomAnchor.constraint(equalTo: scrollView.topAnchor, constant: 28),
            
            // --- 2. ScrollView Constraints ---
            // We pin the ScrollView top to the Header's TITLE label
            // This guarantees the title is always visible, and the card starts just below it
            scrollView.topAnchor.constraint(equalTo: headerView.screenTitleLabel.bottomAnchor, constant: 30),
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // --- 3. Content View Constraints ---
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // --- 4. Card Constraints (With Landscape Max Width) ---
            // Center the card horizontally
            card.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Width is the container width minus padding...
            card.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            
            // ...BUT cap the width at 500pts so it doesn't stretch too wide in landscape
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 500),
            
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
        ])

        // --- 5. Field Constraints inside Card (Unchanged) ---
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

            // --- Button Spacing Increased ---
            signUpButton.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            signUpButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24), // Increased from 18
            signUpButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24) // Increased from 18
        ])
    }

    // MARK: - Behaviors
    private func configureBehaviors() {
        // Action re-enabled
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    
        // Header action (log in)
        headerView.actionButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)

        // Button actions
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)

        // Keyboard handling
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        // small tweaks
        roleSegmented.layer.cornerRadius = 18
        roleSegmented.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Add a calendar icon on the right of dobField (template so tint works)
        let calImage = UIImageView(image: UIImage(systemName: "calendar")?.withRenderingMode(.alwaysTemplate))
        calImage.tintColor = .systemGray
        calImage.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        calImage.contentMode = .center
        dobField.rightView = calImage
        dobField.rightViewMode = .always

        // Prefill DOB with a sensible default (optional)
        dobField.selectedDate = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()

        // Tap to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Actions
    
    // <<< MODIFIED: This function now handles both 'push' and 'modal' presentations >>>
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
    
    @objc private func didTapLogin() {
        let vc = Login()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func didTapSignUp() {
        view.endEditing(true)

        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let pass = passwordField.text ?? ""

        guard !name.isEmpty, !email.isEmpty, !pass.isEmpty else {
            showAlert(title: "Missing fields", message: "Please complete all fields.")
            return
        }

        let role = roleSegmented.titleForSegment(at: roleSegmented.selectedSegmentIndex) ?? "Mom"
        let dob = dobField.text ?? ""

        let alert = UIAlertController(
            title: "Success",
            message: "Name: \(name)\nEmail: \(email)\nRole: \(role)\nDOB: \(dob)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let vc = FamilyName()

//            // Optional passing of data
//            vc.userName = name
//            vc.userEmail = email
//            vc.userRole = role
//            vc.userDOB = dob

            self.navigationController?.pushViewController(vc, animated: true)
        }))

        present(alert, animated: true)
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

        // If any field is hidden by keyboard, scroll to it
        if let firstResponder = view.currentFirstResponder() as? UIView {
            let converted = firstResponder.convert(firstResponder.bounds, to: scrollView)
            scrollView.scrollRectToVisible(converted.insetBy(dx: 0, dy: -20), animated: true)
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    // MARK: - Helpers
    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - UIView extension to find current first responder
private extension UIView {
    func currentFirstResponder() -> UIResponder? {
        if self.isFirstResponder { return self }
        for sub in subviews {
            if let r = sub.currentFirstResponder() { return r }
        }
        return nil
    }
}
