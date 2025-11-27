//import UIKit
//
//final class ApprovalCell: UITableViewCell {
//
//    // MARK: - Callbacks
//    var onApproveTapped: (() -> Void)?
//    var onDeclineTapped: (() -> Void)?
//
//    // MARK: - UI Components
//    private let containerView = UIView()
//    
//    // Left Icon
//    private let iconView = UIView()
//    private let iconImageView = UIImageView()
//    
//    // Text Labels
//    private let titleLabel = UILabel()
//    private let subtitleLabel = UILabel()
//    private let dateLabel = UILabel()
//    private let pointsLabel = UILabel()
//    
//    // Buttons
//    private let buttonStack = UIStackView()
//    private let approveButton = UIButton(type: .system)
//    private let declineButton = UIButton(type: .system)
//
//    // Constraints for dynamic sizing
//    private var containerBottomToButtons: NSLayoutConstraint?
//    private var containerBottomToDate: NSLayoutConstraint?
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupUI() {
//        backgroundColor = .clear
//        selectionStyle = .none
//
//        // 1. Card Container - COLOR CHANGED HERE
//        // Matches the dark navy/purple from your screenshot
//        containerView.backgroundColor = UIColor(red: 40/255, green: 45/255, blue: 65/255, alpha: 0.7)
//        containerView.layer.cornerRadius = 16
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(containerView)
//
//        // 2. Icon (Circle Background)
//        iconView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
//        iconView.layer.cornerRadius = 20
//        iconView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(iconView)
//        
//        iconImageView.image = UIImage(systemName: "star.circle.fill")
//        iconImageView.tintColor = .white
//        iconImageView.contentMode = .scaleAspectFit
//        iconImageView.translatesAutoresizingMaskIntoConstraints = false
//        iconView.addSubview(iconImageView)
//
//        // 3. Labels
//        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
//        titleLabel.textColor = .white
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
//        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
//        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
//        dateLabel.textColor = UIColor.white.withAlphaComponent(0.5)
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        pointsLabel.font = .systemFont(ofSize: 16, weight: .bold)
//        pointsLabel.textColor = .systemYellow
//        pointsLabel.textAlignment = .right
//        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        containerView.addSubview(titleLabel)
//        containerView.addSubview(subtitleLabel)
//        containerView.addSubview(dateLabel)
//        containerView.addSubview(pointsLabel)
//
//        // 4. Buttons
//        setupButtons()
//
//        // 5. Layout Constraints
//        NSLayoutConstraint.activate([
//            // Container margins
//            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//
//            // Icon (Top Left)
//            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
//            iconView.widthAnchor.constraint(equalToConstant: 40),
//            iconView.heightAnchor.constraint(equalToConstant: 40),
//            
//            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
//            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
//            iconImageView.widthAnchor.constraint(equalToConstant: 24),
//            iconImageView.heightAnchor.constraint(equalToConstant: 24),
//
//            // Title & Points
//            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
//            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
//            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: pointsLabel.leadingAnchor, constant: -8),
//
//            pointsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            pointsLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
//
//            // Subtitle
//            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//
//            // Date
//            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            dateLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
//            
//            // Button Stack position
//            buttonStack.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
//            buttonStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            buttonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            buttonStack.heightAnchor.constraint(equalToConstant: 40)
//        ])
//        
//        // Dynamic Bottom Constraints
//        containerBottomToButtons = containerView.bottomAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 16)
//        containerBottomToDate = containerView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16)
//    }
//
//    private func setupButtons() {
//        // Decline
//        declineButton.setTitle("Decline", for: .normal)
//        declineButton.setTitleColor(.white, for: .normal)
//        declineButton.backgroundColor = UIColor(red: 235/255, green: 87/255, blue: 87/255, alpha: 1) // Red
//        declineButton.layer.cornerRadius = 10
//        declineButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
//        declineButton.addTarget(self, action: #selector(handleDecline), for: .touchUpInside)
//
//        // Approve
//        approveButton.setTitle("Approve", for: .normal)
//        approveButton.setTitleColor(.white, for: .normal)
//        approveButton.backgroundColor = UIColor(red: 47/255, green: 128/255, blue: 237/255, alpha: 1) // Blue
//        approveButton.layer.cornerRadius = 10
//        approveButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
//        approveButton.addTarget(self, action: #selector(handleApprove), for: .touchUpInside)
//
//        buttonStack.axis = .horizontal
//        buttonStack.spacing = 12
//        buttonStack.distribution = .fillEqually
//        buttonStack.translatesAutoresizingMaskIntoConstraints = false
//        
//        buttonStack.addArrangedSubview(declineButton)
//        buttonStack.addArrangedSubview(approveButton)
//        
//        containerView.addSubview(buttonStack)
//    }
//
//    func configure(title: String, subtitle: String, date: String, points: String, showButtons: Bool) {
//        titleLabel.text = title
//        subtitleLabel.text = subtitle
//        dateLabel.text = date
//        pointsLabel.text = points
//
//        if showButtons {
//            buttonStack.isHidden = false
//            containerBottomToDate?.isActive = false
//            containerBottomToButtons?.isActive = true
//        } else {
//            buttonStack.isHidden = true
//            containerBottomToButtons?.isActive = false
//            containerBottomToDate?.isActive = true
//        }
//        
//        if points.contains("-") {
//            pointsLabel.textColor = UIColor(red: 255/255, green: 107/255, blue: 107/255, alpha: 1)
//            iconImageView.image = UIImage(systemName: "gift.fill")
//        } else {
//            pointsLabel.textColor = .systemYellow
//            iconImageView.image = UIImage(systemName: "checkmark.circle.fill")
//        }
//    }
//
//    @objc private func handleApprove() {
//        animateClick(approveButton)
//        onApproveTapped?()
//    }
//
//    @objc private func handleDecline() {
//        animateClick(declineButton)
//        onDeclineTapped?()
//    }
//    
//    private func animateClick(_ view: UIView) {
//        UIView.animate(withDuration: 0.1, animations: {
//            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//        }) { _ in
//            UIView.animate(withDuration: 0.1) {
//                view.transform = .identity
//            }
//        }
//        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//    }
//}
