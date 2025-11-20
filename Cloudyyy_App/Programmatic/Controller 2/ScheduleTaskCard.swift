//
//  ScheduleTaskCard.swift
//  Cloudyyy_App
//
//  Created by user@10 on 16/11/25.
//

import Foundation
//  ScheduleTaskCard.swift
//  Cloudyyy_App
//
//  Simple card view to display a schedule task.
//  Layout: color stripe (left) + title / time stacked on right.
//  No kid name as you requested.

import UIKit

final class ScheduleTaskCard: UIView {

    private let leadingStripe = UIView()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let container = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))

    init(task: ScheduleTask) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 12
        clipsToBounds = true
        backgroundColor = .clear

        // stripe
        leadingStripe.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leadingStripe)

        // container for labels (glass)
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        // labels
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.text = task.title

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 13)
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        timeLabel.text = task.time

        container.contentView.addSubview(titleLabel)
        container.contentView.addSubview(timeLabel)

        NSLayoutConstraint.activate([
            leadingStripe.leadingAnchor.constraint(equalTo: leadingAnchor),
            leadingStripe.topAnchor.constraint(equalTo: topAnchor),
            leadingStripe.bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingStripe.widthAnchor.constraint(equalToConstant: 6),

            container.leadingAnchor.constraint(equalTo: leadingStripe.trailingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: container.contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.contentView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: container.contentView.topAnchor, constant: 14),

            timeLabel.leadingAnchor.constraint(equalTo: container.contentView.leadingAnchor, constant: 12),
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            timeLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.contentView.bottomAnchor, constant: -12)
        ])

        // status color mapping
        let status = task.status.lowercased()
        if status.contains("completed") {
            leadingStripe.backgroundColor = UIColor.systemGreen
        } else if status.contains("progress") || status.contains("in progress") {
            leadingStripe.backgroundColor = UIColor.systemYellow
        } else {
            // not completed / not started
            leadingStripe.backgroundColor = UIColor.systemRed
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}
