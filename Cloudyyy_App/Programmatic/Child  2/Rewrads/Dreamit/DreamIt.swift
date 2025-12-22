import UIKit

// MARK: - 1. Custom BadgeLabel Utility
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

// MARK: - 2. DreamIt View Controller
final class ChildDreamItViewController: UIViewController {
    
    // MARK: Properties
    // Dynamically choose the reward model from your Library
    var activeReward: RewardModel = RewardLibrary.allRewards[0]
    
    private var currentFrame = 1
    private var animationTimer: Timer?
    private var nextPurchaseIndex = 0
    
    // UI Components
    private let backgroundGradientLayer = CAGradientLayer()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let subTitleLabel = UILabel()
    private let coinBadge = BadgeLabel(top: 4, left: 10, bottom: 4, right: 10)
    private let bellButton = UIButton(type: .system)
    private let profileButton = UIButton(type: .system)
    
    private let bannerContainer = UIView()
    private let glowView = UIView()
    private let glassContainerView = UIView()
    private let videoWrapperView = UIView()
    private let simulationImageView = UIImageView()
    private let pageControl = UIPageControl()
    
    private let storeTitleLabel = UILabel()
    private let storeGridStack = UIStackView()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        setupScrollView()
        
        // ADD EVERYTHING TO VIEW HIERARCHY FIRST
        setupHeaderUI()
        setupBannerUI()
        setupStoreSection()
        setupSimulationDisplay()
        
        // ACTIVATE CONSTRAINTS LAST TO PREVENT CRASH
        layoutUI()
        
        updateStoreItemStates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }
    
    // MARK: Setup Methods
    private func setupHeaderUI() {
        let backConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: backConfig), for: .normal)
        backButton.tintColor = UIColor(red: 0.2, green: 0.7, blue: 1.0, alpha: 1.0)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // ✅ FIXED: Title is now locked to "Dream it"
        titleLabel.text = "Dream it"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        
        // ✅ DYNAMIC: Subtitle shows reward context (e.g., "Build your trail-ready ride!")
        subTitleLabel.text = activeReward.subtitle
        subTitleLabel.font = UIFont.systemFont(ofSize: 14)
        subTitleLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
        
        coinBadge.text = "★ 207"
        coinBadge.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        coinBadge.textColor = .black
        coinBadge.backgroundColor = UIColor(red: 1.0, green: 0.75, blue: 0.1, alpha: 1)
        coinBadge.layer.cornerRadius = 14
        coinBadge.layer.masksToBounds = true
        
        profileButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
        profileButton.tintColor = .white
        
        bellButton.setImage(UIImage(systemName: "bell"), for: .normal)
        bellButton.tintColor = .white
        
        [backButton, titleLabel, subTitleLabel, coinBadge, bellButton, profileButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupBannerUI() {
        bannerContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bannerContainer)
        
        glowView.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.4)
        glowView.layer.cornerRadius = 32
        glowView.layer.shadowColor = UIColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1).cgColor
        glowView.layer.shadowOpacity = 0.6
        glowView.layer.shadowRadius = 30
        glowView.layer.shadowOffset = .zero
        
        glassContainerView.layer.cornerRadius = 32
        glassContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        glassContainerView.layer.borderWidth = 1.5
        glassContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        videoWrapperView.backgroundColor = .clear
        videoWrapperView.layer.cornerRadius = 24
        
        pageControl.numberOfPages = activeReward.parts.count
        pageControl.currentPage = 0
        
        [glowView, glassContainerView, pageControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            bannerContainer.addSubview($0)
        }
        
        videoWrapperView.translatesAutoresizingMaskIntoConstraints = false
        glassContainerView.addSubview(videoWrapperView)
    }

    private func setupStoreSection() {
        storeTitleLabel.text = "Store"
        storeTitleLabel.textColor = .white
        storeTitleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        storeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(storeTitleLabel)
        
        storeGridStack.axis = .vertical
        storeGridStack.spacing = 16
        storeGridStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(storeGridStack)
        
        var currentStack: UIStackView?
        for (index, part) in activeReward.parts.enumerated() {
            if index % 2 == 0 {
                currentStack = UIStackView()
                currentStack?.axis = .horizontal
                currentStack?.spacing = 16
                currentStack?.distribution = .fillEqually
                storeGridStack.addArrangedSubview(currentStack!)
            }
            let card = createStoreItemCard(part: part, index: index)
            currentStack?.addArrangedSubview(card)
        }
    }

    private func createStoreItemCard(part: RewardPart, index: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        card.layer.cornerRadius = 24
        card.tag = index
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleStoreItemTap)))
        
        let img = UIImageView(image: UIImage(named: part.iconName))
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        
        let priceBadge = BadgeLabel(top: 4, left: 10, bottom: 4, right: 10)
        priceBadge.text = "★ \(part.price)"
        priceBadge.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        priceBadge.backgroundColor = UIColor(red: 1.0, green: 0.75, blue: 0.1, alpha: 1)
        priceBadge.layer.cornerRadius = 10
        priceBadge.layer.masksToBounds = true
        priceBadge.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(img)
        card.addSubview(priceBadge)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 150),
            img.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            img.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: -10),
            img.widthAnchor.constraint(equalTo: card.widthAnchor, multiplier: 0.6),
            priceBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            priceBadge.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        return card
    }

    // MARK: Layout Activation
    private func layoutUI() {
        let safe = contentView.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Header
            backButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            profileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            profileButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 34),
            profileButton.heightAnchor.constraint(equalToConstant: 34),
            
            bellButton.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -16),
            bellButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            
            coinBadge.trailingAnchor.constraint(equalTo: bellButton.leadingAnchor, constant: -12),
            coinBadge.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            
            // Banner
            bannerContainer.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 25),
            bannerContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bannerContainer.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            bannerContainer.heightAnchor.constraint(equalToConstant: 320),
            
            glowView.topAnchor.constraint(equalTo: bannerContainer.topAnchor),
            glowView.leadingAnchor.constraint(equalTo: bannerContainer.leadingAnchor),
            glowView.trailingAnchor.constraint(equalTo: bannerContainer.trailingAnchor),
            glowView.heightAnchor.constraint(equalToConstant: 280),
            
            glassContainerView.topAnchor.constraint(equalTo: bannerContainer.topAnchor),
            glassContainerView.leadingAnchor.constraint(equalTo: bannerContainer.leadingAnchor),
            glassContainerView.trailingAnchor.constraint(equalTo: bannerContainer.trailingAnchor),
            glassContainerView.heightAnchor.constraint(equalToConstant: 280),
            
            videoWrapperView.topAnchor.constraint(equalTo: glassContainerView.topAnchor, constant: 12),
            videoWrapperView.bottomAnchor.constraint(equalTo: glassContainerView.bottomAnchor, constant: -12),
            videoWrapperView.leadingAnchor.constraint(equalTo: glassContainerView.leadingAnchor, constant: 12),
            videoWrapperView.trailingAnchor.constraint(equalTo: glassContainerView.trailingAnchor, constant: -12),
            
            pageControl.bottomAnchor.constraint(equalTo: bannerContainer.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: bannerContainer.centerXAnchor),
            
            // Store
            storeTitleLabel.topAnchor.constraint(equalTo: bannerContainer.bottomAnchor, constant: 20),
            storeTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            storeGridStack.topAnchor.constraint(equalTo: storeTitleLabel.bottomAnchor, constant: 16),
            storeGridStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            storeGridStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            storeGridStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: Simulation and Handlers
    private func setupSimulationDisplay() {
        simulationImageView.translatesAutoresizingMaskIntoConstraints = false
        simulationImageView.contentMode = .scaleAspectFit
        simulationImageView.backgroundColor = .clear
        videoWrapperView.addSubview(simulationImageView)
        updateImageFrame(to: currentFrame)
        
        NSLayoutConstraint.activate([
            simulationImageView.topAnchor.constraint(equalTo: videoWrapperView.topAnchor),
            simulationImageView.bottomAnchor.constraint(equalTo: videoWrapperView.bottomAnchor),
            simulationImageView.leadingAnchor.constraint(equalTo: videoWrapperView.leadingAnchor),
            simulationImageView.trailingAnchor.constraint(equalTo: videoWrapperView.trailingAnchor)
        ])
    }
    
    private func updateImageFrame(to index: Int) {
        let frameName = String(format: "%04d", index)
        let path = "\(activeReward.folderName)/\(frameName)"
        
        if let image = UIImage(named: path) {
            simulationImageView.image = image
        }
    }
    
    private func playJoiningAnimation(to target: Int) {
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.currentFrame < target {
                self.currentFrame += 1
                self.updateImageFrame(to: self.currentFrame)
            } else { self.animationTimer?.invalidate() }
        }
    }

    @objc private func handleStoreItemTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, view.tag == nextPurchaseIndex else {
            if let v = sender.view { shakeView(v) }
            return
        }
        let target = activeReward.parts[view.tag].targetFrame
        playJoiningAnimation(to: target)
        
        nextPurchaseIndex += 1
        pageControl.currentPage = nextPurchaseIndex
        updateStoreItemStates()
    }

    private func updateStoreItemStates() {
        for (index, _) in activeReward.parts.enumerated() {
            guard let card = findCardView(by: index) else { continue }
            card.alpha = index < nextPurchaseIndex ? 0.5 : 1.0
        }
    }

    private func findCardView(by tag: Int) -> UIView? {
        for case let rowStack as UIStackView in storeGridStack.arrangedSubviews {
            for view in rowStack.arrangedSubviews where view.tag == tag { return view }
        }
        return nil
    }

    private func setupBackgroundGradient() {
        backgroundGradientLayer.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    private func shakeView(_ view: UIView) {
        let anim = CABasicAnimation(keyPath: "position")
        anim.duration = 0.05; anim.repeatCount = 3; anim.autoreverses = true
        anim.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 4, y: view.center.y))
        anim.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 4, y: view.center.y))
        view.layer.add(anim, forKey: "position")
    }

    @objc private func backButtonTapped() { navigationController?.popViewController(animated: true) }
}
