import UIKit

protocol ChoiceMessageCellDelegate: AnyObject {
    func choiceMessageCell(_ cell: ChoiceMessageCell, didSelectChoice title: String)
}

final class ChoiceMessageCell: UITableViewCell {
    static let reuseId = "ChoiceMessageCell"

    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let stack = UIStackView()
    private let leftButton = UIButton(type: .system)
    private let rightButton = UIButton(type: .system)

    weak var delegate: ChoiceMessageCellDelegate?

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
        bubbleView.backgroundColor = UIColor(white: 0.93, alpha: 1)
        bubbleView.layer.cornerRadius = 14
        contentView.addSubview(bubbleView)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = .darkText
        bubbleView.addSubview(messageLabel)

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        bubbleView.addSubview(stack)

        [leftButton, rightButton].forEach { btn in
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
            btn.layer.cornerRadius = 18
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = UIColor(red: 36/255, green: 64/255, blue: 110/255, alpha: 1)
            stack.addArrangedSubview(btn)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 18, bottom: 8, right: 18)
            btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }

        NSLayoutConstraint.activate([
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12),

            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),

            stack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            stack.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: bubbleView.trailingAnchor, constant: -12)
        ])
    }

    func configure(with model: ChatMessage) {
        messageLabel.text = model.text
        if let choices = model.choices {
            if choices.count > 0 { leftButton.setTitle(choices[0], for: .normal) } else { leftButton.setTitle("", for: .normal) }
            if choices.count > 1 { rightButton.setTitle(choices[1], for: .normal) } else { rightButton.setTitle("", for: .normal) }
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        delegate?.choiceMessageCell(self, didSelectChoice: title)
    }
}
