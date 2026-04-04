// HomeHeaderView.swift
// Drop-in replacement for your header. Includes chevron-in-circle back button (no label).

import UIKit

// Keep this commented-out if you already define Kid in the project
// struct Kid { let id: String; let name: String }

final class HomeHeaderView: UIView {

    // MARK: - Callbacks
    var onChildTapped: (() -> Void)?
    var onBellTapped: (() -> Void)?
    var onProfileTapped: (() -> Void)?
    var onPlusTapped: (() -> Void)?
    var onBackTapped: (() -> Void)?       // NEW: used by controllers that want the back chevron

    // MARK: - State
    private var kidsList: [Kid] = []
    private var selectedKid: Kid?

    // MARK: - UI

    // Back button style: chevron only inside a soft circular background (like your screenshot)
    private lazy var backButton: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: "chevron.left", withConfiguration: cfg)
        b.setImage(image, for: .normal)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false

        // background circle
        b.backgroundColor = UIColor(white: 1, alpha: 0.10)
        b.layer.cornerRadius = 20
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor(white: 1, alpha: 0.15).cgColor
        b.layer.masksToBounds = true

        // back button is hidden unless VC enables it
        b.isHidden = true // ← important

        // constraints
        NSLayoutConstraint.activate([
            b.widthAnchor.constraint(equalToConstant: 40),
            b.heightAnchor.constraint(equalToConstant: 40)
        ])

        b.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return b
    }()


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        l.adjustsFontForContentSizeCategory = true
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    let childButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("", for: .normal)
        b.setTitleColor(.white.withAlphaComponent(0.9), for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        b.contentHorizontalAlignment = .left
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private lazy var plusButton: UIButton = {
        let b = makeIconButton(systemName: "plus.circle.fill", pointSize: 20)
        b.isHidden = true   // ✅ DEFAULT: hidden
        return b
    }()
    private lazy var bellButton = makeIconButton(systemName: "bell", pointSize: 20)
    private lazy var profileButton = makeIconButton(systemName: "person.circle.fill", pointSize: 22)

    // MARK: - Init
    init(title: String = "") {
        super.init(frame: .zero)
        setupUI(title: title)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI(title: "")
    }

    // MARK: - Public API
    func setKids(_ kids: [Kid]) {
        self.kidsList = kids
        updateChildButton()
    }

    func setSelectedKid(_ kid: Kid) {
        self.selectedKid = kid
        updateChildButton()
    }

    func showNotificationButton(_ visible: Bool) { bellButton.isHidden = !visible }
    func showProfileButton(_ visible: Bool)      { profileButton.isHidden = !visible }
    func showPlusButton(_ visible: Bool)         { plusButton.isHidden = !visible }
    func showBackButton(_ visible: Bool)         { backButton.isHidden = !visible }

    // MARK: - Private
    private func updateChildButton() {
        childButton.showsMenuAsPrimaryAction = false
        childButton.menu = nil

        let count = kidsList.count
        if count == 0 {
            childButton.setTitle("No Kids", for: .normal)
            childButton.isUserInteractionEnabled = false
            return
        }
        if count == 1 {
            childButton.setTitle(kidsList.first?.name ?? "Kid", for: .normal)
            childButton.isUserInteractionEnabled = false
            return
        }
        if let sel = selectedKid {
            childButton.setTitle("\(sel.name) ▾", for: .normal)
        } else {
            childButton.setTitle("Kids ▾", for: .normal)
        }
        childButton.isUserInteractionEnabled = true
    }

    private func makeIconButton(systemName: String, pointSize: CGFloat) -> UIButton {
        let b = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .regular)
        b.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            b.widthAnchor.constraint(equalToConstant: 44),
            b.heightAnchor.constraint(equalToConstant: 44)
        ])
        return b
    }

    private func setupUI(title: String) {
        backgroundColor = .clear
        titleLabel.text = title

        preservesSuperviewLayoutMargins = true
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

        // Top row: back button + title + spacer + icons
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let topRow = UIStackView(arrangedSubviews: [
            backButton,
            titleLabel,
            spacer,
            plusButton,
            bellButton,
            profileButton
        ])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 8
        topRow.translatesAutoresizingMaskIntoConstraints = false

        addSubview(topRow)
        addSubview(childButton)

        // Make sure back button & title don't get pushed away — hugging priorities reduce giant gaps
        backButton.setContentHuggingPriority(.required, for: .horizontal)
        backButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            // TOP ROW (Back + Title + Icons)
            topRow.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            topRow.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            topRow.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            // Child dropdown UNDER TITLE (NOT under back button)
            childButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            childButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            childButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])

        // Actions
        childButton.addTarget(self, action: #selector(childTapped), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        bellButton.addTarget(self, action: #selector(bellTapped), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func childTapped()  { onChildTapped?() }
    @objc private func bellTapped()   { onBellTapped?() }
    @objc private func profileTapped(){ onProfileTapped?() }
    @objc private func plusTapped()   { onPlusTapped?() }
    @objc private func backTapped()   { onBackTapped?() }
}

