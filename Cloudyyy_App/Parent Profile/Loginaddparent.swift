import UIKit

// MARK: - LoginAddParent
final class LoginAddParent: UIViewController {

    // MARK: - UI Components

    private var backgroundGradientLayer: CAGradientLayer?

    private let mainScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .interactive
        sv.backgroundColor = .clear
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()

    // Decorative Icon
    private let headerImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        // Ensure you have an image named 'cloudyy_logo' or change this
        iv.image = UIImage(named: "cloudyy_logo") ?? UIImage(systemName: "person.2.circle.fill")
        iv.tintColor = .white.withAlphaComponent(0.8)
        return iv
    }()

    // Floating Back Button
    private lazy var backButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        b.tintColor = .white
        b.addTarget(self, action: #selector(handleBackTap), for: .touchUpInside)
        return b
    }()

    // Main Card
    private let formCardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.15
        v.layer.shadowRadius = 20
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Add Parent"
        l.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        l.textColor = UIColor(red: 12/255, green: 34/255, blue: 76/255, alpha: 1)
        l.textAlignment = .center
        return l
    }()

    // MARK: - Form Fields

    private lazy var nameLabel = makeHeaderLabel(text: "Full Name")
    private lazy var roleLabel = makeHeaderLabel(text: "Role")
    
    // 1. Updated Labels (Removed Contact, Added Password)
    private lazy var emailLabel = makeHeaderLabel(text: "Email Address")
    private lazy var passwordLabel = makeHeaderLabel(text: "Password")

    private lazy var nameTextField = makeStyledTextField(placeholder: "e.g., John Smith")
    
    // Custom Segment Control for Mom/Dad
    private let roleControl = ParentRoleSelectionControl(items: ["Mom", "Dad"])
    
    private lazy var emailTextField = makeStyledTextField(placeholder: "e.g., john.smith@example.com")
    
    // 2. Added Password Field
    private lazy var passwordTextField: UITextField = {
        let tf = makeStyledTextField(placeholder: "Enter password")
        tf.isSecureTextEntry = true
        return tf
    }()

    private lazy var doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Done", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1) // Standard Blue
        b.layer.cornerRadius = 16
        b.heightAnchor.constraint(equalToConstant: 54).isActive = true
        b.addTarget(self, action: #selector(handleDoneTap), for: .touchUpInside)

        b.layer.shadowColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1).cgColor
        b.layer.shadowOpacity = 0.3
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.layer.shadowRadius = 8
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Keyboard types
        emailTextField.keyboardType = .emailAddress
        registerKeyboardObservers()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupGradient()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer?.frame = view.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(mainScrollView)
        mainScrollView.addSubview(contentView)

        contentView.addSubview(headerImageView)
        contentView.addSubview(formCardView)

        // Back Button Logic
        if let nav = navigationController, !nav.isNavigationBarHidden {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(handleBackTap)
            )
            navigationItem.leftBarButtonItem?.tintColor = .white
        } else {
            view.addSubview(backButton)
        }

        setupFormStack()
        setupConstraints()
    }

    private func setupFormStack() {
        // 3. Reordered Stack: Name -> Role -> Email -> Password
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            createSpacer(height: 10),
            
            nameLabel, nameTextField,
            createSpacer(height: 4),
            
            roleLabel, roleControl,
            createSpacer(height: 4),
            
            emailLabel, emailTextField,
            createSpacer(height: 4),
            
            passwordLabel, passwordTextField,
            createSpacer(height: 16),
            
            doneButton
        ])

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        
        // Custom spacing for visual separation
        stack.setCustomSpacing(24, after: nameTextField)
        stack.setCustomSpacing(24, after: roleControl)
        stack.setCustomSpacing(24, after: emailTextField)
        stack.setCustomSpacing(30, after: passwordTextField)

        formCardView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: formCardView.topAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: formCardView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: formCardView.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: formCardView.bottomAnchor, constant: -32)
        ])
    }

    private func setupConstraints() {
        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // ScrollView
            mainScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content View
            contentView.topAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.widthAnchor),

            // Header Image
            headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            headerImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: 120),
            headerImageView.widthAnchor.constraint(equalToConstant: 200),

            // Card
            formCardView.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 30),
            formCardView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            formCardView.widthAnchor.constraint(lessThanOrEqualToConstant: 480),
            formCardView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -40).withPriority(.defaultHigh),
            formCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])

        if backButton.superview != nil {
            NSLayoutConstraint.activate([
                backButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
                backButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 8),
                backButton.widthAnchor.constraint(equalToConstant: 44),
                backButton.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
    }

    private func setupGradient() {
        if backgroundGradientLayer == nil {
            let gradient = CAGradientLayer()
            
            // 4. Updated Gradient Colors as requested
            gradient.colors = [
                UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
                UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
            ]
            
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
            view.layer.insertSublayer(gradient, at: 0)
            backgroundGradientLayer = gradient
        }
    }

    // MARK: - Actions

    @objc private func handleBackTap() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func handleDoneTap() {
        view.endEditing(true)

        // Basic validation for Name and Password
        guard let name = nameTextField.text, !name.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            shakeCard()
            return
        }
        
        let role = roleControl.selectedIndex == 0 ? "Mom" : "Dad"

        // Updated success message
        let alert = UIAlertController(title: "Success!", message: "\(role) profile for \(name) created.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigateToParentProfile()
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    private func navigateToParentProfile() {
        print("Navigate to ParentProfileMembers screen")
        handleBackTap()
    }

    private func shakeCard() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0]
        formCardView.layer.add(animation, forKey: "shake")
    }

    // MARK: - Input Helpers

    private func makeHeaderLabel(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = .gray
        return l
    }

    private func makeStyledTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = placeholder
        tf.backgroundColor = UIColor(white: 0.97, alpha: 1)
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 50))
        tf.leftView = paddingView
        tf.leftViewMode = .always

        return tf
    }

    private func createSpacer(height: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }

    // MARK: - Keyboard Handling

    private func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight + 20, right: 0)
        mainScrollView.contentInset = insets
        mainScrollView.scrollIndicatorInsets = insets
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        mainScrollView.contentInset = .zero
        mainScrollView.scrollIndicatorInsets = .zero
    }
}

// MARK: - Custom Controls & Extensions

private extension NSLayoutConstraint {
    func withPriority(_ p: UILayoutPriority) -> NSLayoutConstraint {
        priority = p
        return self
    }
}

// Custom Control for Parent Role Selection
private class ParentRoleSelectionControl: UIControl {
    
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    private let selectionPill = UIView()
    private let items: [String]
    
    private var pillConstraints: [NSLayoutConstraint] = []
    
    var selectedIndex: Int = 0 {
        didSet { updateSelection() }
    }
    
    init(items: [String]) {
        self.items = items
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 48).isActive = true
        backgroundColor = UIColor(white: 0.95, alpha: 1)
        layer.cornerRadius = 14
        
        selectionPill.backgroundColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1)
        selectionPill.layer.cornerRadius = 12
        selectionPill.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionPill)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        for (index, title) in items.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        DispatchQueue.main.async {
            self.updateSelection(animated: false)
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        sendActions(for: .valueChanged)
    }
    
    private func updateSelection(animated: Bool = true) {
        guard buttons.indices.contains(selectedIndex) else { return }
        let selectedButton = buttons[selectedIndex]
        
        buttons.forEach { $0.setTitleColor(UIColor.darkGray, for: .normal) }
        selectedButton.setTitleColor(.white, for: .normal)
        
        NSLayoutConstraint.deactivate(pillConstraints)
        pillConstraints.removeAll()
        
        pillConstraints = [
            selectionPill.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor, constant: 4),
            selectionPill.trailingAnchor.constraint(equalTo: selectedButton.trailingAnchor, constant: -4),
            selectionPill.topAnchor.constraint(equalTo: selectedButton.topAnchor, constant: 4),
            selectionPill.bottomAnchor.constraint(equalTo: selectedButton.bottomAnchor, constant: -4)
        ]
        
        NSLayoutConstraint.activate(pillConstraints)
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }
}
