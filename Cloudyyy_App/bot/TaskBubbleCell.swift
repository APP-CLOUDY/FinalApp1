import UIKit

final class TaskBubbleCell: UITableViewCell {
    static let reuseId = "TaskBubbleCell"

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Which mission should we do next?"
        lbl.textColor = .white
        lbl.font = .boldSystemFont(ofSize: 18)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let bubbleContainer = UIView()
    private var tasks: [Task] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        bubbleContainer.translatesAutoresizingMaskIntoConstraints = false
        bubbleContainer.backgroundColor = .clear
        contentView.addSubview(titleLabel)
        contentView.addSubview(bubbleContainer)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            bubbleContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            bubbleContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            bubbleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            bubbleContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            bubbleContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 240)
        ])
    }

    func configure(tasks: [Task]) {
        self.tasks = tasks

        // Remove any previous bubbles
        bubbleContainer.subviews.forEach { $0.removeFromSuperview() }

        let containerWidth = UIScreen.main.bounds.width - 40
        let containerHeight: CGFloat = 260

        for (i, task) in tasks.enumerated() {
            let bubble = createBubble(for: task)

            // random size range (varied)
            let size: CGFloat = CGFloat.random(in: 90...150)
            let xPos = CGFloat.random(in: 10...(containerWidth - size - 10))
            let yPos = CGFloat.random(in: 10...(containerHeight - size - 10))

            bubble.frame = CGRect(x: xPos, y: yPos, width: size, height: size)
            bubbleContainer.addSubview(bubble)

            // ✅ Animate pop-in
            bubble.alpha = 0
            bubble.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            UIView.animate(withDuration: 0.4,
                           delay: Double(i) * 0.08,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.5,
                           options: [.curveEaseOut]) {
                bubble.alpha = 1
                bubble.transform = .identity
            }
        }
    }

    private func createBubble(for task: Task) -> UIView {
        let bubble = UIView()
        bubble.layer.cornerRadius = 999
        bubble.backgroundColor = task.color.withAlphaComponent(0.2)
        bubble.layer.shadowColor = task.color.cgColor
        bubble.layer.shadowOpacity = 0.4
        bubble.layer.shadowRadius = 8
        bubble.layer.shadowOffset = CGSize(width: 0, height: 4)
        bubble.clipsToBounds = false

        // Title
        let title = UILabel()
        title.text = task.title
        title.textColor = task.color
        title.font = .systemFont(ofSize: 13, weight: .semibold)
        title.textAlignment = .center
        title.numberOfLines = 2
        title.adjustsFontSizeToFitWidth = true

        // Time
        let time = UILabel()
        time.text = task.time
        time.textColor = task.color.withAlphaComponent(0.9)
        time.font = .systemFont(ofSize: 12)
        time.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [title, time])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false

        bubble.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: bubble.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 6),
            stack.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -6)
        ])

        return bubble
    

    }
}
