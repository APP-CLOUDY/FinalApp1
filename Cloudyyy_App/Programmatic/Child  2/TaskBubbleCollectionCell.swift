//import UIKit
//
//final class TaskBubbleCollectionCell: UICollectionViewCell {
//    static let reuseId = "TaskBubbleCollectionCell"
//
//    private let bubble = UIView()
//    private let titleLabel = UILabel()
//    private let timeLabel = UILabel()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setup()
//    }
//    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
//
//    private func setup() {
//        contentView.addSubview(bubble)
//        bubble.translatesAutoresizingMaskIntoConstraints = false
//        bubble.layer.cornerRadius = 999
//        bubble.clipsToBounds = false
//
//        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
//        titleLabel.textAlignment = .center
//        titleLabel.numberOfLines = 1
//        titleLabel.adjustsFontSizeToFitWidth = true
//
//        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//        timeLabel.textAlignment = .center
//        timeLabel.numberOfLines = 1
//
//        bubble.addSubview(titleLabel)
//        bubble.addSubview(timeLabel)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        timeLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            bubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            bubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            bubble.topAnchor.constraint(equalTo: contentView.topAnchor),
//            bubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//
//            titleLabel.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
//            titleLabel.centerYAnchor.constraint(equalTo: bubble.centerYAnchor, constant: -6),
//            titleLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 6),
//            titleLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -6),
//
//            timeLabel.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
//            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
//        ])
//    }
//
//    func configure(with task: Task) {
//        titleLabel.text = task.title
//        timeLabel.text = task.time
//
//        // color, text colors
//        bubble.backgroundColor = task.color.withAlphaComponent(0.12)
//        titleLabel.textColor = task.color
//        timeLabel.textColor = task.color.withAlphaComponent(0.9)
//
//        // shadow / glow
//        bubble.layer.shadowColor = task.color.cgColor
//        bubble.layer.shadowOpacity = 0.18
//        bubble.layer.shadowRadius = 10
//        bubble.layer.shadowOffset = CGSize(width: 0, height: 6)
//    }
//}
