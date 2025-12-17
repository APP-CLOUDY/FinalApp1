//
//  DreamIt.swift
//  Cloudyyy_App
//
//  Created by user@5 on 20/11/25.
//

import UIKit
import AVFoundation

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

// MARK: - Data Model
struct BikePart {
    let id: String
    let name: String
    let iconName: String
    let price: String
    let videoEndTime: Double
}

// MARK: - DreamIt View Controller

final class ChildDreamItViewController: UIViewController {
    
    // MARK: - Properties
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var currentVideoEndTime: Double = 0.0
    private var nextPurchaseIndex = 0
    
    // ⚠️ Check your timestamps match your video!
    private let bikeParts: [BikePart] = [
        BikePart(id: "frame", name: "Frame", iconName: "frame", price: "500", videoEndTime: 2.5),
        BikePart(id: "fork", name: "Fork", iconName: "fork", price: "300", videoEndTime: 4.0),
        BikePart(id: "wheel", name: "Wheels", iconName: "wheel", price: "200", videoEndTime: 6.0),
        BikePart(id: "seat", name: "Seat", iconName: "seat", price: "150", videoEndTime: 7.5)
    ]
    
    // --- UI COMPONENTS ---
    private let backgroundGradientLayer = CAGradientLayer()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Top Bar
    private let topBarContainer = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let coinBadge = BadgeLabel(top: 4, left: 10, bottom: 4, right: 10)
    private let profileButton = UIButton(type: .system)
    
    // Banner Section (Updated for Glass Look)
    private let bannerContainer = UIView()
    private let glassContainerView = UIView() // The frosted glass frame
    private let videoWrapperView = UIView()   // The actual video container
    private let pageControl = UIPageControl()
    
    // Store Section
    private let storeTitleLabel = UILabel()
    private let storeGridStack = UIStackView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        setupScrollView()
        setupTopBar()
        setupBanner()
        setupStoreSection()
        setupVideoPlayer()
        layoutUI()
        
        updateStoreItemStates()
        player?.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if nextPurchaseIndex > 0 { player?.play() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        player?.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
        if let pLayer = playerLayer {
            pLayer.frame = videoWrapperView.bounds
        }
    }
    
    // MARK: - Video Setup
    
    private func setupVideoPlayer() {
        guard let path = Bundle.main.path(forResource: "bike_animation", ofType: "mp4") else {
            print("Video file not found")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        player?.actionAtItemEnd = .pause
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect // Ensures the whole bike fits
        
        videoWrapperView.layer.addSublayer(playerLayer!)
        
        let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.checkVideoProgress(currentTime: time.seconds)
        }
    }
    
    private func checkVideoProgress(currentTime: Double) {
        if nextPurchaseIndex == 0 {
            if currentTime > 0.1 { player?.pause(); player?.seek(to: .zero) }
            return
        }
        if currentTime >= currentVideoEndTime {
            player?.pause()
        }
    }
    
    // MARK: - Purchase Logic
    
    @objc private func handleStoreItemTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        let tappedIndex = view.tag
        
        if tappedIndex == nextPurchaseIndex {
            performPurchase(at: tappedIndex)
        } else if tappedIndex < nextPurchaseIndex {
            print("Already bought")
        } else {
            shakeView(view)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    private func performPurchase(at index: Int) {
        let part = bikeParts[index]
        currentVideoEndTime = part.videoEndTime
        player?.play()
        nextPurchaseIndex += 1
        updateStoreItemStates()
        showCongratulationsPopup(for: part)
    }
    
    // MARK: - Helper: Update Visual States (Locks)
    private func updateStoreItemStates() {
        for (index, _) in bikeParts.enumerated() {
            guard let card = findCardView(by: index) else { continue }
            card.viewWithTag(999)?.removeFromSuperview()
            
            if index < nextPurchaseIndex {
                UIView.animate(withDuration: 0.3) {
                    card.alpha = 0.5
                    card.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }
            } else if index == nextPurchaseIndex {
                UIView.animate(withDuration: 0.3) {
                    card.alpha = 1.0
                    card.transform = .identity
                }
            } else {
                card.alpha = 1.0
                card.transform = .identity
                addLockOverlay(to: card)
            }
        }
    }
    
    private func addLockOverlay(to card: UIView) {
        let overlay = UIView()
        overlay.tag = 999
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.layer.cornerRadius = 24
        
        let lockIcon = UIImageView(image: UIImage(systemName: "lock.fill"))
        lockIcon.tintColor = UIColor.white.withAlphaComponent(0.8)
        lockIcon.contentMode = .scaleAspectFit
        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        
        overlay.addSubview(lockIcon)
        card.addSubview(overlay)
        
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: card.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            
            lockIcon.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            lockIcon.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            lockIcon.widthAnchor.constraint(equalToConstant: 30),
            lockIcon.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func shakeView(_ view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 5, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 5, y: view.center.y))
        view.layer.add(animation, forKey: "position")
    }
    
    // MARK: - Congratulations Popup
    
    private func showCongratulationsPopup(for part: BikePart) {
        let dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        dimView.alpha = 0
        view.addSubview(dimView)
        
        let popupView = UIView()
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 24
        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        popupView.alpha = 0
        dimView.addSubview(popupView)
        
        let iconView = UIImageView(image: UIImage(named: part.iconName))
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(iconView)
        
        let titleLabel = UILabel()
        titleLabel.text = "Awesome!"
        titleLabel.font = .systemFont(ofSize: 24, weight: .heavy)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(titleLabel)
        
        let msgLabel = UILabel()
        msgLabel.text = "You got the \(part.name)!"
        msgLabel.font = .systemFont(ofSize: 16, weight: .medium)
        msgLabel.textColor = .darkGray
        msgLabel.textAlignment = .center
        msgLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(msgLabel)
        
        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: dimView.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: dimView.centerYAnchor),
            popupView.widthAnchor.constraint(equalToConstant: 280),
            popupView.heightAnchor.constraint(equalToConstant: 220),
            
            titleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            
            iconView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            iconView.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 80),
            iconView.widthAnchor.constraint(equalToConstant: 80),
            
            msgLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 15),
            msgLabel.centerXAnchor.constraint(equalTo: popupView.centerXAnchor)
        ])
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            dimView.alpha = 1
            popupView.alpha = 1
            popupView.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: {
                dimView.alpha = 0
                popupView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                dimView.removeFromSuperview()
            }
        }
    }
    
    private func findCardView(by tag: Int) -> UIView? {
        for case let row as UIStackView in storeGridStack.arrangedSubviews {
            for view in row.arrangedSubviews {
                if view.tag == tag { return view }
            }
        }
        return nil
    }

    // MARK: - UI Setup & Layout
    
    private func setupBackgroundGradient() {
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
        
        let backConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: backConfig), for: .normal)
        backButton.tintColor = UIColor(red: 0.2, green: 0.7, blue: 1.0, alpha: 1.0)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        titleLabel.text = "Dream it"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        coinBadge.text = "★ 207"
        coinBadge.font = .systemFont(ofSize: 14, weight: .bold)
        coinBadge.textColor = UIColor(red: 0.2, green: 0.15, blue: 0.05, alpha: 1.0)
        coinBadge.backgroundColor = UIColor(red: 1.0, green: 0.75, blue: 0.1, alpha: 1)
        coinBadge.layer.cornerRadius = 14
        coinBadge.layer.masksToBounds = true
        coinBadge.translatesAutoresizingMaskIntoConstraints = false
        
        let profileConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .light)
        profileButton.setImage(UIImage(systemName: "person.circle", withConfiguration: profileConfig), for: .normal)
        profileButton.tintColor = .white
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        
        topBarContainer.addSubview(backButton)
        topBarContainer.addSubview(titleLabel)
        topBarContainer.addSubview(coinBadge)
        topBarContainer.addSubview(profileButton)
    }
    
    // MARK: - UPDATED BANNER (GLASS EFFECT)
    private func setupBanner() {
        bannerContainer.translatesAutoresizingMaskIntoConstraints = false
        bannerContainer.clipsToBounds = false
        contentView.addSubview(bannerContainer)

        // 1. The Glass Container (Background Frame)
        glassContainerView.translatesAutoresizingMaskIntoConstraints = false
        glassContainerView.layer.cornerRadius = 32 // More rounded
        glassContainerView.layer.masksToBounds = true
        glassContainerView.backgroundColor = .clear
        
        // Add Glass Blur Effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight) // "Frosty" look
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        glassContainerView.addSubview(blurView)
        
        // Add a subtle white tint overlay for the "Milky Glass" look
        let tintView = UIView()
        tintView.translatesAutoresizingMaskIntoConstraints = false
        tintView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        glassContainerView.addSubview(tintView)
        
        // Glass Border
        glassContainerView.layer.borderWidth = 1.5
        glassContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor

        // 2. Glowing Shadow (Behind the glass)
        let glowView = UIView()
        glowView.translatesAutoresizingMaskIntoConstraints = false
        glowView.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.5) // Cyan Glow
        glowView.layer.cornerRadius = 32
        glowView.layer.shadowColor = UIColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1).cgColor
        glowView.layer.shadowOpacity = 0.6
        glowView.layer.shadowOffset = .zero
        glowView.layer.shadowRadius = 30 // Big soft glow
        bannerContainer.addSubview(glowView)
        
        bannerContainer.addSubview(glassContainerView)

        // 3. Video Wrapper (Inside the glass)
        videoWrapperView.translatesAutoresizingMaskIntoConstraints = false
        // Match video background color (Dark Gray)
        videoWrapperView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        videoWrapperView.layer.cornerRadius = 24
        videoWrapperView.layer.masksToBounds = true
        glassContainerView.addSubview(videoWrapperView)

        // 4. Page Control
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        bannerContainer.addSubview(pageControl)

        // Layout Constraints
        NSLayoutConstraint.activate([
            // Blur fills glass container
            blurView.topAnchor.constraint(equalTo: glassContainerView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: glassContainerView.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: glassContainerView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: glassContainerView.trailingAnchor),
            
            tintView.topAnchor.constraint(equalTo: glassContainerView.topAnchor),
            tintView.bottomAnchor.constraint(equalTo: glassContainerView.bottomAnchor),
            tintView.leadingAnchor.constraint(equalTo: glassContainerView.leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: glassContainerView.trailingAnchor),
            
            // Glass Container Sizing
            glassContainerView.centerXAnchor.constraint(equalTo: bannerContainer.centerXAnchor),
            glassContainerView.centerYAnchor.constraint(equalTo: bannerContainer.centerYAnchor),
            glassContainerView.widthAnchor.constraint(equalTo: bannerContainer.widthAnchor, multiplier: 0.9), // Wider
            glassContainerView.heightAnchor.constraint(equalTo: glassContainerView.widthAnchor, multiplier: 0.8), // Taller frame
            
            // Glow matches glass size
            glowView.centerXAnchor.constraint(equalTo: glassContainerView.centerXAnchor),
            glowView.centerYAnchor.constraint(equalTo: glassContainerView.centerYAnchor),
            glowView.widthAnchor.constraint(equalTo: glassContainerView.widthAnchor),
            glowView.heightAnchor.constraint(equalTo: glassContainerView.heightAnchor),
            
            // Video sits inside Glass with padding
            videoWrapperView.topAnchor.constraint(equalTo: glassContainerView.topAnchor, constant: 12),
            videoWrapperView.bottomAnchor.constraint(equalTo: glassContainerView.bottomAnchor, constant: -12),
            videoWrapperView.leadingAnchor.constraint(equalTo: glassContainerView.leadingAnchor, constant: 12),
            videoWrapperView.trailingAnchor.constraint(equalTo: glassContainerView.trailingAnchor, constant: -12),

            pageControl.centerXAnchor.constraint(equalTo: bannerContainer.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bannerContainer.bottomAnchor, constant: -10)
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
        
        var currentRowStack: UIStackView?
        for (index, part) in bikeParts.enumerated() {
            if index % 2 == 0 {
                currentRowStack = UIStackView()
                currentRowStack?.axis = .horizontal
                currentRowStack?.distribution = .fillEqually
                currentRowStack?.spacing = 16
                storeGridStack.addArrangedSubview(currentRowStack!)
            }
            let card = createStoreItemCard(part: part, index: index)
            currentRowStack?.addArrangedSubview(card)
        }
    }
    
    private func createStoreItemCard(part: BikePart, index: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        container.layer.cornerRadius = 24
        container.clipsToBounds = true
        container.tag = index
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleStoreItemTap(_:)))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        let tintOverlay = UIView()
        tintOverlay.translatesAutoresizingMaskIntoConstraints = false
        tintOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        
        container.addSubview(blurView)
        container.addSubview(tintOverlay)
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: part.iconName)
        imageView.contentMode = .scaleAspectFit
        
        let priceBadge = BadgeLabel(top: 4, left: 10, bottom: 4, right: 10)
        priceBadge.translatesAutoresizingMaskIntoConstraints = false
        priceBadge.text = "★ \(part.price)"
        priceBadge.font = .systemFont(ofSize: 12, weight: .bold)
        priceBadge.textColor = UIColor(red: 0.2, green: 0.15, blue: 0.05, alpha: 1.0)
        priceBadge.backgroundColor = UIColor(red: 1.0, green: 0.75, blue: 0.1, alpha: 1)
        priceBadge.layer.cornerRadius = 10
        priceBadge.layer.masksToBounds = true
        
        container.addSubview(imageView)
        container.addSubview(priceBadge)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: container.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            tintOverlay.topAnchor.constraint(equalTo: container.topAnchor),
            tintOverlay.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tintOverlay.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tintOverlay.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            container.heightAnchor.constraint(equalTo: container.widthAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -12),
            imageView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.65),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            priceBadge.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            priceBadge.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    
    private func layoutUI() {
        let safe = view.safeAreaLayoutGuide
        let p: CGFloat = 20
        
        NSLayoutConstraint.activate([
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
            
            scrollView.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            bannerContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            bannerContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bannerContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bannerContainer.heightAnchor.constraint(equalToConstant: 330),
            
            storeTitleLabel.topAnchor.constraint(equalTo: bannerContainer.bottomAnchor, constant: 24),
            storeTitleLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: p),
            
            storeGridStack.topAnchor.constraint(equalTo: storeTitleLabel.bottomAnchor, constant: 16),
            storeGridStack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: p),
            storeGridStack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -p),
            storeGridStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
        ])
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
