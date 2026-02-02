//
//  StreakCardView.swift
//  Cloudyyy_App
//
//  Created by user@10 on 19/12/25.
//

import Foundation
import UIKit

final class StreakCardView: UIView {
    
    var onTap: (() -> Void)?

    @objc private func handleTap() {
        onTap?()
    }

    private let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        // Updated background color to #3C4558 (RGB: 60, 69, 88)
        v.backgroundColor = UIColor(red: 60/255, green: 69/255, blue: 88/255, alpha: 1.0)
        v.layer.cornerRadius = 24
        return v
    }()

    private let cloudImage: UIImageView = {
        // Using the cloud logo
        let image = (UIImage(named: "cloudrevhub") ?? UIImage(systemName: "cloud.fill"))
        
        let iv = UIImageView(image: image)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        
        // Fallback tint if custom asset is missing
        if UIImage(named: "cloudyy_logo") == nil {
            iv.tintColor = .systemGray4
        }
        return iv
    }()

    private let streakNumber: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "0" // Default to 0 instead of empty string
        lb.font = .systemFont(ofSize: 40, weight: .bold)
        lb.textColor = .white
        return lb
    }()

    private let streakText: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Day streak"
        lb.font = .systemFont(ofSize: 15, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.8)
        return lb
    }()
    
    // Stack for "4" and "Day streak"
    private let textStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .leading
        sv.spacing = 0 // Reduced spacing
        return sv
    }()

    private let daysStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .equalSpacing // Distribute evenly
        sv.alignment = .top
        sv.spacing = 10 // Spacing between day columns
        return sv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Enforce the requested size
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: 365).isActive = true
        self.heightAnchor.constraint(equalToConstant: 143).isActive = true
        
        // ✅ Enable tap on the card
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true

        
        addSubview(container)
        
        // Assemble Text Stack
        textStack.addArrangedSubview(streakNumber)
        textStack.addArrangedSubview(streakText)
        
        container.addSubview(cloudImage)
        container.addSubview(textStack)
        container.addSubview(daysStack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Cloud Image - Adjusted size to 80x80 to fit in 143 height
            cloudImage.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            cloudImage.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            cloudImage.widthAnchor.constraint(equalToConstant: 100),
            cloudImage.heightAnchor.constraint(equalToConstant: 100),

            // Text Stack (Number + Label) - Adjusted top constraint
            textStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            textStack.leadingAnchor.constraint(equalTo: cloudImage.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),

            // Days Stack - Compact vertical spacing
            daysStack.topAnchor.constraint(equalTo: textStack.bottomAnchor, constant: 12),
            daysStack.leadingAnchor.constraint(equalTo: cloudImage.trailingAnchor, constant: 16),
            daysStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            daysStack.heightAnchor.constraint(equalToConstant: 45)
        ])

        setupDays()
        
        // ✅ Set the requested Streak Value of 2 immediately
        setStreak(2)
    }
    
    private func setupDays() {
        let days = ["M","T","W","T","F","S","S"]

        for day in days {
            let view = createDayView(day: day, isFilled: false)
            daysStack.addArrangedSubview(view)
        }
    }

    
    // MARK: - Backend Binding
    func setStreak(_ value: Int) {
        // Checks if the value is 0, allowing you to handle logic if needed.
        // Currently sets the text exactly to the integer provided.
        streakNumber.text = "\(value)"
    }
    
    func setWeekStatus(_ states: [Bool]) {
        daysStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let days = ["M","T","W","T","F","S","S"]

        for i in 0..<days.count {
            let filled = i < states.count ? states[i] : false
            let view = createDayView(day: days[i], isFilled: filled)
            daysStack.addArrangedSubview(view)
        }
    }


    
    private func createDayView(day: String, isFilled: Bool) -> UIView {
        let circleSize: CGFloat = 16
        
        // 1. The Circle
        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.widthAnchor.constraint(equalToConstant: circleSize).isActive = true
        circle.heightAnchor.constraint(equalToConstant: circleSize).isActive = true
        circle.layer.cornerRadius = circleSize / 2
        
        if isFilled {
            // Orange Background
            circle.backgroundColor = UIColor(red: 1.0, green: 0.58, blue: 0.2, alpha: 1.0) // Vivid Orange
            circle.layer.borderWidth = 0
            
            // Add Checkmark
            let config = UIImage.SymbolConfiguration(pointSize: 8, weight: .bold)
            let checkmark = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: config))
            checkmark.translatesAutoresizingMaskIntoConstraints = false
            checkmark.tintColor = .white
            
            circle.addSubview(checkmark)
            NSLayoutConstraint.activate([
                checkmark.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
                checkmark.centerYAnchor.constraint(equalTo: circle.centerYAnchor)
            ])
        } else {
            // Transparent with Grey Border
            circle.backgroundColor = .clear
            circle.layer.borderColor = UIColor.lightGray.cgColor
            circle.layer.borderWidth = 2
        }
        
        // 2. The Label (Below the circle)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = day
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        
        // 3. Stack them vertically
        let wrapper = UIStackView(arrangedSubviews: [circle, label])
        wrapper.axis = .vertical
        wrapper.alignment = .center
        wrapper.spacing = 6
        
        return wrapper
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
