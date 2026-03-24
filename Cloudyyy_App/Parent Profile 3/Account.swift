//
//  Account.swift
//  Cloudyyy_App
//
//  Created by user@5 on 25/11/25.
//

import UIKit

final class AccountViewController: UIViewController {
    private var backgroundGradientLayer: CAGradientLayer?
    private var isEditingProfile = false

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .interactive
        sv.backgroundColor = .clear
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()

    private let cloudImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "cloudyy_logo")
        return iv
    }()

    private lazy var backButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .white
        b.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return b
    }()

    private lazy var editButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Edit", for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        b.tintColor = .white
        b.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        return b
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.12
        v.layer.shadowRadius = 16
        v.layer.shadowOffset = CGSize(width: 0, height: 10)
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Account"
        l.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        l.textAlignment = .center
        l.textColor = UIColor(red: 12/255, green: 34/255, blue: 76/255, alpha: 1)
        return l
    }()

    private lazy var nameLabel = makeLabel(text: "Name")
    private lazy var roleLabel = makeLabel(text: "Role")

    private lazy var nameField = makeTextField(placeholder: "Enter name")

    private let roleSegmented: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Mom", "Dad", "Guardian"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1)
        sc.backgroundColor = UIColor(white: 0.95, alpha: 1)
        sc.layer.cornerRadius = 18
        return sc
    }()

    private let successBanner: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 34/255, green: 177/255, blue: 76/255, alpha: 1)
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.18
        view.layer.shadowRadius = 16
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.alpha = 0
        return view
    }()

    private let successLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Profile updated successfully"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupHierarchy()
        setupConstraints()
        registerKeyboardNotifications()
        setupSegmentAppearance()
        applyEditingState()
        loadProfile()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        applyFullBackgroundGradient()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer?.frame = view.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cloudImageView)
        contentView.addSubview(cardView)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            nameLabel,
            nameField,
            roleLabel,
            roleSegmented
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.distribution = .fill
        stack.setCustomSpacing(28, after: titleLabel)
        stack.setCustomSpacing(4, after: nameLabel)
        stack.setCustomSpacing(24, after: nameField)
        stack.setCustomSpacing(4, after: roleLabel)

        cardView.addSubview(stack)
        view.addSubview(successBanner)
        successBanner.addSubview(successLabel)

        if let nav = navigationController, !nav.isNavigationBarHidden {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(backTapped)
            )
            navigationItem.leftBarButtonItem?.tintColor = .white

            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit",
                style: .plain,
                target: self,
                action: #selector(editTapped)
            )
            navigationItem.rightBarButtonItem?.tintColor = .white
        } else {
            view.addSubview(backButton)
            view.addSubview(editButton)
        }
    }

    private func setupConstraints() {
        let contentLayoutGuide = scrollView.contentLayoutGuide
        let frameLayoutGuide = scrollView.frameLayoutGuide
        let safe = view.safeAreaLayoutGuide

        var constraints: [NSLayoutConstraint] = [
            scrollView.topAnchor.constraint(equalTo: safe.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safe.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor),

            cloudImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cloudImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            cloudImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 180),
            cloudImageView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.75),

            cardView.topAnchor.constraint(equalTo: cloudImageView.bottomAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),

            successBanner.topAnchor.constraint(equalTo: safe.topAnchor, constant: 12),
            successBanner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successBanner.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.82),

            successLabel.topAnchor.constraint(equalTo: successBanner.topAnchor, constant: 14),
            successLabel.bottomAnchor.constraint(equalTo: successBanner.bottomAnchor, constant: -14),
            successLabel.leadingAnchor.constraint(equalTo: successBanner.leadingAnchor, constant: 18),
            successLabel.trailingAnchor.constraint(equalTo: successBanner.trailingAnchor, constant: -18)
        ]

        if backButton.superview != nil {
            constraints.append(contentsOf: [
                backButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
                backButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 12),
                backButton.widthAnchor.constraint(equalToConstant: 36),
                backButton.heightAnchor.constraint(equalToConstant: 36)
            ])
        }

        if editButton.superview != nil {
            constraints.append(contentsOf: [
                editButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
                editButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
                editButton.heightAnchor.constraint(equalToConstant: 36)
            ])
        }

        NSLayoutConstraint.activate(constraints)

        NSLayoutConstraint.activate([
            cloudImageView.heightAnchor.constraint(lessThanOrEqualTo: frameLayoutGuide.heightAnchor, multiplier: 0.30).withPriority(.defaultHigh),
            cloudImageView.widthAnchor.constraint(equalToConstant: 280).withPriority(.defaultHigh)
        ])

        if let stack = cardView.subviews.compactMap({ $0 as? UIStackView }).first {
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
                stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
                stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
                stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24)
            ])
        }

        let contentMinHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: frameLayoutGuide.heightAnchor)
        contentMinHeight.priority = .defaultLow
        contentMinHeight.isActive = true
        contentView.bottomAnchor.constraint(greaterThanOrEqualTo: cardView.bottomAnchor, constant: 40).isActive = true

        roleSegmented.heightAnchor.constraint(equalToConstant: 38).isActive = true
    }

    private func setupSegmentAppearance() {
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.darkGray,
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ]
        roleSegmented.setTitleTextAttributes(normalAttributes, for: .normal)
        roleSegmented.setTitleTextAttributes(selectedAttributes, for: .selected)
    }

    private func loadProfile() {
        Task {
            do {
                let profile = try await ProfileService.shared.fetchUserProfile()
                await MainActor.run {
                    self.nameField.text = profile.first_name
                    self.applyRole(profile.role)
                }
            } catch {
                print("❌ Failed to load parent account: \(error)")
            }
        }
    }

    private func applyRole(_ role: String) {
        switch role.lowercased() {
        case "dad":
            roleSegmented.selectedSegmentIndex = 1
        case "guardian":
            roleSegmented.selectedSegmentIndex = 2
        default:
            roleSegmented.selectedSegmentIndex = 0
        }
    }

    private func currentRoleValue() -> String {
        switch roleSegmented.selectedSegmentIndex {
        case 1:
            return "dad"
        case 2:
            return "guardian"
        default:
            return "mom"
        }
    }

    private func applyEditingState() {
        nameField.isEnabled = isEditingProfile
        roleSegmented.isEnabled = isEditingProfile
        roleSegmented.alpha = isEditingProfile ? 1.0 : 0.92

        let title = isEditingProfile ? "Save" : "Edit"
        if let nav = navigationController, !nav.isNavigationBarHidden {
            navigationItem.rightBarButtonItem?.title = title
        } else {
            editButton.setTitle(title, for: .normal)
        }
    }

    private func saveProfile() {
        view.endEditing(true)

        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            shakeCard()
            return
        }

        let role = currentRoleValue()

        Task {
            do {
                try await ProfileService.shared.updateUserProfile(name: name, role: role)
                await MainActor.run {
                    self.isEditingProfile = false
                    self.applyEditingState()
                    self.showSuccessBanner()
                }
            } catch {
                print("❌ Failed to update parent account: \(error)")
                await MainActor.run {
                    self.shakeCard()
                }
            }
        }
    }

    private func showSuccessBanner() {
        successBanner.transform = CGAffineTransform(translationX: 0, y: -18)
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
            self.successBanner.alpha = 1
            self.successBanner.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 1.3, options: [.curveEaseIn]) {
                self.successBanner.alpha = 0
                self.successBanner.transform = CGAffineTransform(translationX: 0, y: -12)
            }
        }
    }

    private func shakeCard() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.45
        animation.values = [-10.0, 10.0, -8.0, 8.0, -4.0, 4.0, 0.0]
        cardView.layer.add(animation, forKey: "shake")
    }

    private func applyFullBackgroundGradient() {
        if backgroundGradientLayer == nil {
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1).cgColor,
                UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1).cgColor
            ]
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
            view.layer.insertSublayer(gradient, at: 0)
            backgroundGradientLayer = gradient
        }
        backgroundGradientLayer?.frame = view.bounds
    }

    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func kbWillShow(_ n: Notification) {
        guard let info = n.userInfo,
              let kbFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let converted = view.convert(kbFrame, from: nil)
        let inset = converted.height - view.safeAreaInsets.bottom + 20
        scrollView.contentInset.bottom = inset
        scrollView.verticalScrollIndicatorInsets.bottom = inset
    }

    @objc private func kbWillHide(_ n: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = .zero
    }

    @objc private func backTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func editTapped() {
        if isEditingProfile {
            saveProfile()
            return
        }

        isEditingProfile = true
        applyEditingState()
    }

    private func makeLabel(text: String) -> UILabel {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = text
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(white: 0.35, alpha: 1)
        return l
    }

    private func makeTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = placeholder
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.backgroundColor = UIColor(white: 0.96, alpha: 1)
        tf.layer.cornerRadius = 10
        tf.setAccountLeftPadding(12)
        tf.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return tf
    }
}

private extension UITextField {
    func setAccountLeftPadding(_ amount: CGFloat) {
        let pad = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 48))
        leftView = pad
        leftViewMode = .always
    }
}

private extension NSLayoutConstraint {
    func withPriority(_ p: UILayoutPriority) -> NSLayoutConstraint {
        priority = p
        return self
    }
}
