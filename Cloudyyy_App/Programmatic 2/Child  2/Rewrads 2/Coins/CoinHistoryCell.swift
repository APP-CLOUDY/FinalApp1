//
//  CoinHistoryCell.swift
//  Cloudyyy_App
//

import UIKit

final class CoinHistoryCell: UITableViewCell {

    // MARK: - UI
    private let card = UIView()

    // Left (Stars)
    private let starIcon = UIImageView()
    private let pointsLabel = UILabel()

    // Right (Content)
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let contentStack = UIStackView()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        // Card
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(
            red: 30/255,
            green: 35/255,
            blue: 60/255,
            alpha: 1
        )
        card.layer.cornerRadius = 16
        contentView.addSubview(card)

        // ⭐ Star Icon
        starIcon.translatesAutoresizingMaskIntoConstraints = false
        starIcon.image = UIImage(systemName: "star.fill")
        starIcon.tintColor = UIColor(
            red: 255/255,
            green: 204/255,
            blue: 92/255,
            alpha: 1
        )

        // ⭐ Points
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        pointsLabel.font = .systemFont(ofSize: 16, weight: .bold)
        pointsLabel.textColor = starIcon.tintColor
        pointsLabel.textAlignment = .left

        // Title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white

        // Date pill
        dateLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        dateLabel.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        dateLabel.layer.cornerRadius = 10
        dateLabel.clipsToBounds = true
        dateLabel.textAlignment = .center

        // Right Stack
        contentStack.axis = .vertical
        contentStack.spacing = 6
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(dateLabel)

        // Add subviews
        card.addSubview(starIcon)
        card.addSubview(pointsLabel)
        card.addSubview(contentStack)

        NSLayoutConstraint.activate([
            // Card
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // ⭐ Icon
            starIcon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            starIcon.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            starIcon.widthAnchor.constraint(equalToConstant: 20),
            starIcon.heightAnchor.constraint(equalToConstant: 20),

            // ⭐ Points
            pointsLabel.leadingAnchor.constraint(equalTo: starIcon.trailingAnchor, constant: 6),
            pointsLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            pointsLabel.widthAnchor.constraint(equalToConstant: 40),

            // Content Stack
            contentStack.leadingAnchor.constraint(equalTo: pointsLabel.trailingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            contentStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            // Date height
            dateLabel.heightAnchor.constraint(equalToConstant: 20),
            dateLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])
    }

    // MARK: - Configure
    func configure(title: String, points: Int, date: String) {
        titleLabel.text = title
        pointsLabel.text = "+\(points)"
        dateLabel.text = "  \(date)  "
    }
}

