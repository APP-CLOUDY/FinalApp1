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

    // MARK: - Fields

    private lazy var nameField = makeTextField(placeholder: "Enter name")
    private lazy var nickField = makeTextField(placeholder: "Display name")

    private lazy var dobField: UITextField = {
        let tf = makeTextField(placeholder: "Date of Birth (DD/MM/YYYY)")
        let cal = UIImageView(image: UIImage(systemName: "calendar"))
        cal.tintColor = UIColor(white: 0.55, alpha: 1)
        cal.contentMode = .center
        cal.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        tf.rightView = cal
        tf.rightViewMode = .always
        return tf
    }()

    private let genderSelector = ProfileGenderSelector(options: ["Female", "Male"])

    private lazy var familyField = makeTextField(placeholder: "Family Name")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        setupHierarchy()
        setupConstraints()
        setupDatePicker()
        registerKeyboardNotifications()
        applyReadOnlyState()
        fetchChildDetails()
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
            self.genderSelector.refreshPillPosition(animated: false)
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

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            nameField,
            nickField,
            dobField,
            genderSelector,
            familyField
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.distribution = .fill
        stack.setCustomSpacing(32, after: titleLabel)

        cardView.addSubview(stack)

        if let nav = navigationController, !nav.isNavigationBarHidden {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(backTapped)
            )
            navigationItem.leftBarButtonItem?.tintColor = .white
            
        } else {
            view.addSubview(backButton)
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

    // MARK: - Data

    private func fetchChildDetails() {
        Task {
            do {
                let child = try await ProfileService.shared.fetchChildProfile()
                let familyName = try await ProfileService.shared.fetchChildFamilyName(familyId: child.family_id)

                await MainActor.run {
                    self.nameField.text = child.name
                    self.nickField.text = (child.nickname?.isEmpty == false) ? child.nickname : "Chore Champion"
                    self.dobField.text = self.formattedDate(child.birth_date)
                    self.familyField.text = familyName ?? "--"
                    self.genderSelector.setSelection(gender: child.gender)
                }
            } catch {
                print("❌ Failed to load child account details: \(error)")
            }
        }
    }

    private func formattedDate(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "--" }

        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd"
        input.locale = Locale(identifier: "en_US_POSIX")

        let output = DateFormatter()
        output.dateFormat = "dd/MM/yyyy"
        output.locale = Locale(identifier: "en_US_POSIX")

        if let date = input.date(from: value) {
            return output.string(from: date)
        }

        return value
    }

    private func applyReadOnlyState() {
        [nameField, nickField, dobField, familyField].forEach {
            $0.isEnabled = false
        }
        genderSelector.isUserInteractionEnabled = false
    }

    // MARK: - Actions

    @objc private func backTapped() {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    private func makeTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = placeholder
        tf.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tf.textColor = UIColor(red: 12/255, green: 34/255, blue: 76/255, alpha: 1)
        tf.backgroundColor = UIColor(white: 0.96, alpha: 1)
        tf.layer.cornerRadius = 14
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(white: 0.68, alpha: 1)]
        )
        tf.setChildAccountLeftPadding(20)
        tf.heightAnchor.constraint(equalToConstant: 56).isActive = true
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

private final class ProfileGenderSelector: UIControl {
    private let stackView = UIStackView()
    private let selectedPill = UIView()
    private var buttons: [UIButton] = []
    private let options: [String]
    private(set) var selectedIndex: Int = 0

    init(options: [String]) {
        self.options = options
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        refreshPillPosition(animated: false)
    }

    private func setup() {
        backgroundColor = UIColor(white: 0.96, alpha: 1)
        layer.cornerRadius = 14
        clipsToBounds = true

        selectedPill.backgroundColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1)
        selectedPill.layer.cornerRadius = 12
        selectedPill.isUserInteractionEnabled = false
        addSubview(selectedPill)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])

        for (index, title) in options.enumerated() {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            button.setTitleColor(index == selectedIndex ? .white : UIColor(white: 0.2, alpha: 1), for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }

    @objc private func optionTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        updateButtonColors()
        refreshPillPosition(animated: true)
        sendActions(for: .valueChanged)
    }

    private func updateButtonColors() {
        for (index, button) in buttons.enumerated() {
            button.setTitleColor(index == selectedIndex ? .white : UIColor(white: 0.2, alpha: 1), for: .normal)
        }
    }

    func refreshPillPosition(animated: Bool) {
        guard selectedIndex < buttons.count else { return }
        let targetButton = buttons[selectedIndex]
        let targetFrame = convert(targetButton.frame, from: stackView)
        let insetFrame = targetFrame.insetBy(dx: 0, dy: 0)

        let updates = {
            self.selectedPill.frame = insetFrame
        }

        if animated {
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
                updates()
            }
        } else {
            updates()
        }
    }

    func setSelection(gender: String?) {
        let normalized = gender?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized == "male" {
            selectedIndex = 1
        } else {
            selectedIndex = 0
        }
        updateButtonColors()
        refreshPillPosition(animated: false)
    }
}
