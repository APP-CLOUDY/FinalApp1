import UIKit

final class OutgoingMessageCell: UITableViewCell {
    static let reuseId = "OutgoingMessageCell"

    private let bubbleView = UIView()
    private let messageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.backgroundColor = UIColor(red: 36/255, green: 64/255, blue: 110/255, alpha: 1)
        bubbleView.layer.cornerRadius = 14
        contentView.addSubview(bubbleView)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 14 , weight: .regular)
        messageLabel.textColor = .white
        bubbleView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 80),

            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
        ])
    }

    func configure(with model: ChatMessage) {
        messageLabel.text = model.text
    }
}
