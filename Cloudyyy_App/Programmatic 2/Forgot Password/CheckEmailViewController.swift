//
//  CheckEmailViewController.swift
//  Cloudyyy_App
//
//  Created by user@5 on 17/11/25.
//

import UIKit

final class CheckEmailViewController: UIViewController {

    // MARK: - UI Components
    private let headerView = GradientHeaderView(dottedImage: UIImage(named: "dots"))

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.keyboardDismissMode = .onDrag
        s.alwaysBounceVertical = true
        return s
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let card = CardView()

    // Back button
    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.backward", withConfiguration: config), for: .normal)
        b.tintColor = .white
        b.accessibilityLabel = "Back"
        return b
    }()

    // MARK: - Fields (Inside Card)
    private let codeField: CustomTextField = {
        let t = CustomTextField(placeholder: "Enter 5-digit code")
        t.keyboardType = .numberPad
        t.textAlignment = .center
        t.font = .systemFont(ofSize: 24, weight: .medium)
        return t
    }()
    
    private let resendLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Haven't got the email yet?"
        l.font = .systemFont(ofSize: 14)
        l.textColor = .gray
        return l
    }()
    
    private let resendButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Resend email", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        b.tintColor = .systemBlue // Or your app's primary color
        return b
    }()
    
    private lazy var resendStackView: UIStackView = {
        let s = UIStackView(arrangedSubviews: [resendLabel, resendButton])
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.spacing = 4
        return s
    }()

    private let verifyButton = GradientButton(title: "Verify Code")

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupHeader()
        setupHierarchy()
        setupConstraints()
        setupActions()
        
        // Keyboard handling
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup Header
    private func setupHeader() {
        headerView.screenTitleLabel.text = "Check Your E-Mail"
        headerView.smallInfoLabel.text = "We sent a reset link to example@gmail 5 digit code that mentioned in the email"
        
        // This is CRITICAL for letting the text wrap
        headerView.smallInfoLabel.numberOfLines = 0
        
        headerView.actionButton.setTitle(nil, for: .normal) // No action button
    }

    // MARK: - Hierarchy
    private func setupHierarchy() {
        view.addSubview(headerView)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(card)
        
        // Add items to card
        card.addSubview(codeField)
        card.addSubview(resendStackView)
        card.addSubview(verifyButton)
            
        view.addSubview(closeButton)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Back button constraints
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
        
            // Header constraints
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // This is the correct constraint:
            // The header's height is determined by the content inside it.
            // We assume the GradientHeaderView has its own internal constraints
            // pinning its bottom to the smallInfoLabel's bottom.
            // (This was the logic from the "good" layout).
            headerView.bottomAnchor.constraint(equalTo: headerView.smallInfoLabel.bottomAnchor, constant: 20),


            // ScrollView constraints
            // This pins the scrollview to the *title* to create the overlap.
            scrollView.topAnchor.constraint(equalTo: headerView.screenTitleLabel.bottomAnchor, constant: 30),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Card constraints (landscape-safe)
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            card.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            card.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 500),
        ])

        // --- Constraints inside the card ---
        let padding: CGFloat = 20
        NSLayoutConstraint.activate([
            codeField.topAnchor.constraint(equalTo: card.topAnchor, constant: padding + 10), // A bit more top padding
            codeField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: padding),
            codeField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -padding),
            
            resendStackView.topAnchor.constraint(equalTo: codeField.bottomAnchor, constant: 16),
            resendStackView.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            verifyButton.topAnchor.constraint(equalTo: resendStackView.bottomAnchor, constant: 24),
            verifyButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: padding),
            verifyButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -padding),
            verifyButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -padding)
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        verifyButton.addTarget(self, action: #selector(didTapVerify), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(didTapResend), for: .touchUpInside)
    }
    
    @objc private func didTapClose() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc private func didTapVerify() {
        view.endEditing(true)
        guard let code = codeField.text, !code.isEmpty else {
            showAlert("Missing Code", "Please enter the 5-digit code.")
            return
        }
        
        // --- TODO: Add your code verification logic here ---
        
        // On success:
        showAlert("Success", "Your password has been reset.")
    }
    
    @objc private func didTapResend() {
        view.endEditing(true)
        // --- TODO: Add your logic to resend the code ---
        
        showAlert("Code Sent", "A new code has been sent to your email.")
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

    // MARK: - Helper
    private func showAlert(_ title: String, _ msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
