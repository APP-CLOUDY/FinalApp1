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
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 18
        layer.masksToBounds = false
        updateShadowColor()
        layer.shadowOpacity = 0.08
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 12
    }

    private func updateShadowColor() {
        layer.shadowColor = UIColor.label.withAlphaComponent(0.2).cgColor
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateShadowColor()
        }
    }
}

// MARK: - CustomTextField
public class CustomTextField: UITextField {
    public init(placeholder: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemGray6
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.separator.cgColor
        font = .systemFont(ofSize: 15)
        textColor = .label
        
        // Default placeholder color fix
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderText]
        )
        
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        leftViewMode = .always
        autocorrectionType = .no
        spellCheckingType = .no
        autocapitalizationType = .none
        keyboardType = .default
        heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            layer.borderColor = UIColor.separator.cgColor
        }
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

// MARK: - Legal Documents
public enum LegalDocument: Int, CaseIterable {
    case privacyPolicy
    case termsOfService

    public var title: String {
        switch self {
        case .privacyPolicy:
            return "Privacy Policy"
        case .termsOfService:
            return "Terms of Service"
        }
    }

    fileprivate var segmentedTitle: String {
        switch self {
        case .privacyPolicy:
            return "Privacy"
        case .termsOfService:
            return "Terms"
        }
    }
}

private enum LegalContentProvider {
    static let lastUpdated = "April 4, 2026"

    static func text(for document: LegalDocument) -> String {
        switch document {
        case .privacyPolicy:
            return """
            Cloudyyy Privacy Policy
            Last updated: \(lastUpdated)

            Cloudyyy helps families manage tasks, rewards, approvals, and progress for parents and children. This Privacy Policy explains what information we collect, how we use it, and the choices families have when using the app.

            1. Information We Collect
            We may collect account details such as a parent name, email address, role, family name, child nicknames, child profile details, avatars, assigned tasks, reward data, approval submissions, uploaded proof photos, and activity history inside the app.

            2. How We Use Information
            We use information to create and manage family accounts, let parents assign tasks and rewards, let children complete missions, process approvals and redos, track points and redemption history, personalize profile screens, and improve reliability and safety across the app.

            3. Child Information
            Cloudyyy is designed for family use under parent or guardian supervision. Child profiles are created and managed within a family account. Parents or guardians control assigned tasks, rewards, submitted proof, and profile information associated with their family group.

            4. Photos and Submitted Proof
            If a task requires photo proof, the image submitted by the child is stored so the parent can review, approve, or request a redo. These uploads are only used for the family workflow inside the app unless disclosure is required by law.

            5. Sharing of Information
            We do not use family data for public display. Information is shared only within the relevant family experience, with service providers that help operate the app, or when required for security, fraud prevention, or legal compliance.

            6. Data Storage and Security
            We use reasonable administrative, technical, and organizational safeguards to protect stored data. No system can guarantee absolute security, but we work to reduce unauthorized access, loss, or misuse.

            7. Retention
            We keep information for as long as it is needed to operate the family account, maintain records such as task and reward history, comply with legal obligations, resolve disputes, and enforce our agreements.

            8. Your Choices
            Parents may review and update profile details, family information, and account content available through the app. You may also stop using the service and request account-related support through the contact channel provided with the app distribution.

            9. Children's Privacy
            Parents or guardians are responsible for the information they create or submit for child profiles. If you believe child data has been added in error or without proper authorization, please contact us through the support channel listed for the app.

            10. Changes to This Policy
            We may update this Privacy Policy from time to time. When we do, the updated version will be reflected in the app with a new last-updated date.

            11. Contact
            For privacy questions or account requests, please use the support contact provided in the app or in the app listing.
            """
        case .termsOfService:
            return """
            Cloudyyy Terms of Service
            Last updated: \(lastUpdated)

            These Terms of Service govern access to and use of Cloudyyy. By creating an account or using the app, you agree to these terms on behalf of yourself and, if applicable, your family group.

            1. Use of the Service
            Cloudyyy is intended for personal family organization, including tasks, approvals, rewards, schedules, and progress tracking. You agree to use the app only for lawful purposes and in a way that does not harm the service or other users.

            2. Accounts and Family Access
            Parents or guardians are responsible for account creation, family setup, and the management of child profiles. You are responsible for keeping login credentials secure and for activity that occurs under your account.

            3. Child Participation
            Child use of the app must be supervised by a parent or guardian. Parents control family content, including assigned tasks, rewards, approvals, redos, and profile details.

            4. Tasks, Rewards, and Points
            Task completion, approvals, redos, points, and rewards are part of the in-app family workflow. Cloudyyy provides tools to support that workflow, but parents remain responsible for how they configure and use chores, approvals, and rewards inside their family account.

            5. User Content
            You retain responsibility for the information, text, photos, and other content submitted through the app. You agree not to upload unlawful, abusive, infringing, or harmful material.

            6. Acceptable Use
            You may not misuse the service, attempt unauthorized access, interfere with normal operation, reverse engineer protected parts of the app where prohibited, or use the app to violate any law or third-party rights.

            7. Availability and Changes
            We may update, improve, suspend, or discontinue features at any time. We do not guarantee that every feature will always be available or error free.

            8. Termination
            We may limit or terminate access if these terms are violated or if use of the service creates risk for the app, our systems, or other users.

            9. Disclaimers
            The service is provided on an as-is and as-available basis to the extent permitted by law. We do not guarantee uninterrupted service, perfect accuracy, or that the app will meet every family’s needs.

            10. Limitation of Liability
            To the extent permitted by law, Cloudyyy and its operators will not be liable for indirect, incidental, special, consequential, or punitive damages arising from use of the service.

            11. Changes to These Terms
            We may revise these Terms of Service from time to time. Continued use of the app after updates means you accept the revised terms.

            12. Contact
            For questions about these terms, please use the support contact provided in the app or in the app listing.
            """
        }
    }
}

public final class LegalDocumentsViewController: UIViewController {
    private let initialDocument: LegalDocument

    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            CloudyyyColors.deepBlack.cgColor,
            CloudyyyColors.deepBlue.cgColor
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return layer
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Legal"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Review how Cloudyyy handles privacy and service use."
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor(white: 1, alpha: 0.78)
        label.numberOfLines = 0
        return label
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white: 1, alpha: 0.08)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(white: 1, alpha: 0.14).cgColor
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .white
        return button
    }()

    private let cardView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 26
        view.clipsToBounds = true
        view.contentView.backgroundColor = UIColor(white: 1, alpha: 0.06)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 1, alpha: 0.08).cgColor
        return view
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: LegalDocument.allCases.map(\.segmentedTitle))
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = initialDocument.rawValue
        return control
    }()

    private let textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.textColor = .white
        view.font = .systemFont(ofSize: 15)
        view.isEditable = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        view.textContainer.lineFragmentPadding = 0
        return view
    }()

    public init(initialDocument: LegalDocument = .privacyPolicy) {
        self.initialDocument = initialDocument
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLayout()
        setupActions()
        updateDocument()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = backgroundView.bounds
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupLayout() {
        view.addSubview(backgroundView)
        backgroundView.layer.addSublayer(gradientLayer)

        view.addSubview(backButton)
        view.addSubview(headerLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(cardView)
        cardView.contentView.addSubview(segmentedControl)
        cardView.contentView.addSubview(textView)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            headerLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 18),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),

            cardView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            segmentedControl.topAnchor.constraint(equalTo: cardView.contentView.topAnchor, constant: 18),
            segmentedControl.leadingAnchor.constraint(equalTo: cardView.contentView.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: cardView.contentView.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 34),

            textView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 18),
            textView.leadingAnchor.constraint(equalTo: cardView.contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: cardView.contentView.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: cardView.contentView.bottomAnchor, constant: -16)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
    }

    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func handleSegmentChange() {
        updateDocument()
    }

    private func updateDocument() {
        let document = LegalDocument(rawValue: segmentedControl.selectedSegmentIndex) ?? initialDocument
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4

        textView.attributedText = NSAttributedString(
            string: LegalContentProvider.text(for: document),
            attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraph
            ]
        )
        textView.setContentOffset(.zero, animated: false)
        title = document.title
    }
}

public extension UIViewController {
    func showLegalDocuments(initialDocument: LegalDocument) {
        let controller = LegalDocumentsViewController(initialDocument: initialDocument)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
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

        overlay.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.4)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        layer.borderWidth = 1
        updateBorderColor()

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

    private func updateBorderColor() {
        if #available(iOS 13.0, *) {
            layer.borderColor = UIColor.separator.cgColor
        } else {
            layer.borderColor = UIColor(white: 0.88, alpha: 1).cgColor
        }
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateBorderColor()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.6
        }
    }
}

// MARK: - Role segmented factory
public func makeRoleSegmentedControl(items: [String] = ["Mom", "Dad" , "Guardian"]) -> UISegmentedControl {
    let sc = UISegmentedControl(items: items)
    sc.translatesAutoresizingMaskIntoConstraints = false
    sc.selectedSegmentIndex = 0
    sc.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .normal)
    sc.backgroundColor = .systemGray6
    if #available(iOS 13.0, *) {
        sc.selectedSegmentTintColor = CloudyyyColors.accentBlue
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel], for: .normal)
    }
    sc.layer.cornerRadius = 14
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
