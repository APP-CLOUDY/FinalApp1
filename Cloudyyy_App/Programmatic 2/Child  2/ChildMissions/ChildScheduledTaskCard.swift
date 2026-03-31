import UIKit

enum KidTaskStatusState {
    case approved
    case pending
    case redo
    case overdue
    case todo
}

final class KidAgendaItemPanel: UIView {

    // MARK: - UI Components
    private let leadingStripe = UIView()
    // Assumes you have the same GlassView class as the parent schedule
    private let glass = GlassView(style: .row, cornerRadius: 16)

    private let titleLabel = UILabel()
    private let detailsLabel = UILabel()

    // Category info (Optional: keeps design consistent with Parent card)
    private let categoryIcon = UIImageView()
    private let categoryLabel = UILabel()
    private let categoryStack = UIStackView()
    
    private let statusIcon = UIImageView()
    private let statusBadge = UILabel()

    // MARK: - Init
    init(task: ScheduleTaskModelChild) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI(task: task)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup UI
    private func setupUI(task: ScheduleTaskModelChild) {

        layer.cornerRadius = 16
        clipsToBounds = true

        // 1. Backgrounds
        leadingStripe.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leadingStripe)

        glass.translatesAutoresizingMaskIntoConstraints = false
        addSubview(glass)

        // 2. Title
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.text = task.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 3. Details (Points + Due Time)
        detailsLabel.font = .systemFont(ofSize: 13)
        detailsLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // --- DETAILS LOGIC ---
        var detailsText = "\(task.points) Points"
        
        if let timeStr = task.due_time, let formattedTime = formatTimeOnly(timeStr) {
            detailsText += " • Due \(formattedTime)"
        }
        else if task.frequency != "Once" {
            detailsText += " • \(task.frequency)"
        }
        
        detailsLabel.text = detailsText
        // ---------------------

        // 4. Category (Uses list_name or default)
        categoryIcon.image = UIImage(systemName: "folder")
        categoryIcon.tintColor = UIColor.white.withAlphaComponent(0.5)
        categoryIcon.widthAnchor.constraint(equalToConstant: 14).isActive = true
        categoryIcon.heightAnchor.constraint(equalToConstant: 14).isActive = true

        categoryLabel.text = task.list_name ?? "General"
        categoryLabel.font = .systemFont(ofSize: 12, weight: .medium)
        categoryLabel.textColor = UIColor.white.withAlphaComponent(0.5)

        categoryStack.axis = .horizontal
        categoryStack.spacing = 6
        categoryStack.alignment = .center
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        categoryStack.addArrangedSubview(categoryIcon)
        categoryStack.addArrangedSubview(categoryLabel)

        // 5. Status Icon
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.contentMode = .scaleAspectFit
        statusIcon.tintColor = .white

        statusBadge.font = .systemFont(ofSize: 11, weight: .bold)
        statusBadge.textColor = .white
        statusBadge.textAlignment = .center
        statusBadge.layer.cornerRadius = 10
        statusBadge.clipsToBounds = true
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        statusBadge.isHidden = true

        // 6. Assembly
        glass.addSubview(titleLabel)
        glass.addSubview(detailsLabel)
        glass.addSubview(categoryStack)
        glass.addSubview(statusIcon)
        glass.addSubview(statusBadge)

        // 7. Constraints
        NSLayoutConstraint.activate([
            // Stripe
            leadingStripe.leadingAnchor.constraint(equalTo: leadingAnchor),
            leadingStripe.topAnchor.constraint(equalTo: topAnchor),
            leadingStripe.bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingStripe.widthAnchor.constraint(equalToConstant: 6),

            // Glass Container
            glass.leadingAnchor.constraint(equalTo: leadingStripe.trailingAnchor),
            glass.trailingAnchor.constraint(equalTo: trailingAnchor),
            glass.topAnchor.constraint(equalTo: topAnchor),
            glass.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Title
            titleLabel.leadingAnchor.constraint(equalTo: glass.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: statusIcon.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: glass.topAnchor, constant: 14),

            // Details
            detailsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            // Category
            categoryStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            categoryStack.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 10),
            categoryStack.bottomAnchor.constraint(equalTo: glass.bottomAnchor, constant: -14),
            
            // Icon
            statusIcon.trailingAnchor.constraint(equalTo: glass.trailingAnchor, constant: -14),
            statusIcon.centerYAnchor.constraint(equalTo: glass.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 24),

            statusBadge.trailingAnchor.constraint(equalTo: glass.trailingAnchor, constant: -14),
            statusBadge.centerYAnchor.constraint(equalTo: glass.centerYAnchor),
            statusBadge.heightAnchor.constraint(equalToConstant: 24),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 56)
        ])
    }

    // MARK: - Dynamic Color Logic
    // Called by Controller to update color state
    func setStatusState(_ state: KidTaskStatusState) {
        statusBadge.isHidden = true
        statusIcon.isHidden = false

        switch state {
        case .approved:
            leadingStripe.backgroundColor = .systemGreen
            statusIcon.tintColor = .systemGreen
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
        case .pending:
            leadingStripe.backgroundColor = .systemYellow
            statusIcon.tintColor = .systemYellow
            statusIcon.image = UIImage(systemName: "hourglass")
        case .redo:
            let redoColor = UIColor(red: 243/255, green: 156/255, blue: 18/255, alpha: 1)
            leadingStripe.backgroundColor = redoColor
            statusIcon.isHidden = true
            statusBadge.isHidden = false
            statusBadge.backgroundColor = redoColor.withAlphaComponent(0.22)
            statusBadge.text = "REDO"
        case .overdue:
            leadingStripe.backgroundColor = .systemRed
            statusIcon.tintColor = .systemRed
            statusIcon.image = UIImage(systemName: "exclamationmark.circle.fill")
        case .todo:
            leadingStripe.backgroundColor = .systemYellow
            statusIcon.tintColor = .systemYellow
            statusIcon.image = nil
        }
    }

    // MARK: - Helper
    private func formatTimeOnly(_ timeString: String) -> String? {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss" // Matches DB format
        f.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = f.date(from: timeString) {
            f.dateFormat = "h:mm a" // e.g. "5:30 PM"
            return f.string(from: date)
        }
        return nil
    }
}
