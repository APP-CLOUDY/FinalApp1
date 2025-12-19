//
//  childAccount.swift
//  Cloudyyy_App
//
//  Created by user@5 on 26/11/25.
//



import UIKit

// MARK: - ChildAccountViewController
final class ChildAccountViewController: UIViewController {

    // MARK: - Views

    private var backgroundGradientLayer: CAGradientLayer?

    private let scrollView: UIScrollView = {
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

    private let cloudImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "cloudyy_logo")
        return iv
    }()

    private lazy var backButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .white
        b.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var editButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Edit", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        b.tintColor = .white
        b.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        return b
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.12
        v.layer.shadowRadius = 16
        v.layer.shadowOffset = CGSize(width: 0, height: 10)
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Child Account"
        l.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        l.textAlignment = .center
        l.textColor = UIColor(red: 12/255, green: 34/255, blue: 76/255, alpha: 1)
        return l
    }()

    // MARK: - Labels & Fields

    private lazy var nameLabel = makeLabel(text: "Name")
    private lazy var nickNameLabel = makeLabel(text: "Nick name")
    private lazy var dobLabel = makeLabel(text: "Birth of date")
    private lazy var familyNameLabel = makeLabel(text: "Family Name")

    // Merged Name Field (as requested)
    private lazy var nameField = makeTextField(placeholder: "Enter name")
    
    private lazy var nickField = makeTextField(placeholder: "Display name")
    
    private lazy var dobField: UITextField = {
        let tf = makeTextField(placeholder: "18/03/2024")
        // Calendar icon for Date field
        let cal = UIImageView(image: UIImage(systemName: "calendar"))
        cal.tintColor = UIColor(white: 0.6, alpha: 1)
        cal.contentMode = .center
        cal.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        tf.rightView = cal
        tf.rightViewMode = .always
        return tf
    }()
    
    // New Family Name Field
    private lazy var familyNameField: UITextField = {
        let tf = makeTextField(placeholder: "Happy Home")
        // Eye-slash icon for Family Name (matching ref image style)
        let eye = UIImageView(image: UIImage(systemName: "eye.slash"))
        eye.tintColor = UIColor(white: 0.6, alpha: 1)
        eye.contentMode = .center
        eye.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        tf.rightView = eye
        tf.rightViewMode = .always
        return tf
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        setupHierarchy()
        setupConstraints()
        setupDatePicker()
        registerKeyboardNotifications()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        applyFullBackgroundGradient()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer?.frame = view.bounds
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.backgroundGradientLayer?.frame = CGRect(origin: .zero, size: size)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Setup

    private func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(cloudImageView)
        contentView.addSubview(cardView)

        // Stack updated with Family Name instead of Gender
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,

            nameLabel,
            nameField,

            nickNameLabel,
            nickField,

            dobLabel,
            dobField,
            
            familyNameLabel,
            familyNameField
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.distribution = .fill

        // Custom Spacing
        stack.setCustomSpacing(24, after: nameField)
        stack.setCustomSpacing(24, after: nickField)
        stack.setCustomSpacing(24, after: dobField)
        stack.setCustomSpacing(24, after: familyNameField)

        // Label spacing
        stack.setCustomSpacing(4, after: nameLabel)
        stack.setCustomSpacing(4, after: nickNameLabel)
        stack.setCustomSpacing(4, after: dobLabel)
        stack.setCustomSpacing(4, after: familyNameLabel)

        cardView.addSubview(stack)

        // Navigation / Buttons
        if let nav = navigationController, !nav.isNavigationBarHidden {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(backTapped)
            )
            navigationItem.leftBarButtonItem?.tintColor = .white
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit",
                style: .plain,
                target: self,
                action: #selector(editTapped)
            )
            navigationItem.rightBarButtonItem?.tintColor = .white
            
        } else {
            view.addSubview(backButton)
            view.addSubview(editButton)
        }
    }

    private func setupConstraints() {
        let contentLayoutGuide = scrollView.contentLayoutGuide
        let frameLayoutGuide = scrollView.frameLayoutGuide
        let safe = view.safeAreaLayoutGuide

        var activeConstraints: [NSLayoutConstraint] = [
            scrollView.topAnchor.constraint(equalTo: safe.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safe.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor),

            cloudImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cloudImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            cloudImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 180),
            cloudImageView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.75),

            cardView.topAnchor.constraint(equalTo: cloudImageView.bottomAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22)
        ]

        if backButton.superview != nil {
            activeConstraints.append(contentsOf: [
                backButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
                backButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 12),
                backButton.widthAnchor.constraint(equalToConstant: 36),
                backButton.heightAnchor.constraint(equalToConstant: 36)
            ])
        }
        
        if editButton.superview != nil {
            activeConstraints.append(contentsOf: [
                editButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
                editButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
                editButton.heightAnchor.constraint(equalToConstant: 36)
            ])
        }

        NSLayoutConstraint.activate(activeConstraints)

        NSLayoutConstraint.activate([
            cloudImageView.heightAnchor.constraint(lessThanOrEqualTo: frameLayoutGuide.heightAnchor, multiplier: 0.30).withChildPriority(.defaultHigh),
            cloudImageView.widthAnchor.constraint(equalToConstant: 280).withChildPriority(.defaultHigh)
        ])

        guard let stack = cardView.subviews.compactMap({ $0 as? UIStackView }).first else { return }
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 22),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -22)
        ])

        let contentMinHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: frameLayoutGuide.heightAnchor)
        contentMinHeight.priority = .defaultLow
        contentMinHeight.isActive = true

        contentView.bottomAnchor.constraint(greaterThanOrEqualTo: cardView.bottomAnchor, constant: 40).isActive = true
    }

    private func applyFullBackgroundGradient() {
        if backgroundGradientLayer == nil {
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1).cgColor,
                UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1).cgColor
            ]
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint   = CGPoint(x: 0.5, y: 1.0)
            view.layer.insertSublayer(gradient, at: 0)
            backgroundGradientLayer = gradient
        }
        backgroundGradientLayer?.frame = view.bounds
    }

    // MARK: - Date Picker

    private func setupDatePicker() {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) { picker.preferredDatePickerStyle = .wheels }
        picker.maximumDate = Date()
        picker.addTarget(self, action: #selector(datePicked(_:)), for: .valueChanged)

        dobField.inputView = picker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem.flexibleSpace(),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissPicker))
        ]
        dobField.inputAccessoryView = toolbar
    }

    @objc private func datePicked(_ sender: UIDatePicker) {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        dobField.text = df.string(from: sender.date)
    }

    @objc private func dismissPicker() {
        view.endEditing(true)
    }

    // MARK: - Keyboard

    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func kbWillShow(_ n: Notification) {
        guard let info = n.userInfo,
              let kbFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let converted = view.convert(kbFrame, from: nil)
        let inset = converted.height - view.safeAreaInsets.bottom + 20
        scrollView.contentInset.bottom = inset
        scrollView.verticalScrollIndicatorInsets.bottom = inset

        if let firstResponder = UIResponder.currentChildFirstResponder as? UIView {
            let responderRectInContent = firstResponder.convert(firstResponder.bounds, to: contentView)
            let visibleY = responderRectInContent.maxY - (view.bounds.height - converted.height) / 2
            let targetOffsetY = max(0, visibleY - 20)
            scrollView.setContentOffset(CGPoint(x: 0, y: targetOffsetY), animated: true)
        }
    }

    @objc private func kbWillHide(_ n: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = .zero
    }

    // MARK: - Actions

    @objc private func backTapped() {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc private func editTapped() {
        print("Edit tapped")
        let isEditing = !nameField.isEnabled
        nameField.isEnabled = isEditing
        nickField.isEnabled = isEditing
        dobField.isEnabled = isEditing
        familyNameField.isEnabled = isEditing
        
        let newTitle = isEditing ? "Save" : "Edit"
        if let nav = navigationController, !nav.isNavigationBarHidden {
            navigationItem.rightBarButtonItem?.title = newTitle
        } else {
            editButton.setTitle(newTitle, for: .normal)
        }
    }

    // MARK: - Helpers

    private func makeLabel(text: String) -> UILabel {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = text
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(white: 0.35, alpha: 1)
        return l
    }

    private func makeTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = placeholder
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.backgroundColor = UIColor(white: 0.96, alpha: 1)
        tf.layer.cornerRadius = 10
        tf.setChildAccountLeftPadding(12)
        tf.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return tf
    }
}

// MARK: - Unique Extensions for Child Account
// These are renamed to avoid conflicts with Account.swift if both are in the same module.

private extension UITextField {
    func setChildAccountLeftPadding(_ amount: CGFloat) {
        let pad = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 48))
        leftView = pad
        leftViewMode = .always
    }
}

private extension UIResponder {
    private static weak var _currentChildFirstResponder: UIResponder?

    static var currentChildFirstResponder: UIResponder? {
        _currentChildFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findChildAccountFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentChildFirstResponder
    }

    @objc func findChildAccountFirstResponder(_ sender: Any) {
        UIResponder._currentChildFirstResponder = self
    }
}

private extension NSLayoutConstraint {
    func withChildPriority(_ p: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = p
        return self
    }
}
