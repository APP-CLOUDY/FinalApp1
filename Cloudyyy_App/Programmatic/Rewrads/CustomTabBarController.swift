//
//  CustomTabBar.swift
//  Cloudyyy_App
//
//  Created by Gemini
//
import UIKit

// MARK: - Delegate Protocol
protocol CustomTabBarDelegate: AnyObject {
    func didSelectTab(at index: Int)
}

// MARK: - CustomTabBar
final class CustomTabBar: UIView {

    public weak var delegate: CustomTabBarDelegate?
    private var itemViews: [TabBarItemView] = []
    
    private let backgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThickMaterialDark)
        let v = UIVisualEffectView(effect: blurEffect)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        // Use this for the non-blurred background from your code:
        // v.backgroundColor = UIColor(white: 1.0, alpha: 0.12)
        return v
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .center
        return sv
    }()

    private let tabItems: [(icon: String, title: String)] = [
        ("house.fill", "Home"),
        ("medal.fill", "Rewards"),
        ("calendar", "Missions"),
        ("cloud.fill", "Ask")
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // Use this if you want the non-blurred background
        // backgroundColor = UIColor(white: 1.0, alpha: 0.12)
        // layer.cornerRadius = 12
        
        // Using blur effect view
        addSubview(backgroundView)
        backgroundView.contentView.addSubview(stackView)

        for (index, item) in tabItems.enumerated() {
            let itemView = TabBarItemView(
                icon: UIImage(systemName: item.icon),
                title: item.title,
                index: index
            )
            itemView.delegate = self
            itemViews.append(itemView)
            stackView.addArrangedSubview(itemView)
        }

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: backgroundView.contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: backgroundView.contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: backgroundView.contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: backgroundView.contentView.bottomAnchor)
        ])

        // Set "Rewards" as selected per your image
        selectItem(at: 1)
    }

    public func selectItem(at index: Int) {
        for (i, view) in itemViews.enumerated() {
            view.setSelected(i == index)
        }
    }
}

// MARK: - TabBarItemViewDelegate
extension CustomTabBar: TabBarItemViewDelegate {
    func didTapItem(at index: Int) {
        selectItem(at: index)
        delegate?.didSelectTab(at: index)
    }
}

// MARK: - TabBarItemView (Private Helper)
private protocol TabBarItemViewDelegate: AnyObject {
    func didTapItem(at index: Int)
}

private final class TabBarItemView: UIView {
    
    weak var delegate: TabBarItemViewDelegate?
    private let index: Int
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.font = .systemFont(ofSize: 11, weight: .medium)
        lb.textAlignment = .center
        return lb
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 4
        return sv
    }()

    init(icon: UIImage?, title: String, index: Int) {
        self.index = index
        super.init(frame: .zero)
        iconImageView.image = icon
        titleLabel.text = title
        
        setupView()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        delegate?.didTapItem(at: index)
    }
    
    public func setSelected(_ isSelected: Bool) {
        let color = isSelected ? UIColor.systemBlue : UIColor.gray
        iconImageView.tintColor = color
        titleLabel.textColor = color
        
        // Match blue text from your reference image
        if isSelected {
             titleLabel.textColor = UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1.0)
        }
    }
}
