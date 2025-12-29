//
//  PendingApprovalViewController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 23/12/25.
//

import Foundation
import UIKit

final class PendingApprovalViewController: UIViewController {

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
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        return v
    }()

    // MARK: - Content
    private let mascotImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(named: "cloudyy_glasses") // 👈 friendly waiting mascot
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Waiting for Approval ⏳"
        lb.font = .systemFont(ofSize: 22, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()

    private let messageLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = """
We’ve sent this reward to your parent!
You’ll get it once they say yes 😊
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
        b.setTitle("Okay 👍", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = .white
        b.setTitleColor(.black, for: .normal)
        b.layer.cornerRadius = 16
        return b
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        addFloatAnimation()
    }

    // MARK: - UI
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
            blurView.widthAnchor.constraint(equalToConstant: 300)
        ])

        let stack = UIStackView(arrangedSubviews: [
            mascotImageView,
            titleLabel,
            messageLabel,
            okButton
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        blurView.contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -20),

            mascotImageView.heightAnchor.constraint(equalToConstant: 100),
            mascotImageView.widthAnchor.constraint(equalToConstant: 140),

            okButton.widthAnchor.constraint(equalToConstant: 150),
            okButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        okButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        dimView.addGestureRecognizer(tap)
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }

    // MARK: - Animation
    private func addFloatAnimation() {
        let float = CABasicAnimation(keyPath: "transform.translation.y")
        float.fromValue = 0
        float.toValue = -6
        float.duration = 1.8
        float.autoreverses = true
        float.repeatCount = .infinity
        mascotImageView.layer.add(float, forKey: "float")
    }
}

