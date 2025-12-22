//
//  NotificationCell.swift
//  Cloudyyy_App
//
//  Created by user@5 on 13/11/25.
//

import UIKit

final class NotificationCell: UITableViewCell {

    static let reuseIdentifier = "NotificationCell"

    // Rounded container inside the cell to create spacing between rows
    private let roundedBackground: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 12
        v.clipsToBounds = true
        // subtle translucent fill so it reads over the dark gradient
        v.backgroundColor = UIColor(white: 1.0, alpha: 0.04)
        return v
    }()

    private let iconContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 24
        v.layer.masksToBounds = true
        return v
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    private let unreadDot: UIView = {
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = .systemRed
        dot.layer.cornerRadius = 5
        dot.isHidden = true
        // border so it's visible on light/dark backgrounds
        dot.layer.borderWidth = 1
        dot.layer.borderColor = UIColor.black.withAlphaComponent(0.25).cgColor
        return dot
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.preferredFont(forTextStyle: .headline)
        lbl.textColor = .white
        lbl.numberOfLines = 1
        return lbl
    }()

    private let messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.preferredFont(forTextStyle: .subheadline)
        lbl.textColor = UIColor.white.withAlphaComponent(0.75)
        lbl.numberOfLines = 2
        return lbl
    }()

    private let timeLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.preferredFont(forTextStyle: .footnote)
        lbl.textColor = UIColor.white.withAlphaComponent(0.6)
        lbl.setContentCompressionResistancePriority(.required, for: .horizontal)
        return lbl
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear          // show gradient behind
        contentView.backgroundColor = .clear
        selectionStyle = .none            // use custom selection if needed
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(roundedBackground)
        roundedBackground.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        roundedBackground.addSubview(unreadDot)
        roundedBackground.addSubview(titleLabel)
        roundedBackground.addSubview(messageLabel)
        roundedBackground.addSubview(timeLabel)

        // Rounded background inset from cell edges to create spacing
        NSLayoutConstraint.activate([
            roundedBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            roundedBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            roundedBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            roundedBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            // Icon container
            iconContainer.leadingAnchor.constraint(equalTo: roundedBackground.leadingAnchor, constant: 12),
            iconContainer.centerYAnchor.constraint(equalTo: roundedBackground.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),

            // Icon image
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 26),
            iconImageView.heightAnchor.constraint(equalToConstant: 26),

            // unread dot
            unreadDot.topAnchor.constraint(equalTo: iconContainer.topAnchor, constant: -4),
            unreadDot.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: -12),
            unreadDot.widthAnchor.constraint(equalToConstant: 10),
            unreadDot.heightAnchor.constraint(equalToConstant: 10),

            // Title
            titleLabel.topAnchor.constraint(equalTo: roundedBackground.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8),

            // Message
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: roundedBackground.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: roundedBackground.bottomAnchor, constant: -12),

            // Time
            timeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: roundedBackground.trailingAnchor, constant: -12)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // keep icon container subtle on top of gradient
        iconContainer.backgroundColor = UIColor.white.withAlphaComponent(0.08)
    }

    // MARK: - Configure

    // ... (Your Init and Setup code remains exactly the same) ...

        // MARK: - Configure

        func configure(with model: AppNotification) {
            titleLabel.text = model.category
            messageLabel.text = model.message
            timeLabel.text = model.timeAgo
            unreadDot.isHidden = !model.isUnread

            // 1. Set the Icon
            let configImage = UIImage(systemName: model.symbolName) ?? UIImage(systemName: "bell")
            iconImageView.image = configImage

            // 2. Apply Dynamic Styling (Colors)
            let style = styleForCategory(model.category)
            
            // Icon color
            iconImageView.tintColor = style.color
            
            // Container background (same color but transparent)
            iconContainer.backgroundColor = style.color.withAlphaComponent(0.15)
            
            // Unread state opacity
            roundedBackground.alpha = model.isUnread ? 1.0 : 0.6
            
            // Optional: Highlight border for critical items
            if model.category == "Approval Needed" && model.isUnread {
                roundedBackground.layer.borderWidth = 1
                roundedBackground.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.3).cgColor
            } else {
                roundedBackground.layer.borderWidth = 0
            }
        }
        
        // MARK: - Private Styling Helper
        
        private func styleForCategory(_ category: String) -> (color: UIColor, effect: String) {
            switch category {
            case "Approval Needed":
                return (.systemOrange, "Critical") // Attention grabbing
                
            case "Reward Redeemed":
                return (.systemYellow, "Gold") // Premium feel
                
            case "On Fire!", "Dream Goal":
                return (.systemPurple, "Magic") // Special/Gamified
                
            case "Task Completed":
                return (.systemGreen, "Success") // Positive reinforcement
                
            case "Missed Task":
                return (.systemRed, "Alert") // Warning
                
            default:
                return (.white, "Standard") // Default system notification
            }
        }
    }
