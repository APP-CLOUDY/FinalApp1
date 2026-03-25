import UIKit

final class SpringOnViewController: UIViewController {

    // MARK: - Properties
    private var kids: [ChildModel] = []
    private var selectedKid: ChildModel?
    
    private var activeItems: [RewardDetailItem] = []
    private var completedItems: [RewardDetailItem] = []
    private var currentBalance: Int = 0

    // MARK: - UI Components
    
    // 1. Header (Pass empty string to hide default title)
    private let header = HomeHeaderView(title: "Spring On")
    private let gradient = CAGradientLayer()
    // Scroll Layout
    private let scrollView = UIScrollView()
    private let content = UIView()

    // Sections
    private let activeLabel = SectionLabel(text: "Upcoming Adventures")
    private let activeScroll = UIScrollView()
    private let activeStack = UIStackView()

    private let completedLabel = SectionLabel(text: "Memories")
    private let completedStack = UIStackView()
    private let bottomSpacer = UIView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupGradient()
        setupHeader()
        
        // Use built-in header (title + dropdown + chevron)
        header.showNotificationButton(false)
        header.showProfileButton(false)
        header.showPlusButton(true)      // optional
        header.showBackButton(true)      // show chevron-in-circle back button

        // Hook up header callbacks
        header.onChildTapped = { [weak self] in self?.showKidsMenu() }
        header.onBackTapped  = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        header.onPlusTapped  = { [weak self] in self?.openNewReward() }

       
        setupScroll()
        setupContentLayout()
        
        header.showPlusButton(true)
        header.onPlusTapped = { [weak self] in self?.openNewReward() }

        fetchKidsAndLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataChange), name: NSNotification.Name("DataChanged"), object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSelectedKidChanged(_:)),
            name: .selectedKidChanged,
            object: nil
        )

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleDataChange() {
        if let kid = selectedKid {
            reloadForKid(kid)
        }
    }
    
    @objc private func didTapChildMenu() {
        showKidsMenu()
    }

    // MARK: - Data Logic
    private func fetchKidsAndLoad() {
        _Concurrency.Task {
            do {
                let data = try await FamilyService.shared.fetchDashboard()
                await MainActor.run {
                    self.kids = data.children
                    let uiKids = self.kids.map { Kid(id: $0.id.uuidString, name: $0.name) }
                    self.header.setKids(uiKids)   // <-- IMPORTANT

                    // restore saved selected kid or pick first
                    if let saved = SelectedKidStore.shared.selectedKid,
                       let realKid = self.kids.first(where: { $0.id.uuidString == saved.id }) {
                        self.selectKid(realKid)
                    } else if let first = self.kids.first {
                        self.selectKid(first)
                    }
                }

            } catch {
                print("Error fetching kids: \(error)")
            }
        }
    }

    private func selectKid(_ kid: ChildModel) {
        self.selectedKid = kid
        self.header.setSelectedKid(Kid(id: kid.id.uuidString, name: kid.name)) // <-- sync header
        SelectedKidStore.shared.updateKid(Kid(id: kid.id.uuidString, name: kid.name))
        reloadForKid(kid)
    }

    private func reloadForKid(_ kid: ChildModel) {
        self.selectedKid = kid
        self.header.setSelectedKid(Kid(id: kid.id.uuidString, name: kid.name))
        
        _Concurrency.Task {
            do {
                let summary = try await RewardService.shared.fetchParentRewardSummary(for: kid.id)
                let lists = try await RewardService.shared.fetchRewards(for: kid.id, category: "Spring On")

                var upcomingItems: [RewardDetailItem] = []
                var memoryItems: [RewardDetailItem] = lists.history.map { item in
                    RewardDetailItem(
                        id: item.id.uuidString,
                        title: item.title,
                        subtitle: item.description ?? "Completed adventure",
                        points: item.points,
                        imageName: item.image_url,
                        isActive: false,
                        claimLimit: item.claim_limit,
                        subType: item.reward_sub_type,
                        progressFraction: 1.0
                    )
                }
                var memoryIDs = Set(memoryItems.map(\.id))

                for item in lists.active {
                    let progress = try? await SpringOnService.shared.fetchProgress(
                        childId: kid.id,
                        rewardId: item.id
                    )

                    let isCompleted = {
                        guard let progress else { return false }
                        return progress.total_pieces > 0 && progress.unlocked_pieces >= progress.total_pieces
                    }()
                    let progressFraction: Float? = {
                        guard let progress, progress.total_pieces > 0 else { return nil }
                        return min(Float(progress.unlocked_pieces) / Float(progress.total_pieces), 1.0)
                    }()

                    let mappedItem = RewardDetailItem(
                        id: item.id.uuidString,
                        title: item.title,
                        subtitle: item.description ?? (isCompleted ? "Completed adventure" : "Ongoing adventure"),
                        points: item.points,
                        imageName: item.image_url,
                        isActive: !isCompleted,
                        claimLimit: item.claim_limit,
                        subType: item.reward_sub_type,
                        progressFraction: progressFraction
                    )

                    if isCompleted {
                        if memoryIDs.insert(mappedItem.id).inserted {
                            memoryItems.append(mappedItem)
                        }
                    } else {
                        upcomingItems.append(mappedItem)
                    }
                }
                
                await MainActor.run {
                    self.currentBalance = summary.currentPoints
                    self.activeItems = upcomingItems
                    self.completedItems = memoryItems
                    
                    self.populateActive(self.activeItems)
                    self.populateCompleted(self.completedItems)
                }
            } catch {
                print("Error loading rewards: \(error)")
            }
        }
    }

    // MARK: - UI Population
    private func populateActive(_ arr: [RewardDetailItem]) {
        activeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, item) in arr.enumerated() {
            let card = ExperienceCard(item: item, currentBalance: currentBalance)
            card.widthAnchor.constraint(equalToConstant: 200).isActive = true
            
            // Edit Tap
            card.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
            card.tag = index
            card.addGestureRecognizer(tap)
            
            activeStack.addArrangedSubview(card)
        }
        
        if arr.isEmpty {
            let lbl = UILabel()
            lbl.text = "No upcoming adventures! 🏕️"
            lbl.textColor = .white
            activeStack.addArrangedSubview(lbl)
        }
    }

    private func populateCompleted(_ arr: [RewardDetailItem]) {
        completedStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if arr.isEmpty {
            let lbl = UILabel()
            lbl.text = "No memories yet"
            lbl.textColor = .white
            completedStack.addArrangedSubview(lbl)
            return
        }

        for item in arr {
            let row = RewardSmallCards(item: item)
            row.heightAnchor.constraint(equalToConstant: 70).isActive = true
            completedStack.addArrangedSubview(row)
        }
    }

    // MARK: - Actions
    @objc private func handleCardTap(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag, index < activeItems.count else { return }
        let item = activeItems[index]
        guard let uuid = UUID(uuidString: item.id) else { return }
        
        let model = RewardItemModel(
            id: uuid,
            title: item.title,
            description: item.subtitle,
            points: item.points,
            image_url: item.imageName,
            claim_limit: item.claimLimit,
            reward_sub_type: item.subType,
            object_3d_id: nil   // ✅ IMPORTANT
        )
        
        let vc = NewRewardViewController()
        vc.mode = .edit(model, category: "Spring On")
        vc.hidesBottomBarWhenPushed = true // ✅ Hides bottom bar
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openNewReward() {
        let vc = NewRewardViewController()
        vc.mode = .create
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showKidsMenu() {
        guard !kids.isEmpty else { return }
        let uiKids = kids.map { Kid(id: $0.id.uuidString, name: $0.name) }
        let menu = FloatingKidsMenu(kids: uiKids)
        menu.manager = FloatingMenuManager.shared
        menu.onKidSelected = { selectedUiKid in
            SelectedKidStore.shared.updateKid(selectedUiKid)
        }
        menu.show(in: view, anchor: header.childButton)
    }
    
    // MARK: - Visuals & Layout
    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func setupHeader() {
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.showNotificationButton(false)
        header.showProfileButton(false)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 110)
        ])
    }

   
    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(content)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupContentLayout() {
        // Do NOT add searchBar or categoryScroll here (removed)
        // We'll add the active and completed sections directly.

        activeScroll.showsHorizontalScrollIndicator = false
        activeScroll.translatesAutoresizingMaskIntoConstraints = false
        activeStack.axis = .horizontal
        activeStack.spacing = 16
        activeStack.translatesAutoresizingMaskIntoConstraints = false
        activeScroll.addSubview(activeStack)
        content.addSubview(activeScroll)

        completedStack.axis = .vertical
        completedStack.spacing = 12
        completedStack.translatesAutoresizingMaskIntoConstraints = false

        // Add labels & stacks
        [activeLabel, activeScroll, completedLabel, completedStack, bottomSpacer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview($0)
        }

        NSLayoutConstraint.activate([
            // Put activeLabel at top of content (was previously below search bar)
            activeLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
            activeLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),

            activeScroll.topAnchor.constraint(equalTo: activeLabel.bottomAnchor, constant: 12),
            activeScroll.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            activeScroll.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            activeScroll.heightAnchor.constraint(equalToConstant: 240),

            activeStack.leadingAnchor.constraint(equalTo: activeScroll.contentLayoutGuide.leadingAnchor),
            activeStack.trailingAnchor.constraint(equalTo: activeScroll.contentLayoutGuide.trailingAnchor, constant: -20),
            activeStack.heightAnchor.constraint(equalTo: activeScroll.frameLayoutGuide.heightAnchor),

            completedLabel.topAnchor.constraint(equalTo: activeScroll.bottomAnchor, constant: 30),
            completedLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),

            completedStack.topAnchor.constraint(equalTo: completedLabel.bottomAnchor, constant: 12),
            completedStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            completedStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),

            bottomSpacer.topAnchor.constraint(equalTo: completedStack.bottomAnchor, constant: 20),
            bottomSpacer.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            bottomSpacer.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            bottomSpacer.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            bottomSpacer.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    
    @objc private func handleSelectedKidChanged(_ notification: Notification) {
        guard let uiKid = notification.userInfo?["kid"] as? Kid else { return }

        if let realKid = kids.first(where: { $0.id.uuidString == uiKid.id }) {
            reloadForKid(realKid)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }


}

// ======================================================
// MARK: - Experience Card (With Image Loader)
// ======================================================
final class ExperienceCard: UIView {
    
    private let titleLabel = UILabel()
    private let costLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let progressLabel = UILabel()
    private let iconView = UILabel()
    private let bgImageView = UIImageView()
    private let dimOverlay = UIView()
    
    init(item: RewardDetailItem, currentBalance: Int) {
        super.init(frame: .zero)
        
        backgroundColor = UIColor(red: 40/255, green: 45/255, blue: 65/255, alpha: 1)
        layer.cornerRadius = 24
        clipsToBounds = true
        
        // Background Image
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.clipsToBounds = true
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bgImageView)
        
        // Dark Overlay
        dimOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimOverlay.translatesAutoresizingMaskIntoConstraints = false
        dimOverlay.isHidden = true
        addSubview(dimOverlay)
        
        // Load Image Logic
        if let urlString = item.imageName, let url = URL(string: urlString) {
            dimOverlay.isHidden = false
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.bgImageView.image = img
                    }
                }
            }
        }
        
        // Icon
        iconView.text = "🎟️"
        if item.title.contains("Zoo") { iconView.text = "🦁" }
        if item.title.contains("Camping") { iconView.text = "⛺️" }
        iconView.font = .systemFont(ofSize: 100)
        iconView.alpha = 0.05
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        if let urlString = item.imageName, !urlString.isEmpty {
            iconView.isHidden = true
        }
        addSubview(iconView)
        
        // Title
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        // Cost
        costLabel.text = "\(item.points) ⭐️"
        costLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        costLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(costLabel)
        
        // Progress Bar
        let walletProgress = Float(currentBalance) / Float(item.points > 0 ? item.points : 1)
        let progress = item.progressFraction ?? walletProgress
        
        progressView.progress = min(progress, 1.0)
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.2)
        progressView.progressTintColor = UIColor(red: 76/255, green: 209/255, blue: 55/255, alpha: 1)
        progressView.layer.cornerRadius = 3
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        
        // Progress Text
        if let progressFraction = item.progressFraction {
            let percent = Int(progressFraction * 100)
            progressLabel.text = percent >= 100 ? "Completed" : "\(percent)% completed"
            progressLabel.textColor = percent >= 100
                ? .systemGreen
                : UIColor.white.withAlphaComponent(0.9)
        } else if currentBalance >= item.points {
            progressLabel.text = "Let's Go! 🚀"
            progressLabel.textColor = .systemGreen
        } else {
            let percent = Int(progress * 100)
            progressLabel.text = "\(percent)% saved"
            progressLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        }
        progressLabel.font = .systemFont(ofSize: 12, weight: .medium)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressLabel)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            bgImageView.topAnchor.constraint(equalTo: topAnchor),
            bgImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bgImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            dimOverlay.topAnchor.constraint(equalTo: topAnchor),
            dimOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            iconView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            costLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            costLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 6),
            
            progressLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -8),
            progressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
