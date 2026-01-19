import UIKit

// ===========================================================
// MARK: - Base Card
// ===========================================================

class RewardCardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 14
        backgroundColor = UIColor.white.withAlphaComponent(0.06)
        translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) { fatalError() }
}

// ===========================================================
// MARK: - Styled TextField (FIXED)
// ===========================================================

// Reminders-style single-line Title field
final class StyledTextField: UIView {
    private let container = UIView()
    private let tf = UITextField()
    private let bottomSeparator = UIView()

    // same API as before
    var textValue: String {
        get { tf.text ?? "" }
        set { tf.text = newValue }
    }

    init(placeholder: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        // Container uses system grouped background for that "cell" look
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 8
        container.layer.masksToBounds = true

        // Text field styling — larger font to match Reminders "title"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .none
        tf.placeholder = placeholder
        tf.font = .systemFont(ofSize: 18, weight: .semibold)
        tf.textColor = .label
        tf.clearButtonMode = .whileEditing

        // subtle bottom separator (optional, for even closer look)
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparator.backgroundColor = UIColor.separator.withAlphaComponent(0.6)

        addSubview(container)
        container.addSubview(tf)
        container.addSubview(bottomSeparator)

        NSLayoutConstraint.activate([
            // container fills the component
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            // tf inset inside container
            tf.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            tf.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            tf.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            tf.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),

            // bottom separator
            bottomSeparator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            bottomSeparator.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    // outer view remains transparent so stack spacing is controlled externally
    override var backgroundColor: UIColor? { get { .clear } set { /* ignore */ } }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


// ===========================================================
// MARK: - Styled TextView (FIXED)
// ===========================================================
// Reminders-style multi-line notes with a placeholder label
final class StyledTextView: UIView, UITextViewDelegate {
    private let container = UIView()
    private let tv = UITextView()
    private let placeholderLabel = UILabel()

    // same API as before but now uses a real placeholder label
    var textValue: String {
        get { tv.text == "" ? "" : tv.text }
        set {
            tv.text = newValue
            placeholderLabel.isHidden = !tv.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            tv.textColor = newValue.isEmpty ? .secondaryLabel : .label
        }
    }

    init(placeholder: String) {
        self.placeholderLabel.text = placeholder
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        // container mimics grouped inset
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemGroupedBackground
        container.layer.cornerRadius = 10
        container.layer.masksToBounds = true

        // text view config
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 16)
        tv.textColor = .label
        tv.isScrollEnabled = true
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        tv.textContainer.lineFragmentPadding = 0

        // placeholder label sits where the text starts
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.textColor = .secondaryLabel
        placeholderLabel.font = .systemFont(ofSize: 16)
        placeholderLabel.numberOfLines = 0
        placeholderLabel.isUserInteractionEnabled = false

        addSubview(container)
        container.addSubview(tv)
        container.addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            tv.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tv.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tv.topAnchor.constraint(equalTo: container.topAnchor),
            tv.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            // placeholder positioned with insets
            placeholderLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            placeholderLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            placeholderLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14)
        ])

        // start empty with placeholder visible
        placeholderLabel.isHidden = false
        tv.text = ""
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.12) { self.placeholderLabel.alpha = 0.0 }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        let empty = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        placeholderLabel.isHidden = !empty
        UIView.animate(withDuration: 0.12) { self.placeholderLabel.alpha = empty ? 1.0 : 0.0 }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// ===========================================================
// MARK: - SelectRow (button-backed, supports UIMenu)
// ===========================================================

class RewardSelectRow: RewardCardView {
    // Hides the chevron arrow
    func hideChevron() {
        chevron.isHidden = true
    }
    
    var detailValue: String?

    // Inserts custom views at the end of the right side
    func addTrailingViews(_ views: [UIView]) {
        for v in views {
            v.translatesAutoresizingMaskIntoConstraints = false
            hStack.addArrangedSubview(v)
        }
    }

    func setAttributedTitle(_ text: NSAttributedString) {
        titleLabel.attributedText = text
    }
    
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
    private let button = UIButton(configuration: .plain())
    private var usesMenu = false
    
    let hStack = UIStackView()

    var onTap: (() -> Void)?
    var detailText: String? { detailLabel.text }

    init(title: String) {
        super.init(frame: .zero)

        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16)

        detailLabel.text = "Select"
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        detailLabel.font = .systemFont(ofSize: 14)

        chevron.tintColor = UIColor.white.withAlphaComponent(0.5)

        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = 8
        hStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(hStack)

        hStack.addArrangedSubview(titleLabel)
        hStack.addArrangedSubview(UIView())  // spacer
        hStack.addArrangedSubview(detailLabel)
        hStack.addArrangedSubview(chevron)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSubview(button)

        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            hStack.topAnchor.constraint(equalTo: topAnchor),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor),

            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        button.showsMenuAsPrimaryAction = true
    }

    func setMenu(_ menu: UIMenu) {
            usesMenu = true
            button.menu = menu
            button.showsMenuAsPrimaryAction = true
        }
    
    func enableNavigationTap() {
           usesMenu = false
           button.showsMenuAsPrimaryAction = false
       }
    
    func setDetail(_ text: String, value: String? = nil) {
        detailLabel.text = text
        detailValue = value ?? text   // fallback safety
    }


    @objc private func buttonTapped() {
        onTap?()
    }

    required init?(coder: NSCoder) { fatalError() }
}

// ===========================================================
// MARK: - PointsRow
// ===========================================================
class PointsRow: RewardCardView, UITextFieldDelegate {

    private let title = UILabel()
    private let minus = UIButton(type: .system)
    private let plus = UIButton(type: .system)

    private let minPoints: Int   // ✅ configurable minimum

    private let valueField: UITextField = {
        let tf = UITextField()
        tf.textColor = .white
        tf.font = .boldSystemFont(ofSize: 18)
        tf.textAlignment = .center
        tf.keyboardType = .numberPad
        tf.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        tf.layer.cornerRadius = 8
        tf.clipsToBounds = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    // ✅ SINGLE SOURCE OF TRUTH
    var countValue: Int {
        didSet {
            if countValue < minPoints {
                countValue = minPoints
                return
            }
            valueField.text = "\(countValue)"
        }
    }

    // ✅ Custom initializer
    init(minPoints: Int) {
        self.minPoints = minPoints
        self.countValue = minPoints
        super.init(frame: .zero)

        title.text = "Points"
        title.textColor = .white
        title.font = .systemFont(ofSize: 16)

        minus.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        plus.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        minus.tintColor = .white
        plus.tintColor = .white

        minus.addTarget(self, action: #selector(dec), for: .touchUpInside)
        plus.addTarget(self, action: #selector(inc), for: .touchUpInside)

        valueField.delegate = self
        valueField.text = "\(minPoints)"

        let h = UIStackView(arrangedSubviews: [title, UIView(), minus, valueField, plus])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 10
        h.translatesAutoresizingMaskIntoConstraints = false

        addSubview(h)

        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            h.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            h.topAnchor.constraint(equalTo: topAnchor),
            h.bottomAnchor.constraint(equalTo: bottomAnchor),

            valueField.widthAnchor.constraint(equalToConstant: 60),
            valueField.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    // MARK: - Actions
    @objc private func inc() {
        countValue += 10
    }

    @objc private func dec() {
        countValue = max(minPoints, countValue - 10)
    }

    // MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        let entered = Int(textField.text ?? "") ?? minPoints
        countValue = max(minPoints, entered)
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string.isEmpty { return true }
        return string.rangeOfCharacter(from: .decimalDigits) != nil
    }

    required init?(coder: NSCoder) { fatalError() }
}

// ===========================================================
// MARK: - UploadBoxCard
// ===========================================================

class UploadBoxCard: RewardCardView {

    private let icon = UIImageView()
    private let label = UILabel()
    private let imageView = UIImageView()
    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        icon.image = UIImage(systemName: "photo.on.rectangle.angled")
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit

        label.text = "Upload your photo here"
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.0
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let v = UIStackView(arrangedSubviews: [icon, label])
        v.axis = .vertical
        v.alignment = .center
        v.spacing = 12
        v.translatesAutoresizingMaskIntoConstraints = false

        addSubview(v)
        addSubview(imageView)

        // tap gesture for opening image picker
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)

        NSLayoutConstraint.activate([
            v.centerXAnchor.constraint(equalTo: centerXAnchor),
            v.centerYAnchor.constraint(equalTo: centerYAnchor),

            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func setImage(_ img: UIImage?) {
        guard let img = img else {
            imageView.image = nil
            imageView.alpha = 0
            return
        }
        imageView.image = img
        imageView.alpha = 1
    }

    @objc private func tapped() { onTap?() }
    required init?(coder: NSCoder) { fatalError() }
}

// ===========================================================
// MARK: - Select3DCard (shows selected 3D object & opens 3D selector)
// ===========================================================
final class Select3DCard: RewardCardView {

    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {

        // Image
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "cube.box")
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.text = "Tap to choose 3D Object"
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),

            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.38),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.38)
        ])

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }

    // ✅ Call this after selecting an object
    func configure(title: String, image: UIImage?) {
        titleLabel.text = title
        titleLabel.textColor = .white
        imageView.image = image ?? UIImage(systemName: "cube.box")
    }

    @objc private func tapped() {
        onTap?()
    }
}
// ===========================================================
// MARK: - ApprovalToggleRow (FIXED)
// ===========================================================

class ApprovalToggleRow: RewardCardView {

    private let titleLabel = UILabel()
    private let toggle = UISwitch()

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16)

        toggle.onTintColor = .systemGreen

        let h = UIStackView(arrangedSubviews: [titleLabel, UIView(), toggle])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 8
        h.translatesAutoresizingMaskIntoConstraints = false

        addSubview(h)

        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            h.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            h.topAnchor.constraint(equalTo: topAnchor),
            h.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // ✅ FIX: Added method to set switch state programmatically
    func setOn(_ isOn: Bool) {
        toggle.setOn(isOn, animated: false)
    }

    var isOn: Bool { toggle.isOn }
    required init?(coder: NSCoder) { fatalError() }
}
