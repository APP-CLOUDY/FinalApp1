//
//  CoinHistoryCell.swift
//  Cloudyyy_App
//
//  Created by user@10 on 19/12/25.
//

import Foundation
import UIKit

final class CoinHistoryCell: UITableViewCell {

    private let card = UIView()
    private let titleLabel = UILabel()
    private let pointsLabel = UILabel()
    private let dateLabel = UILabel()

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

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        card.layer.cornerRadius = 16
        contentView.addSubview(card)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white

        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        pointsLabel.font = .systemFont(ofSize: 16, weight: .bold)
        pointsLabel.textColor = UIColor(red: 255/255, green: 204/255, blue: 92/255, alpha: 1)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .lightGray

        card.addSubview(titleLabel)
        card.addSubview(pointsLabel)
        card.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            pointsLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            pointsLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
    }

    func configure(title: String, points: Int, date: String) {
        titleLabel.text = title
        pointsLabel.text = "+\(points) ⭐"
        dateLabel.text = date
    }
}

