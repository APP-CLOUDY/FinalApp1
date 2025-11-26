//
//  DreamIt.swift
//  Cloudyyy_App
//
//  Created by user@5 on 20/11/25.
//

import UIKit

// MARK: - Custom BadgeLabel Utility
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
    
    // --- NEW BANNER CONSTANTS ---
    private let bannerRotationDegrees: CGFloat = 8.5      // rotation
    private let bannerWidthMultiplier: CGFloat = 1.3      // banner width
    private let bannerHeight: CGFloat = 770// banner height
    
    // Full-screen background gradient property
    private let backgroundGradientLayer = CAGradientLayer()
    
    // Colors based on the screenshot
    private let mainBackgroundColor = UIColor(red: 10/255, green: 16/255, blue: 32/255, alpha: 1)
    
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
    private let bannerBackgroundImageView = UIImageView()
    private let bannerImageView = UIImageView()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.numberOfPages = 3
        pc.currentPage = 0
        pc.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        pc.currentPageIndicatorTintColor = .white
        return pc
    }()
    
    // --- STORE SECTION ---
    private let storeTitleLabel = UILabel()
    private let storeGridStack = UIStackView()
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
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
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }
    
    // MARK: - Setup UI
    
    private func setupBackgroundGradient() {
        // Deep Dark Navy Background
        backgroundGradientLayer.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
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
        
        // Back Button - Cyan/Blue Tint
        let backConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: backConfig), for: .normal)
        backButton.tintColor = UIColor(red: 0.2, green: 0.7, blue: 1.0, alpha: 1.0)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        titleLabel.text = "Dream it"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Coin Badge
        coinBadge.text = "★ 207"
        coinBadge.font = .systemFont(ofSize: 14, weight: .bold)
        coinBadge.textColor = UIColor(red: 0.2, green: 0.15, blue: 0.05, alpha: 1.0)
        coinBadge.backgroundColor = UIColor(red: 1.0, green: 0.75, blue: 0.1, alpha: 1)
        coinBadge.layer.cornerRadius = 14
        coinBadge.layer.masksToBounds = true
        coinBadge.translatesAutoresizingMaskIntoConstraints = false
        
        // Profile Icon
        let profileConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .light)
        profileButton.setImage(UIImage(systemName: "person.circle", withConfiguration: profileConfig), for: .normal)
        profileButton.tintColor = .white
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        
        topBarContainer.addSubview(backButton)
        topBarContainer.addSubview(titleLabel)
        topBarContainer.addSubview(coinBadge)
        topBarContainer.addSubview(profileButton)
    }
    
    // MARK: - Setup Banner (Updated with Rotation)
    private func setupBanner() {
        bannerContainer.translatesAutoresizingMaskIntoConstraints = false
        bannerContainer.clipsToBounds = false
        contentView.addSubview(bannerContainer)

        // Background image
        bannerBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        bannerBackgroundImageView.image = UIImage(named: "banner")
        bannerBackgroundImageView.contentMode = .scaleAspectFill
        bannerContainer.addSubview(bannerBackgroundImageView)

        // Bike Image
        bannerImageView.translatesAutoresizingMaskIntoConstraints = false
        bannerImageView.image = UIImage(named: "Cycle")
        bannerImageView.contentMode = .scaleAspectFit
        bannerContainer.addSubview(bannerImageView)

        // Page Control
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        bannerContainer.addSubview(pageControl)

        // --- APPLY ROTATION ---
        let radians = bannerRotationDegrees * (.pi / 180)
        bannerBackgroundImageView.transform = CGAffineTransform(rotationAngle: radians)

        // Background size + position
        NSLayoutConstraint.activate([
            bannerBackgroundImageView.centerXAnchor.constraint(equalTo: bannerContainer.centerXAnchor),
            bannerBackgroundImageView.centerYAnchor.constraint(equalTo: bannerContainer.centerYAnchor),
            bannerBackgroundImageView.widthAnchor.constraint(equalTo: bannerContainer.widthAnchor, multiplier: bannerWidthMultiplier),
            bannerBackgroundImageView.heightAnchor.constraint(equalToConstant: bannerHeight)
        ])

        // Bike image
        NSLayoutConstraint.activate([
            bannerImageView.centerXAnchor.constraint(equalTo: bannerContainer.centerXAnchor),
            bannerImageView.centerYAnchor.constraint(equalTo: bannerContainer.centerYAnchor, constant: -10),
            bannerImageView.widthAnchor.constraint(equalToConstant: 350),
            bannerImageView.heightAnchor.constraint(equalTo: bannerImageView.widthAnchor, multiplier: 0.7)
        ])

        // Page control
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: bannerContainer.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bannerContainer.bottomAnchor, constant: -8)
        ])
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
        
        // Mock Data
        // INSIDE setupStoreSection()

        // Replace "AssetImageName1", etc. with the exact names in your Asset Catalog
        let items = [
            ("wheel", "100", UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1)),
            ("frame", "500", UIColor(red: 0.8, green: 0.6, blue: 0.9, alpha: 1)),
            ("seat", "1000", UIColor(red: 0.9, green: 0.6, blue: 0.4, alpha: 1)),
            ("wheel", "1000", UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1))
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
                    let card = createStoreItemCard(icon: item.0, price: item.1, tint: item.2)
                    rowStack.addArrangedSubview(card)
                }
            }
            storeGridStack.addArrangedSubview(rowStack)
        }
    }
    
    // MARK: - Helper: Create Store Card
    // MARK: - Helper: Create Store Card (Updated for Assets)
    private func createStoreItemCard(icon: String, price: String, tint: UIColor) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        container.layer.cornerRadius = 24
        container.clipsToBounds = true
        
        // 1. Blur Effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 24
        blurView.clipsToBounds = true
        
        // 2. Tint Overlay
        let tintOverlay = UIView()
        tintOverlay.translatesAutoresizingMaskIntoConstraints = false
        tintOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        // 3. Border (Optional: Use the 'tint' color for the border for a nice effect?)
        container.layer.borderWidth = 1
        // You can use 'tint.withAlphaComponent(0.3).cgColor' here if you want colored borders
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        
        container.addSubview(blurView)
        container.addSubview(tintOverlay)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: container.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            tintOverlay.topAnchor.constraint(equalTo: container.topAnchor),
            tintOverlay.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tintOverlay.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tintOverlay.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // 4. Image View (UPDATED)
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // CHANGED: Use 'named' instead of 'systemName'
        // This loads the picture from your Assets folder
        imageView.image = UIImage(named: icon)
        
        // Scale aspect fit ensures the whole picture is visible without stretching
        imageView.contentMode = .scaleAspectFit
        
        // Note: We REMOVED 'imageView.tintColor = tint' so your photos show in full color.
        
        // 5. Price Badge
        let priceBadge = BadgeLabel(top: 4, left: 10, bottom: 4, right: 10)
        priceBadge.translatesAutoresizingMaskIntoConstraints = false
        priceBadge.text = "★ \(price)"
        priceBadge.font = .systemFont(ofSize: 12, weight: .bold)
        priceBadge.textColor = UIColor(red: 0.2, green: 0.15, blue: 0.05, alpha: 1.0)
        priceBadge.backgroundColor = UIColor(red: 1.0, green: 0.75, blue: 0.1, alpha: 1)
        priceBadge.layer.cornerRadius = 10
        priceBadge.layer.masksToBounds = true
        
        container.addSubview(imageView)
        container.addSubview(priceBadge)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1.0),
            
            // Centered Image with padding
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -12),
            imageView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.7), // Slightly larger for photos
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            priceBadge.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            priceBadge.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    // MARK: - Layout
    
    private func layoutUI() {
        let safe = view.safeAreaLayoutGuide
        let p: CGFloat = 20
        
        NSLayoutConstraint.activate([
            // --- Top Bar ---
            topBarContainer.topAnchor.constraint(equalTo: safe.topAnchor),
            topBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarContainer.heightAnchor.constraint(equalToConstant: 60),
            
            backButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: p),
            backButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            
            profileButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -p),
            profileButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 34),
            profileButton.heightAnchor.constraint(equalToConstant: 34),
            
            coinBadge.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -12),
            coinBadge.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            
            // --- ScrollView ---
            scrollView.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // --- Banner (Updated Constraints) ---
            bannerContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            bannerContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bannerContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bannerContainer.heightAnchor.constraint(equalToConstant: 330),
            
            // --- Store Section ---
            storeTitleLabel.topAnchor.constraint(equalTo: bannerContainer.bottomAnchor, constant: 24),
            storeTitleLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: p),
            
            storeGridStack.topAnchor.constraint(equalTo: storeTitleLabel.bottomAnchor, constant: 16),
            storeGridStack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: p),
            storeGridStack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -p),
            storeGridStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
        ])
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
