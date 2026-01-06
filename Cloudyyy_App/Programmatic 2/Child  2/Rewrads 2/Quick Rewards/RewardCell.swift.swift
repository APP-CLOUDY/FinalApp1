//
//  RewardCell.swift
//  Cloudyyy_App
//

import UIKit

final class RewardCell: UICollectionViewCell {
    
    static let reuseID = "RewardCell"
    
    // MARK: - UI Elements
    
    private let circleView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 40
        v.layer.masksToBounds = true
        v.backgroundColor = UIColor(white: 1.0, alpha: 0.06)
        return v
    }()
    
    private let iconImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .white
        iv.clipsToBounds = true
        return iv
    }()
    
    private let lockIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "lock.fill"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = UIColor.white.withAlphaComponent(0.85)
        iv.isHidden = true
        return iv
    }()
    
    private let textLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = .systemFont(ofSize: 12, weight: .medium)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(circleView)
        circleView.addSubview(iconImage)
        circleView.addSubview(lockIcon)
        contentView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            // Circle
            circleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 80),
            circleView.heightAnchor.constraint(equalToConstant: 80),
            
            // Image fills circle
            iconImage.topAnchor.constraint(equalTo: circleView.topAnchor),
            iconImage.bottomAnchor.constraint(equalTo: circleView.bottomAnchor),
            iconImage.leadingAnchor.constraint(equalTo: circleView.leadingAnchor),
            iconImage.trailingAnchor.constraint(equalTo: circleView.trailingAnchor),
            
            // Lock icon (centered)
            lockIcon.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            lockIcon.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            lockIcon.widthAnchor.constraint(equalToConstant: 22),
            lockIcon.heightAnchor.constraint(equalToConstant: 22),
            
            // Label
            textLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 6),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(title: String, image: UIImage?, isEnabled: Bool) {
        
        textLabel.text = title
        if let image = image {
            iconImage.image = image
        }

        iconImage.contentMode = .scaleAspectFit
        iconImage.preferredSymbolConfiguration = nil
        
        // 🚨 IMPORTANT: handle missing image
        if image == nil {
            iconImage.alpha = 0.0
            lockIcon.isHidden = true
            return
        }
        
        if isEnabled {
            circleView.alpha = 1.0
            iconImage.alpha = 1.0
            textLabel.alpha = 1.0
            lockIcon.isHidden = true
        } else {
            circleView.alpha = 0.35
            iconImage.alpha = 0.25
            textLabel.alpha = 0.5
            lockIcon.isHidden = false
        }
    }
}

