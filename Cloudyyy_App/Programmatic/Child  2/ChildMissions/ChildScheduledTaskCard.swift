// TaskDisplayPanel.swift
// Cloudyyy_App
//
// Simple card view to display a schedule task.

import UIKit

// RENAMED CLASS HERE
final class KidAgendaItemPanel: UIView {

    private let accentStripeView = UIView()
    private let headingLabel = UILabel()
    private let scheduleTimeLabel = UILabel()
    private let blurContainerView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))

    // The rest of the implementation is correct, using 'entry: AgendaEntry'
    init(entry: AgendaEntry) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 12
        clipsToBounds = true
        backgroundColor = .clear

        // stripe
        accentStripeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(accentStripeView)

        // container for labels (glass)
        blurContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurContainerView)

        // labels
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        headingLabel.textColor = .white
        headingLabel.text = entry.title

        scheduleTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduleTimeLabel.font = .systemFont(ofSize: 13)
        scheduleTimeLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        scheduleTimeLabel.text = entry.time

        blurContainerView.contentView.addSubview(headingLabel)
        blurContainerView.contentView.addSubview(scheduleTimeLabel)

        NSLayoutConstraint.activate([
            accentStripeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            accentStripeView.topAnchor.constraint(equalTo: topAnchor),
            accentStripeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            accentStripeView.widthAnchor.constraint(equalToConstant: 6),

            blurContainerView.leadingAnchor.constraint(equalTo: accentStripeView.trailingAnchor),
            blurContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurContainerView.topAnchor.constraint(equalTo: topAnchor),
            blurContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            headingLabel.leadingAnchor.constraint(equalTo: blurContainerView.contentView.leadingAnchor, constant: 12),
            headingLabel.trailingAnchor.constraint(lessThanOrEqualTo: blurContainerView.contentView.trailingAnchor, constant: -12),
            headingLabel.topAnchor.constraint(equalTo: blurContainerView.contentView.topAnchor, constant: 14),

            scheduleTimeLabel.leadingAnchor.constraint(equalTo: blurContainerView.contentView.leadingAnchor, constant: 12),
            scheduleTimeLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 6),
            scheduleTimeLabel.bottomAnchor.constraint(lessThanOrEqualTo: blurContainerView.contentView.bottomAnchor, constant: -12)
        ])

        // status color mapping
        let normalizedStatus = entry.status.lowercased()
        if normalizedStatus.contains("completed") {
            accentStripeView.backgroundColor = UIColor.systemGreen
        } else if normalizedStatus.contains("progress") || normalizedStatus.contains("in progress") {
            accentStripeView.backgroundColor = UIColor.systemYellow
        } else {
            // not completed / not started
            accentStripeView.backgroundColor = UIColor.systemRed
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}
