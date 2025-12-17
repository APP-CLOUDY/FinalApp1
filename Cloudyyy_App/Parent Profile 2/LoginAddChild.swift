import UIKit

// MARK: - LoginAddChild
final class LoginAddChild: UIViewController {

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
        // Large configuration for better touch area
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
        l.text = "Add Child Profile"
        l.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        l.textColor = UIColor(red: 12/255, green: 34/255, blue: 76/255, alpha: 1)
        l.textAlignment = .center
        return l
    }()

    // MARK: - Form Fields
    
    private lazy var nameLabel = makeHeaderLabel(text: "Full Name")
    
    // UPDATED: Added (Optional) text
    private lazy var nickNameLabel = makeHeaderLabel(text: "Nickname (Optional)")
    
    private lazy var dobLabel = makeHeaderLabel(text: "Date of Birth")
    private lazy var genderLabel = makeHeaderLabel(text: "Gender")

    private lazy var nameTextField = makeStyledTextField(placeholder: "e.g., Sarah Jones")
    private lazy var nickNameTextField = makeStyledTextField(placeholder: "e.g., Sary")
    private lazy var dobTextField = makeStyledTextField(placeholder: "DD/MM/YYYY")
    
    // Custom private class to avoid redeclaration conflicts
    private let genderControl = ChildGenderSelectionControl(items: ["Female", "Male"])

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
        
        // Add shadow to button
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
        setupDatePicker()
        registerKeyboardObservers()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupGradient()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update gradient frame
        backgroundGradientLayer?.frame = view.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .systemBackground // Fallback
        
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
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            createSpacer(height: 10),
            nameLabel, nameTextField,
            createSpacer(height: 4),
            nickNameLabel, nickNameTextField,
            createSpacer(height: 4),
            dobLabel, dobTextField,
            createSpacer(height: 4),
            genderLabel, genderControl,
            createSpacer(height: 16),
            doneButton
        ])
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.setCustomSpacing(24, after: nameTextField)
        stack.setCustomSpacing(24, after: nickNameTextField)
        stack.setCustomSpacing(24, after: dobTextField)
        stack.setCustomSpacing(30, after: genderControl)
        
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
            mainScrollView.topAnchor.constraint(equalTo: view.topAnchor), // Go to top of screen for gradient effect
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
            
            // Card (Updated for Landscape & Responsiveness)
            formCardView.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 30),
            formCardView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            // Max width constraint ensures it doesn't look stretched on landscape/iPad
            formCardView.widthAnchor.constraint(lessThanOrEqualToConstant: 480),
            // Priority low ensures it can shrink on small screens, constant -40 gives padding
            formCardView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -40).withPriority(.defaultHigh),
            
            // Important: This connects bottom of card to bottom of content view
            formCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        // Floating back button constraints (if added)
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
            
            // UPDATED: Darker gradient colors as requested
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
        // 1. Dismiss Keyboard
        view.endEditing(true)
        
        // 2. Validate (Optional)
        guard let name = nameTextField.text, !name.isEmpty else {
            shakeCard()
            return
        }
        
        // Note: Nickname is now explicitly optional, so we don't guard against it.
        
        // 3. Show Success Popover (Alert)
        let alert = UIAlertController(title: "Success!", message: "\(name) has been added to the family.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigateToParentProfile()
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func navigateToParentProfile() {
        let parentVC = ParentProfileMembers()
        navigationController?.pushViewController(parentVC, animated: true)
    }
    
    private func shakeCard() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0]
        formCardView.layer.add(animation, forKey: "shake")
    }

    // MARK: - Input Helpers

    private func setupDatePicker() {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.maximumDate = Date()
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        dobTextField.inputView = picker
        
        // Toolbar
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolBar.items = [.flexibleSpace(), doneBtn]
        dobTextField.inputAccessoryView = toolBar
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dobTextField.text = formatter.string(from: sender.date)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

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
        
        // Left Padding
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

// MARK: - Private Custom Gender Control
// Extension to use Auto Layout for the selection pill instead of frames to fix rotation issues
private extension NSLayoutConstraint {
    func withPriority(_ p: UILayoutPriority) -> NSLayoutConstraint {
        priority = p
        return self
    }
}

private class ChildGenderSelectionControl: UIControl {
    
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    private let selectionPill = UIView()
    private let items: [String]
    
    // Auto Layout constraints for the pill
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
        
        // 1. Add Pill (Selection Indicator) FIRST so it's behind buttons if buttons are transparent
        // Note: Standard system buttons are transparent, so the pill will show through.
        // If we want the text on TOP, the button needs to be on TOP of the pill visually.
        selectionPill.backgroundColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1)
        selectionPill.layer.cornerRadius = 12
        selectionPill.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionPill)
        
        // 2. Add Stack View
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
        
        // 3. Add Buttons
        for (index, title) in items.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        // Initial Selection State
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
        
        // Update Text Colors
        buttons.forEach { $0.setTitleColor(UIColor.darkGray, for: .normal) }
        selectedButton.setTitleColor(.white, for: .normal)
        
        // Update Pill Constraints (Robust for Rotation)
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
