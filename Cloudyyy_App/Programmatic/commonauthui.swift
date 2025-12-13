//
// CommonUI.swift
// Reusable UI components for Cloudyyy (Login / Signup / JoinWithCode screens)
//

import UIKit

// MARK: - Appearance helpers
public enum CloudyyyColors {
    public static let deepBlack = UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1)
    public static let deepBlue  = UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1)
    public static let accentBlue = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    public static let accentBlue2 = UIColor(red: 0/255, green: 88/255, blue: 255/255, alpha: 1)
}

// MARK: - GradientHeaderView
public final class GradientHeaderView: UIView {
    private let gradient = CAGradientLayer()
    private let dottedImageView = UIImageView()

    public let appTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 48, weight: .black)
        l.text = "Cloudyyy"
        l.textColor = CloudyyyColors.accentBlue
        return l
    }()

    public let screenTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.textColor = .white
        return l
    }()

    public let smallInfoLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 14)
        l.textColor = UIColor(white: 1.0, alpha: 0.85)
        return l
    }()

    public let actionButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        return b
    }()

    public init(dottedImage: UIImage? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        setupGradient()
        setupSubviews(dottedImage: dottedImage)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupGradient() {
        gradient.colors = [CloudyyyColors.deepBlack.cgColor, CloudyyyColors.deepBlue.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.insertSublayer(gradient, at: 0)
    }

    private func setupSubviews(dottedImage: UIImage?) {
        if let img = dottedImage {
            dottedImageView.translatesAutoresizingMaskIntoConstraints = false
            dottedImageView.image = img.withRenderingMode(.alwaysTemplate)
            dottedImageView.tintColor = UIColor(white: 1, alpha: 0.06)
            dottedImageView.contentMode = .scaleAspectFill
            addSubview(dottedImageView)
            NSLayoutConstraint.activate([
                dottedImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                dottedImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                dottedImageView.topAnchor.constraint(equalTo: topAnchor),
                dottedImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        addSubview(appTitleLabel)
        addSubview(screenTitleLabel)
        addSubview(smallInfoLabel)
        addSubview(actionButton)

        NSLayoutConstraint.activate([
            appTitleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 24),
            appTitleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 44),

            screenTitleLabel.leadingAnchor.constraint(equalTo: appTitleLabel.leadingAnchor),
            screenTitleLabel.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor, constant: 12),

            smallInfoLabel.leadingAnchor.constraint(equalTo: appTitleLabel.leadingAnchor),
            smallInfoLabel.topAnchor.constraint(equalTo: screenTitleLabel.bottomAnchor, constant: 12),

            actionButton.leadingAnchor.constraint(equalTo: smallInfoLabel.trailingAnchor, constant: 6),
            actionButton.centerYAnchor.constraint(equalTo: smallInfoLabel.centerYAnchor)
        ])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}

// MARK: - CardView
public final class CardView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 18
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 12
    }
}

// MARK: - CustomTextField
public class CustomTextField: UITextField {
    public init(placeholder: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(white: 0.98, alpha: 1)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.89, alpha: 1).cgColor
        font = .systemFont(ofSize: 15)
        
        // Default placeholder color fix
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        )
        
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        leftViewMode = .always
        autocorrectionType = .no
        spellCheckingType = .no
        autocapitalizationType = .none
        keyboardType = .default
        heightAnchor.constraint(equalToConstant: 52).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - DateTextField
public class DateTextField: CustomTextField {
    private let picker = UIDatePicker()
    private var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()

    public var selectedDate: Date {
        get { picker.date }
        set { picker.date = newValue; updateText() }
    }

    public override init(placeholder: String) {
        super.init(placeholder: placeholder)
        configurePicker()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func configurePicker() {
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) { picker.preferredDatePickerStyle = .wheels }
        picker.maximumDate = Date()
        picker.locale = Locale.current
        picker.addTarget(self, action: #selector(valueChanged), for: .valueChanged)

        inputView = picker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        toolbar.items = [flex, done]
        inputAccessoryView = toolbar

        updateText()
    }

    @objc private func valueChanged() {
        updateText()
    }

    @objc private func doneTapped() {
        updateText()
        resignFirstResponder()
    }

    private func updateText() {
        text = dateFormatter.string(from: picker.date)
    }
}

// MARK: - PasswordField (FIXED)
public class PasswordField: CustomTextField {
    private let toggleButton = UIButton(type: .custom)

    public var disableAutoFill: Bool = false {
        didSet {
            if #available(iOS 12.0, *) {
                textContentType = disableAutoFill ? .oneTimeCode : .password
            } else {
                textContentType = nil
            }
        }
    }

    public override init(placeholder: String) {
        super.init(placeholder: placeholder)

        textColor = .label
        if #available(iOS 12.0, *) {
            textContentType = .password
        } else {
            textContentType = .none
        }

        isSecureTextEntry = true
        configureToggle()

        autocorrectionType = .no
        spellCheckingType = .no
        autocapitalizationType = .none
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // --- FIX START: Correct centering logic ---
    private func configureToggle() {
        // 1. Container width for touch area, height matches text field (52)
        let containerWidth: CGFloat = 48
        let height: CGFloat = 52
        let container = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: height))
        
        // 2. Button Size (Standard touch target)
        let buttonSize: CGFloat = 44
        
        // 3. Center vertically: (ContainerHeight - ButtonHeight) / 2
        // y = (52 - 44) / 2 = 4
        toggleButton.frame = CGRect(
            x: (containerWidth - buttonSize) / 2,
            y: (height - buttonSize) / 2,
            width: buttonSize,
            height: buttonSize
        )
        
        // 4. Configuration for a crisp, properly sized icon
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        toggleButton.setImage(UIImage(systemName: "eye.slash", withConfiguration: config), for: .normal)
        
        toggleButton.tintColor = .systemGray
        toggleButton.addTarget(self, action: #selector(toggleSecureEntry), for: .touchUpInside)
        
        container.addSubview(toggleButton)

        rightView = container
        rightViewMode = .always

        // Ensure left padding exists
        if leftView == nil {
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
            leftViewMode = .always
        }
    }

    @objc private func toggleSecureEntry() {
        let wasFirstResponder = isFirstResponder
        
        // Preserve selection cursor logic
        let previousRange = selectedTextRange

        isSecureTextEntry.toggle()
        
        // Force layout update to prevent font jump
        if let existingText = text {
            text = nil
            text = existingText
        }

        if wasFirstResponder {
            becomeFirstResponder()
            if let r = previousRange {
                selectedTextRange = r
            }
        }

        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let name = isSecureTextEntry ? "eye.slash" : "eye"
        toggleButton.setImage(UIImage(systemName: name, withConfiguration: config), for: .normal)
    }
    // --- FIX END ---
}

// MARK: - GradientButton
public final class GradientButton: UIButton {
    private let gradientLayer = CAGradientLayer()

    public init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        layer.cornerRadius = 14
        clipsToBounds = true
        heightAnchor.constraint(equalToConstant: 52).isActive = true

        gradientLayer.colors = [CloudyyyColors.accentBlue.cgColor, CloudyyyColors.accentBlue2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
    }
}

// MARK: - GlassButton
public final class GlassButton: UIButton {
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    private let overlay = UIView()
    private let iconView = UIImageView()
    private let contentStack = UIStackView()

    public init(title: String, icon: UIImage? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 52).isActive = true
        layer.cornerRadius = 14
        clipsToBounds = true

        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        overlay.backgroundColor = UIColor(white: 1, alpha: 0.90)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.88, alpha: 1).cgColor

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .label
        iconView.setContentHuggingPriority(.required, for: .horizontal)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = 12

        if let img = icon {
            iconView.image = img.withRenderingMode(.alwaysTemplate)
            contentStack.addArrangedSubview(iconView)
            iconView.widthAnchor.constraint(equalToConstant: 22).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        }

        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = title
        lbl.font = .systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = .label
        contentStack.addArrangedSubview(lbl)

        addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        accessibilityLabel = title
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.6
        }
    }
}

// MARK: - Role segmented factory
public func makeRoleSegmentedControl(items: [String] = ["Mom", "Dad"]) -> UISegmentedControl {
    let sc = UISegmentedControl(items: items)
    sc.translatesAutoresizingMaskIntoConstraints = false
    sc.selectedSegmentIndex = 0
    sc.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .normal)
    sc.backgroundColor = UIColor(white: 0.95, alpha: 1)
    if #available(iOS 13.0, *) {
        sc.selectedSegmentTintColor = CloudyyyColors.accentBlue
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.darkGray], for: .normal)
    }
    sc.layer.cornerRadius = 18
    sc.layer.masksToBounds = true
    sc.heightAnchor.constraint(equalToConstant: 36).isActive = true
    return sc
}

// MARK: - Helpers
public extension UIImage {
    func asTemplate() -> UIImage { withRenderingMode(.alwaysTemplate) }
}

public extension DateFormatter {
    static func cloudyyyFormatter() -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f
    }
}
