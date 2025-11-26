//
//  RewardCell.swift
//  Cloudyyy_App
//
//  Created by Gemini
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
        // CHANGED: Default to fill for custom images
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .white
        iv.clipsToBounds = true
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
        contentView.addSubview(textLabel)

        NSLayoutConstraint.activate([
            // Circle Container
            circleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 80),
            circleView.heightAnchor.constraint(equalToConstant: 80),

            // CHANGED: Pin Image to Edges of Circle (No multiplier)
            iconImage.topAnchor.constraint(equalTo: circleView.topAnchor),
            iconImage.bottomAnchor.constraint(equalTo: circleView.bottomAnchor),
            iconImage.leadingAnchor.constraint(equalTo: circleView.leadingAnchor),
            iconImage.trailingAnchor.constraint(equalTo: circleView.trailingAnchor),

            // Label
            textLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 6),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Configuration
    func configure(title: String, image: UIImage?) {
        textLabel.text = title
        
        guard let img = image else {
            iconImage.image = UIImage(systemName: "gift")
            return
        }
        
        iconImage.image = img
        
        // LOGIC: Check if it is a System Symbol (SF Symbol)
        // If it's a symbol, we don't want it to stretch to the edges.
        if img.isSymbolImage {
            iconImage.contentMode = .scaleAspectFit
            // Add a bit of padding for symbols by using a smaller symbol configuration if needed
            // or we rely on the fact that scaleAspectFit respects the image aspect inside the frame
            // To make symbols appear smaller like 60%, we can use an inset constraint,
            // but simply setting contentMode .center or .scaleAspectFit usually works well for symbols
            // inside a large frame if the symbol point size is set.
            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
            iconImage.preferredSymbolConfiguration = config
            iconImage.contentMode = .center
        } else {
            // It is an Asset Image (like your "Screen Time"): Fill the circle
            iconImage.contentMode = .scaleAspectFill
            iconImage.preferredSymbolConfiguration = nil
            
            
        }
    }
}
