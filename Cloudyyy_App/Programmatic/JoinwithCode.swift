//
//  JoinWithCode.swift
//  Cloudyyy_App
//
//  Single visible text field version (5-digit numeric code)
//

import UIKit

final class JoinWithCode: UIViewController {

    // MARK: - UI
    private let headerView = GradientHeaderView(dottedImage: UIImage(named: "dots"))

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.keyboardDismissMode = .interactive
        s.alwaysBounceVertical = true // <<< ADDED
        return s
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let card = CardView()

    // <<< ADDED: Back button for UI consistency >>>
    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.backward", withConfiguration: config), for: .normal)
        b.tintColor = .white
        b.accessibilityLabel = "Back"
        return b
    }()

    // Single visible text field
    private let codeField: UITextField = {
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.keyboardType = .numberPad
        if #available(iOS 12.0, *) { t.textContentType = .oneTimeCode }
        t.textAlignment = .center
        t.font = .systemFont(ofSize: 28, weight: .semibold)
        t.backgroundColor = UIColor(white: 0.98, alpha: 1)
        t.layer.cornerRadius = 12
        t.layer.borderWidth = 1
        t.layer.borderColor = UIColor(white: 0.88, alpha: 1).cgColor
        t.tintColor = CloudyyyColors.accentBlue
        t.textColor = .label
        t.autocorrectionType = .no
        t.spellCheckingType = .no
        t.autocapitalizationType = .none
        // some left/right padding
        let pad = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 10))
        t.leftView = pad
        t.leftViewMode = .always
        t.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 10))
        t.rightViewMode = .always
        t.placeholder = ""
        return t
    }()

    private let hintLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Enter the 5 digit Code"
        l.font = .systemFont(ofSize: 14)
        l.textColor = UIColor(white: 0.28, alpha: 1)
        return l
    }()

    private let joinButton = GradientButton(title: "Join Family")

    // MARK: - Config
    private let codeLength = 5

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupHeader()
        setupHierarchy()
        setupConstraints()
        setupActions()

        codeField.delegate = self
        codeField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ensure keyboard appears after view appears
        DispatchQueue.main.async { [weak self] in
            self?.codeField.becomeFirstResponder()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func setupHeader() {
        headerView.screenTitleLabel.text = "Join with Code"
        headerView.smallInfoLabel.text = nil
    }

    private func setupHierarchy() {
        view.addSubview(headerView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(card)
        contentView.addSubview(joinButton)

        card.addSubview(codeField)
        card.addSubview(hintLabel)
        
        // <<< ADDED: Add close button to main view >>>
        view.addSubview(closeButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // <<< ADDED: Back button constraints >>>
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
        
            // <<< MODIFIED: Header constraints (dynamic height) >>>
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // headerView.heightAnchor.constraint(equalToConstant: 360), // <<< REMOVED
            headerView.bottomAnchor.constraint(equalTo: scrollView.topAnchor, constant: 28), // <<< ADDED

            // <<< MODIFIED: ScrollView constraints (pinned to label) >>>
            // scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20), // <<< REMOVED
            scrollView.topAnchor.constraint(equalTo: headerView.screenTitleLabel.bottomAnchor, constant: 30), // <<< ADDED
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // content sizing
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // <<< MODIFIED: Card constraints (landscape-safe) >>>
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40), // <<< MODIFIED: Was 20
            // card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16), // <<< REMOVED
            // card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16), // <<< REMOVED
            card.centerXAnchor.constraint(equalTo: contentView.centerXAnchor), // <<< ADDED
            card.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32), // <<< ADDED
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 500), // <<< ADDED

            // codeField centered in card
            codeField.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            codeField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            codeField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            codeField.heightAnchor.constraint(equalToConstant: 56),

            // hint
            hintLabel.topAnchor.constraint(equalTo: codeField.bottomAnchor, constant: 14),
            hintLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            hintLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),

            // card bottom (ensure card expands)
            card.bottomAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 18), // <<< MODIFIED: Was greaterThanOrEqualTo

            // join button below
            joinButton.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 28),
            joinButton.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            joinButton.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            joinButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    private func setupActions() {
        joinButton.addTarget(self, action: #selector(didTapJoin), for: .touchUpInside)

        // <<< ADDED: Back button action >>>
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)

        // keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // <<< ADDED: Action to go back >>>
    @objc private func didTapClose() {
        // Check if we were pushed onto a navigation controller
        if let nav = self.navigationController {
            // If yes, pop this view controller
            nav.popViewController(animated: true)
        } else {
            // Otherwise, we were presented modally. Dismiss ourselves.
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Input handling
    @objc private func textChanged(_ tf: UITextField) {
        // keep only digits and enforce length
        let digits = (tf.text ?? "").filter { $0.isWholeNumber }
        if digits != tf.text {
            tf.text = digits
        }
        if digits.count >= codeLength {
            tf.text = String(digits.prefix(codeLength))
            // auto submit a tiny moment later so UI updates
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
                self?.trySubmitCode()
            }
        }
    }

    private func trySubmitCode() {
        guard let code = codeField.text?.filter({ $0.isWholeNumber }), code.count == codeLength else {
            // if not complete, do nothing or show hint
            return
        }
        view.endEditing(true)
        
        // <<< MODIFIED: Navigate to child home >>>
        navigateToChildHome()
        // showAlert(title: "Joining", message: "Joining with code: \(code)") // <<< REMOVED
        
        // optionally clear:
        // codeField.text = ""
    }

    @objc private func didTapJoin() {
        view.endEditing(true)
        guard let code = codeField.text?.filter({ $0.isWholeNumber }), code.count == codeLength else {
            showAlert(title: "Invalid Code", message: "Please enter the full 5 digit code.")
            return
        }
        trySubmitCode()
    }
    
    // <<< ADDED: Navigation action >>>
    private func navigateToChildHome() {
        // This assumes ChildHomeViewController() exists in your project
        let vc = ChildHomeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Keyboard handling
    @objc private func kbWillShow(_ n: Notification) {
        guard let info = n.userInfo,
              let kbFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let bottomInset = kbFrame.height - view.safeAreaInsets.bottom
        scrollView.contentInset.bottom = bottomInset + 12
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset + 12
    }

    @objc private func kbWillHide(_ n: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    // MARK: - Helpers
    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension JoinWithCode: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow deletion/backspace
        if string.isEmpty { return true }

        // Only allow digits
        if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            return false
        }

        // If paste multiple digits, insert them but cap to codeLength
        if string.count > 1 {
            let current = (textField.text ?? "")
            let combined = (current + string).filter { $0.isWholeNumber }
            textField.text = String(combined.prefix(codeLength))
            // call editing changed manually
            textChanged(textField)
            return false
        }

        // Prevent more than codeLength characters
        let currentCount = (textField.text ?? "").count
        return currentCount < codeLength
    }
}


// <<< ADDED: Placeholder for navigation target >>>
// (You can replace this with your actual view controller)


