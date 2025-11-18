//
//  ApprovalCardView.swift
//  Cloudyyy_App
//
//  Created by user@10 on 16/11/25.
//

import Foundation
import UIKit

final class ApprovalCardView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let starLabel = UILabel()
    private let tagLabel = UILabel()

    init(title: String, subtitle: String, stars: Int, tagType: String) {
        super.init(frame: .zero)
        setupUI()

        titleLabel.text = title
        subtitleLabel.text = subtitle

        // If stars = 0 → hide star label (schedule page)
        if stars > 0 {
            starLabel.text = "\(stars) ⭐️"
            starLabel.isHidden = false
        } else {
            starLabel.isHidden = true
        }

        tagLabel.text = tagType.uppercased()
        applyTagStyle(tagType)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        layer.cornerRadius = 14
        backgroundColor = UIColor.white.withAlphaComponent(0.08)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 84).isActive = true

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white

        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.75)

        starLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        starLabel.textColor = .white
        starLabel.textAlignment = .right

        tagLabel.font = .systemFont(ofSize: 11, weight: .bold)
        tagLabel.textColor = .white
        tagLabel.textAlignment = .center
        tagLabel.layer.cornerRadius = 6
        tagLabel.clipsToBounds = true
        tagLabel.setContentHuggingPriority(.required, for: .horizontal)
        tagLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let container = UIStackView(arrangedSubviews: [
            makeTextColumn(),
            starLabel,
            tagLabel
        ])
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        addSubview(container)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            container.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func makeTextColumn() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }

    private func applyTagStyle(_ type: String) {
        switch type.lowercased() {
        case "pending":
            tagLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.8)
        case "approved":
            tagLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.8)
        case "redeemed":
            tagLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        case "in progress":
            tagLabel.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.6)
        case "completed":
            tagLabel.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.7)
        default:
            tagLabel.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        }
    }
}
