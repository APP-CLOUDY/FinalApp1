//
//  RewardCell.swift.swift
//  Cloudyyy_App
//
//  Created by user@5 on 16/11/25.
//

//
//  RewardCell.swift
//  Cloudyyy_App
//
//  Created by Gemini
//
import UIKit

final class RewardCell: UICollectionViewCell {
    
    // ... (All the code for RewardCell from your original file) ...
    
    static let reuseID = "RewardCell"

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
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let textLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = .systemFont(ofSize: 12)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(circleView)
        circleView.addSubview(iconImage)
        contentView.addSubview(textLabel)

        NSLayoutConstraint.activate([
            circleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 80),
            circleView.heightAnchor.constraint(equalToConstant: 80),

            iconImage.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            iconImage.widthAnchor.constraint(equalTo: circleView.widthAnchor, multiplier: 0.6),
            iconImage.heightAnchor.constraint(equalTo: circleView.heightAnchor, multiplier: 0.6),

            textLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 6),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, image: UIImage?) {
        textLabel.text = title
        if let img = image { iconImage.image = img }
        else { iconImage.image = UIImage(systemName: "gift") }
    }
}
