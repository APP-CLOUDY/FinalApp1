//import UIKit
//
//protocol ChoiceMessageCellDelegate: AnyObject {
//    func choiceMessageCell(_ cell: ChoiceMessageCell, didSelectChoice title: String)
//}
//
//final class ChoiceMessageCell: UITableViewCell {
//    static let reuseId = "ChoiceMessageCell"
//
//    private let bubbleView = UIView()
//    private let messageLabel = UILabel()
//    private let stack = UIStackView()
//    private let leftButton = UIButton(type: .system)
//    private let rightButton = UIButton(type: .system)
//
//    weak var delegate: ChoiceMessageCellDelegate?
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setup()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setup()
//    }
//
//    private func setup() {
//        backgroundColor = .clear
//        contentView.backgroundColor = .clear
//        selectionStyle = .none
//
//        bubbleView.translatesAutoresizingMaskIntoConstraints = false
//        bubbleView.backgroundColor = UIColor(white: 0.93, alpha: 1)
//        bubbleView.layer.cornerRadius = 14
//        contentView.addSubview(bubbleView)
//
//        messageLabel.translatesAutoresizingMaskIntoConstraints = false
//        messageLabel.numberOfLines = 0
//        messageLabel.font = UIFont.systemFont(ofSize: 16)
//        messageLabel.textColor = .black
//        bubbleView.addSubview(messageLabel)
//
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.axis = .horizontal
//        stack.spacing = 12
//        stack.alignment = .center
//        bubbleView.addSubview(stack)
//
//        configureButton(leftButton)
//        configureButton(rightButton)
//        stack.addArrangedSubview(leftButton)
//        stack.addArrangedSubview(rightButton)
//
//        NSLayoutConstraint.activate([
//            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
//            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12),
//
//            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
//            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
//            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
//
//            stack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
//            stack.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 12),
//            stack.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
//            stack.trailingAnchor.constraint(lessThanOrEqualTo: bubbleView.trailingAnchor, constant: -12)
//        ])
//    }
//
//    private func configureButton(_ button: UIButton) {
//        if #available(iOS 15.0, *) {
//            var config = UIButton.Configuration.filled()
//            config.cornerStyle = .capsule
//            config.baseBackgroundColor = UIColor(red: 36/255, green: 64/255, blue: 110/255, alpha: 1)
//            config.baseForegroundColor = .white
//            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
//            button.configuration = config
//        } else {
//            button.layer.cornerRadius = 18
//            button.backgroundColor = UIColor(red: 36/255, green: 64/255, blue: 110/255, alpha: 1)
//            button.setTitleColor(.white, for: .normal)
//        }
//
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
//        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
//    }
//
//    func configure(with model: ChatMessage) {
//        messageLabel.text = model.text
//        if let choices = model.choices {
//            leftButton.setTitle(choices.count > 0 ? choices[0] : "", for: .normal)
//            rightButton.setTitle(choices.count > 1 ? choices[1] : "", for: .normal)
//        }
//    }
//
//    @objc private func buttonTapped(_ sender: UIButton) {
//        guard let title = sender.title(for: .normal) else { return }
//        delegate?.choiceMessageCell(self, didSelectChoice: title)
//    }
//}

