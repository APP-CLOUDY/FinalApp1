import UIKit

final class HomeHeaderView: UIView {

    // MARK: - Callbacks
    var onChildTapped: (() -> Void)?
    var onBellTapped: (() -> Void)?
    var onProfileTapped: (() -> Void)?
    var onPlusTapped: (() -> Void)?

    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 32, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    let childButton: UIButton = {
        let b = UIButton(type: .system)
        // Add arrow to show it's clickable
        b.setTitle("Kids ▾", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        // Ensure interaction is enabled
        b.isUserInteractionEnabled = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let bellButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "bell"), for: .normal)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let profileButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let plusButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true
        return b
    }()
    
    // MARK: - Public Control
    func showNotificationButton(_ visible: Bool) { bellButton.isHidden = !visible }
    func showProfileButton(_ visible: Bool) { profileButton.isHidden = !visible }
    func showPlusButton(_ visible: Bool) { plusButton.isHidden = !visible }

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
        
        // Allow touch events
        self.isUserInteractionEnabled = true

        // Spacer ensures buttons are pushed to the right
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let topRow = UIStackView(arrangedSubviews: [
            titleLabel,
            spacer,
            plusButton,
            bellButton,
            profileButton
        ])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 14
        topRow.translatesAutoresizingMaskIntoConstraints = false

        addSubview(topRow)
        addSubview(childButton)

        NSLayoutConstraint.activate([
            // 1. Top Row Constraints
            // We use constant 0 instead of -20 to ensure it stays inside the view bounds
            topRow.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            topRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            topRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // 2. Child Button Constraints
            childButton.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 4),
            childButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            childButton.heightAnchor.constraint(equalToConstant: 40), // Increased height for better touch area
            
            // 3. CRITICAL: Pin to bottom so the parent VC knows how big this view is content-wise
            childButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -5)
        ])
        
        // REMOVED: heightAnchor.constraint(...) <-- This line was breaking your code

        // Assign actions
        childButton.addTarget(self, action: #selector(childTapped), for: .touchUpInside)
        bellButton.addTarget(self, action: #selector(bellTapped), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func childTapped() {
        // Debug print to verify tap is registered
        print("👶 Child button tapped")
        onChildTapped?()
    }
    @objc private func bellTapped()   { onBellTapped?() }
    @objc private func profileTapped(){ onProfileTapped?() }
    @objc private func plusTapped() { onPlusTapped?() }
}
