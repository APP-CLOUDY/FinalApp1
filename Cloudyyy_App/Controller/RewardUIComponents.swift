//
//  RewardUIComponents.swift
//  Cloudyyy_App
//
//  Created by user@10 on 16/11/25.
//

import Foundation
import UIKit

// -------------------------------------------------
// MARK: - Shared UI Components (Visible to all controllers)
// -------------------------------------------------

// Section Label
final class SectionLabel: UIView {
    init(text: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false

        addSubview(lbl)

        NSLayoutConstraint.activate([
            lbl.leadingAnchor.constraint(equalTo: leadingAnchor),
            lbl.topAnchor.constraint(equalTo: topAnchor),
            lbl.bottomAnchor.constraint(equalTo: bottomAnchor),
            lbl.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// Large card
final class RewardLargeCard: UIView {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let pointsLabel = UILabel()
    var onTap: (() -> Void)?

    init(item: RewardDetailItem) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 14
        layer.masksToBounds = true
        backgroundColor = UIColor(white: 1, alpha: 0.03)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        if let name = item.imageName, let img = UIImage(named: name) {
            imageView.image = img
        } else {
            imageView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
        }

        imageView.translatesAutoresizingMaskIntoConstraints = false

        let bottom = UIView()
        bottom.backgroundColor = UIColor(white: 0, alpha: 0.3)
        bottom.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        pointsLabel.text = "\(item.points) Points"
        pointsLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        pointsLabel.textColor = .white
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(bottom)
        bottom.addSubview(titleLabel)
        bottom.addSubview(pointsLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottom.topAnchor),

            bottom.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottom.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottom.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottom.heightAnchor.constraint(equalToConstant: 70),

            titleLabel.leadingAnchor.constraint(equalTo: bottom.leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: bottom.topAnchor, constant: 8),

            pointsLabel.leadingAnchor.constraint(equalTo: bottom.leadingAnchor, constant: 12),
            pointsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
    }

    @objc private func didTap() { onTap?() }
    required init?(coder: NSCoder) { fatalError() }
}

// Small card
final class RewardSmallCard: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
    var onTap: (() -> Void)?

    init(item: RewardDetailItem) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 12
        backgroundColor = UIColor(white: 1, alpha: 0.03)
        clipsToBounds = true

        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.text = item.subtitle
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        chevron.tintColor = UIColor.white.withAlphaComponent(0.6)
        chevron.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(chevron)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),

            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 18)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
    }

    @objc private func didTap() { onTap?() }
    required init?(coder: NSCoder) { fatalError() }
}

// Shared Detail
final class RewardDetailViewController: UIViewController {
    private let item: RewardDetailItem

    init(item: RewardDetailItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
        title = item.title
        view.backgroundColor = .systemBackground
    }

    required init?(coder: NSCoder) { fatalError() }
}

// Search Bar
final class SimpleSearchBar: UIView {
    let textField = UITextField()

    init() {
        super.init(frame: .zero)
        layer.cornerRadius = 10
        backgroundColor = UIColor(white: 1, alpha: 0.03)
        translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = UIColor.white.withAlphaComponent(0.6)
        icon.translatesAutoresizingMaskIntoConstraints = false

        textField.placeholder = "Search"
        textField.textColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false

        addSubview(icon)
        addSubview(textField)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),

            textField.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

