import UIKit

final class TaskBubbleCell: UITableViewCell {
    static let reuseId = "TaskBubbleCell"

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Which mission should we do next?"
        lbl.textColor = .white

        let baseFont = UIFont.boldSystemFont(ofSize: 20)
        if #available(iOS 13.0, *),
           let roundedDescriptor = baseFont.fontDescriptor.withDesign(.rounded) {
            lbl.font = UIFont(descriptor: roundedDescriptor, size: 20)
        } else {
            lbl.font = baseFont
        }

        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let bubbleContainer = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        bubbleContainer.translatesAutoresizingMaskIntoConstraints = false
        bubbleContainer.backgroundColor = .clear

        contentView.addSubview(titleLabel)
        contentView.addSubview(bubbleContainer)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            bubbleContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            bubbleContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bubbleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bubbleContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func configure(tasks: [Task]) {
        bubbleContainer.subviews.forEach { $0.removeFromSuperview() }
        contentView.layoutIfNeeded()
        bubbleContainer.layoutIfNeeded()

        let containerWidth = bubbleContainer.bounds.width
        let containerHeight: CGFloat = 800
        bubbleContainer.heightAnchor.constraint(equalToConstant: containerHeight).isActive = true

        // Sort by size (largest first)
        let sortedTasks = tasks.sorted { $0.sizeFactor > $1.sizeFactor }

        // Hold circle data (center + radius)
        var placed: [(center: CGPoint, radius: CGFloat, frame: CGRect)] = []

        // Initial center point
        let center = CGPoint(x: containerWidth / 2, y: containerHeight / 2)

        for (index, task) in sortedTasks.enumerated() {
            let radius = CGFloat(40 + task.sizeFactor * 30)
            var newCenter = center

            if index == 0 {
                // place first bubble at center
                placed.append((center, radius, CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)))
                continue
            }

            // Try angles around the existing cluster to find a non-overlapping spot
            var found = false
            var angle: CGFloat = 0
            var dist = radius + (placed.first?.radius ?? 0) + 2

            while !found && dist < containerWidth {
                angle += .pi / 24  // step around in small increments
                let x = center.x + cos(angle) * dist
                let y = center.y + sin(angle) * dist
                let newFrame = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)

                // ensure within container bounds
                if newFrame.minX < 0 || newFrame.maxX > containerWidth || newFrame.minY < 0 || newFrame.maxY > containerHeight {
                    dist += 10
                    continue
                }

                // check for overlap
                let overlaps = placed.contains { other in
                    let dx = x - other.center.x
                    let dy = y - other.center.y
                    let distance = sqrt(dx * dx + dy * dy)
                    return distance < (radius + other.radius + 4)
                }

                if !overlaps {
                    newCenter = CGPoint(x: x, y: y)
                    found = true
                } else {
                    dist += 2
                }
            }

            let frame = CGRect(x: newCenter.x - radius, y: newCenter.y - radius, width: radius * 2, height: radius * 2)
            placed.append((newCenter, radius, frame))
        }

        // Add bubbles
        for (i, task) in sortedTasks.enumerated() {
            let bubbleFrame = placed[i].frame
            let bubbleView = createGlassyBubble(for: task, frame: bubbleFrame)
            bubbleView.alpha = 0
            bubbleView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            bubbleContainer.addSubview(bubbleView)

            UIView.animate(withDuration: 0.5,
                           delay: Double(i) * 0.05,
                           usingSpringWithDamping: 0.65,
                           initialSpringVelocity: 0.5,
                           options: [.curveEaseOut],
                           animations: {
                bubbleView.alpha = 1
                bubbleView.transform = .identity
            })
        }
    }

    // MARK: - Glassy Bubble
    private func createGlassyBubble(for task: Task, frame: CGRect) -> UIView {
        let bubble = UIView(frame: frame)
        bubble.layer.cornerRadius = frame.width / 2
        bubble.clipsToBounds = false
        bubble.backgroundColor = .clear

        // Soft shadow (optional)
        bubble.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        bubble.layer.shadowOpacity = 0.25
        bubble.layer.shadowRadius = 6
        bubble.layer.shadowOffset = CGSize(width: 0, height: 3)

        // Glass effect layer
        let glass = UIView(frame: bubble.bounds)
        glass.layer.cornerRadius = frame.width / 2
        glass.clipsToBounds = true
        glass.backgroundColor = task.color.withAlphaComponent(0.15)
        bubble.addSubview(glass)

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = glass.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false
        glass.addSubview(blurView)

        // Centered labels
        let title = UILabel()
        title.text = task.title
        title.textColor = task.color
        title.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        title.textAlignment = .center
        title.numberOfLines = 2

        let time = UILabel()
        time.text = task.time
        time.textColor = task.color.withAlphaComponent(0.85)
        time.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        time.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [title, time])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        glass.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: glass.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: glass.centerYAnchor)
        ])

        return bubble
    }
}
