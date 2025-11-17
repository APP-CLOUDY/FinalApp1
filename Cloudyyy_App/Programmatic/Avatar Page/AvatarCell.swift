import UIKit

final class AvatarCell: UICollectionViewCell {
    
    static let reuseID = "AvatarCell"
    
    // MARK: - UI Elements
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark) // Use dark blur
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.layer.cornerRadius = 24 // Match the rounded corners of the cell
        visualEffectView.clipsToBounds = true
        return visualEffectView
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill // Images will fill the circle
        iv.clipsToBounds = true
        // No background color here; the glass will be the background
        return iv
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Make the image view perfectly circular within its bounds
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    // MARK: - Public
    
    public func set(imageName: String) {
        if let img = UIImage(named: imageName) {
            avatarImageView.image = img
            avatarImageView.contentMode = .scaleAspectFill
            avatarImageView.tintColor = nil // Clear tint if using a real image
        } else {
            // Fallback to a system icon
            // Adjust pointSize to make the icon fit well in the circle
            let config = UIImage.SymbolConfiguration(pointSize: bounds.width * 0.35, weight: .regular)
            avatarImageView.image = UIImage(systemName: "person.fill", withConfiguration: config)
            avatarImageView.contentMode = .center // Center system icon
            avatarImageView.tintColor = .white // System icon color
        }
    }
    
    // MARK: - Setup
    
    private func configure() {
        // Add the blur effect view to the content view
        contentView.addSubview(blurEffectView)
        
        // Add a light border to enhance the glass effect
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor // Semi-transparent white border
        contentView.layer.cornerRadius = 24
        contentView.clipsToBounds = true // Ensure content respects corner radius
        
        // Pin blur effect view to the cell's content view
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: contentView.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Add the avatar image view on top of the blur effect view
        contentView.addSubview(avatarImageView)
        
        // Inset the circular image from the cell's edges
        let avatarPadding: CGFloat = 16 // Adjust this value to control circle size within the square
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: avatarPadding),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: avatarPadding),
            avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -avatarPadding),
            avatarImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -avatarPadding)
        ])
    }
}
