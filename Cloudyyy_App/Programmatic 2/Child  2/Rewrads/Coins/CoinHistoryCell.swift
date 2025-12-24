//
//  CoinHistoryCell.swift
//  Cloudyyy_App
//

import UIKit

final class CoinHistoryCell: UITableViewCell {

    private let card = UIView()
    private let titleLabel = UILabel()
    private let pointsLabel = UILabel()
    private let dateLabel = UILabel()
    private let starIcon = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        // Card
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        card.layer.cornerRadius = 18
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.25
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.addSubview(card)

        // Star icon
        starIcon.translatesAutoresizingMaskIntoConstraints = false
        starIcon.text = "⭐️"
        starIcon.font = .systemFont(ofSize: 26)
        card.addSubview(starIcon)

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        card.addSubview(titleLabel)

        // Points
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        pointsLabel.font = .systemFont(ofSize: 18, weight: .bold)
        pointsLabel.textColor = UIColor(red: 255/255, green: 204/255, blue: 92/255, alpha: 1)
        card.addSubview(pointsLabel)

        // Date
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        card.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            starIcon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            starIcon.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: starIcon.trailingAnchor, constant: 12),

            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            pointsLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            pointsLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
    }

    func configure(title: String, points: Int, date: String) {
        titleLabel.text = title
        pointsLabel.text = "+\(points)"
        dateLabel.text = date
    }
}

