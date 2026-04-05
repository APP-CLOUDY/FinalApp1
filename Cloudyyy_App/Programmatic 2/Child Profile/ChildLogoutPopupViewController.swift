//
//  ChildLogoutPopupViewController.swift
//  Cloudyyy_App
//

import UIKit

final class ChildLogoutPopupViewController: UIViewController {

    var onLogoutConfirmed: (() -> Void)?

    // MARK: - Background
    private let dimView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v
    }()

    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemChromeMaterialDark)
        let v = UIVisualEffectView(effect: blur)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    // MARK: - Content
    private let mascotImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "cloudyy_please")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Log out"
        lb.font = .systemFont(ofSize: 22, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()

    private let messageLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Are you sure you want to log out?"
        lb.font = .systemFont(ofSize: 15, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.85)
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()

    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 15
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let noButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("No", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = .lightGray.withAlphaComponent(0.3)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 16
        return b
    }()

    private let yesButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Yes", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = .white
        b.setTitleColor(.systemRed, for: .normal)
        b.layer.cornerRadius = 16
        return b
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        setupUI()
        setupActions()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .clear

        view.addSubview(dimView)
        view.addSubview(blurView)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            blurView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blurView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            blurView.widthAnchor.constraint(equalToConstant: 280)
        ])

        buttonStackView.addArrangedSubview(noButton)
        buttonStackView.addArrangedSubview(yesButton)

        let mainStack = UIStackView(arrangedSubviews: [
            mascotImageView,
            titleLabel,
            messageLabel,
            buttonStackView
        ])
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.spacing = 15
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        mainStack.setCustomSpacing(8, after: titleLabel)
        mainStack.setCustomSpacing(20, after: messageLabel)

        blurView.contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 24),
            mainStack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -24),
            mainStack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -20),

            mascotImageView.heightAnchor.constraint(equalToConstant: 90),
            
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        mascotImageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        titleLabel.textAlignment = .center
        messageLabel.textAlignment = .center
    }

    // MARK: - Actions
    private func setupActions() {
        noButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        yesButton.addTarget(self, action: #selector(yesTapped), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        dimView.addGestureRecognizer(tap)
    }

    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
    
    @objc private func yesTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onLogoutConfirmed?()
        }
    }
}
