//import UIKit
//
//protocol TaskBubbleCellDelegate: AnyObject {
//    func taskBubbleCell(_ cell: TaskBubbleCell, didSelectTask task: Task)
//}
//
//final class TaskBubbleCell: UITableViewCell {
//    static let reuseId = "TaskBubbleCell"
//
//    private let titleLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.text = "Here are your missions for today"
//        lbl.textColor = .white
//        lbl.font = .boldSystemFont(ofSize: 20)
//        lbl.translatesAutoresizingMaskIntoConstraints = false
//        return lbl
//    }()
//
//    private let scrollView = UIScrollView()
//    private let bubbleContainer = UIView()
//    private var currentTasks: [Task] = []
//    weak var delegate: TaskBubbleCellDelegate?
//
//    private var didLayoutBubbles = false
//    private var containerHeightConstraint: NSLayoutConstraint!
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setup()
//    }
//
//    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
//
//    private func setup() {
//        backgroundColor = .clear
//        selectionStyle = .none
//
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(scrollView)
//        scrollView.addSubview(bubbleContainer)
//
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        bubbleContainer.translatesAutoresizingMaskIntoConstraints = false
//
//        containerHeightConstraint = bubbleContainer.heightAnchor.constraint(equalToConstant: 500)
//        containerHeightConstraint.isActive = true
//
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//
//            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
//            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//
//            bubbleContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            bubbleContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            bubbleContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            bubbleContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            bubbleContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
//        ])
//    }
//
//    func configure(tasks: [Task]) {
//        currentTasks = tasks
//        bubbleContainer.subviews.forEach { $0.removeFromSuperview() }
//        didLayoutBubbles = false
//        setNeedsLayout()
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        guard !didLayoutBubbles, bubbleContainer.bounds.width > 0 else { return }
//        didLayoutBubbles = true
//        layoutBubbles()
//    }
//
//    // Tell the table how tall this cell should be
//    override func systemLayoutSizeFitting(_ targetSize: CGSize,
//                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
//                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
//        return CGSize(width: targetSize.width, height: 520)
//    }
//
//    private func layoutBubbles() {
//        guard !currentTasks.isEmpty else { return }
//
//        let containerWidth = max(50, bubbleContainer.bounds.width)
//        let containerHeight: CGFloat = CGFloat(400 + (currentTasks.count * 60))
//        containerHeightConstraint.constant = containerHeight
//
//        var placedFrames: [CGRect] = []
//
//        for (index, task) in currentTasks.enumerated() {
//            let bubbleSize = CGFloat.random(in: 80...120)
//            var frame = CGRect.zero
//            var attempts = 0
//
//            repeat {
//                let maxX = max(20, containerWidth - bubbleSize - 20)
//                let maxY = max(20, containerHeight - bubbleSize - 20)
//                let x = CGFloat.random(in: 20...maxX)
//                let y = CGFloat.random(in: 20...maxY)
//                frame = CGRect(x: x, y: y, width: bubbleSize, height: bubbleSize)
//                attempts += 1
//            } while placedFrames.contains(where: { $0.intersects(frame.insetBy(dx: -6, dy: -6)) }) && attempts < 80
//
//            placedFrames.append(frame)
//            bubbleContainer.addSubview(createGlassyBubble(for: task, frame: frame))
//        }
//    }
//
//    private func createGlassyBubble(for task: Task, frame: CGRect) -> UIView {
//        let bubble = UIView(frame: frame)
//        bubble.layer.cornerRadius = frame.width / 2
//        bubble.clipsToBounds = true
//        bubble.isUserInteractionEnabled = true
//
//        // glassy blur
//        let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
//        let blurView = UIVisualEffectView(effect: blur)
//        blurView.frame = bubble.bounds
//        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        bubble.addSubview(blurView)
//
//        // border
//        bubble.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
//        bubble.layer.borderWidth = 0.7
//
//        // labels
//        let title = UILabel()
//        title.text = task.title
//        title.font = .systemFont(ofSize: 15, weight: .semibold)
//        title.textColor = task.color
//        title.textAlignment = .center
//        title.translatesAutoresizingMaskIntoConstraints = false
//
//        let time = UILabel()
//        time.text = task.time
//        time.font = .systemFont(ofSize: 13)
//        time.textColor = .white
//        time.textAlignment = .center
//        time.translatesAutoresizingMaskIntoConstraints = false
//
//        bubble.addSubview(title)
//        bubble.addSubview(time)
//
//        NSLayoutConstraint.activate([
//            title.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
//            title.centerYAnchor.constraint(equalTo: bubble.centerYAnchor, constant: -8),
//            time.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
//            time.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2)
//        ])
//
//        let tap = UITapGestureRecognizer(target: self, action: #selector(bubbleTapped(_:)))
//        bubble.addGestureRecognizer(tap)
//
//        return bubble
//    }
//
//    @objc private func bubbleTapped(_ sender: UITapGestureRecognizer) {
//        guard let view = sender.view else { return }
//        let index = bubbleContainer.subviews.firstIndex(of: view) ?? 0
//        guard index < currentTasks.count else { return }
//
//        UIView.animate(withDuration: 0.1, animations: {
//            view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//        }) { _ in
//            UIView.animate(withDuration: 0.2) {
//                view.transform = .identity
//            }
//        }
//
//        delegate?.taskBubbleCell(self, didSelectTask: currentTasks[index])
//    }
//}

