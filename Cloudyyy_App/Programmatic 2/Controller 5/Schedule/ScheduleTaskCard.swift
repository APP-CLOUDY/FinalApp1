import UIKit

final class ScheduleTaskCard: UIView {

    // MARK: - UI Components
    private let leadingStripe = UIView()
    // Note: Ensure GlassView exists in your project, otherwise use UIView with alpha
    private let glass = GlassView(style: .row, cornerRadius: 16)

    private let titleLabel = UILabel()
    private let detailsLabel = UILabel()

    private let categoryIcon = UIImageView()
    private let categoryLabel = UILabel()
    private let categoryStack = UIStackView()
    
    private let statusIcon = UIImageView()

    // MARK: - Init
    init(task: ScheduleTaskModel) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI(task: task)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup UI
    private func setupUI(task: ScheduleTaskModel) {

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

        // 3. Details (Points + Time/Frequency)
        detailsLabel.font = .systemFont(ofSize: 13)
        detailsLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // --- LOGIC: Combine Date + Time ---
        var detailsText = "\(task.points) Points"
        
        // Check if we have a specific time column from DB
        if let timeStr = task.due_time, let formattedTime = formatTimeOnly(timeStr) {
            detailsText += " • Due \(formattedTime)"
        }
        else if let freq = task.frequency, freq != "Once" {
            // Fallback to frequency if no time is set
            detailsText += " • \(freq)"
        }
        
        detailsLabel.text = detailsText
        // ----------------------------------

        // 4. Category
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

        // 6. Assembly
        glass.addSubview(titleLabel)
        glass.addSubview(detailsLabel)
        glass.addSubview(categoryStack)
        glass.addSubview(statusIcon)

        // 7. Constraints
        NSLayoutConstraint.activate([
            // Stripe (Left side bar)
            leadingStripe.leadingAnchor.constraint(equalTo: leadingAnchor),
            leadingStripe.topAnchor.constraint(equalTo: topAnchor),
            leadingStripe.bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingStripe.widthAnchor.constraint(equalToConstant: 6),

            // Glass Background
            glass.leadingAnchor.constraint(equalTo: leadingStripe.trailingAnchor),
            glass.trailingAnchor.constraint(equalTo: trailingAnchor),
            glass.topAnchor.constraint(equalTo: topAnchor),
            glass.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Title
            titleLabel.leadingAnchor.constraint(equalTo: glass.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: statusIcon.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: glass.topAnchor, constant: 14),

            // Details (Points/Time)
            detailsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            // Category Stack
            categoryStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            categoryStack.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 10),
            categoryStack.bottomAnchor.constraint(equalTo: glass.bottomAnchor, constant: -14),
            
            // Status Icon (Right side)
            statusIcon.trailingAnchor.constraint(equalTo: glass.trailingAnchor, constant: -14),
            statusIcon.centerYAnchor.constraint(equalTo: glass.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 24),
            statusIcon.heightAnchor.constraint(equalToConstant: 24)
        ])

        applyStatusColor(task)
    }

    // MARK: - Status Logic
    private func applyStatusColor(_ task: ScheduleTaskModel) {
        
        let colorGreen = UIColor(red: 76/255, green: 209/255, blue: 55/255, alpha: 1)   // Approved
        let colorYellow = UIColor(red: 255/255, green: 217/255, blue: 61/255, alpha: 1) // Pending / Upcoming
        let colorRed = UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1)     // Overdue
        
        let status = task.submission_status?.lowercased()
        
        if status == "approved" {
            // ✅ Case 1: Approved
            leadingStripe.backgroundColor = colorGreen
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.tintColor = colorGreen
            
        } else if status == "pending" {
            // ⏳ Case 2: Submitted (Pending Approval)
            leadingStripe.backgroundColor = colorYellow
            statusIcon.image = UIImage(systemName: "hourglass")
            statusIcon.tintColor = colorYellow
            
        } else {
            // 📝 Case 3: Not Done Yet
            // Check if we missed the deadline
            if isPastDue(dateStr: task.due_date, timeStr: task.due_time) {
                // 🔴 Late!
                leadingStripe.backgroundColor = colorRed
                statusIcon.image = UIImage(systemName: "exclamationmark.circle.fill")
                statusIcon.tintColor = colorRed
            } else {
                // 🟡 Upcoming (Have time)
                leadingStripe.backgroundColor = colorYellow
                statusIcon.image = nil // Clean look for to-do items
            }
        }
    }

    // MARK: - Helpers

    /// Formats "14:30:00" -> "2:30 PM"
    private func formatTimeOnly(_ timeString: String) -> String? {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss" // Matches Supabase 'time' column format
        f.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = f.date(from: timeString) {
            f.dateFormat = "h:mm a" // Output: 2:30 PM
            return f.string(from: date)
        }
        return nil
    }

    /// Combines Date Column + Time Column to check if it's past
    private func isPastDue(dateStr: String?, timeStr: String?) -> Bool {
        guard let dateStr = dateStr else { return false }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        // 1. If we have BOTH date and time
        if let timeStr = timeStr {
            let combinedString = "\(dateStr) \(timeStr)" // e.g., "2025-10-25 14:30:00"
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let dueDateTime = formatter.date(from: combinedString) {
                // Return true if NOW is greater than the deadline
                return Date() > dueDateTime
            }
        }
        
        // 2. If we only have date (treat as strict end of day check)
        formatter.dateFormat = "yyyy-MM-dd"
        if let dueDate = formatter.date(from: dateStr) {
            // Strict logic: If today is 26th, 25th is overdue.
            // If today is 25th, it is NOT overdue (you have until end of day).
            return Calendar.current.startOfDay(for: Date()) > Calendar.current.startOfDay(for: dueDate)
        }

        return false
    }
}
