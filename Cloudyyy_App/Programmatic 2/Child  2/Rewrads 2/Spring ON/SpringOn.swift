import UIKit

final class SpringOnChildViewController: UIViewController {

    // MARK: - UI + Layout state

    // 1. Added ScrollView and ContentView
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let gradientLayer = CAGradientLayer()
    
    private var rewardStats: ChildRewardStats?
    private var progressReport: ProgressReport?
    // Top bar
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let coinBadge = PaddingLabel(top: 4, left: 10, bottom: 4, right: 10)

    // Carousel
    private let carouselScrollView = UIScrollView()
    private let carouselStack = UIStackView()

    // Main puzzle card
    private let puzzleCard = UIView()
    private let overlayContainer = UIView()
    
    // 🔗 Spring On backend
    private var springRewardIds: [UUID] = []
    private var currentRewardIndex: Int = 0
    private var springRewardPoints: [UUID: Int] = [:]
    private var springRewardTitles: [UUID: String] = [:]



    private func configureCarouselWithURLs(_ urls: [URL]) {
        carouselStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for url in urls {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false

            carouselStack.addArrangedSubview(iv)

            NSLayoutConstraint.activate([
                iv.widthAnchor.constraint(equalTo: carouselScrollView.widthAnchor)
            ])

            // Async image load
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        await MainActor.run {
                            iv.image = image
                        }
                    }
                } catch {
                    print("❌ Image load failed:", error)
                }
            }
        }

        picturePageControl.numberOfPages = urls.count
        picturePageControl.isHidden = urls.count <= 1
    }

    // Page Control
    private let picturePageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
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
    private var pieceOverlays: [UIView] = []
    private var unlockedPieces: [Bool] = Array(repeating: false, count: 16)
    private var gridBuilt = false


    // MARK: - Lifecycle

    
    private func updateStoreButtons() {
        let completed = unlockedPieces.allSatisfy { $0 }
        let remaining = 16 - unlockedPieces.filter { $0 }.count

        storeGrid.arrangedSubviews.forEach { row in
            guard let stack = row as? UIStackView else { return }

            stack.arrangedSubviews.forEach { view in
                guard let button = view as? UIButton else { return }

                let pieces = button.tag
                let canBuyPieces = pieces <= remaining
                let enabled = !completed && canBuyPieces

                button.isUserInteractionEnabled = enabled
                button.alpha = enabled ? 1.0 : 0.4
            }
        }
    }

    
    private func loadSpringRewards() async {
        guard let childId = SessionManager.shared.childId else { return }

        do {
            let rewardIds = try await SpringOnService.shared
                .fetchSpringOnRewardIds(childId: childId)

            guard !rewardIds.isEmpty else { return }

            self.springRewardIds = rewardIds

            // ✅ ORDERED IMAGE FETCH (NO TASK GROUP)
            var urls: [URL] = []

            for id in rewardIds {
                let (url, points, title) = try await SpringOnService.shared
                    .fetchSpringOnRewardMedia(rewardId: id)

                springRewardTitles[id] = title
                springRewardPoints[id] = max(points, 100)
                urls.append(url)
            }


            await MainActor.run {
                configureCarouselWithURLs(urls)
                self.updateRewardTitle()   // ✅ INITIAL TITLE
            }

            // load progress for first reward
            await loadProgressForCurrentReward()
            await MainActor.run {
                self.rebuildStoreGrid()
                self.updateStoreButtons()
            }



        } catch {
            print("❌ Failed to load Spring On rewards:", error)
        }
    }
    
    private func updateRewardTitle() {
        guard currentRewardIndex < springRewardIds.count else { return }

        let rewardId = springRewardIds[currentRewardIndex]
        progressTitleLabel.text = springRewardTitles[rewardId] ?? "Reward"
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        // 2. Setup scroll view first
        setupScrollView()
        
        // These functions will now add subviews to the `contentView`
        setupTopBar()
        setupPuzzleCard()
        setupProgress()
        setupStore()
        
        // This function will now add constraints to the `contentView`
        layoutEverything()
        updateProgressUI()
        
        Task {
            await loadStars()
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshStars),
            name: .taskDidComplete,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshStars),
            name: .rewardRedeemed,
            object: nil
        )
        
        Task {
            await loadSpringRewards()
        }


    }

    private func loadProgressForCurrentReward() async {
        guard
            let childId = SessionManager.shared.childId,
            currentRewardIndex < springRewardIds.count
        else { return }

        let rewardId = springRewardIds[currentRewardIndex]

        do {
            let progress = try await SpringOnService.shared.fetchProgress(
                childId: childId,
                rewardId: rewardId
            )

            await MainActor.run {
                unlockedPieces = Array(repeating: false, count: 16)
                for i in 0..<min(progress.unlocked_pieces, 16) {
                    unlockedPieces[i] = true
                }

                pieceOverlays.enumerated().forEach { index, view in
                    let unlocked = index < progress.unlocked_pieces
                    view.isHidden = unlocked
                    view.alpha = unlocked ? 0 : 1
                    view.transform = .identity
                }

                updateProgressUI()
                rebuildStoreGrid()
                updateStoreButtons()


            }
        } catch {
            print("❌ Failed to load progress:", error)
        }
    }

    
    @objc private func refreshStars() {
        Task {
            await loadStars()
        }
    }

    private func updateCoinBadge(old: Int, new: Int) {
        guard new != old else {
            coinBadge.text = "★ \(new)"
            return
        }

        coinBadge.text = "★ \(new)"

        UIView.animate(withDuration: 0.15,
                       animations: {
            self.coinBadge.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) {
                self.coinBadge.transform = .identity
            }
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        buildGridIfNeeded()
    }

    // MARK: - Setup

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 10/255, green: 16/255, blue: 32/255, alpha: 1).cgColor,
            UIColor(red: 24/255, green: 46/255, blue: 92/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func loadStars() async {
        guard let childId = SessionManager.shared.childId else { return }

        let oldStars = progressReport?.current_balance ?? 0

        do {
            let rewardStats = try await ChildHomeService.shared.fetchChildRewardStats()
            let progress = try await ProgressService.shared.fetchStats(
                childId: childId,
                scope: .monthly   // or .weekly
            )

            await MainActor.run {
                self.rewardStats = rewardStats          // 🔒 KEEP
                self.progressReport = progress          // ⭐ SOURCE OF TRUTH
                self.updateCoinBadge(
                    old: oldStars,
                    new: progress.current_balance
                )
            }
        } catch { 
            print("❌ Failed to load stars:", error)
        }
    }


    
    // 2. Added new function to setup scroll view
    private func setupScrollView() {
        scrollView.alwaysBounceVertical = true

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        // Pin ScrollView to the main view's safe area
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Pin ContentView to the ScrollView's content area
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            // Pin ContentView's width to the ScrollView's frame width
            // This is the key to only allow vertical scrolling
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupTopBar() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        coinBadge.translatesAutoresizingMaskIntoConstraints = false

        // Back Button (circle)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        backButton.layer.cornerRadius = 18
        backButton.layer.masksToBounds = true
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        // Title
        titleLabel.text = "Spring On"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white

        // Coin badge
        coinBadge.font = .systemFont(ofSize: 14, weight: .bold)
        coinBadge.textColor = .black
        coinBadge.backgroundColor = UIColor(red: 1.0, green: 0.82, blue: 0.0, alpha: 1)
        coinBadge.layer.cornerRadius = 14
        coinBadge.layer.masksToBounds = true

        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(coinBadge)
    }

    private func setupPuzzleCard() {
        puzzleCard.translatesAutoresizingMaskIntoConstraints = false
        carouselScrollView.translatesAutoresizingMaskIntoConstraints = false
        carouselStack.translatesAutoresizingMaskIntoConstraints = false
        overlayContainer.translatesAutoresizingMaskIntoConstraints = false

        puzzleCard.backgroundColor = UIColor(white: 1.0, alpha: 0.06)
        puzzleCard.layer.cornerRadius = 20
        puzzleCard.layer.masksToBounds = true

        carouselScrollView.isPagingEnabled = true
        carouselScrollView.showsHorizontalScrollIndicator = false
        carouselScrollView.delegate = self

        carouselStack.axis = .horizontal
        carouselStack.alignment = .fill
        carouselStack.distribution = .fillEqually

        overlayContainer.isUserInteractionEnabled = false   // ✅ FIX

        contentView.addSubview(puzzleCard)
        puzzleCard.addSubview(carouselScrollView)
        carouselScrollView.addSubview(carouselStack)
        puzzleCard.addSubview(overlayContainer)

        contentView.addSubview(picturePageControl)
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

        // 3. Add to `contentView` instead of `view`
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

        contentView.addSubview(storeTitleLabel)
        contentView.addSubview(storeGrid)
    }

    private func layoutEverything() {
        // 4. No longer need `safe` guide, as `contentView` is our new reference
        
        NSLayoutConstraint.activate([
            // Top bar (all constraints relative to `contentView`)
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            coinBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            coinBadge.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            // Puzzle card (all constraints relative to `contentView`)
            puzzleCard.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            puzzleCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            puzzleCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            // Reverted to fixed height
            puzzleCard.heightAnchor.constraint(equalToConstant: 190),
            
            carouselScrollView.topAnchor.constraint(equalTo: puzzleCard.topAnchor),
            carouselScrollView.leadingAnchor.constraint(equalTo: puzzleCard.leadingAnchor),
            carouselScrollView.trailingAnchor.constraint(equalTo: puzzleCard.trailingAnchor),
            carouselScrollView.bottomAnchor.constraint(equalTo: puzzleCard.bottomAnchor),

            carouselStack.topAnchor.constraint(equalTo: carouselScrollView.contentLayoutGuide.topAnchor),
            carouselStack.leadingAnchor.constraint(equalTo: carouselScrollView.contentLayoutGuide.leadingAnchor),
            carouselStack.trailingAnchor.constraint(equalTo: carouselScrollView.contentLayoutGuide.trailingAnchor),
            carouselStack.bottomAnchor.constraint(equalTo: carouselScrollView.contentLayoutGuide.bottomAnchor),

            carouselStack.heightAnchor.constraint(equalTo: carouselScrollView.frameLayoutGuide.heightAnchor),


            // 3. Pin the overlay to the puzzleImageView
            overlayContainer.topAnchor.constraint(equalTo: carouselScrollView.topAnchor),
            overlayContainer.leadingAnchor.constraint(equalTo: carouselScrollView.leadingAnchor),
            overlayContainer.trailingAnchor.constraint(equalTo: carouselScrollView.trailingAnchor),
            overlayContainer.bottomAnchor.constraint(equalTo: carouselScrollView.bottomAnchor),
            // --- END DYNAMIC PUZZLE FIX REMOVED ---

            // Page Control
            picturePageControl.topAnchor.constraint(equalTo: puzzleCard.bottomAnchor, constant: 6),
            picturePageControl.centerXAnchor.constraint(equalTo: puzzleCard.centerXAnchor),

            // Progress
            progressTitleLabel.topAnchor.constraint(equalTo: picturePageControl.bottomAnchor, constant: 12),
            progressTitleLabel.centerXAnchor.constraint(equalTo: puzzleCard.centerXAnchor),

            progressBar.topAnchor.constraint(equalTo: progressTitleLabel.bottomAnchor, constant: 6),
            progressBar.leadingAnchor.constraint(equalTo: puzzleCard.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: puzzleCard.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 4),

            partsLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 6),
            partsLabel.leadingAnchor.constraint(equalTo: puzzleCard.leadingAnchor),

            percentLabel.centerYAnchor.constraint(equalTo: partsLabel.centerYAnchor),
            percentLabel.trailingAnchor.constraint(equalTo: puzzleCard.trailingAnchor),

            // Store
            storeTitleLabel.topAnchor.constraint(equalTo: partsLabel.bottomAnchor, constant: 24),
            storeTitleLabel.leadingAnchor.constraint(equalTo: puzzleCard.leadingAnchor),

            storeGrid.topAnchor.constraint(equalTo: storeTitleLabel.bottomAnchor, constant: 12),
            storeGrid.leadingAnchor.constraint(equalTo: puzzleCard.leadingAnchor),
            storeGrid.trailingAnchor.constraint(equalTo: puzzleCard.trailingAnchor),
            
            // 5. This is the *most important* new constraint.
            // It pins the bottom of the last element (the store grid)
            // to the bottom of the `contentView`. This defines the
            // scrollable height.
            storeGrid.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40) // 40pts of padding
        ])
    }

    
    private func configureCarousel(images: [UIImage]) {
        carouselStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for image in images {
            let iv = UIImageView(image: image)
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false

            carouselStack.addArrangedSubview(iv)

            NSLayoutConstraint.activate([
                iv.widthAnchor.constraint(equalTo: carouselScrollView.widthAnchor)
            ])
        }

        picturePageControl.numberOfPages = images.count
        picturePageControl.isHidden = images.count <= 1
    }

    
    // MARK: - Grid / Puzzle pieces
    
    private func buildGridIfNeeded() {
        guard !gridBuilt, overlayContainer.bounds.width > 0 else { return }
        gridBuilt = true
        
        let rows = 4
        let cols = 4
        let w = overlayContainer.bounds.width / CGFloat(cols)
        let h = overlayContainer.bounds.height / CGFloat(rows)
        
        for row in 0..<rows {
            for col in 0..<cols {
                let index = row * cols + col
                
                let frame = CGRect(
                    x: CGFloat(col) * w,
                    y: CGFloat(row) * h,
                    width: w,
                    height: h
                )
                
                // Glassy blur tile
                let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
                blur.frame = frame.insetBy(dx: 1, dy: 1)
                blur.layer.cornerRadius = 6
                blur.clipsToBounds = true
                
                // Slight dark overlay for more contrast
                let dim = UIView(frame: blur.bounds)
                dim.backgroundColor = UIColor(white: 0.0, alpha: 0.45)
                dim.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                blur.contentView.addSubview(dim)
                
                // Puzzle icon
                let icon = UIImageView(image: UIImage(systemName: "puzzlepiece.fill"))
                icon.tintColor = UIColor(white: 1.0, alpha: 0.9)
                icon.translatesAutoresizingMaskIntoConstraints = false
                blur.contentView.addSubview(icon)
                NSLayoutConstraint.activate([
                    icon.centerXAnchor.constraint(equalTo: blur.contentView.centerXAnchor),
                    icon.centerYAnchor.constraint(equalTo: blur.contentView.centerYAnchor),
                    icon.widthAnchor.constraint(equalToConstant: 22),
                    icon.heightAnchor.constraint(equalToConstant: 22)
                ])
                
                overlayContainer.addSubview(blur)
                pieceOverlays.append(blur)
            }
        }
    }
    
    
    private func unlockPieces(count: Int) {
        let lockedIndices = unlockedPieces.enumerated()
            .filter { !$0.element }
            .map { $0.offset }
        
        guard !lockedIndices.isEmpty else { return }
        
        let remaining = 16 - unlockedPieces.filter { $0 }.count
        let toUnlockCount = min(count, remaining)

        
        // Randomly choose tiles to unlock
        var indices = lockedIndices.shuffled()
        let chosen = Array(indices.prefix(toUnlockCount))
        
        for idx in chosen {
            unlockedPieces[idx] = true
            guard idx < pieceOverlays.count else { continue }
            let tile = pieceOverlays[idx]
            
            // Animate fade-out of blur tile
            UIView.animate(withDuration: 0.35,
                           delay: 0,
                           options: [.curveEaseOut],
                           animations: {
                // Modified: Shrink down slightly instead of scaling up.
                // This ensures we never obscure neighbors, and 'fade away' cleanly.
                tile.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                tile.alpha = 0
            }, completion: { _ in
                tile.isHidden = true
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
        percentLabel.text = "\(Int(round(fraction * 100)))%"

        updateStoreButtons() // ✅ ADD THIS
    }

    // MARK: - Actions

    @objc private func backTapped() {
        // This will work as long as this VC was pushed onto a navigation stack
        navigationController?.popViewController(animated: true)
    }
    private func presentNotEnoughStarsPopup() {
        let popup = LockedRewardPopupViewController()
        popup.modalPresentationStyle = .overFullScreen
        present(popup, animated: true)
    }

    @objc private func storeButtonTapped(_ sender: UIButton) {
        let pieces = sender.tag
        let cost = costForPieces(pieces)

        // 🔒 Puzzle already complete
        guard unlockedPieces.contains(false) else { return }

        // 🚫 Not enough stars → SHOW POPUP (NOT DISABLE BUTTON)
        let currentStars = progressReport?.current_balance ?? 0
        if currentStars < cost {
            presentNotEnoughStarsPopup()
            return
        }

        let message = """
        Do you want to spend ★\(cost)
        to unlock \(pieces) puzzle pieces?
        """

        let popup = SpringOnConfirmPurchasePopupViewController(message: message)
        popup.onConfirm = { [weak self] in
            self?.performPurchase(pieces: pieces, cost: cost)
        }

        present(popup, animated: true)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func costForPieces(_ pieces: Int) -> Int {
        guard currentRewardIndex < springRewardIds.count else { return 0 }

        let rewardId = springRewardIds[currentRewardIndex]
        let totalPoints = springRewardPoints[rewardId] ?? 100

        let base = totalPoints / 16
        let remainder = totalPoints % 16

        let unlocked = unlockedPieces.filter { $0 }.count
        let remaining = 16 - unlocked

        // If this purchase completes the puzzle → absorb remainder
        if pieces >= remaining {
            return base * pieces + remainder
        }

        return base * pieces
    }
    
    private func rebuildStoreGrid() {
        storeGrid.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let counts = [1, 4, 8, 16]
        let labels = ["1x", "4x", "8x", "16x"]

        for row in 0..<2 {
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.distribution = .fillEqually
            hStack.spacing = 12

            for col in 0..<2 {
                let index = row * 2 + col
                let pieces = counts[index]
                let cost = costForPieces(pieces)   // ✅ CORRECT

                let button = makeStoreButton(
                    title: labels[index],
                    cost: cost,
                    pieces: pieces
                )

                hStack.addArrangedSubview(button)
            }

            storeGrid.addArrangedSubview(hStack)
        }
    }


    
    private func performPurchase(pieces: Int, cost: Int) {
        guard let childId = SessionManager.shared.childId else { return }
        guard currentRewardIndex < springRewardIds.count else { return }

        let rewardId = springRewardIds[currentRewardIndex]
        let oldStars = progressReport?.current_balance ?? 0

        Task {
            do {
                let progress = try await SpringOnService.shared.unlockPieces(
                    childId: childId,
                    rewardId: rewardId,
                    pieces: pieces,
                    cost: cost
                )

                await MainActor.run {
                    // Update puzzle
                    unlockedPieces = Array(repeating: false, count: 16)
                    for i in 0..<min(progress.unlocked_pieces, 16) {
                        unlockedPieces[i] = true
                    }

                    pieceOverlays.forEach {
                        $0.alpha = 1
                        $0.isHidden = false
                        $0.transform = .identity
                    }

                    for (index, isUnlocked) in unlockedPieces.enumerated() {
                        if isUnlocked {
                            pieceOverlays[index].isHidden = true
                            pieceOverlays[index].alpha = 0
                        }
                    }

                    updateProgressUI()
                    updateStoreButtons()

                    NotificationCenter.default.post(name: .rewardRedeemed, object: nil)

                }

            } catch {
                print("❌ Spring On purchase failed:", error)
            }
        }
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
            s.draw(
                at: CGPoint(x: (600-size.width)/2, y: (360-size.height)/2),
                withAttributes: attrs
            )
        }
    }
    
    
    private func makeStoreButton(title: String, cost: Int, pieces: Int) -> UIButton {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        
        // Use a UIVisualEffectView for the glass effect
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.isUserInteractionEnabled = false
        blur.layer.cornerRadius = 18
        blur.clipsToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false
        
        b.addSubview(blur)
        
        // Top-left label
        let quantityLabel = UILabel()
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.text = title
        quantityLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        quantityLabel.textColor = .white.withAlphaComponent(0.9)
        blur.contentView.addSubview(quantityLabel)
        
        // Center icon
        let iconView = UIImageView(image: UIImage(systemName: "puzzlepiece"))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        blur.contentView.addSubview(iconView)
        
        // Bottom-right cost chip
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
            // Make button square
            b.heightAnchor.constraint(equalTo: b.widthAnchor),
            
            // Blur view fills button
            blur.topAnchor.constraint(equalTo: b.topAnchor),
            blur.leadingAnchor.constraint(equalTo: b.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: b.trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: b.bottomAnchor),
            
            // quantityLabel (Top-left)
            quantityLabel.topAnchor.constraint(equalTo: blur.contentView.topAnchor, constant: 14),
            quantityLabel.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor, constant: 14),
            
            // iconView (Center)
            iconView.centerXAnchor.constraint(equalTo: blur.contentView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: blur.contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalTo: blur.contentView.widthAnchor, multiplier: 0.35), // Scaled size
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            
            // costTag (Bottom-right)
            costTag.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -12),
            costTag.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor, constant: -12)
        ])
        
        b.tag = pieces // This is how many pieces to unlock
        b.addTarget(self, action: #selector(storeButtonTapped(_:)), for: .touchUpInside)
        return b
    }
    
    
    // MARK: - PaddingLabel helper
    
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

extension SpringOnChildViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == carouselScrollView else { return }

        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)

        guard page != currentRewardIndex,
              page < springRewardIds.count else { return }

        currentRewardIndex = page
        picturePageControl.currentPage = page

        // ✅ Load progress ONCE per page
        updateRewardTitle()

        Task {
            await loadProgressForCurrentReward()
            await MainActor.run {
                self.rebuildStoreGrid()
                self.updateStoreButtons()
            }
        }

    }
}
