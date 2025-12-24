import UIKit

final class SelectRow: UIView {

    // MARK: - UI
    // We use .custom to avoid default system flashing effects
    private let button = UIButton(type: .custom)
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.down"))

    // MARK: - Tap handler
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
        
        // 1. ✅ Apply Styling to SELF (The Container), not the button
        self.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        self.layer.cornerRadius = 12
        
        // 2. Setup Labels (Visuals)
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
        content.isUserInteractionEnabled = false // Let touches pass through to button

        // 3. Add Visuals to SELF
        addSubview(content)

        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            content.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        // 4. Setup Button as an INVISIBLE OVERLAY
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear // Transparent
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        addSubview(button) // Add button LAST so it sits on top

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Menu support
    func setMenu(_ menu: UIMenu) {
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
    }

    // MARK: - Tap handler
    @objc private func handleTap() {
        if button.menu != nil { return }
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
