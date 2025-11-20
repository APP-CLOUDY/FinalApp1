import UIKit

final class StreakCardView: UIView {

    private let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 24 // Match modern aesthetic
        v.backgroundColor = UIColor(white: 1.0, alpha: 0.10)
        return v
    }()

    private let cloudImage: UIImageView = {
        // Larger Icon - Using 'named' for custom assets
        let image = UIImage(named: "cloudyy_logo") ?? UIImage(systemName: "cloud.fill")
        
        let iv = UIImageView(image: image)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1) // Light Blue Cloud
        return iv
    }()

    private let streakNumber: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "4"
        lb.font = .systemFont(ofSize: 52, weight: .heavy) // Much larger font
        lb.textColor = .white
        return lb
    }()

    private let streakText: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Day streak"
        lb.font = .systemFont(ofSize: 18, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.9)
        return lb
    }()

    private let daysStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
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

            // Cloud Icon (Top Left) - INCREASED SIZE HERE
            cloudImage.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            cloudImage.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            cloudImage.widthAnchor.constraint(equalToConstant: 80),  // Increased from 60 to 80
            cloudImage.heightAnchor.constraint(equalToConstant: 80), // Increased from 60 to 80

            // Number (Right of Cloud)
            streakNumber.leadingAnchor.constraint(equalTo: cloudImage.trailingAnchor, constant: 16),
            streakNumber.centerYAnchor.constraint(equalTo: cloudImage.centerYAnchor, constant: -2), // Slightly adjust for baseline

            // "Day streak" Text (Next to number)
            streakText.leadingAnchor.constraint(equalTo: streakNumber.trailingAnchor, constant: 8),
            streakText.lastBaselineAnchor.constraint(equalTo: streakNumber.lastBaselineAnchor, constant: -8),

            // Days Stack (Bottom area)
            daysStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            daysStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            daysStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            daysStack.heightAnchor.constraint(equalToConstant: 40)
        ])

        setupDays()
    }
    
    private func setupDays() {
        let days = ["M","T","W","T","F","S","S"]
        let dayStates = [true, true, true, true, false, false, false]

        for i in 0..<days.count {
            daysStack.addArrangedSubview(createDayView(day: days[i], isFilled: dayStates[i]))
        }
    }
    
    private func createDayView(day: String, isFilled: Bool) -> UIView {
        let dotSize: CGFloat = 22 // Larger dots
        
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: dotSize).isActive = true
        dot.heightAnchor.constraint(equalToConstant: dotSize).isActive = true
        dot.layer.cornerRadius = dotSize / 2
        
        if isFilled {
            dot.backgroundColor = UIColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 1)
        } else {
            dot.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        }
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = day
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white.withAlphaComponent(0.7)
        
        let wrapper = UIStackView(arrangedSubviews: [dot, label])
        wrapper.axis = .vertical
        wrapper.alignment = .center
        wrapper.spacing = 6
        return wrapper
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
