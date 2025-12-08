import UIKit

final class JoinWithCode: UIViewController {

    // MARK: - Properties
    // ✅ Enforce 6 digits (Matches Database Schema)
    private let codeLength = 6

    // MARK: - UI Components
    private let headerView = GradientHeaderView(dottedImage: UIImage(named: "dots"))

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.keyboardDismissMode = .interactive
        s.alwaysBounceVertical = true
        return s
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let card = CardView()

    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.backward", withConfiguration: config), for: .normal)
        b.tintColor = .white
        b.accessibilityLabel = "Back"
        return b
    }()

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
        t.tintColor = UIColor.systemBlue
        t.textColor = .label
        t.autocorrectionType = .no
        t.spellCheckingType = .no
        t.autocapitalizationType = .none
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
        l.text = "Enter the 6 digit Code"
        l.font = .systemFont(ofSize: 14)
        l.textColor = UIColor(white: 0.28, alpha: 1)
        return l
    }()

    private let joinButton = GradientButton(title: "Join Family")

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
        DispatchQueue.main.async { [weak self] in
            self?.codeField.becomeFirstResponder()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup UI
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
        view.addSubview(closeButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
        
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: scrollView.topAnchor, constant: 28),

            scrollView.topAnchor.constraint(equalTo: headerView.screenTitleLabel.bottomAnchor, constant: 30),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            card.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            card.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 500),

            codeField.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            codeField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            codeField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            codeField.heightAnchor.constraint(equalToConstant: 56),

            hintLabel.topAnchor.constraint(equalTo: codeField.bottomAnchor, constant: 14),
            hintLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            hintLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),

            card.bottomAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 18),

            joinButton.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 28),
            joinButton.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            joinButton.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            joinButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    private func setupActions() {
        joinButton.addTarget(self, action: #selector(didTapJoin), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func didTapClose() {
        if let nav = self.navigationController { nav.popViewController(animated: true) }
        else { self.dismiss(animated: true, completion: nil) }
    }

    // MARK: - Logic
    private func trySubmitCode() {
        guard let code = codeField.text?.filter({ $0.isWholeNumber }), code.count == codeLength else { return }
        view.endEditing(true)
        
        // Disable UI while checking
        codeField.isEnabled = false
        joinButton.isEnabled = false
        
        _Concurrency.Task {
            do {
                // ✅ Use the separate AuthService
                let success = try await AuthService.shared.loginChild(code: code)
                
                await MainActor.run {
                    self.codeField.isEnabled = true
                    self.joinButton.isEnabled = true
                    
                    if success {
                        self.navigateToChildHome()
                    } else {
                        self.showAlert(title: "Invalid Code", message: "That code didn't work. Please try again.")
                        self.codeField.text = ""
                    }
                }
            } catch {
                await MainActor.run {
                    self.codeField.isEnabled = true
                    self.joinButton.isEnabled = true
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Input handling
    @objc private func textChanged(_ tf: UITextField) {
        let digits = (tf.text ?? "").filter { $0.isWholeNumber }
        if digits != tf.text { tf.text = digits }
        
        if digits.count >= codeLength {
            tf.text = String(digits.prefix(codeLength))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
                self?.trySubmitCode()
            }
        }
    }

    @objc private func didTapJoin() {
        view.endEditing(true)
        guard let code = codeField.text?.filter({ $0.isWholeNumber }), code.count == codeLength else {
            showAlert(title: "Invalid Code", message: "Please enter the full \(codeLength) digit code.")
            return
        }
        trySubmitCode()
    }
    
    private func navigateToChildHome() {
        // Change this to your actual Child Tab Bar Controller class
        let vc = ChildTabBarController()
        
        if let window = view.window {
            window.rootViewController = vc
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        } else {
            navigationController?.setViewControllers([vc], animated: true)
        }
    }
    
    // MARK: - Keyboard & Helpers
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

    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension JoinWithCode: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        if string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil { return false }
        if string.count > 1 {
            let current = (textField.text ?? "")
            let combined = (current + string).filter { $0.isWholeNumber }
            textField.text = String(combined.prefix(codeLength))
            textChanged(textField)
            return false
        }
        return (textField.text ?? "").count < codeLength
    }
}
