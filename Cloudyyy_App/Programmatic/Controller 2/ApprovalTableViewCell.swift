import UIKit

class ApprovalCell: UITableViewCell {

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let dateLabel = UILabel()
    private let pointsLabel = UILabel()
    private let declineButton = UIButton(type: .system)
    private let approveButton = UIButton(type: .system)

    // Callbacks
    var onApproveTapped: (() -> Void)?
    var onDeclineTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        // Card container
        containerView.backgroundColor = UIColor(red: 43/255, green: 46/255, blue: 74/255, alpha: 1)
        containerView.layer.cornerRadius = 14
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 3
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        // Labels
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white

        subtitleLabel.font = UIFont.systemFont(ofSize: 13.5)
        subtitleLabel.textColor = UIColor(white: 0.85, alpha: 1)

        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = UIColor(white: 0.65, alpha: 1)

        pointsLabel.font = UIFont.boldSystemFont(ofSize: 14.5)
        pointsLabel.textColor = .systemYellow
        pointsLabel.textAlignment = .right

        // Buttons
        declineButton.setTitle("Decline", for: .normal)
        declineButton.backgroundColor = .systemRed
        declineButton.setTitleColor(.white, for: .normal)
        declineButton.layer.cornerRadius = 9
        declineButton.titleLabel?.font = UIFont.systemFont(ofSize: 13.5, weight: .medium)
        declineButton.addTarget(self, action: #selector(declineTapped), for: .touchUpInside)

        approveButton.setTitle("Approve", for: .normal)
        approveButton.backgroundColor = .systemBlue
        approveButton.setTitleColor(.white, for: .normal)
        approveButton.layer.cornerRadius = 9
        approveButton.titleLabel?.font = UIFont.systemFont(ofSize: 13.5, weight: .medium)
        approveButton.addTarget(self, action: #selector(approveTapped), for: .touchUpInside)

        // Add subviews
        [titleLabel, subtitleLabel, dateLabel, pointsLabel, declineButton, approveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }

        // Constraints
        NSLayoutConstraint.activate([
            // Container padding
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            // Title + Points
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),

            pointsLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            pointsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            // Date
            dateLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 3),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            // Buttons (appear only when needed)
            approveButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            approveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            approveButton.widthAnchor.constraint(equalToConstant: 80),
            approveButton.heightAnchor.constraint(equalToConstant: 30),

            declineButton.centerYAnchor.constraint(equalTo: approveButton.centerYAnchor),
            declineButton.trailingAnchor.constraint(equalTo: approveButton.leadingAnchor, constant: -6),
            declineButton.widthAnchor.constraint(equalToConstant: 80),
            declineButton.heightAnchor.constraint(equalToConstant: 30),

            // Bottom spacing
            containerView.bottomAnchor.constraint(equalTo: approveButton.bottomAnchor, constant: 10)
        ])
    }

    func configure(title: String, subtitle: String, date: String, points: String, showButtons: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        dateLabel.text = date
        pointsLabel.text = points

        approveButton.isHidden = !showButtons
        declineButton.isHidden = !showButtons

        // Dynamic bottom constraint when buttons are hidden
        if showButtons {
            approveButton.isHidden = false
            declineButton.isHidden = false
        } else {
            approveButton.isHidden = true
            declineButton.isHidden = true
        }
    }

    // MARK: - Actions
    @objc private func approveTapped() {
        animateButton(approveButton)
        onApproveTapped?()
    }

    @objc private func declineTapped() {
        animateButton(declineButton)
        onDeclineTapped?()
    }

    // MARK: - Subtle Animation
    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.08,
                       animations: { button.transform = CGAffineTransform(scaleX: 0.94, y: 0.94) },
                       completion: { _ in
            UIView.animate(withDuration: 0.08) { button.transform = .identity }
        })
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
