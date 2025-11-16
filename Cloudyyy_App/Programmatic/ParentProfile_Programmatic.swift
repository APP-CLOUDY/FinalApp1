//
//  ParentProfile_Programmatic.swift
//  Cloudyyy_App
//
//  Created by user@5 on 13/11/25.
//


//
// ParentProfile_Programmatic.swift
// Copy this into your project (or split into multiple files)
//

import UIKit

// --------------------------
// AppDelegate
// --------------------------

    // SceneDelegate will create the window for iOS 13+


// --------------------------
// SceneDelegate
// --------------------------


// --------------------------
// ParentProfileViewController
// --------------------------
final class ParentProfileViewController: UIViewController {

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let topContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .white
        return b
    }()

    private let headerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Happy Home"
        l.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let profileAvatarButton: UIButton = {
        let b = UIButton(type: .custom)
        b.translatesAutoresizingMaskIntoConstraints = false
        // Placeholder system image
        let img = UIImage(systemName: "person.crop.circle.fill")?.withRenderingMode(.alwaysOriginal)
        b.setImage(img, for: .normal)
        b.imageView?.contentMode = .scaleAspectFill
        b.clipsToBounds = true
        b.layer.borderColor = UIColor.white.cgColor
        b.layer.borderWidth = 4
        b.backgroundColor = .clear
        return b
    }()

    private let editPencilButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "pencil"), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(white: 0.15, alpha: 0.95)
        b.layer.cornerRadius = 20
        b.clipsToBounds = true
        return b
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Ridu Mom"
        l.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        l.textAlignment = .center
        return l
    }()

    private let roleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Mom"
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = .darkGray
        l.textAlignment = .center
        return l
    }()

    private let whiteCardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 20
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        return v
    }()

    private let optionsContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // Menu rows
    private lazy var familyRow = makeRow(title: "Family", tag: 0)
    private lazy var accountRow = makeRow(title: "Account", tag: 1)
    private lazy var privacyRow = makeRow(title: "Privacy and Policy", tag: 2)
    private lazy var logoutRow = makeRow(title: "Logout", tag: 3, titleColor: .systemRed)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.98, alpha: 1)
        setupHierarchy()
        setupConstraints()
        setupActions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradientToTop()
        profileAvatarButton.layer.cornerRadius = profileAvatarButton.bounds.width / 2
    }

    // MARK: - Setup
    private func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(topContainer)
        topContainer.addSubview(backButton)
        topContainer.addSubview(headerLabel)

        contentView.addSubview(whiteCardView)
        contentView.addSubview(profileAvatarButton)
        contentView.addSubview(editPencilButton)

        whiteCardView.addSubview(nameLabel)
        whiteCardView.addSubview(roleLabel)
        whiteCardView.addSubview(optionsContainer)

        optionsContainer.addSubview(familyRow)
        optionsContainer.addSubview(accountRow)
        optionsContainer.addSubview(privacyRow)
        optionsContainer.addSubview(logoutRow)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // scroll view
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // top container
            topContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topContainer.heightAnchor.constraint(equalToConstant: 240),

            backButton.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: topContainer.topAnchor, constant: 12),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            headerLabel.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            headerLabel.topAnchor.constraint(equalTo: topContainer.topAnchor, constant: 40),

            // avatar - centered horizontally and overlapping top of white card
            profileAvatarButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileAvatarButton.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -48),
            profileAvatarButton.widthAnchor.constraint(equalToConstant: 112),
            profileAvatarButton.heightAnchor.constraint(equalToConstant: 112),

            editPencilButton.widthAnchor.constraint(equalToConstant: 40),
            editPencilButton.heightAnchor.constraint(equalToConstant: 40),
            editPencilButton.trailingAnchor.constraint(equalTo: profileAvatarButton.trailingAnchor, constant: 6),
            editPencilButton.bottomAnchor.constraint(equalTo: profileAvatarButton.bottomAnchor, constant: 6),

            // white card
            whiteCardView.topAnchor.constraint(equalTo: profileAvatarButton.bottomAnchor, constant: 12),
            whiteCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            whiteCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            whiteCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),

            nameLabel.topAnchor.constraint(equalTo: whiteCardView.topAnchor, constant: 56),
            nameLabel.leadingAnchor.constraint(equalTo: whiteCardView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: whiteCardView.trailingAnchor, constant: -16),

            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            roleLabel.leadingAnchor.constraint(equalTo: whiteCardView.leadingAnchor, constant: 16),
            roleLabel.trailingAnchor.constraint(equalTo: whiteCardView.trailingAnchor, constant: -16),

            optionsContainer.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 24),
            optionsContainer.leadingAnchor.constraint(equalTo: whiteCardView.leadingAnchor, constant: 18),
            optionsContainer.trailingAnchor.constraint(equalTo: whiteCardView.trailingAnchor, constant: -18),
            optionsContainer.bottomAnchor.constraint(lessThanOrEqualTo: whiteCardView.bottomAnchor, constant: -24),

            // rows
            familyRow.topAnchor.constraint(equalTo: optionsContainer.topAnchor),
            familyRow.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            familyRow.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            familyRow.heightAnchor.constraint(equalToConstant: 56),

            accountRow.topAnchor.constraint(equalTo: familyRow.bottomAnchor),
            accountRow.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            accountRow.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            accountRow.heightAnchor.constraint(equalToConstant: 56),

            privacyRow.topAnchor.constraint(equalTo: accountRow.bottomAnchor),
            privacyRow.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            privacyRow.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            privacyRow.heightAnchor.constraint(equalToConstant: 56),

            logoutRow.topAnchor.constraint(equalTo: privacyRow.bottomAnchor, constant: 6),
            logoutRow.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            logoutRow.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            logoutRow.heightAnchor.constraint(equalToConstant: 56),
            logoutRow.bottomAnchor.constraint(equalTo: optionsContainer.bottomAnchor)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        profileAvatarButton.addTarget(self, action: #selector(handleAvatarTap), for: .touchUpInside)
        editPencilButton.addTarget(self, action: #selector(handleAvatarTap), for: .touchUpInside)
    }

    // MARK: - Helpers
    private func applyGradientToTop() {
        // remove existing gradient layers so we don't stack multiple
        topContainer.layer.sublayers?.filter({ $0.name == "topGradient" }).forEach({ $0.removeFromSuperlayer() })

        let gradient = CAGradientLayer()
        gradient.name = "topGradient"
        gradient.frame = topContainer.bounds
        gradient.colors = [UIColor(red: 0.18, green: 0.55, blue: 0.99, alpha: 1).cgColor,
                           UIColor(red: 0.22, green: 0.66, blue: 1.00, alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        topContainer.layer.insertSublayer(gradient, at: 0)

        // round bottom corners of topContainer for the soft capsule look
        let maskPath = UIBezierPath(roundedRect: topContainer.bounds,
                                    byRoundingCorners: [.bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: 18, height: 18))
        let mask = CAShapeLayer()
        mask.path = maskPath.cgPath
        topContainer.layer.mask = mask
    }

    private func makeRow(title: String, tag: Int, titleColor: UIColor = .black) -> UIControl {
        let container = UIControl()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.tag = tag

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = titleColor

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = .darkGray

        container.addSubview(label)
        container.addSubview(chevron)

        // subtle separator
        let bottomLine = UIView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = UIColor(white: 0.9, alpha: 1)
        container.addSubview(bottomLine)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            bottomLine.heightAnchor.constraint(equalToConstant: 1),
            bottomLine.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        container.addTarget(self, action: #selector(menuTapped(_:)), for: .touchUpInside)
        return container
    }

    // MARK: - Actions
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func handleAvatarTap() {
        let editVC = EditProfilePlaceholderViewController()
        navigationController?.pushViewController(editVC, animated: true)
    }

    @objc private func menuTapped(_ sender: UIControl) {
        switch sender.tag {
        case 0:
            print("Family tapped")
            // push family screen
        case 1:
            print("Account tapped")
        case 2:
            print("Privacy and Policy tapped")
        case 3:
            print("Logout tapped")
        default:
            break
        }
    }
}

// --------------------------
// EditProfilePlaceholderViewController
// --------------------------
final class EditProfilePlaceholderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Edit Profile"

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Edit profile screen (design later)"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
