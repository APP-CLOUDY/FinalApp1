//
//  LockedRewardPopupViewController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 20/12/25.
//

import Foundation
import UIKit

final class LockedRewardPopupViewController: UIViewController {

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
        iv.image = UIImage(named: "cloudyy_please") // ✅ YOUR ASSET
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Oops!"
        lb.font = .systemFont(ofSize: 22, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()

    private let messageLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = """
This reward is locked right now.
Your parent can unlock it for you!
"""
        lb.font = .systemFont(ofSize: 15, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.85)
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()

    private let okButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Okay 😊", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = .white
        b.setTitleColor(.black, for: .normal)
        b.layer.cornerRadius = 16
        return b
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen
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

        let stack = UIStackView(arrangedSubviews: [
            mascotImageView,
            titleLabel,
            messageLabel,
            okButton
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        blurView.contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -20),

            mascotImageView.heightAnchor.constraint(equalToConstant: 90),
            mascotImageView.widthAnchor.constraint(equalToConstant: 120),

            okButton.widthAnchor.constraint(equalToConstant: 140),
            okButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        okButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        dimView.addGestureRecognizer(tap)
    }

    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
}
