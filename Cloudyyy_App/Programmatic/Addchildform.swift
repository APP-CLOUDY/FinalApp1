import UIKit

// MARK: - Addchildform
final class Addchildform: UIViewController {

    // MARK: - Data Properties
    // We store the actual date object here to send to Supabase
    private var selectedDate: Date = Date()

    // MARK: - Views

    // This layer handles the full-screen gradient
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

    // Cloud image (from Assets)
    private let cloudImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        // Replace "cloudyy_logo" with your actual asset name
        iv.image = UIImage(named: "cloudyy_logo")
        return iv
    }()

    // Floating back button
    private lazy var backButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .white
        b.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return b
    }()

    // White rounded card
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
        l.text = "Add Children"
        l.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        l.textAlignment = .center
        l.textColor = UIColor(red: 12/255, green: 34/255, blue: 76/255, alpha: 1)
        return l
    }()

    // MARK: - Labels & Fields

    private lazy var nameLabel = makeLabel(text: "Name")
    private lazy var nickNameLabel = makeLabel(text: "Nick name")
    private lazy var dobLabel = makeLabel(text: "Birth of date")
    private lazy var genderLabel = makeLabel(text: "Gender")

    private lazy var nameField = makeTextField(placeholder: "Enter child's name")
    private lazy var nickField = makeTextField(placeholder: "Chore Champion")
    private lazy var dobField = makeTextField(placeholder: "18/03/2024")

    private let genderSelector = GenderSelector(options: ["Female", "Male"])

    private lazy var doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Done", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1)
        b.layer.cornerRadius = 14
        b.heightAnchor.constraint(equalToConstant: 52).isActive = true
        b.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        setupHierarchy()
        setupConstraints()
        setupDatePicker()
        registerKeyboardNotifications()
        
        // Hide default back button if we are using our custom one
        navigationItem.hidesBackButton = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        applyFullBackgroundGradient()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer?.frame = view.bounds
        genderSelector.refreshPillPosition(animated: false)
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

    // MARK: - Setup Logic

    private func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cloudImageView)
        contentView.addSubview(cardView)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            nameLabel, nameField,
            nickNameLabel, nickField,
            dobLabel, dobField,
            genderLabel, genderSelector,
            doneButton
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
        stack.setCustomSpacing(24, after: genderSelector)
        stack.setCustomSpacing(4, after: nameLabel)
        stack.setCustomSpacing(4, after: nickNameLabel)
        stack.setCustomSpacing(4, after: dobLabel)
        stack.setCustomSpacing(4, after: genderLabel)

        cardView.addSubview(stack)

        if let nav = navigationController, !nav.isNavigationBarHidden {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(backTapped))
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
                backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
                backButton.widthAnchor.constraint(equalToConstant: 36),
                backButton.heightAnchor.constraint(equalToConstant: 36)
            ])
        }

        NSLayoutConstraint.activate(activeConstraints)

        NSLayoutConstraint.activate([
            cloudImageView.heightAnchor.constraint(lessThanOrEqualTo: frameLayoutGuide.heightAnchor, multiplier: 0.30).withPriority(.defaultHigh),
            cloudImageView.widthAnchor.constraint(equalToConstant: 280).withPriority(.defaultHigh)
        ])

        if let stack = cardView.subviews.compactMap({ $0 as? UIStackView }).first {
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 22),
                stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
                stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
                stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -22)
            ])
        }

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

        let cal = UIImageView(image: UIImage(systemName: "calendar"))
        cal.tintColor = UIColor(white: 0.6, alpha: 1)
        cal.contentMode = .center
        cal.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        dobField.rightView = cal
        dobField.rightViewMode = .always
    }

    @objc private func datePicked(_ sender: UIDatePicker) {
        // 1. Store the Date object for the API
        self.selectedDate = sender.date
        
        // 2. Update display text
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        dobField.text = df.string(from: sender.date)
    }

    @objc private func dismissPicker() {
        view.endEditing(true)
    }

    // MARK: - Keyboard Handling

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

        if let firstResponder = UIResponder.currentFirstResponder as? UIView {
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

    @objc private func doneTapped() {
        view.endEditing(true)
        
        // 1. Validate (Using single name field)
        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            // Optional: Shake animation or alert here
            print("Name is empty")
            return
        }
        
        let nick = nickField.text ?? ""
        let gender = genderSelector.selectedGender.rawValue.lowercased()
        
        // 2. UI Loading State
        doneButton.isEnabled = false
        doneButton.setTitle("Saving...", for: .normal)
        doneButton.alpha = 0.7
        
        // 3. API Call via Service
        // Use _Concurrency.Task to avoid conflict with "Task" model
        _Concurrency.Task {
            do {
                // We send the SINGLE name directly
                let joinCode = try await ChildService.shared.addChild(
                    name: name,
                    nickname: nick,
                    dob: self.selectedDate,
                    gender: gender
                )
                
                print("Success! Child Added. Code: \(joinCode)")
                
                await MainActor.run {
                    self.doneButton.isEnabled = true
                    self.doneButton.setTitle("Done", for: .normal)
                    self.doneButton.alpha = 1.0
                    
                    // 4. Navigate to Family/Dashboard
                    let vc = FamilyViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } catch {
                print("Error adding child: \(error)")
                await MainActor.run {
                    self.doneButton.isEnabled = true
                    self.doneButton.setTitle("Try Again", for: .normal)
                    self.doneButton.alpha = 1.0
                }
            }
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
        tf.setLeftPaddingPoints(12)
        tf.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return tf
    }
}

// MARK: - GenderSelector (Custom Control)

private class GenderSelector: UIControl {
    enum Gender: String {
        case female = "Female"
        case male = "Male"
        case others = "Others"
    }

    private let stack = UIStackView()
    private var buttons: [UIButton] = []
    private let pill = UIView()
    private let titles: [String]

    private(set) var selectedIndex: Int = 0 {
        didSet { updateSelection(animated: true) }
    }

    var selectedGender: Gender {
        switch titles[selectedIndex] {
        case "Female": return .female
        case "Male": return .male
        default: return .others
        }
    }

    private var pillLeading: NSLayoutConstraint?
    private var pillWidth: NSLayoutConstraint?
    private var pillTop: NSLayoutConstraint?
    private var pillHeight: NSLayoutConstraint?

    init(options: [String]) {
        self.titles = options
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 46).isActive = true
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        backgroundColor = UIColor(white: 0.94, alpha: 1)
        layer.cornerRadius = 14
        clipsToBounds = false

        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.backgroundColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1)
        pill.layer.cornerRadius = 12
        addSubview(pill)

        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        for (i, t) in titles.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(t, for: .normal)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.tag = i
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            btn.setTitleColor(i == selectedIndex ? .white : UIColor(white: 0.12, alpha: 1), for: .normal)
            btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttons.append(btn)
            stack.addArrangedSubview(btn)
        }

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        refreshPillPosition(animated: false)
    }

    func refreshPillPosition(animated: Bool) {
        guard buttons.indices.contains(selectedIndex) else { return }

        pillLeading?.isActive = false
        pillWidth?.isActive = false
        pillTop?.isActive = false
        pillHeight?.isActive = false

        let target = buttons[selectedIndex]
        let frameInSelf = target.convert(target.bounds, to: self)

        pillLeading = pill.leadingAnchor.constraint(equalTo: leadingAnchor, constant: frameInSelf.minX + 6)
        pillWidth = pill.widthAnchor.constraint(equalToConstant: max(44, frameInSelf.width - 12))
        pillTop = pill.topAnchor.constraint(equalTo: topAnchor, constant: 6)
        pillHeight = pill.heightAnchor.constraint(equalToConstant: bounds.height - 12)

        pillLeading?.isActive = true
        pillWidth?.isActive = true
        pillTop?.isActive = true
        pillHeight?.isActive = true

        for (i, btn) in buttons.enumerated() {
            if i == selectedIndex {
                btn.setTitleColor(.white, for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            } else {
                btn.setTitleColor(UIColor(white: 0.12, alpha: 1), for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            }
        }

        if animated {
            UIView.animate(withDuration: 0.22, animations: { self.layoutIfNeeded() })
        } else {
            layoutIfNeeded()
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        sendActions(for: .valueChanged)
    }

    private func updateSelection(animated: Bool) {
        refreshPillPosition(animated: animated)
    }
}

// MARK: - UITextField padding helper

private extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let pad = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 48))
        leftView = pad
        leftViewMode = .always
    }
}

// MARK: - UIResponder extension

private extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder?

    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    @objc func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
}

// MARK: - NSLayoutConstraint convenience

private extension NSLayoutConstraint {
    func withPriority(_ p: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = p
        return self
    }
}
