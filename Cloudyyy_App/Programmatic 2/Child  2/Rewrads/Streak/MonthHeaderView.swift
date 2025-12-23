//
//  MonthHeaderView.swift
//  Cloudyyy_App
//
//  Created by user@10 on 19/12/25.
//

import Foundation
import UIKit

final class MonthHeaderView: UIView {

    var onPrevious: (() -> Void)?
    var onNext: (() -> Void)?

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 18, weight: .semibold)
        lb.textColor = .white
        return lb
    }()

    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        prevButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)

        prevButton.tintColor = .white
        nextButton.tintColor = .white

        prevButton.addTarget(self, action: #selector(prevTap), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTap), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [prevButton, titleLabel, nextButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalCentering

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }

    func set(month: Int, year: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let date = Calendar.current.date(from: DateComponents(year: year, month: month))!
        titleLabel.text = formatter.string(from: date).uppercased()
    }

    @objc private func prevTap() { onPrevious?() }
    @objc private func nextTap() { onNext?() }
}

