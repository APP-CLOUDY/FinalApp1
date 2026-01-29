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

// MARK: - DreamIt View Controller

final class ChildDreamItViewController: UIViewController {
    
    // MARK: - Properties
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var currentVideoEndTime: Double = 0.0
    private var nextPurchaseIndex = 0
    // 🔁 Multiple Dream It rewards (unique per object)
    private var dreamRewardIds: [UUID] = []
    private var currentRewardIndex: Int = 0

    private var progressReport: ProgressReport?
    private var currentStars: Int = 0
    
    private var parts: [DreamObjectPart] = []
    private var totalSeconds: Int = 0
    private var rewardPoints: Int = 0
    
    private var pendingSeekTime: Double?
    private var playerStatusObserver: NSKeyValueObservation?
    private var isPurchasing = false




    
    // 🔥 Backend-driven state
    var rewardId: UUID!   // passed from RewardsViewController
    private var childId: UUID!


    private var progress: DreamItProgress?

    private func loadStars() async {
        guard let childId = childId else { return }

        let oldStars = currentStars

        do {
            let stats = try await ProgressService.shared.fetchStats(
                childId: childId,
                scope: .monthly
            )

            await MainActor.run {
                self.currentStars = stats.current_balance
                self.updateCoinBadge(old: oldStars, new: stats.current_balance)
            }
        } catch {
            print("❌ Failed to load stars:", error)
        }
    }

    private func updateCoinBadge(old: Int, new: Int) {
        coinBadge.text = "★ \(new)"

        guard old != new else { return }

        UIView.animate(withDuration: 0.15, animations: {
            self.coinBadge.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.coinBadge.transform = .identity
            }
        }
    }

    // --- UI COMPONENTS ---
    private let backgroundGradientLayer = CAGradientLayer()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Top Bar
    private let topBarContainer = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let coinBadge = BadgeLabel(top: 4, left: 10, bottom: 4, right: 10)
    
    
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
        layoutUI()
        
        updateStoreItemStates()
        player?.pause()
        
        childId = ChildSessionManager.shared.currentChildId

        Task {
            await loadStars()
            await loadDreamItRewards()
        }
        print("👶 Current Child ID:", childId ?? "nil")
        print("🎁 Reward ID:", rewardId ?? "nil")

    }
    
    private func loadDreamItRewards() async {
        guard let childId = childId else { return }

        do {
            let ids = try await DreamItService.shared
                .fetchDreamItRewardIds(childId: childId)

            // 🔍 ADD THIS DEBUG LINE
            print("🎯 DreamIt Reward IDs:", ids)

            guard !ids.isEmpty else {
                print("⚠️ No Dream It rewards found for child:", childId)
                return
            }

            dreamRewardIds = ids
            currentRewardIndex = 0
            rewardId = ids.first

            // 🔍 ADD THIS TOO (VERY IMPORTANT)
            print("🎁 Selected Reward ID:", rewardId ?? "nil")

            await MainActor.run {
                let count = self.dreamRewardIds.count

                self.pageControl.numberOfPages = count
                self.pageControl.currentPage = 0

                // ✅ SHOW DOT ONLY IF 2 OR MORE REWARDS
                self.pageControl.isHidden = count < 2
            }


            await loadDreamItProgress()

        } catch {
            print("❌ Failed to load Dream It rewards:", error)
        }
    }


    private func loadDreamItProgress() async {
        guard let childId = childId, let rewardId = rewardId else { return }

        do {
            async let partsTask =
                DreamItService.shared.fetchDreamItParts(rewardId: rewardId)

            async let mediaTask =
                DreamItService.shared.fetchDreamItRewardMedia(rewardId: rewardId)

            let progress = try await DreamItService.shared.fetchProgress(
                childId: childId,
                rewardId: rewardId
            )

            let (parts, media) = try await (partsTask, mediaTask)

            await MainActor.run {
                self.progress = progress
                self.parts = parts
                self.rewardPoints = media.points
                self.totalSeconds = media.totalSeconds

                self.applyProgressToUI(progress)   // FIRST
                self.rebuildStoreUI()              // THEN build UI
                self.setupVideo(url: media.url)

            }

        } catch {
            // 🔑 NEW LOGIC
            print("⚠️ Progress not found, starting fresh Dream It")

            let parts = try? await DreamItService.shared.fetchDreamItParts(rewardId: rewardId)
            let media = try? await DreamItService.shared.fetchDreamItRewardMedia(rewardId: rewardId)

            await MainActor.run {
                self.resetDreamItState()
                self.progress = DreamItProgress(
                    unlocked_parts: 0,
                    total_seconds: media?.totalSeconds ?? 0,
                    completed: false
                )
                self.parts = parts ?? []
                self.rebuildStoreUI()
                if let url = media?.url {
                    self.setupVideo(url: url)
                }
            }
        }
        print("🧩 Parts loaded:", parts.count)

    }


    private func presentErrorState() {
        let alert = UIAlertController(
            title: "Something went wrong",
            message: "This Dream could not be loaded. Please ask your parent to reassign it.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setupStoreSection() {
        storeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        storeTitleLabel.text = "Build Your Dream"
        storeTitleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        storeTitleLabel.textColor = .white

        storeGridStack.translatesAutoresizingMaskIntoConstraints = false
        storeGridStack.axis = .vertical
        storeGridStack.spacing = 16
        storeGridStack.alignment = .fill
        storeGridStack.distribution = .fill

        contentView.addSubview(storeTitleLabel)
        contentView.addSubview(storeGridStack)
    }
    
    private func performPurchase(at index: Int) {
        let part = parts[index]
        let cost = costForPart(part)

        // ✅ Soft UI check (NOT authoritative)
        if currentStars < cost {
            presentNotEnoughStarsPopup()
            return
        }

        let message = """
        Do you want to unlock the \(part.name) for ★\(cost)?
        """

        let popup = SpringOnConfirmPurchasePopupViewController(message: message)
        popup.onConfirm = { [weak self] in
            self?.confirmUnlock(seconds: 1, part: part)
        }

        present(popup, animated: true)
        print("🧮 Cost:", cost)
        print("⭐ Current Stars:", currentStars)

    }

    
    private func costForPart(_ part: DreamObjectPart) -> Int {
        guard parts.count > 0 else { return 0 }

        // total reward points (from media, already fetched)
        let totalRewardPoints = rewardPoints   // 120

        // equal cost per part
        return totalRewardPoints / parts.count
    }


    private func applyProgressToUI(_ progress: DreamItProgress) {
        let unlockedParts = progress.unlocked_parts
        nextPurchaseIndex = unlockedParts

        updateStoreItemStates()

        pendingSeekTime = allowedVideoTime(for: unlockedParts)
        currentVideoEndTime = pendingSeekTime ?? 0
        
        if progress.completed {
            pendingSeekTime = Double(totalSeconds)
        }


        print("🧠 Pending seek set to:", pendingSeekTime ?? -1)
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
    
    private func setupVideo(url: URL) {
        player?.pause()
        timeObserver.map { player?.removeTimeObserver($0) }

        let playerItem = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: playerItem)
        newPlayer.actionAtItemEnd = .pause

        let newLayer = AVPlayerLayer(player: newPlayer)
        newLayer.videoGravity = .resizeAspect
        newLayer.frame = videoWrapperView.bounds

        videoWrapperView.layer.sublayers?.removeAll()
        videoWrapperView.layer.addSublayer(newLayer)

        player = newPlayer
        playerLayer = newLayer

        // ✅ WAIT FOR READY STATE
        playerStatusObserver = playerItem.observe(
            \.status,
            options: [.initial, .new]
        ) { [weak self] item, _ in
            guard let self = self else { return }


            if item.status == .readyToPlay {
                DispatchQueue.main.async {
                    let seekTime = self.pendingSeekTime ?? 0
                    print("🎬 Seeking video to:", seekTime)

                    self.player?.seek(
                        to: CMTime(seconds: seekTime, preferredTimescale: 600),
                        toleranceBefore: .zero,
                        toleranceAfter: .zero
                    )

                    self.pendingSeekTime = nil
                }
            }
        }

        let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            self?.checkVideoProgress(currentTime: time.seconds)
        }
    }


    
    private func checkVideoProgress(currentTime: Double) {
        guard let progress = progress else { return }

        let allowedTime = allowedVideoTime(for: progress.unlocked_parts)

        if currentTime >= allowedTime {
            player?.pause()
        }
        if progress.completed {
            return // allow full playback
        }

    }


    
    // MARK: - Purchase Logic
    
    @objc private func handleStoreItemTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        
        // 🔒 BLOCK ALL PURCHASES IF COMPLETED
           if progress?.completed == true {
               return
           }
        
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
    
    private func confirmUnlock(seconds: Int, part: DreamObjectPart) {
            guard !isPurchasing else { return }
            isPurchasing = true

            Task {
                defer { isPurchasing = false }   // 🔑 CRITICAL

                do {
                    let response = try await DreamItService.shared.unlockNextPart(
                        childId: childId,
                        rewardId: rewardId
                    )

                    let refreshed = try await DreamItService.shared.fetchProgress(
                        childId: childId,
                        rewardId: rewardId
                    )

                    await MainActor.run {
                        guard let newStars = response.remaining_stars else {
                            Task { await self.loadStars() }
                            return
                        }

                        let oldStars = self.currentStars
                        self.currentStars = newStars
                        self.updateCoinBadge(old: oldStars, new: newStars)

                        self.progress = refreshed
                        self.applyProgressToUI(refreshed)
                        self.rebuildStoreUI()
                        
                        // 1. Start the "Building" Animation (Video)
                        self.player?.play()
                        
                        // 🔥 FIX: Calculate the duration of this specific part's video segment
                        // Formula: Total Video Time / Total Number of Parts
                        let partCount = max(1, self.parts.count)
                        let segmentDuration = Double(self.totalSeconds) / Double(partCount)
                        
                        // 2. Schedule the Popup to appear AFTER the video finishes
                        // We add a small 0.5s buffer so the video settles before the popup covers it
                        DispatchQueue.main.asyncAfter(deadline: .now() + segmentDuration + 0.5) { [weak self] in
                            self?.showCongratulationsPopup(for: part)
                        }
                    }

                }  catch {
                    let raw = error.localizedDescription
                    print("❌ Unlock failed:", raw)

                    await MainActor.run {
                        if raw.contains("E_NOT_ENOUGH_STARS") {
                            self.presentNotEnoughStarsPopup()
                        } else if raw.contains("E_PROGRESS_NOT_FOUND") {
                            self.showDebugError(
                                title: "Progress Error",
                                message: "Progress row missing in DB"
                            )
                        } else if raw.contains("E_NO_PARTS") {
                            self.showDebugError(
                                title: "Config Error",
                                message: "No parts mapped to this reward"
                            )
                        } else if raw.contains("E_REWARD_NOT_FOUND") {
                            self.showDebugError(
                                title: "Reward Error",
                                message: "Reward missing in DB"
                            )
                        } else {
                            self.showDebugError(
                                title: "Unknown Error",
                                message: raw
                            )
                        }
                    }
                }
            }
        }

    private func showDebugError(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showGenericErrorPopup() {
        let alert = UIAlertController(
            title: "Something went wrong",
            message: "Please try again in a moment.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Helper: Update Visual States (Locks)
    private func updateStoreItemStates() {
        guard let progress = progress else {
            storeGridStack.arrangedSubviews.forEach { row in
                row.alpha = 1
                row.isUserInteractionEnabled = false
            }
            return
        }

        let completed = progress.completed


        for (index, _) in parts.enumerated() {
            guard let card = findCardView(by: index) else { continue }
            card.viewWithTag(999)?.removeFromSuperview()

            card.isUserInteractionEnabled = !completed

            if completed {
                card.alpha = 0.4
                continue
            }

            if index < nextPurchaseIndex {
                card.alpha = 0.5
            } else if index == nextPurchaseIndex {
                card.alpha = 1.0
            } else {
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
    
    private func showCongratulationsPopup(for part: DreamObjectPart) {
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

        backButton.translatesAutoresizingMaskIntoConstraints = false   // ✅ REQUIRED
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        backButton.layer.cornerRadius = 18
        backButton.layer.masksToBounds = true
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false   // (already correct)
        titleLabel.text = "Dream it"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white

        coinBadge.translatesAutoresizingMaskIntoConstraints = false
        coinBadge.font = .systemFont(ofSize: 14, weight: .bold)
        coinBadge.textColor = .black
        coinBadge.backgroundColor = UIColor(red: 1.0, green: 0.82, blue: 0.0, alpha: 1)
        coinBadge.layer.cornerRadius = 14
        coinBadge.layer.masksToBounds = true

        topBarContainer.addSubview(backButton)
        topBarContainer.addSubview(titleLabel)
        topBarContainer.addSubview(coinBadge)
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
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
        bannerContainer.addSubview(pageControl)
        pageControl.isHidden = true

        
        let swipeLeft = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleDreamRewardSwipe(_:))
        )
        swipeLeft.direction = .left

        let swipeRight = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleDreamRewardSwipe(_:))
        )
        swipeRight.direction = .right

        bannerContainer.addGestureRecognizer(swipeLeft)
        bannerContainer.addGestureRecognizer(swipeRight)


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
            
            // Video sits inside Glass with padding
            videoWrapperView.topAnchor.constraint(equalTo: glassContainerView.topAnchor, constant: 12),
            videoWrapperView.bottomAnchor.constraint(equalTo: glassContainerView.bottomAnchor, constant: -12),
            videoWrapperView.leadingAnchor.constraint(equalTo: glassContainerView.leadingAnchor, constant: 12),
            videoWrapperView.trailingAnchor.constraint(equalTo: glassContainerView.trailingAnchor, constant: -12),

            pageControl.centerXAnchor.constraint(equalTo: bannerContainer.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bannerContainer.bottomAnchor, constant: -10)
        ])
    }
    
    @objc private func handleDreamRewardSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard dreamRewardIds.count > 1 else { return } // 🔒 ADD THIS

        if gesture.direction == .left {
            currentRewardIndex = min(currentRewardIndex + 1, dreamRewardIds.count - 1)
        } else {
            currentRewardIndex = max(currentRewardIndex - 1, 0)
        }

        rewardId = dreamRewardIds[currentRewardIndex]
        pageControl.currentPage = currentRewardIndex

        resetDreamItState()

        Task {
            await loadDreamItProgress()
            await loadStars()
        }
    }

    
    private func resetDreamItState() {
        progress = nil
        nextPurchaseIndex = 0
        currentVideoEndTime = 0
        pendingSeekTime = nil
        player?.pause()
    }

    
    private func rebuildStoreUI() {
        storeGridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        var currentRow: UIStackView?

        for (index, part) in parts.enumerated() {
            if index % 2 == 0 {
                currentRow = UIStackView()
                currentRow?.axis = .horizontal
                currentRow?.distribution = .fillEqually
                currentRow?.spacing = 16
                storeGridStack.addArrangedSubview(currentRow!)
            }

            let card = createStoreItemCard(part: part, index: index)
            currentRow?.addArrangedSubview(card)
        }

        updateStoreItemStates()
        
        print("🧮 rewardPoints:", rewardPoints)
        print("⏱ totalSeconds:", totalSeconds)
        print("🔓 unlocked:", progress?.unlocked_parts ?? -1)


        // 🔥 ADD THESE
        storeGridStack.layoutIfNeeded()
        contentView.layoutIfNeeded()
    }


    private func createStoreItemCard(part: DreamObjectPart, index: Int)->UIView {
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
        priceBadge.font = .systemFont(ofSize: 12, weight: .bold)
        priceBadge.textColor = UIColor(red: 0.2, green: 0.15, blue: 0.05, alpha: 1.0)
        priceBadge.backgroundColor = UIColor(red: 1.0, green: 0.75, blue: 0.1, alpha: 1)
        priceBadge.layer.cornerRadius = 10
        priceBadge.layer.masksToBounds = true
        
        priceBadge.text = "★ \(costForPart(part))"
        
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
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),

            coinBadge.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -p),
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
    
    private func presentNotEnoughStarsPopup() {
        let popup = LockedRewardPopupViewController()
        popup.modalPresentationStyle = .overFullScreen
        present(popup, animated: true)
    }
    private func allowedVideoTime(for unlockedParts: Int) -> Double {
        guard parts.count > 0 else { return 0 }
        return (Double(unlockedParts) / Double(parts.count)) * Double(totalSeconds)
    }

}
