//
//  VerifyOTPViewControlle.swift
//  Cloudyyy_App
//
//  Created by user@5 on 03/12/25.
//

//
// VerifyOTPViewController.swift
//

import UIKit
import Supabase

final class VerifyOTPViewController: UIViewController {

    private let email: String

    // MARK: - UI Components
    // Reusing your GradientHeaderView
    private let headerView = GradientHeaderView(dottedImage: UIImage(named: "dots"))
    
    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.alwaysBounceVertical = true
        s.keyboardDismissMode = .interactive
        return s
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let card = CardView()

    // Instruction Label inside the card
    private let instructionLabel: UILabel = {
        let l = UILabel()
        l.text = "We've sent a 6-digit verification code to your email. Please enter it below."
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Code Input Field
    private let codeField: UITextField = {
        let f = UITextField()
        f.placeholder = "123456"
        f.backgroundColor = .secondarySystemBackground
        f.layer.cornerRadius = 12
        f.font = .systemFont(ofSize: 28, weight: .bold) // Big font for code
        f.textAlignment = .center
        f.keyboardType = .numberPad
        f.translatesAutoresizingMaskIntoConstraints = false
        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        f.leftView = paddingView
        f.leftViewMode = .always
        f.rightView = paddingView
        f.rightViewMode = .always
        return f
    }()

    private let verifyButton = GradientButton(title: "Verify")

    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.backward", withConfiguration: config), for: .normal)
        b.tintColor = .white
        return b
    }()

    private let activity = UIActivityIndicatorView(style: .large)

    // MARK: - Init
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupHeader()
        setupHierarchy()
        setupConstraints()
        configureBehaviors()
    }

    // MARK: - Setup Header
    private func setupHeader() {
        headerView.screenTitleLabel.text = "Verify Email"
        headerView.smallInfoLabel.text = "Almost there!"
        // Hide the top-right action button since we are already in the flow
        headerView.actionButton.isHidden = true
    }

    // MARK: - Hierarchy
    private func setupHierarchy() {
        view.addSubview(headerView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(card)

        card.addSubview(instructionLabel)
        card.addSubview(codeField)
        card.addSubview(verifyButton)
        
        view.addSubview(backButton)
        view.addSubview(activity)
    }

    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Header
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.bottomAnchor.constraint(equalTo: scrollView.topAnchor, constant: 28),

            // ScrollView
            scrollView.topAnchor.constraint(equalTo: headerView.screenTitleLabel.bottomAnchor, constant: 30),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Card
            card.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            card.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 500),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            // Activity
            activity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Card Content Constraints
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            instructionLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            codeField.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 24),
            codeField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            codeField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            codeField.heightAnchor.constraint(equalToConstant: 56), // Taller field
            
            verifyButton.topAnchor.constraint(equalTo: codeField.bottomAnchor, constant: 24),
            verifyButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            verifyButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            verifyButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24)
        ])
    }

    // MARK: - Behaviors
    private func configureBehaviors() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        verifyButton.addTarget(self, action: #selector(didTapVerify), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    // MARK: - Actions
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func didTapVerify() {
            guard let code = codeField.text, code.count >= 6 else {
                showAlert(title: "Invalid Code", message: "Please enter the 6-digit code.")
                return
            }

            setLoading(true)
            
            // FIX 1: Use _Concurrency.Task to avoid conflict with your 'Task' model
            _Concurrency.Task {
                do {
                    // FIX 2: Put 'email' first, as requested by the compiler error
                    let _ = try await SupabaseManager.shared.client.auth.verifyOTP(
                        email: email,
                        token: code,
                        type: .signup
                    )
                    
                    await MainActor.run {
                        self.setLoading(false)
                        let vc = FamilyName()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } catch {
                    await MainActor.run {
                        self.setLoading(false)
                        self.showAlert(title: "Verification Failed", message: "Invalid code. Please try again.")
                    }
                }
            }
        }

    // MARK: - Helpers
    private func setLoading(_ loading: Bool) {
        if loading {
            activity.startAnimating()
            verifyButton.isEnabled = false
            verifyButton.alpha = 0.6
        } else {
            activity.stopAnimating()
            verifyButton.isEnabled = true
            verifyButton.alpha = 1.0
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
