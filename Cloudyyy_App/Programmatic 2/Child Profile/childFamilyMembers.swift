//
//  childFamilyMembers.swift
//  Cloudyyy_App
//
//  Created by user@5 on 26/11/25.
//

import UIKit

// MARK: - ProfileChildMembers
final class ProfileChildMembers: UIViewController {

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
        iv.image = UIImage(named: "cloudyy_logo") ?? UIImage(systemName: "person.2.circle.fill")
        iv.tintColor = .white.withAlphaComponent(0.8)
        return iv
    }()

    // Floating Back Button
    private lazy var backButton: UIButton = {
        ChildBackButtonFactory.make(target: self, action: #selector(handleBackTap))
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
        l.text = "Child Profile" // Adjusted title slightly to fit context
        l.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        l.textColor = UIColor(red: 12/255, green: 34/255, blue: 76/255, alpha: 1)
        l.textAlignment = .center
        return l
    }()

    // MARK: - Form Fields
    
    // Removed "Full Name" (Family Name) as requested
    private lazy var nickNameLabel = makeHeaderLabel(text: "Nickname")
    private lazy var dobLabel = makeHeaderLabel(text: "Date of Birth")
    private lazy var genderLabel = makeHeaderLabel(text: "Gender")

    private lazy var nickNameTextField = makeStyledTextField(placeholder: "e.g., Sary")
    private lazy var dobTextField = makeStyledTextField(placeholder: "DD/MM/YYYY")
    
    // Renamed control class to avoid redeclaration error
    private let genderControl = ProfileGenderControl(items: ["Female", "Male"])

    // Removed "Done/Add" Button as requested

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
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        } else {
            view.addSubview(backButton)
        }

        setupFormStack()
        setupConstraints()
    }

    private func setupFormStack() {
        // Removed Name Label, Name TextField, and Done Button from stack
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            createSpacer(height: 10),
            nickNameLabel, nickNameTextField,
            createSpacer(height: 4),
            dobLabel, dobTextField,
            createSpacer(height: 4),
            genderLabel, genderControl,
            createSpacer(height: 16)
        ])
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
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
            
            // Bottom Constraint
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
            gradient.colors = [
                UIColor(red: 10/255, green: 20/255, blue: 50/255, alpha: 1).cgColor,
                UIColor(red: 30/255, green: 60/255, blue: 120/255, alpha: 1).cgColor
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

// MARK: - Private Custom Gender Control (Renamed)
private extension NSLayoutConstraint {
    func withPriority(_ p: UILayoutPriority) -> NSLayoutConstraint {
        priority = p
        return self
    }
}

// Renamed class to ProfileGenderControl to prevent redeclaration errors with other files
private class ProfileGenderControl: UIControl {
    
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
