import UIKit

final class SelectRow: UIView {

    // MARK: - UI
    private let button = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.down"))

    // MARK: - Tap handler (for Date row etc.)
    var onTap: (() -> Void)?

    // MARK: - Init
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true

        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        button.layer.cornerRadius = 12

        // 🔥 IMPORTANT: manual tap handling
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        addSubview(button)

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .white

        detailLabel.font = .systemFont(ofSize: 14)
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        detailLabel.textAlignment = .right

        chevron.tintColor = UIColor.white.withAlphaComponent(0.5)

        let content = UIStackView(arrangedSubviews: [
            titleLabel,
            UIView(),
            detailLabel,
            chevron
        ])
        content.translatesAutoresizingMaskIntoConstraints = false
        content.axis = .horizontal
        content.spacing = 8

        button.addSubview(content)

        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            content.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }

    // MARK: - Menu support
    func setMenu(_ menu: UIMenu) {
        button.menu = menu
        button.showsMenuAsPrimaryAction = true   // ✅ ONLY when menu exists
        button.isEnabled = true
    }

    // MARK: - Tap handler
    @objc private func handleTap() {
        // If menu exists, system handles it
        if button.menu != nil { return }

        // Otherwise manual tap
        onTap?()
    }

    // MARK: - Detail
    func setDetail(_ text: String) {
        detailLabel.text = text
    }

    var detailText: String? {
        detailLabel.text
    }
}

