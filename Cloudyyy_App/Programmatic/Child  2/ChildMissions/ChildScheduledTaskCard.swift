import UIKit

final class KidAgendaItemPanel: UIView {

    // MARK: - UI Components
    private let accentStripeView = UIView()
    private let headingLabel = UILabel()
    private let subLabel = UILabel()
    private let blurContainerView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    
    // Visual-only icon
    private let statusIcon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    // MARK: - Init
    init(task: ScheduleTaskModelChild) {
        super.init(frame: .zero)
        setupUI()
        configure(with: task)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 12
        clipsToBounds = true
        backgroundColor = .clear

        // 1. Stripe (Left)
        accentStripeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(accentStripeView)

        // 2. Glass Container (Right)
        blurContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurContainerView)

        // 3. Content
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        headingLabel.textColor = .white

        subLabel.translatesAutoresizingMaskIntoConstraints = false
        subLabel.font = .systemFont(ofSize: 13)
        subLabel.textColor = UIColor.white.withAlphaComponent(0.75)

        let content = blurContainerView.contentView
        content.addSubview(headingLabel)
        content.addSubview(subLabel)
        content.addSubview(statusIcon)

        NSLayoutConstraint.activate([
            // Stripe (Left edge, fixed width)
            accentStripeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            accentStripeView.topAnchor.constraint(equalTo: topAnchor),
            accentStripeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            accentStripeView.widthAnchor.constraint(equalToConstant: 6),

            // Container (Fills the rest)
            blurContainerView.leadingAnchor.constraint(equalTo: accentStripeView.trailingAnchor),
            blurContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurContainerView.topAnchor.constraint(equalTo: topAnchor),
            blurContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Status Icon (Right side)
            statusIcon.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            statusIcon.centerYAnchor.constraint(equalTo: content.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 24),

            // Heading
            headingLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 12),
            headingLabel.trailingAnchor.constraint(equalTo: statusIcon.leadingAnchor, constant: -8),
            headingLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 14),

            // Sub Label
            subLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 12),
            subLabel.trailingAnchor.constraint(equalTo: statusIcon.leadingAnchor, constant: -8),
            subLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 4),
            subLabel.bottomAnchor.constraint(lessThanOrEqualTo: content.bottomAnchor, constant: -12)
        ])
    }

    private func configure(with task: ScheduleTaskModelChild) {
        headingLabel.text = task.title
        subLabel.text = "\(task.points) pts • \(task.frequency)"
        
        // Default icon
        statusIcon.image = UIImage(systemName: "hourglass")
    }
    
    // ✅ THIS IS THE FUNCTION THAT WAS MISSING
    func setStatusColor(_ color: UIColor) {
        accentStripeView.backgroundColor = color
        statusIcon.tintColor = color
        
        // Update icon based on color logic
        if color == .systemGreen {
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
        } else if color == .systemRed {
            statusIcon.image = UIImage(systemName: "xmark.circle.fill")
        } else {
            statusIcon.image = UIImage(systemName: "hourglass")
        }
    }
}

