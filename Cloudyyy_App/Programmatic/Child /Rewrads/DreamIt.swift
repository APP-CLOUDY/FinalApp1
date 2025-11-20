//
//  DreamIt.swift
//  Cloudyyy_App
//
//  Created by user@5 on 20/11/25.
//

import UIKit

// MARK: - Custom BadgeLabel Utility (Renamed from PaddingLabel)
class BadgeLabel: UILabel {
    private let inset: UIEdgeInsets
    
    init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.inset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        self.inset = .zero
        super.init(coder: coder)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + inset.left + inset.right,
                      height: size.height + inset.top + inset.bottom)
    }
}

// MARK: - DreamIt View Controller

final class ChildDreamItViewController: UIViewController {
    
    // MARK: - Properties & UI Components
    
    // Full-screen background gradient property (ADDED)
    private let backgroundGradientLayer = CAGradientLayer()
    
    private let mainBackgroundColor = UIColor(red: 10/255, green: 16/255, blue: 32/255, alpha: 1)
    private let cardBackgroundColor = UIColor(white: 1.0, alpha: 0.1)
    
    // --- SCROLL VIEW SUPPORT ---
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // --- TOP HEADER ---
    private let topBarContainer = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let coinBadge = BadgeLabel(top: 4, left: 10, bottom: 4, right: 10)
    private let profileButton = UIButton(type: .system)
    
    // --- HERO / BANNER SECTION ---
    private let bannerContainer = UIView()
    private let bannerGradientLayer = CAGradientLayer()
    private let bannerImageView = UIImageView()
    private let leftArrowButton = UIButton(type: .system)
    private let rightArrowButton = UIButton(type: .system)
    
    // --- STORE SECTION ---
    private let storeTitleLabel = UILabel()
    private let storeGridStack = UIStackView()
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
        // Hides the standard tab bar
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundGradient()
        setupScrollView()
        setupTopBar()
        setupBanner()
        setupStoreSection()
        
        layoutUI()
        
        // Hide native iOS navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        backgroundGradientLayer.frame = view.bounds
        bannerGradientLayer.frame = bannerContainer.bounds
        
        applyJaggedBottomMask(to: bannerContainer)
    }
    
    // MARK: - Setup UI
    
    private func setupBackgroundGradient() {
        // Full-screen background gradient setup
        backgroundGradientLayer.colors = [
            UIColor(red: 10/255, green: 16/255, blue: 32/255, alpha: 1).cgColor,
            UIColor(red: 24/255, green: 46/255, blue: 92/255, alpha: 1).cgColor
        ]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradientLayer.endPoint  = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    private func setupTopBar() {
        topBarContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBarContainer)
        
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        backButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .bold), forImageIn: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        // Add back action functionality
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        titleLabel.text = "Dream it"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        coinBadge.text = "★ 207"
        coinBadge.font = .systemFont(ofSize: 14, weight: .bold)
        coinBadge.textColor = .black
        coinBadge.backgroundColor = UIColor(red: 1.0, green: 0.75, blue: 0.0, alpha: 1)
        coinBadge.layer.cornerRadius = 14
        coinBadge.layer.masksToBounds = true
        coinBadge.translatesAutoresizingMaskIntoConstraints = false
        
        profileButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
        profileButton.tintColor = .white
        profileButton.contentHorizontalAlignment = .fill
        profileButton.contentVerticalAlignment = .fill
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        
        topBarContainer.addSubview(backButton)
        topBarContainer.addSubview(titleLabel)
        topBarContainer.addSubview(coinBadge)
        topBarContainer.addSubview(profileButton)
    }
    
    private func setupBanner() {
        bannerContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bannerContainer)
        
        bannerGradientLayer.colors = [
            UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.3, green: 0.2, blue: 0.9, alpha: 1.0).cgColor
        ]
        bannerGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        bannerGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        bannerContainer.layer.insertSublayer(bannerGradientLayer, at: 0)
        
        bannerImageView.translatesAutoresizingMaskIntoConstraints = false
        bannerImageView.contentMode = .scaleAspectFit
        bannerImageView.image = UIImage(systemName: "bicycle")?.withTintColor(.white.withAlphaComponent(0.8), renderingMode: .alwaysOriginal)
        bannerContainer.addSubview(bannerImageView)
        
        configureArrow(leftArrowButton, icon: "chevron.left")
        configureArrow(rightArrowButton, icon: "chevron.right")
        
        bannerContainer.addSubview(leftArrowButton)
        bannerContainer.addSubview(rightArrowButton)
    }
    
    private func configureArrow(_ button: UIButton, icon: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: icon), for: .normal)
        button.tintColor = .white.withAlphaComponent(0.6)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy), forImageIn: .normal)
    }
    
    private func setupStoreSection() {
        storeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        storeTitleLabel.text = "Store"
        storeTitleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        storeTitleLabel.textColor = .white
        contentView.addSubview(storeTitleLabel)
        
        storeGridStack.translatesAutoresizingMaskIntoConstraints = false
        storeGridStack.axis = .vertical
        storeGridStack.distribution = .fillEqually
        storeGridStack.spacing = 16
        contentView.addSubview(storeGridStack)
        
        let items = [
            ("circle.grid.cross.fill", "100"),
            ("bicycle.circle", "500"),
            ("handlebars", "1000"),
            ("circle.dashed", "1000")
        ]
        
        for i in 0..<2 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 16
            
            for j in 0..<2 {
                let index = (i * 2) + j
                if index < items.count {
                    let item = items[index]
                    let card = createStoreItemCard(icon: item.0, price: item.1)
                    rowStack.addArrangedSubview(card)
                }
            }
            storeGridStack.addArrangedSubview(rowStack)
        }
    }
    
    // MARK: - Helper: Create Store Card
    private func createStoreItemCard(icon: String, price: String) -> UIView {
        let container = UIView()
        container.backgroundColor = cardBackgroundColor
        container.layer.cornerRadius = 20
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: icon)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(red: 0.6, green: 0.7, blue: 0.9, alpha: 1)
        
        let priceBadge = BadgeLabel(top: 4, left: 12, bottom: 4, right: 12)
        priceBadge.translatesAutoresizingMaskIntoConstraints = false
        priceBadge.text = "★ \(price)"
        priceBadge.font = .systemFont(ofSize: 13, weight: .bold)
        priceBadge.textColor = .black
        priceBadge.backgroundColor = UIColor(red: 1.0, green: 0.75, blue: 0.0, alpha: 1)
        priceBadge.layer.cornerRadius = 12
        priceBadge.layer.masksToBounds = true
        
        container.addSubview(imageView)
        container.addSubview(priceBadge)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1.0),
            
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -10),
            imageView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.5),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            priceBadge.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            priceBadge.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    
    // MARK: - Layout
    
    private func layoutUI() {
        let safe = view.safeAreaLayoutGuide
        let p: CGFloat = 20 // padding
        
        NSLayoutConstraint.activate([
            // --- Top Bar (Pinned to View Edges Horizontally for full background color) ---
            topBarContainer.topAnchor.constraint(equalTo: safe.topAnchor),
            topBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarContainer.heightAnchor.constraint(equalToConstant: 60),
            
            // Content inside Top Bar respects safe area
            backButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: p),
            backButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            
            profileButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -p),
            profileButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 34),
            profileButton.heightAnchor.constraint(equalToConstant: 34),
            
            coinBadge.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -12),
            coinBadge.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            
            // --- ScrollView (Pinned Edge-to-Edge) ---
            scrollView.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // --- ContentView (Matches ScrollView width) ---
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // --- Banner (Pinned Edge-to-Edge) ---
            bannerContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            bannerContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bannerContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bannerContainer.heightAnchor.constraint(equalToConstant: 280),
            
            // Banner contents respect safe area for placement
            bannerImageView.centerXAnchor.constraint(equalTo: bannerContainer.centerXAnchor),
            bannerImageView.centerYAnchor.constraint(equalTo: bannerContainer.centerYAnchor),
            bannerImageView.widthAnchor.constraint(equalToConstant: 200),
            bannerImageView.heightAnchor.constraint(equalTo: bannerImageView.widthAnchor, multiplier: 0.75),
            
            leftArrowButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: p),
            leftArrowButton.centerYAnchor.constraint(equalTo: bannerContainer.centerYAnchor),
            
            rightArrowButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -p),
            rightArrowButton.centerYAnchor.constraint(equalTo: bannerContainer.centerYAnchor),
            
            // --- Store Section (Pinned to Safe Area) ---
            storeTitleLabel.topAnchor.constraint(equalTo: bannerContainer.bottomAnchor, constant: 30),
            storeTitleLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: p),
            
            storeGridStack.topAnchor.constraint(equalTo: storeTitleLabel.bottomAnchor, constant: 20),
            storeGridStack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: p),
            storeGridStack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -p),
            storeGridStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        // Functionality to pop the view controller off the stack
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Special Effects
    
    private func applyJaggedBottomMask(to view: UIView) {
        let height = view.bounds.height
        let width = view.bounds.width
        let toothWidth: CGFloat = 10.0
        let toothHeight: CGFloat = 6.0
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height - toothHeight))
        
        // Draw Zig Zags
        var x: CGFloat = width
        while x > 0 {
            path.addLine(to: CGPoint(x: x - (toothWidth / 2), y: height))
            path.addLine(to: CGPoint(x: x - toothWidth, y: height - toothHeight))
            x -= toothWidth
        }
        
        path.addLine(to: CGPoint(x: 0, y: height - toothHeight))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        
        if view.layer.mask != nil {
            let oldMask = view.layer.mask
            view.layer.mask = nil
            oldMask?.removeFromSuperlayer()
        }
        
        view.layer.mask = shapeLayer
    }
}
