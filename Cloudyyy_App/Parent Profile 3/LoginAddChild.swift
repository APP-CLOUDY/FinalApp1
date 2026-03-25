import UIKit

final class LoginAddChild: UIViewController {

    // MARK: - Data
    var familyId: UUID? // ✅ Recieves Family ID from ParentProfileMembers
    private var selectedDate: Date = Date()

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
        ParentBackButtonFactory.make(target: self, action: #selector(handleBack))
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
        l.text = "Add Child Profile"
        l.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        l.textAlignment = .center
        l.textColor = UIColor(red: 12/255, green: 34/255, blue: 76/255, alpha: 1)
        return l
    }()

    // MARK: - Inputs
    private lazy var nameField = makeTextField(placeholder: "Enter child's name")
    private lazy var nickField = makeTextField(placeholder: "Nick Name (e.g. Chore Champion)")
    private lazy var dobField = makeTextField(placeholder: "Date of Birth (DD/MM/YYYY)")
    
    private let genderSelector = GenderSelector(options: ["Female", "Male"])

    private lazy var doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Done", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1)
        b.layer.cornerRadius = 14
        b.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDatePicker()
        registerKeyboardNotifications()
        navigationItem.hidesBackButton = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if backgroundGradientLayer == nil {
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1).cgColor,
                UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1).cgColor
            ]
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
            view.layer.insertSublayer(gradient, at: 0)
            backgroundGradientLayer = gradient
        }
        backgroundGradientLayer?.frame = view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        genderSelector.refreshPillPosition(animated: false)
    }

    // MARK: - Actions

    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func handleDone() {
        view.endEditing(true)
        
        // 1. Validation
        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            shake(view: nameField)
            shake(view: doneButton)
            return
        }
        
        let nick = nickField.text ?? ""
        let gender = genderSelector.selectedGender.rawValue.lowercased()
        
        // 2. Loading State
        doneButton.isEnabled = false
        doneButton.setTitle("Saving...", for: .normal)
        doneButton.alpha = 0.7
        
        // 3. Service Call
        _Concurrency.Task {
            do {
                // ✅ REUSING YOUR EXISTING SERVICE
                let joinCode = try await ChildService.shared.addChild(
                    name: name,
                    nickname: nick,
                    dob: selectedDate,
                    gender: gender,
                    familyId: self.familyId
                )
                
                print("Child Added! Join Code: \(joinCode)")
                
                await MainActor.run {
                    self.doneButton.isEnabled = true
                    self.doneButton.setTitle("Done", for: .normal)
                    self.doneButton.alpha = 1.0
                    
                    // ✅ SUCCESS: Pop back to Member List
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("Error adding child: \(error)")
                await MainActor.run {
                    self.doneButton.isEnabled = true
                    self.doneButton.setTitle("Try Again", for: .normal)
                    self.doneButton.alpha = 1.0
                    self.shake(view: self.doneButton)
                }
            }
        }
    }

    // MARK: - Layout Setup
    private func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cloudImageView)
        contentView.addSubview(cardView)
        
        // Form Stack
        let stack = UIStackView(arrangedSubviews: [
            titleLabel, nameField, nickField, dobField, genderSelector, doneButton
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 24
        stack.setCustomSpacing(32, after: titleLabel)
        cardView.addSubview(stack)
        
        // Back Button
        if let nav = navigationController, !nav.isNavigationBarHidden {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(handleBack))
            navigationItem.leftBarButtonItem?.tintColor = .white
        } else {
            view.addSubview(backButton)
        }
        
        let safe = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safe.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            cloudImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cloudImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            cloudImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 180),
            cloudImageView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.75),
            
            cardView.topAnchor.constraint(equalTo: cloudImageView.bottomAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: cardView.bottomAnchor, constant: 40),
            
            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -32),
            
            doneButton.heightAnchor.constraint(equalToConstant: 52),
            nameField.heightAnchor.constraint(equalToConstant: 50),
            nickField.heightAnchor.constraint(equalToConstant: 50),
            dobField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        if backButton.superview != nil {
            NSLayoutConstraint.activate([
                backButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
                backButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 12),
            ])
        }
    }
    
    // MARK: - Helpers & Components
    
    private func shake(view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 8, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 8, y: view.center.y))
        view.layer.add(animation, forKey: "position")
    }

    private func makeTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.systemGray])
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.backgroundColor = UIColor(white: 0.96, alpha: 1)
        tf.layer.cornerRadius = 10
        let pad = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 48))
        tf.leftView = pad
        tf.leftViewMode = .always
        return tf
    }
    
    private func setupDatePicker() {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) { picker.preferredDatePickerStyle = .wheels }
        picker.maximumDate = Date()
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        dobField.inputView = picker
        
        let tool = UIToolbar()
        tool.sizeToFit()
        tool.items = [.flexibleSpace(), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKb))]
        dobField.inputAccessoryView = tool
        
        let iconView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 50))
        let img = UIImageView(image: UIImage(systemName: "calendar"))
        img.tintColor = .gray
        img.frame = CGRect(x: 10, y: 13, width: 24, height: 24)
        iconView.addSubview(img)
        dobField.rightView = iconView
        dobField.rightViewMode = .always
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        dobField.text = df.string(from: sender.date)
    }
    
    @objc private func dismissKb() { view.endEditing(true) }
    
    // Keyboard Logic
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func kbWillShow(_ n: Notification) {
        guard let info = n.userInfo, let kbFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let converted = view.convert(kbFrame, from: nil)
        let inset = converted.height - view.safeAreaInsets.bottom + 20
        scrollView.contentInset.bottom = inset
        scrollView.verticalScrollIndicatorInsets.bottom = inset
    }

    @objc private func kbWillHide(_ n: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = .zero
    }
}

// MARK: - Gender Selector (Included to be standalone)
private class GenderSelector: UIControl {
    enum Gender: String { case female = "Female", male = "Male", others = "Others" }
    
    private let stack = UIStackView()
    private var buttons: [UIButton] = []
    private let pill = UIView()
    private let titles: [String]
    private(set) var selectedIndex: Int = 0 { didSet { refreshPillPosition(animated: true) } }
    
    var selectedGender: Gender {
        switch titles[selectedIndex] {
        case "Female": return .female
        case "Male": return .male
        default: return .others
        }
    }
    
    // Constraints references for pill
    private var pLead: NSLayoutConstraint?, pWidth: NSLayoutConstraint?, pTop: NSLayoutConstraint?, pHeight: NSLayoutConstraint?

    init(options: [String]) {
        self.titles = options
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 46).isActive = true
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = UIColor(white: 0.94, alpha: 1)
        layer.cornerRadius = 14
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.backgroundColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1)
        pill.layer.cornerRadius = 12
        addSubview(pill)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        addSubview(stack)
        
        stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6).isActive = true
        stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6).isActive = true
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        for (i, t) in titles.enumerated() {
            let b = UIButton(type: .system)
            b.setTitle(t, for: .normal)
            b.tag = i
            b.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            buttons.append(b)
            stack.addArrangedSubview(b)
        }
    }
    
    @objc private func tap(_ sender: UIButton) {
        selectedIndex = sender.tag
        sendActions(for: .valueChanged)
    }
    
    func refreshPillPosition(animated: Bool) {
        guard buttons.indices.contains(selectedIndex) else { return }
        pLead?.isActive = false; pWidth?.isActive = false; pTop?.isActive = false; pHeight?.isActive = false
        
        let target = buttons[selectedIndex]
        let rect = target.frame
        
        pLead = pill.leadingAnchor.constraint(equalTo: leadingAnchor, constant: (rect.minX + 6))
        pWidth = pill.widthAnchor.constraint(equalToConstant: max(44, rect.width))
        pTop = pill.topAnchor.constraint(equalTo: topAnchor, constant: 6)
        pHeight = pill.heightAnchor.constraint(equalToConstant: bounds.height - 12)
        
        pLead?.isActive = true; pWidth?.isActive = true; pTop?.isActive = true; pHeight?.isActive = true
        
        buttons.enumerated().forEach { (i, btn) in
            btn.setTitleColor(i == selectedIndex ? .white : .darkGray, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: i == selectedIndex ? .semibold : .regular)
        }
        
        if animated { UIView.animate(withDuration: 0.2) { self.layoutIfNeeded() } } else { layoutIfNeeded() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if pLead == nil { refreshPillPosition(animated: false) }
    }
}
