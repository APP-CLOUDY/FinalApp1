//
//  SpringOnConfirmPurchasePopupViewController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 02/01/26.
//

import UIKit

final class SpringOnConfirmPurchasePopupViewController: UIViewController {

    // MARK: - Public
    var onConfirm: (() -> Void)?

    // MARK: - Background (DIM ONLY — NO BLUR)
    private let dimView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45) // ✅ SAME AS LEFT POPUP
        return v
    }()

    // MARK: - Popup Blur Card
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemChromeMaterialDark) // ✅ SAME STYLE
        let v = UIVisualEffectView(effect: blur)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        return v
    }()

    // MARK: - Content
    private let mascotImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "cloudyy_glasses")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Confirm Purchase"
        lb.font = .systemFont(ofSize: 22, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()

    private let messageLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = .systemFont(ofSize: 16, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.9)
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()

    private let confirmButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Yes, Unlock 😊", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = .white
        b.setTitleColor(.black, for: .normal)
        b.layer.cornerRadius = 16
        return b
    }()

    private let cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Cancel", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        b.setTitleColor(.white.withAlphaComponent(0.8), for: .normal)
        return b
    }()

    // MARK: - Init
    init(message: String) {
        super.init(nibName: nil, bundle: nil)
        messageLabel.text = message
        modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        animateIn()
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
            blurView.widthAnchor.constraint(equalToConstant: 320) // Slightly bigger
        ])

        let buttonStack = UIStackView(arrangedSubviews: [
            confirmButton,
            cancelButton
        ])
        buttonStack.axis = .vertical
        buttonStack.spacing = 10
        buttonStack.alignment = .center

        let stack = UIStackView(arrangedSubviews: [
            mascotImageView,
            titleLabel,
            messageLabel,
            buttonStack
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        blurView.contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -24),

            mascotImageView.heightAnchor.constraint(equalToConstant: 100),
            mascotImageView.widthAnchor.constraint(equalToConstant: 140),

            confirmButton.widthAnchor.constraint(equalToConstant: 180),
            confirmButton.heightAnchor.constraint(equalToConstant: 46)
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        dimView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        )
    }

    @objc private func confirmTapped() {
        dismiss(animated: true) {
            self.onConfirm?()
        }
    }

    @objc private func dismissPopup() {
        dismiss(animated: true)
    }

    // MARK: - Animation
    private func animateIn() {
        blurView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        blurView.alpha = 0

        UIView.animate(withDuration: 0.22,
                       delay: 0,
                       usingSpringWithDamping: 0.85,
                       initialSpringVelocity: 0.6,
                       options: []) {
            self.blurView.transform = .identity
            self.blurView.alpha = 1
        }
    }
}

