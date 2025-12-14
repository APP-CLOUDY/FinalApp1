import UIKit

final class ScheduleTaskCard: UIView {

    // MARK: - UI
    private let leadingStripe = UIView()
    private let glass = GlassView(style: .row, cornerRadius: 16)

    private let titleLabel = UILabel()
    private let timeLabel = UILabel()

    private let categoryIcon = UIImageView()
    private let categoryLabel = UILabel()
    private let categoryStack = UIStackView()

    // MARK: - Init
    init(task: ScheduleTaskModel) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI(task: task)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup
    private func setupUI(task: ScheduleTaskModel) {

        layer.cornerRadius = 16
        clipsToBounds = true

        // Stripe
        leadingStripe.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leadingStripe)

        // Glass
        glass.translatesAutoresizingMaskIntoConstraints = false
        addSubview(glass)

        // Title
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.text = task.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Time / Frequency
        timeLabel.font = .systemFont(ofSize: 13)
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        timeLabel.text = "\(task.points) Points • \(task.frequency)"
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        // Category
        categoryIcon.image = UIImage(systemName: "folder")
        categoryIcon.tintColor = UIColor.white.withAlphaComponent(0.5)
        categoryIcon.translatesAutoresizingMaskIntoConstraints = false
        categoryIcon.widthAnchor.constraint(equalToConstant: 14).isActive = true
        categoryIcon.heightAnchor.constraint(equalToConstant: 14).isActive = true

        categoryLabel.text = "Task"
        categoryLabel.font = .systemFont(ofSize: 12, weight: .medium)
        categoryLabel.textColor = UIColor.white.withAlphaComponent(0.5)

        categoryStack.axis = .horizontal
        categoryStack.spacing = 6
        categoryStack.alignment = .center
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        categoryStack.addArrangedSubview(categoryIcon)
        categoryStack.addArrangedSubview(categoryLabel)

        glass.addSubview(titleLabel)
        glass.addSubview(timeLabel)
        glass.addSubview(categoryStack)

        NSLayoutConstraint.activate([
            // Stripe
            leadingStripe.leadingAnchor.constraint(equalTo: leadingAnchor),
            leadingStripe.topAnchor.constraint(equalTo: topAnchor),
            leadingStripe.bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingStripe.widthAnchor.constraint(equalToConstant: 6),

            // Glass
            glass.leadingAnchor.constraint(equalTo: leadingStripe.trailingAnchor),
            glass.trailingAnchor.constraint(equalTo: trailingAnchor),
            glass.topAnchor.constraint(equalTo: topAnchor),
            glass.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Content
            titleLabel.leadingAnchor.constraint(equalTo: glass.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: glass.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: glass.topAnchor, constant: 14),

            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            categoryStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            categoryStack.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            categoryStack.bottomAnchor.constraint(equalTo: glass.bottomAnchor, constant: -14)
        ])

        applyStatusColor(task)
    }

    // MARK: - Status Color
    private func applyStatusColor(_ task: ScheduleTaskModel) {
        let status = task.submission_status ?? "todo"

        let softRed = UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1)
        let softYellow = UIColor(red: 255/255, green: 217/255, blue: 61/255, alpha: 1)
        let softGreen = UIColor(red: 76/255, green: 209/255, blue: 55/255, alpha: 1)

        switch status {
        case "approved":
            leadingStripe.backgroundColor = softGreen
        case "pending":
            leadingStripe.backgroundColor = softYellow
        default:
            leadingStripe.backgroundColor = softRed
        }
    }
}

