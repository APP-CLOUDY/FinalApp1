import UIKit
final class HomeHeaderView: UIView {

    // MARK: - Callbacks
    var onChildTapped: (() -> Void)?
    var onBellTapped: (() -> Void)?
    var onProfileTapped: (() -> Void)?
    var onPlusTapped: (() -> Void)?   // NEW

    // MARK: - UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 32, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    let childButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Kids ▾", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let bellButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let profileButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "person.crop.circle.fill"), for: .normal)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // 🔥 NEW PLUS BUTTON
    private let plusButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true        // hidden by default
        return b
    }()
    
    // MARK: - Public Control
    func showNotificationButton(_ visible: Bool) {
        bellButton.isHidden = !visible
    }

    func showProfileButton(_ visible: Bool) {
        profileButton.isHidden = !visible
    }

    func showPlusButton(_ visible: Bool) {
        plusButton.isHidden = !visible
    }



    // MARK: - Init
    init(title: String) {
        super.init(frame: .zero)
        setupUI(title: title)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI(title: "")
    }

    // MARK: - Setup UI
    private func setupUI(title: String) {
        titleLabel.text = title

        let topRow = UIStackView(arrangedSubviews: [
            titleLabel,
            UIView(),
            bellButton,
            profileButton,
            plusButton     // 🔥 added here
        ])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 14
        topRow.translatesAutoresizingMaskIntoConstraints = false

        addSubview(topRow)
        addSubview(childButton)

        NSLayoutConstraint.activate([
            topRow.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            topRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            topRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            childButton.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 6),
            childButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            childButton.heightAnchor.constraint(equalToConstant: 32),

            heightAnchor.constraint(equalToConstant: 110)
        ])

        // Assign actions
        childButton.addTarget(self, action: #selector(childTapped), for: .touchUpInside)
        bellButton.addTarget(self, action: #selector(bellTapped), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)

        // 🔥 PLUS BUTTON ACTION
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
    }

    // MARK: - Public contro

    // MARK: - Actions
    @objc private func childTapped() { onChildTapped?() }
    @objc private func bellTapped()   { onBellTapped?() }
    @objc private func profileTapped(){ onProfileTapped?() }

    @objc private func plusTapped() {
        onPlusTapped?()
    }
}

