import UIKit

final class ScheduleTaskCard: UIView {

    private let leadingStripe = UIView()
    private let container = UIView()
    
    // Labels
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    
    // Bottom Category Row
    private let categoryIcon = UIImageView()
    private let categoryLabel = UILabel()
    private let categoryStack = UIStackView()

    init(task: ScheduleTask) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        // 1. Card Styling (Solid Dark Grey)
        backgroundColor = UIColor(red: 40/255, green: 45/255, blue: 65/255, alpha: 1)
        layer.cornerRadius = 12
        clipsToBounds = true

        // 2. Left Stripe
        leadingStripe.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leadingStripe)

        // 3. Container for text
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        // 4. Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.text = task.title

        // 5. Time
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 13, weight: .regular)
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        timeLabel.text = task.time

        // 6. Category (Folder + Text)
        categoryIcon.image = UIImage(systemName: "folder")
        categoryIcon.tintColor = UIColor.white.withAlphaComponent(0.5)
        categoryIcon.contentMode = .scaleAspectFit
        categoryIcon.translatesAutoresizingMaskIntoConstraints = false
        categoryIcon.widthAnchor.constraint(equalToConstant: 14).isActive = true
        categoryIcon.heightAnchor.constraint(equalToConstant: 14).isActive = true
        
        categoryLabel.text = "Habits"
        categoryLabel.font = .systemFont(ofSize: 12, weight: .medium)
        categoryLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        
        // Stack View for perfect alignment of Icon + Text
        categoryStack.axis = .horizontal
        categoryStack.spacing = 6
        categoryStack.alignment = .center
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        categoryStack.addArrangedSubview(categoryIcon)
        categoryStack.addArrangedSubview(categoryLabel)
        
        container.addSubview(titleLabel)
        container.addSubview(timeLabel)
        container.addSubview(categoryStack)

        // 7. Layout Constraints
        NSLayoutConstraint.activate([
            // Stripe
            leadingStripe.leadingAnchor.constraint(equalTo: leadingAnchor),
            leadingStripe.topAnchor.constraint(equalTo: topAnchor),
            leadingStripe.bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingStripe.widthAnchor.constraint(equalToConstant: 6),

            // Container
            container.leadingAnchor.constraint(equalTo: leadingStripe.trailingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Title (Top)
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),

            // Time (Below Title)
            // Align strictly with Title
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            // Category (Bottom)
            // Align strictly with Title
            categoryStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            categoryStack.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10), // Increased spacing for cleaner look
            categoryStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
        ])

        // 8. Color Logic (Stripe)
        let status = task.status.lowercased()
        
        // Custom Colors
        let softRed = UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1)

   // Lighter Red
        let softYellow = UIColor(red: 255/255, green: 217/255, blue: 61/255, alpha: 1) // Soft Yellow
        let softGreen = UIColor(red: 76/255, green: 209/255, blue: 55/255, alpha: 1)   // Soft Green

        if status.contains("completed") {
            leadingStripe.backgroundColor = softGreen
        } else if status.contains("progress") || status.contains("in progress") {
            leadingStripe.backgroundColor = softYellow
        } else {
            leadingStripe.backgroundColor = softRed // Applied new lighter red
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}
