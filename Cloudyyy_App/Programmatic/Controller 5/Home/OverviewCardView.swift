import UIKit

final class OverviewCardView: UIView {
    
    private let blurEffectView: UIVisualEffectView = {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let containerView = UIView()
    
    // Uses the Full Circle class above
    private let arcView = HomeProgressArcView()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Today's Overview"
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let missionsLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let redeemedLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.6)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let chevron: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = UIColor.white.withAlphaComponent(0.3)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        addSubview(blurEffectView)
        blurEffectView.contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Dark Tint Background
        let bg = UIView()
        bg.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        bg.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.contentView.insertSubview(bg, at: 0)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(missionsLabel)
        containerView.addSubview(redeemedLabel)
        containerView.addSubview(arcView)
        containerView.addSubview(chevron)
        
        arcView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Background
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            bg.topAnchor.constraint(equalTo: topAnchor),
            bg.bottomAnchor.constraint(equalTo: bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Container
            containerView.topAnchor.constraint(equalTo: blurEffectView.contentView.topAnchor, constant: 16),
            containerView.bottomAnchor.constraint(equalTo: blurEffectView.contentView.bottomAnchor, constant: -16),
            containerView.leadingAnchor.constraint(equalTo: blurEffectView.contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: blurEffectView.contentView.trailingAnchor, constant: -16),
            
            // Left Text Column
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            
            missionsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            missionsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            
            redeemedLabel.topAnchor.constraint(equalTo: missionsLabel.bottomAnchor, constant: 6),
            redeemedLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            
            // Chevron (Far Right)
            chevron.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 20),
            
            // Circle Arc (Right Side)
            // MUST be square to look circular
            arcView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arcView.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -20),
            arcView.widthAnchor.constraint(equalToConstant: 80),
            arcView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func configure(missionsDone: Int, missionsTotal: Int, redeemedText: String, progress: CGFloat, animated: Bool) {
        missionsLabel.text = "\(missionsDone)/\(missionsTotal) Missions"
        redeemedLabel.text = redeemedText.isEmpty ? "No rewards yet" : "Redeemed \(redeemedText)"
        arcView.setProgress(progress, animated: animated)
    }
}
