//
//  StreakCardView.swift.swift
//  Cloudyyy_App
//
//  Created by user@5 on 16/11/25.
//

//
//  StreakCardView.swift
//  Cloudyyy_App
//
//  Created by Gemini
//
import UIKit

final class StreakCardView: UIView {
    
    // ... (All the code for StreakCardView from your original file) ...
    // (I've copied it here for completeness)

    private let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 14
        v.backgroundColor = UIColor(white: 1.0, alpha: 0.06)
        return v
    }()

    private let cloudImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "cloudCute") ?? UIImage(systemName: "cloud.fill"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let streakNumber: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "4"
        lb.font = .systemFont(ofSize: 36, weight: .bold)
        lb.textColor = .white
        return lb
    }()

    private let streakText: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Day streak"
        lb.font = .systemFont(ofSize: 14, weight: .semibold)
        lb.textColor = .white
        return lb
    }()

    private let daysStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .equalSpacing // Use equalSpacing to fill the width
        sv.alignment = .center
        return sv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(container)
        container.addSubview(cloudImage)
        container.addSubview(streakNumber)
        container.addSubview(streakText)
        container.addSubview(daysStack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            cloudImage.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            cloudImage.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            cloudImage.widthAnchor.constraint(equalToConstant: 64),
            cloudImage.heightAnchor.constraint(equalToConstant: 64),

            streakNumber.leadingAnchor.constraint(equalTo: cloudImage.trailingAnchor, constant: 12),
            streakNumber.topAnchor.constraint(equalTo: container.topAnchor, constant: 22),

            streakText.leadingAnchor.constraint(equalTo: streakNumber.trailingAnchor, constant: 8),
            streakText.centerYAnchor.constraint(equalTo: streakNumber.centerYAnchor),

            daysStack.leadingAnchor.constraint(equalTo: streakNumber.leadingAnchor),
            daysStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16), // Pin to trailing
            daysStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
        ])

        // populate days
        let days = ["M","T","W","T","F","S","S"]
        let dayStates = [true, true, true, true, false, false, false] // Based on 4-day streak

        for i in 0..<days.count {
            daysStack.addArrangedSubview(createDayView(day: days[i], isFilled: dayStates[i]))
        }
    }
    
    private func createDayView(day: String, isFilled: Bool) -> UIView {
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 18).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 18).isActive = true
        dot.layer.cornerRadius = 9
        
        if isFilled {
            dot.backgroundColor = UIColor(red: 1.0, green: 0.62, blue: 0.0, alpha: 1)
        } else {
            dot.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        }
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = day
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .white
        
        let wrapper = UIStackView(arrangedSubviews: [dot, label])
        wrapper.axis = .vertical
        wrapper.alignment = .center
        wrapper.spacing = 4
        return wrapper
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
