//
//  SpringOn.swift
//  Cloudyyy_App
//
//  Created by user@5 on 18/11/25.
//

import UIKit

final class SpringOnChildViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let gradientLayer = CAGradientLayer()
    
    // --- SCROLL VIEW SUPPORT ---
    // Essential for Landscape mode support
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Top bar container (Kept pinned to top, outside scrollview for sticky effect, or inside if you want it to scroll)
    // I will put it outside so it stays visible while scrolling content.
    private let topBarContainer = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let coinBadge = PaddingLabel(top: 4, left: 10, bottom: 4, right: 10)
    private let profileButton = UIButton(type: .system)
    
    // Main puzzle card
    private let puzzleCard = UIView()
    private let puzzleImageView = UIImageView()
    private let overlayContainer = UIView() // Holds the grid
    // We use a stack view for the grid rows to ensure auto-resizing on rotation
    private let gridVerticalStack = UIStackView()
    
    // Page Control
    private let picturePageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.numberOfPages = 4
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .white
        pc.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.25)
        return pc
    }()
    
    // Progress
    private let progressTitleLabel = UILabel()
    private let progressBar = UIProgressView(progressViewStyle: .default)
    private let partsLabel = UILabel()
    private let percentLabel = UILabel()
    
    // Store
    private let storeTitleLabel = UILabel()
    private let storeGrid = UIStackView()
    
    // Internal model
    // Note: We need to track the actual blur views to fade them out
    private var pieceViews: [UIView] = []
    private var unlockedPieces: [Bool] = Array(repeating: false, count: 16)
    private var gridBuilt = false
    
    // MARK: - Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupScrollView()
        setupTopBar()
        setupPuzzleCard()
        setupProgress()
        setupStore()
        
        // Layout
        layoutTopBar()
        layoutContent()
        
        // Logic
        updateProgressUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        
        // We build the grid here to ensure the stack view is ready,
        // but since we use AutoLayout/Stacks now, we only need to add them once.
        if !gridBuilt {
            setupGridSystem()
            gridBuilt = true
        }
    }
    
    // MARK: - Setup Basic UI
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 10/255, green: 16/255, blue: 32/255, alpha: 1).cgColor,
            UIColor(red: 24/255, green: 46/255, blue: 92/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        // Hide scroll indicators for cleaner look if desired
        scrollView.showsVerticalScrollIndicator = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            // ScrollView takes up space BELOW the top bar area (layoutTopBar will handle top anchor)
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor), // Go to edge, not safe area, looks better
            
            // ContentView matches ScrollView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Important: Width must match scrollview to prevent horizontal scrolling
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupTopBar() {
        topBarContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBarContainer)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        coinBadge.translatesAutoresizingMaskIntoConstraints = false
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        titleLabel.text = "Spring On"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        
        coinBadge.text = "★ 207"
        coinBadge.font = .systemFont(ofSize: 14, weight: .semibold)
        coinBadge.textColor = .black
        coinBadge.backgroundColor = UIColor(red: 1.0, green: 0.82, blue: 0.0, alpha: 1)
        coinBadge.layer.cornerRadius = 14
        coinBadge.layer.masksToBounds = true
        
        profileButton.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        profileButton.tintColor = .white
        profileButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        topBarContainer.addSubview(backButton)
        topBarContainer.addSubview(titleLabel)
        topBarContainer.addSubview(coinBadge)
        topBarContainer.addSubview(profileButton)
    }
    
    private func layoutTopBar() {
        let safe = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // Container logic
            topBarContainer.topAnchor.constraint(equalTo: safe.topAnchor),
            topBarContainer.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            topBarContainer.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            topBarContainer.heightAnchor.constraint(equalToConstant: 60), // Fixed height for header
            
            // Connect ScrollView to bottom of Header
            scrollView.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor),
            
            // Inside Container
            backButton.leadingAnchor.constraint(equalTo: topBarContainer.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            
            profileButton.trailingAnchor.constraint(equalTo: topBarContainer.trailingAnchor, constant: -16),
            profileButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 32),
            profileButton.heightAnchor.constraint(equalToConstant: 32),
            
            coinBadge.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -10),
            coinBadge.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor)
        ])
    }
    
    private func setupPuzzleCard() {
        puzzleCard.translatesAutoresizingMaskIntoConstraints = false
        puzzleImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayContainer.translatesAutoresizingMaskIntoConstraints = false
        gridVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        puzzleCard.backgroundColor = UIColor(white: 1.0, alpha: 0.06)
        puzzleCard.layer.cornerRadius = 20
        puzzleCard.layer.masksToBounds = true
        
        puzzleImageView.contentMode = .scaleAspectFill
        puzzleImageView.image = UIImage(named: "spring_trip") ?? makePlaceholderBike()
        puzzleImageView.clipsToBounds = true
        
        overlayContainer.backgroundColor = .clear
        
        contentView.addSubview(puzzleCard)
        puzzleCard.addSubview(puzzleImageView)
        puzzleCard.addSubview(overlayContainer)
        overlayContainer.addSubview(gridVerticalStack)
        contentView.addSubview(picturePageControl)
        
        // Grid Stack config
        gridVerticalStack.axis = .vertical
        gridVerticalStack.distribution = .fillEqually
        gridVerticalStack.alignment = .fill
        gridVerticalStack.spacing = 0
    }
    
    private func setupProgress() {
        progressTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        partsLabel.translatesAutoresizingMaskIntoConstraints = false
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        progressTitleLabel.text = "Trip"
        progressTitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        progressTitleLabel.textColor = .white
        progressTitleLabel.textAlignment = .center
        
        progressBar.trackTintColor = UIColor(white: 1.0, alpha: 0.25)
        progressBar.progressTintColor = UIColor.systemBlue
        progressBar.layer.cornerRadius = 2
        progressBar.clipsToBounds = true
        
        partsLabel.font = .systemFont(ofSize: 14, weight: .regular)
        partsLabel.textColor = .white
        
        percentLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        percentLabel.textColor = .white
        percentLabel.textAlignment = .right
        
        contentView.addSubview(progressTitleLabel)
        contentView.addSubview(progressBar)
        contentView.addSubview(partsLabel)
        contentView.addSubview(percentLabel)
    }
    
    private func setupStore() {
        storeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        storeGrid.translatesAutoresizingMaskIntoConstraints = false
        
        storeTitleLabel.text = "Store"
        storeTitleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        storeTitleLabel.textColor = .white
        
        storeGrid.axis = .vertical
        storeGrid.alignment = .fill
        storeGrid.distribution = .fillEqually
        storeGrid.spacing = 12
        
        let counts = [1, 4, 8, 16]
        let labels = ["1x", "4x", "8x", "16x"]
        
        for row in 0..<2 {
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.alignment = .fill
            hStack.distribution = .fillEqually
            hStack.spacing = 12
            
            for col in 0..<2 {
                let index = row * 2 + col
                let button = makeStoreButton(title: labels[index], cost: counts[index] * 10, pieces: counts[index])
                hStack.addArrangedSubview(button)
            }
            storeGrid.addArrangedSubview(hStack)
        }
        
        contentView.addSubview(storeTitleLabel)
        contentView.addSubview(storeGrid)
    }
    
    private func layoutContent() {
        // Padding for the content
        let p: CGFloat = 20
        
        NSLayoutConstraint.activate([
            // Puzzle Card
            puzzleCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            puzzleCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            puzzleCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            // Allow card to grow in landscape if desired, but fixed height is okay too.
            // Let's keep fixed height for consistency, but you might consider aspect ratio constraint instead.
            puzzleCard.heightAnchor.constraint(equalToConstant: 200),
            
            puzzleImageView.topAnchor.constraint(equalTo: puzzleCard.topAnchor),
            puzzleImageView.leadingAnchor.constraint(equalTo: puzzleCard.leadingAnchor),
            puzzleImageView.trailingAnchor.constraint(equalTo: puzzleCard.trailingAnchor),
            puzzleImageView.bottomAnchor.constraint(equalTo: puzzleCard.bottomAnchor),
            
            overlayContainer.topAnchor.constraint(equalTo: puzzleCard.topAnchor),
            overlayContainer.leadingAnchor.constraint(equalTo: puzzleCard.leadingAnchor),
            overlayContainer.trailingAnchor.constraint(equalTo: puzzleCard.trailingAnchor),
            overlayContainer.bottomAnchor.constraint(equalTo: puzzleCard.bottomAnchor),
            
            // Grid Stack fills overlay
            gridVerticalStack.topAnchor.constraint(equalTo: overlayContainer.topAnchor),
            gridVerticalStack.leadingAnchor.constraint(equalTo: overlayContainer.leadingAnchor),
            gridVerticalStack.trailingAnchor.constraint(equalTo: overlayContainer.trailingAnchor),
            gridVerticalStack.bottomAnchor.constraint(equalTo: overlayContainer.bottomAnchor),
            
            // Page Control
            picturePageControl.topAnchor.constraint(equalTo: puzzleCard.bottomAnchor, constant: 6),
            picturePageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Progress
            progressTitleLabel.topAnchor.constraint(equalTo: picturePageControl.bottomAnchor, constant: 12),
            progressTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            progressBar.topAnchor.constraint(equalTo: progressTitleLabel.bottomAnchor, constant: 8),
            progressBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            progressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            progressBar.heightAnchor.constraint(equalToConstant: 6),
            
            partsLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 8),
            partsLabel.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
            
            percentLabel.centerYAnchor.constraint(equalTo: partsLabel.centerYAnchor),
            percentLabel.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor),
            
            // Store
            storeTitleLabel.topAnchor.constraint(equalTo: partsLabel.bottomAnchor, constant: 30),
            storeTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            
            storeGrid.topAnchor.constraint(equalTo: storeTitleLabel.bottomAnchor, constant: 15),
            storeGrid.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            storeGrid.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            
            // IMPORTANT: Bottom constraint for ScrollView content size
            storeGrid.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    // MARK: - Responsive Grid Construction
    
    private func setupGridSystem() {
        // Clear existing if any
        gridVerticalStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pieceViews.removeAll()
        
        let rows = 4
        let cols = 4
        
        for _ in 0..<rows {
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.distribution = .fillEqually
            hStack.alignment = .fill
            hStack.spacing = 0
            
            for _ in 0..<cols {
                let cell = createPuzzlePieceView()
                pieceViews.append(cell)
                hStack.addArrangedSubview(cell)
            }
            
            gridVerticalStack.addArrangedSubview(hStack)
        }
    }
    
    private func createPuzzlePieceView() -> UIView {
        // Container for the piece
        let container = UIView()
        container.backgroundColor = .clear
        
        // Glassy blur tile
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 6
        blur.clipsToBounds = true
        
        container.addSubview(blur)
        
        // Layout the blur with a tiny inset (margin) so we see lines between pieces
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: container.topAnchor, constant: 1),
            blur.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 1),
            blur.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -1),
            blur.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -1)
        ])
        
        // Dim overlay
        let dim = UIView()
        dim.translatesAutoresizingMaskIntoConstraints = false
        dim.backgroundColor = UIColor(white: 0.0, alpha: 0.45)
        blur.contentView.addSubview(dim)
        
        // Icon
        let icon = UIImageView(image: UIImage(systemName: "puzzlepiece.fill"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = UIColor(white: 1.0, alpha: 0.9)
        blur.contentView.addSubview(icon)
        
        NSLayoutConstraint.activate([
            dim.topAnchor.constraint(equalTo: blur.contentView.topAnchor),
            dim.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor),
            dim.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor),
            dim.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor),
            
            icon.centerXAnchor.constraint(equalTo: blur.contentView.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: blur.contentView.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        // Return the PARENT container (which holds the blur)
        // Wait, for animation purposes we want to fade the whole container
        return container
    }
    
    // MARK: - Logic
    
    private func unlockPieces(count: Int) {
        let lockedIndices = unlockedPieces.enumerated()
            .filter { !$0.element }
            .map { $0.offset }
        
        guard !lockedIndices.isEmpty else { return }
        
        let toUnlockCount = min(count, lockedIndices.count)
        var indices = lockedIndices.shuffled()
        let chosen = Array(indices.prefix(toUnlockCount))
        
        for idx in chosen {
            unlockedPieces[idx] = true
            guard idx < pieceViews.count else { continue }
            
            let tileContainer = pieceViews[idx]
            
            // Animate
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseOut], animations: {
                tileContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                tileContainer.alpha = 0
            }, completion: { _ in
                tileContainer.isHidden = true
            })
        }
        
        updateProgressUI()
    }
    
    private func updateProgressUI() {
        let total = unlockedPieces.count
        let unlocked = unlockedPieces.filter { $0 }.count
        let fraction = total > 0 ? Float(unlocked) / Float(total) : 0
        
        progressBar.setProgress(fraction, animated: true)
        partsLabel.text = "\(unlocked)/\(total) Parts"
        
        let percent = Int(round(fraction * 100))
        percentLabel.text = "\(percent)%"
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func storeButtonTapped(_ sender: UIButton) {
        let pieces = sender.tag
        unlockPieces(count: pieces)
    }
    
    // MARK: - Helpers
    
    private func makePlaceholderBike() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 360))
        return renderer.image { ctx in
            UIColor.darkGray.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 600, height: 360))
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            let s = "Bike"
            let size = s.size(withAttributes: attrs)
            s.draw(at: CGPoint(x: (600-size.width)/2, y: (360-size.height)/2), withAttributes: attrs)
        }
    }
    
    private func makeStoreButton(title: String, cost: Int, pieces: Int) -> UIButton {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.isUserInteractionEnabled = false
        blur.layer.cornerRadius = 18
        blur.clipsToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false
        
        b.addSubview(blur)
        
        let quantityLabel = UILabel()
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.text = title
        quantityLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        quantityLabel.textColor = .white.withAlphaComponent(0.9)
        blur.contentView.addSubview(quantityLabel)
        
        let iconView = UIImageView(image: UIImage(systemName: "puzzlepiece.fill"))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        blur.contentView.addSubview(iconView)
        
        let costTag = PaddingLabel(top: 4, left: 8, bottom: 4, right: 8)
        costTag.translatesAutoresizingMaskIntoConstraints = false
        costTag.text = "★ \(cost)"
        costTag.font = .systemFont(ofSize: 14, weight: .bold)
        costTag.textColor = .black
        costTag.backgroundColor = UIColor(red: 1, green: 0.82, blue: 0, alpha: 1)
        costTag.layer.cornerRadius = 10
        costTag.layer.masksToBounds = true
        blur.contentView.addSubview(costTag)
        
        NSLayoutConstraint.activate([
            b.heightAnchor.constraint(equalTo: b.widthAnchor),
            
            blur.topAnchor.constraint(equalTo: b.topAnchor),
            blur.leadingAnchor.constraint(equalTo: b.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: b.trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: b.bottomAnchor),
            
            quantityLabel.topAnchor.constraint(equalTo: blur.contentView.topAnchor, constant: 14),
            quantityLabel.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor, constant: 14),
            
            iconView.centerXAnchor.constraint(equalTo: blur.contentView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: blur.contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalTo: blur.contentView.widthAnchor, multiplier: 0.35),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            
            costTag.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -12),
            costTag.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor, constant: -12)
        ])
        
        b.tag = pieces
        b.addTarget(self, action: #selector(storeButtonTapped(_:)), for: .touchUpInside)
        return b
    }
    
    class PaddingLabel: UILabel {
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
}
