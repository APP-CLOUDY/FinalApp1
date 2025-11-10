import UIKit

class ApprovalCell: UITableViewCell {
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let dateLabel = UILabel()
    private let pointsLabel = UILabel()
    private let declineButton = UIButton(type: .system)
    private let approveButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.backgroundColor = UIColor(red: 43/255, green: 46/255, blue: 74/255, alpha: 1)
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 6
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = .white
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = UIColor(white: 0.85, alpha: 1)
        
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = UIColor(white: 0.6, alpha: 1)
        
        pointsLabel.font = UIFont.boldSystemFont(ofSize: 15)
        pointsLabel.textColor = .systemYellow
        
        declineButton.setTitle("Decline", for: .normal)
        declineButton.backgroundColor = .systemRed
        declineButton.setTitleColor(.white, for: .normal)
        declineButton.layer.cornerRadius = 10
        
        approveButton.setTitle("Approve", for: .normal)
        approveButton.backgroundColor = .systemBlue
        approveButton.setTitleColor(.white, for: .normal)
        approveButton.layer.cornerRadius = 10
        
        [containerView, titleLabel, subtitleLabel, dateLabel, pointsLabel, declineButton, approveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        contentView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            pointsLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            pointsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            approveButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            approveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            approveButton.widthAnchor.constraint(equalToConstant: 90),
            approveButton.heightAnchor.constraint(equalToConstant: 34),
            
            declineButton.trailingAnchor.constraint(equalTo: approveButton.leadingAnchor, constant: -8),
            declineButton.centerYAnchor.constraint(equalTo: approveButton.centerYAnchor),
            declineButton.widthAnchor.constraint(equalToConstant: 90),
            declineButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
    
    func configure(title: String, subtitle: String, date: String, points: String, showButtons: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        dateLabel.text = date
        pointsLabel.text = points
        declineButton.isHidden = !showButtons
        approveButton.isHidden = !showButtons
    }
}
