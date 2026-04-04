import UIKit
import SwiftUI

final class RewardsViewController: UIViewController {
    
    // MARK: - Properties
    private var isSpringOnActive: Bool = false
    
    // MARK: - UI Elements
    private let gradientLayer = CAGradientLayer()
    
    private var homeStats: ChildHomeStats?
    private var rewardStats: ChildRewardStats?
    
    private var rewardsByCategory: [String: [AssignedQuickReward]] = [:]
    private var enabledCategories: Set<String> = []
    
    private var progressReport: ProgressReport?
    private var resolvedStreakCount: Int = 0
    private var resolvedWeekStatus: [Bool] = []
    private var rpcCurrentStreak: Int = 0
    
    // 🔁 Multiple Dream It rewards (unique)
    private var dreamRewardIds: [UUID] = []
    private var currentRewardIndex: Int = 0

    
    // Coin Badge Container
    private let coinBadgeView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(red: 255/255, green: 204/255, blue: 92/255, alpha: 1.0)
        v.layer.cornerRadius = 14
        
        v.isUserInteractionEnabled = true
        
        // ✨ Optional glow
        v.layer.shadowColor = UIColor(red: 255/255, green: 200/255, blue: 70/255, alpha: 1).cgColor
        v.layer.shadowOpacity = 0.55
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = .zero
        
        return v
    }()
    
    static func normalizeQuickRewardSubtype(_ title: String) -> String {
        let normalized = title
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // 🔥 HARD FIX FOR ICE CREAM BACKEND VALUE
        if normalized == "icecream" {
            return "ice_cream"
        }

        return normalized
    }
    private struct QuickRewardType {
        let key: String        // backend value
        let title: String      // UI label
        let image: String      // asset name
    }
    private let allQuickRewardTypes: [QuickRewardType] = [
        .init(key: RewardsViewController.normalizeQuickRewardSubtype("Ice Cream"), title: "Ice Cream", image: "reward_icecream"),
        .init(key: RewardsViewController.normalizeQuickRewardSubtype("Chocolate"), title: "Chocolate", image: "reward_chocolate"),
        .init(key: RewardsViewController.normalizeQuickRewardSubtype("Snacks"), title: "Snacks", image: "reward_treat"),
        .init(key: RewardsViewController.normalizeQuickRewardSubtype("Takeaway"), title: "Takeaway", image: "reward_outside_food"),
        .init(key: RewardsViewController.normalizeQuickRewardSubtype("TV Time"), title: "TV Time", image: "reward_cartoon"),
        .init(key: RewardsViewController.normalizeQuickRewardSubtype("Gadget Time"), title: "Gadget Time", image: "reward_screen_time"),
        .init(key: RewardsViewController.normalizeQuickRewardSubtype("Outdoor Play"), title: "Outdoor Play", image: "reward_outdoor"),
        .init(key: RewardsViewController.normalizeQuickRewardSubtype("Toys"), title: "Toys", image: "reward_toys"),
        .init(key: RewardsViewController.normalizeQuickRewardSubtype("Surprise"), title: "Surprise", image: "reward_surprise")
    ]

    
    private func loadQuickRewards() async {
        guard let childId = SessionManager.shared.childId else { return }
        
        do {
            let response = try await ChildRewardsService.shared.getChildRewards(
                childId: childId,
                category: "Quick Rewards"
            )
            
            let allRewards = response.active.compactMap { reward -> ChildRewardItem? in
                guard let subtype = reward.reward_sub_type else { return nil }
                return reward
            }

            let backendGrouped = Dictionary(grouping: allRewards) {
                RewardsViewController.normalizeQuickRewardSubtype($0.reward_sub_type!)
            }


            print("🔍 Backend reward_sub_types:")
            response.active.forEach {
                if let subtype = $0.reward_sub_type {
                    print("→ NORMALIZED:", RewardsViewController.normalizeQuickRewardSubtype(subtype))
                } else {
                    print("⚠️ Skipped reward with NULL subtype:", $0.title)
                }
            }


            print("🔑 Frontend keys:")
            allQuickRewardTypes.forEach {
                print("KEY:", $0.key)
            }
            
            var items: [QuickRewardItem] = []
            var rewardsMap: [String: [AssignedQuickReward]] = [:]
            
            for type in allQuickRewardTypes {
                
                let rewardsForType = backendGrouped[type.key] ?? []
                
                let mappedRewards = rewardsForType.map { item in

                    let isLocked = item.is_locked ?? false

                    return AssignedQuickReward(
                        id: item.id,
                        claimId: item.claim_id,
                        title: item.title,
                        cost: item.points,
                        imageName: type.image,
                        isLocked: isLocked,
                        lockReason: AssignedQuickRewardViewController.lockReason(for: item)
                    )
                }


                let hasAvailable = rewardsForType.contains {
                    !($0.is_locked ?? false)
                }
                
                items.append(
                    QuickRewardItem(
                        title: type.title,
                        imageName: type.image,
                        isEnabled: hasAvailable
                    )
                )

                
                if !mappedRewards.isEmpty {
                    rewardsMap[type.key] = mappedRewards
                }

            }
            // 1️⃣ Enabled first, locked later
            let sortedItems = items.sorted {
                ($0.isEnabled ? 0 : 1) < ($1.isEnabled ? 0 : 1)
            }
            
            await MainActor.run {
                self.quickItems = sortedItems
                self.rewardsByCategory = rewardsMap
                self.quickCollectionView.reloadData()
            }
            
        } catch {
            print("❌ Failed to load quick rewards:", error)
        }
    }
    
    @objc private func coinsTapped() {
        let vc = CoinHistoryViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    
    private func addIdlePulse() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.05
        pulse.duration = 1.8
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        coinBadgeView.layer.add(pulse, forKey: "pulse")
    }
    
    
    private let starIcon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .black)
        iv.image = UIImage(systemName: "star.fill", withConfiguration: config)
        iv.tintColor = UIColor(red: 62/255, green: 52/255, blue: 37/255, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let coinLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = ""
        lb.font = .systemFont(ofSize: 14, weight: .bold)
        lb.textColor = UIColor(red: 62/255, green: 52/255, blue: 37/255, alpha: 1.0)
        return lb
    }()
    
    
    private func updateCoins(_ newValue: Int) {
        coinLabel.text = "\(newValue)"
    }
    
    // Header
    private let headerContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let headerTitle: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Rewards Hub"
        l.font = .systemFont(ofSize: 30, weight: .bold)
        l.textColor = .white
        return l
    }()
    


    // --- Scroll View ---
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .onDrag
        return sv
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // --- Content Elements ---
    private let streakCard: StreakCardView = {
        let v = StreakCardView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.2
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 8
        return v
    }()
    
    private let quickLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Quick Rewards"
        lb.font = .systemFont(ofSize: 18, weight: .semibold)
        lb.textColor = .white
        return lb
    }()
    
    private lazy var quickCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(RewardCell.self, forCellWithReuseIdentifier: RewardCell.reuseID)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
        
    // --- Segment Control Elements ---
    private let segmentContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 24
        v.backgroundColor = UIColor(red: 37/255, green: 42/255, blue: 64/255, alpha: 1.0)
        v.clipsToBounds = true
        return v
    }()
    
    private let segmentIndicator: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 4
        v.layer.shadowOpacity = 0.2
        v.layer.masksToBounds = false
        return v
    }()
    
    private let leftSegment: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Dream It", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        b.setTitleColor(.black, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let rightSegment: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Spring On", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        b.setTitleColor(.white, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private var indicatorLeadingConstraint: NSLayoutConstraint?
    
    // --- Carousel ---
    private let carouselCard: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 24
        iv.backgroundColor = UIColor(white: 1.0, alpha: 0.06)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let carouselTitle: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Build a cycle"
        lb.font = .systemFont(ofSize: 18, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .left
        return lb
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.numberOfPages = 4
        pc.currentPage = 0
        pc.pageIndicatorTintColor = UIColor(white: 1.0, alpha: 0.3)
        pc.currentPageIndicatorTintColor = .white
        return pc
    }()
    
    private let bottomPaddingView = UIView()
    
    // --- Data ---
    private let carouselImages: [UIImage?] = [
        UIImage(named:"Cycle"),
        UIImage(named: "springon"),
        UIImage(systemName: "gift.fill"),
        UIImage(systemName: "headphones")
    ]
    
    private var quickItems: [QuickRewardItem] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupViews()
        
        streakCard.onTap = { [weak self] in
            guard let self = self else { return }
            let vc = StreakPageView()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        // 2. Setup Constraints
        setupConstraints()
        
        setupActions()
        
        carouselCard.image = carouselImages.first ?? UIImage()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(coinsTapped))
        coinBadgeView.addGestureRecognizer(tap)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        carouselCard.addGestureRecognizer(tapGesture)
        
        selectLeft()
        
        Task {
            await loadRewardsHomeData()
        }
        
        loadStreakCount()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshRewards),
            name: .rewardApproved,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshRewards),
            name: .rewardRedeemed,
            object: nil
        )

    }
    
    @objc private func refreshRewards() {
        Task {
            await loadRewardsHomeData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    private func loadStreakCount() {
        Task {
            guard let childId = SessionManager.shared.childId else {
                print("❌ No child logged in")
                return
            }

            do {
                let streak = try await StreakService.shared.getCurrentStreak(childId: childId)
                await MainActor.run {
                    print("🔥 Rewards streak debug -> RPC current streak:", streak)
                    NSLog("🔥 Rewards streak debug -> RPC current streak: \(streak)")
                    self.rpcCurrentStreak = streak
                    self.applyResolvedStreak()
                }
            } catch {
                print("❌ Failed to load streak count:", error)
            }
        }
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)

        // 🔥 FORCE REFRESH WHEN SCREEN COMES BACK
        Task {
            await loadRewardsHomeData()
        }
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentIndicator.layer.cornerRadius = 14
        gradientLayer.frame = view.bounds
    }
    
    private func loadRewardsHomeData() async {
        guard let childId = SessionManager.shared.childId else {
            print("❌ No child logged in")
            return
        }
        
        do {
            await MainActor.run {
                self.homeStats = nil
                self.rewardStats = nil
                self.progressReport = nil
                self.resolvedWeekStatus = []
                self.resolvedStreakCount = 0
                self.rpcCurrentStreak = 0
                self.streakCard.setWeekStatus([])
                self.streakCard.setStreak(0)
            }

            let homeStats = try await ChildHomeService.shared.fetchChildHomeStats()
            let rewardStats = try await ChildHomeService.shared.fetchChildRewardStats()
            let progress = try await ProgressService.shared.fetchStats(
                childId: childId,
                scope: .monthly
            )
            let weekStatus = try await fetchResolvedWeekStatus(childId: childId)

            await MainActor.run {
                self.homeStats = homeStats
                self.rewardStats = rewardStats
                self.progressReport = progress
                self.resolvedWeekStatus = weekStatus
                self.updateRewardsUI()
            }
            
        } catch {
            print("❌ Failed to load rewards home data:", error)
        }
    }

    
    private func updateRewardsUI() {
        guard let homeStats = homeStats else { return }

        let hasCurrentWeekCompletion = resolvedWeekStatus.contains(true)
        resolvedStreakCount = hasCurrentWeekCompletion
            ? max(rpcCurrentStreak, homeStats.current_streak ?? 0)
            : 0

        applyResolvedStreak()
        
        print("🔥 Rewards streak debug -> homeStats.current_streak:", homeStats.current_streak ?? 0)
        print("🔥 Rewards streak debug -> progress.completed_tasks:", progressReport?.completed_tasks ?? 0)
        print("🔥 Rewards streak debug -> has current week completion:", hasCurrentWeekCompletion)
        print("🔥 Rewards streak debug -> backend week_status (unused):", homeStats.week_status ?? [])
        print("🔥 Rewards streak debug -> resolved week_status from streak-month (Mon-Sun):", resolvedWeekStatus)
        NSLog("🔥 Rewards streak debug -> resolved week_status from streak-month (Mon-Sun): \(resolvedWeekStatus)")
        streakCard.setWeekStatus(resolvedWeekStatus)
        
        // ⭐ Coins
        let newCoins = progressReport?.current_balance ?? 0
        updateCoins(newCoins)

        
        Task {
            await loadQuickRewards()
        }
        
    }

    private func applyResolvedStreak() {
        print("🔥 Rewards streak debug -> resolved streak shown on card:", resolvedStreakCount)
        NSLog("🔥 Rewards streak debug -> resolved streak shown on card: \(resolvedStreakCount)")
        streakCard.setStreak(resolvedStreakCount)
    }

    private func fetchResolvedWeekStatus(childId: UUID) async throws -> [Bool] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: today)) else {
            return []
        }

        let weekDates = (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: monday)
        }

        let uniqueMonthYears = Set(weekDates.map {
            let comps = calendar.dateComponents([.year, .month], from: $0)
            return "\(comps.year ?? 0)-\(comps.month ?? 0)"
        })

        var completedDaysByMonth: [String: Set<Int>] = [:]

        for key in uniqueMonthYears {
            let parts = key.split(separator: "-")
            guard parts.count == 2,
                  let year = Int(parts[0]),
                  let month = Int(parts[1]) else { continue }

            let days = try await StreakService.shared.getMonthStreak(
                childId: childId,
                month: month,
                year: year
            )
            completedDaysByMonth[key] = days
        }

        let resolved = weekDates.map { date in
            let comps = calendar.dateComponents([.year, .month, .day], from: date)
            let key = "\(comps.year ?? 0)-\(comps.month ?? 0)"
            let completedDays = completedDaysByMonth[key] ?? []
            return completedDays.contains(comps.day ?? -1)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let labels = weekDates.map { formatter.string(from: $0) }
        print("🔥 Rewards streak debug -> resolved week dates:", labels)
        NSLog("🔥 Rewards streak debug -> resolved week dates: \(labels)")

        return resolved
    }
    
    // MARK: - Setup
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
            
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupViews() {
        view.addSubview(headerContainer)
        
        headerContainer.addSubview(headerTitle)
        headerContainer.addSubview(coinBadgeView)
        
        coinBadgeView.addSubview(starIcon)
        coinBadgeView.addSubview(coinLabel)
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(streakCard)
        contentView.addSubview(quickLabel)
        contentView.addSubview(quickCollectionView)
        
        contentView.addSubview(segmentContainer)
        segmentContainer.addSubview(segmentIndicator)
        segmentContainer.addSubview(leftSegment)
        segmentContainer.addSubview(rightSegment)
        
        contentView.addSubview(carouselCard)
        contentView.addSubview(carouselTitle)
        
        bottomPaddingView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomPaddingView)
        
        quickCollectionView.delegate = self
    
    }
    
    private func setupConstraints() {
        let safe = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // --- Top Bar ---
            headerContainer.topAnchor.constraint(equalTo: safe.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 98),
            
            // TITLE
            headerTitle.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            headerTitle.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 16),
            
            // COIN BADGE
            coinBadgeView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
            coinBadgeView.centerYAnchor.constraint(equalTo: headerTitle.centerYAnchor),
            coinBadgeView.heightAnchor.constraint(equalToConstant: 25),
            coinBadgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),

            // ⭐ Star Icon
            starIcon.leadingAnchor.constraint(equalTo: coinBadgeView.leadingAnchor, constant: 10),
            starIcon.centerYAnchor.constraint(equalTo: coinBadgeView.centerYAnchor),
            starIcon.widthAnchor.constraint(equalToConstant: 12),
            starIcon.heightAnchor.constraint(equalToConstant: 12),
            
            // ⭐ Coin Label
            coinLabel.leadingAnchor.constraint(equalTo: starIcon.trailingAnchor, constant: 4),
            coinLabel.trailingAnchor.constraint(equalTo: coinBadgeView.trailingAnchor, constant: -10),
            coinLabel.centerYAnchor.constraint(equalTo: coinBadgeView.centerYAnchor),
            
            
            // --- Scroll View ---
            scrollView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 2),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // --- Streak Card ---
            streakCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            streakCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            streakCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            streakCard.heightAnchor.constraint(equalToConstant: 143),
            
            // --- Quick Rewards ---
            quickLabel.topAnchor.constraint(equalTo: streakCard.bottomAnchor, constant: 24),
            quickLabel.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor),
            
            quickCollectionView.topAnchor.constraint(equalTo: quickLabel.bottomAnchor, constant: 12),
            quickCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            quickCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quickCollectionView.heightAnchor.constraint(equalToConstant: 110),
            
            // --- Segment Control ---
            segmentContainer.topAnchor.constraint(equalTo: quickCollectionView.bottomAnchor, constant: 16),
            segmentContainer.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor),
            segmentContainer.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor),
            segmentContainer.heightAnchor.constraint(equalToConstant: 36),
            
            segmentIndicator.topAnchor.constraint(equalTo: segmentContainer.topAnchor, constant: 4),
            segmentIndicator.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor, constant: -4),
            segmentIndicator.widthAnchor.constraint(equalTo: segmentContainer.widthAnchor, multiplier: 0.5, constant: -4),
            
            leftSegment.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor),
            leftSegment.topAnchor.constraint(equalTo: segmentContainer.topAnchor),
            leftSegment.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor),
            leftSegment.widthAnchor.constraint(equalTo: segmentContainer.widthAnchor, multiplier: 0.5),
            
            rightSegment.trailingAnchor.constraint(equalTo: segmentContainer.trailingAnchor),
            rightSegment.topAnchor.constraint(equalTo: segmentContainer.topAnchor),
            rightSegment.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor),
            rightSegment.widthAnchor.constraint(equalTo: segmentContainer.widthAnchor, multiplier: 0.5),
            
            // --- Carousel ---
            carouselCard.topAnchor.constraint(equalTo: segmentContainer.bottomAnchor, constant: 24),
            carouselCard.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor),
            carouselCard.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor),
            carouselCard.heightAnchor.constraint(equalToConstant: 180),
            
            carouselTitle.topAnchor.constraint(equalTo: carouselCard.bottomAnchor, constant: 16),
            carouselTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Bottom padding
            bottomPaddingView.topAnchor.constraint(equalTo: carouselTitle.bottomAnchor, constant: 20),
            bottomPaddingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomPaddingView.heightAnchor.constraint(equalToConstant: 100), // Extra space for FAB
            
        ])
        
        indicatorLeadingConstraint = segmentIndicator.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor, constant: 4)
        indicatorLeadingConstraint?.isActive = true
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        leftSegment.addTarget(self, action: #selector(selectLeft), for: .touchUpInside)
        rightSegment.addTarget(self, action: #selector(selectRight), for: .touchUpInside)
    }
    
    // MARK: - Actions
    

    @objc private func selectLeft() {
        isSpringOnActive = false
        animateSegmentChange()
        
        leftSegment.setTitleColor(.black, for: .normal)
        leftSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        
        rightSegment.setTitleColor(.white, for: .normal)
        rightSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        
        let image = carouselImages.first ?? UIImage(systemName: "bicycle")
        updateCarouselContent(title: "Build a cycle", image: image)
    }
    
    @objc private func selectRight() {
        isSpringOnActive = true
        animateSegmentChange()
        
        rightSegment.setTitleColor(.black, for: .normal)
        rightSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        
        leftSegment.setTitleColor(.white, for: .normal)
        leftSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        
        var image: UIImage?
        if carouselImages.count > 1 {
            image = carouselImages[1]
        } else {
            image = UIImage(systemName: "sun.max.fill")
        }
        
        updateCarouselContent(title: "Spring Rewards", image: image)
    }
    

    
    // MARK: - Helpers
    private func updateCarouselContent(title: String, image: UIImage?) {
        self.carouselTitle.text = title
        UIView.transition(with: carouselCard, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.carouselCard.image = image
        }, completion: nil)
    }
    
    private func animateSegmentChange() {
        if isSpringOnActive {
            segmentContainer.layoutIfNeeded()
            indicatorLeadingConstraint?.isActive = false
            indicatorLeadingConstraint = segmentIndicator.trailingAnchor.constraint(equalTo: segmentContainer.trailingAnchor, constant: -4)
            indicatorLeadingConstraint?.isActive = true
        } else {
            segmentContainer.layoutIfNeeded()
            indicatorLeadingConstraint?.isActive = false
            indicatorLeadingConstraint = segmentIndicator.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor, constant: 4)
            indicatorLeadingConstraint?.isActive = true
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.segmentContainer.layoutIfNeeded()
        }
    }
    
    @objc private func handleCardTap() {
        if isSpringOnActive {
            let vc = SpringOnChildViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = ChildDreamItViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func presentQuickRewardClaimPopup(reward: AssignedQuickReward) {
        let popup = QuickRewardClaimPopupViewController()
        popup.reward = reward
        popup.modalPresentationStyle = .overFullScreen
        present(popup, animated: true)
    }
}

// MARK: - Collection View Extension
extension RewardsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        quickItems.count
    }
    
    func collectionView(
          _ collectionView: UICollectionView,
          layout collectionViewLayout: UICollectionViewLayout,
          sizeForItemAt indexPath: IndexPath
      ) -> CGSize {
          return CGSize(width: 80, height: 100)
      }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RewardCell.reuseID,
            for: indexPath
        ) as! RewardCell

        let item = quickItems[indexPath.item]
        cell.configure(
            title: item.title,
            image: UIImage(named: item.imageName),
            isEnabled: item.isEnabled
        )

        cell.contentView.alpha = item.isEnabled ? 1.0 : 0.5
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let item = quickItems[indexPath.item]

        guard item.isEnabled else {
            let popup = LockedRewardPopupViewController()
            popup.modalPresentationStyle = .overFullScreen
            popup.modalTransitionStyle = .crossDissolve
            present(popup, animated: true)
            return
        }

        // 🔥 FIX: Normalize the key for consistency
        let key = RewardsViewController.normalizeQuickRewardSubtype(item.title)
        let rewards = rewardsByCategory[key] ?? []

        print("🔑 Lookup key:", key)
        print("📦 rewardsByCategory keys:", rewardsByCategory.keys)


        if rewards.count == 1 {
            presentQuickRewardClaimPopup(reward: rewards[0])
        } else {
            let vc = AssignedQuickRewardViewController()
            vc.rewardTypeTitle = item.title
            
            // 🔥 THE FIX: Use categoryKey instead of rewardIconName
            vc.categoryKey = key
            
            vc.assignedRewards = rewards
            navigationController?.pushViewController(vc, animated: true)
        }
        print("Tapped:", item.title)
        print("Rewards:", rewards)
    }
}
