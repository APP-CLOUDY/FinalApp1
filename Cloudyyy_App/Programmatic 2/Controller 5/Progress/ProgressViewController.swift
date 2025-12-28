import UIKit

// MARK: - Enums
enum TimeScope: Int {
    case weekly = 0
    case monthly = 1
}

final class ProgressViewController: UIViewController {

    // MARK: - Properties
    private var kids: [ChildModel] = []
    private var selectedKid: ChildModel?
    private var currentScope: TimeScope = .weekly

    // MARK: - UI Components
    private let gradient = CAGradientLayer()
    private let header = HomeHeaderView(title: "Progress")
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStack = UIStackView()
    
    // 1. Segment Control
    private lazy var scopeSegment: UISegmentedControl = {
        let items = ["Weekly", "Monthly"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = UIColor(red: 20/255, green: 25/255, blue: 40/255, alpha: 0.8)
        sc.selectedSegmentTintColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        
        let normalAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        let selectedAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 13, weight: .semibold)]
        
        sc.setTitleTextAttributes(normalAttr, for: .normal)
        sc.setTitleTextAttributes(selectedAttr, for: .selected)
        sc.addTarget(self, action: #selector(handleScopeChange(_:)), for: .valueChanged)
        return sc
    }()
    
    // 2. Main Cards
    private let taskCompletionCard = TaskCompletionCard()
    private let pointsRow = PointsOverviewRow()
    
    // 3. Section Headers
    private func createSectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }
    
    private lazy var recentLabel = createSectionHeader("Recent Achievements")
    private lazy var effortsLabel = createSectionHeader("Effort Breakdown")
    
    // 4. Stacks
    private let achievementsStack = UIStackView()
    private let effortsCardContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 30/255, green: 35/255, blue: 55/255, alpha: 0.8)
        v.layer.cornerRadius = 20
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.05).cgColor
        return v
    }()
    private let effortsStack = UIStackView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupGradient()
        setupHeader()
        setupScrollView()
        setupMainStack()
        
        // Embed segment inside card
        taskCompletionCard.embedSegment(scopeSegment)
        
        // Dropdown Action
        header.onChildTapped = { [weak self] in self?.showKidsMenu() }
        
        // 1. Initial Load via Service
        fetchKidsAndLoad()
        
        // 2. Observer for Global Child Selection
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSelectedKidChanged(_:)),
            name: .selectedKidChanged,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Refetch if needed when tab appears
        if let kid = selectedKid {
            updateDataView(for: kid)
        }
    }
    
    // MARK: - Actions
    @objc private func handleScopeChange(_ sender: UISegmentedControl) {
        currentScope = TimeScope(rawValue: sender.selectedSegmentIndex) ?? .weekly
        
        // Animate transition
        UIView.animate(withDuration: 0.15, animations: {
            self.taskCompletionCard.arcContainer.alpha = 0.5
            self.taskCompletionCard.percentageLabel.alpha = 0.5
            self.pointsRow.alpha = 0.5
        }) { _ in
            if let kid = self.selectedKid {
                self.updateDataView(for: kid)
            }
            UIView.animate(withDuration: 0.25) {
                self.taskCompletionCard.arcContainer.alpha = 1.0
                self.taskCompletionCard.percentageLabel.alpha = 1.0
                self.pointsRow.alpha = 1.0
            }
        }
    }
    
    // MARK: - Family Service Logic
    
    private func fetchKidsAndLoad() {
        Task {
            do {
                let dashboardData = try await FamilyService.shared.fetchDashboard()

                await MainActor.run {
                    self.kids = dashboardData.children

                    // Update Header UI
                    let uiKids = kids.map { Kid(id: $0.id.uuidString, name: $0.name) }
                    header.setKids(uiKids)

                    // Logic: Select stored kid OR first available
                    if let storedKid = SelectedKidStore.shared.selectedKid,
                       let realKid = self.kids.first(where: { $0.id.uuidString == storedKid.id }) {
                        selectKid(realKid)
                    } else if let first = kids.first {
                        selectKid(first)
                    }
                }
            } catch {
                print("Error fetching kids in Progress: \(error)")
            }
        }
    }
    
    private func selectKid(_ kid: ChildModel) {
        self.selectedKid = kid
        
        // Update Header
        let uiKid = Kid(id: kid.id.uuidString, name: kid.name)
        header.setSelectedKid(uiKid)
        
        // Update Screen Data
        updateDataView(for: kid)
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
    
    // MARK: - Notification Handler
    @objc private func handleSelectedKidChanged(_ notification: Notification) {
        guard let uiKid = notification.userInfo?["kid"] as? Kid else { return }
        
        if let realKid = kids.first(where: { $0.id.uuidString == uiKid.id }) {
            selectKid(realKid)
        }
    }
    
    // MARK: - Data Update (Backend Connected)
    
    private func updateDataView(for kid: ChildModel) {
        // 1. Clear previous UI
        achievementsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        effortsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let childId = UUID(uuidString: kid.id.uuidString) else { return }
        
        Task {
            do {
                // 🔥 CALL SUPABASE via ProgressService
                let stats = try await ProgressService.shared.fetchStats(childId: childId, scope: currentScope)
                
                await MainActor.run {
                    // A. Update Circle Chart
                    let totalTasks = max(stats.total_tasks, 1) // Prevent divide by zero
                    let percentage = CGFloat(stats.completed_tasks) / CGFloat(totalTasks)
                    
                    self.taskCompletionCard.configure(
                        percentage: percentage,
                        tasksDone: stats.completed_tasks,
                        totalTasks: totalTasks
                    )
                    
                    // B. Update Points
                    // Calculate Goal: Weekly = 350 pts, Monthly = 1500 pts (Adjust as needed)
                    let days = (self.currentScope == .weekly) ? 7 : 30
                    let estimatedGoal = 50 * days
                    
                    self.pointsRow.configure(
                        earned: stats.points_earned,
                        goal: estimatedGoal,
                        totalBalance: stats.current_balance
                    )
                    
                    // C. Update Efforts (Categories)
                    if let breakdown = stats.breakdown, !breakdown.isEmpty {
                        for item in breakdown {
                            let catTotal = max(item.total, 1)
                            let prog = Float(item.count) / Float(catTotal)
                            
                            self.addEffort(
                                title: item.name,
                                prog: prog,
                                text: "\(item.count)/\(item.total)"
                            )
                        }
                    } else {
                        // Empty State
                        self.addEffort(title: "No activity yet", prog: 0.0, text: "0/0")
                    }
                    
                    // D. Dynamic Achievements
                    if stats.points_earned > 100 {
                        self.addAchievement(title: "Point Master", sub: "Earned > 100 pts", kidName: kid.name)
                    }
                    if percentage >= 1.0 && stats.completed_tasks > 0 {
                        self.addAchievement(title: "Perfectionist", sub: "Completed all tasks", kidName: kid.name)
                    } else if percentage >= 0.5 {
                        self.addAchievement(title: "Halfway There", sub: "50% tasks done", kidName: kid.name)
                    }
                }
            } catch {
                print("❌ Error fetching progress stats: \(error)")
            }
        }
    }
    
    private func addAchievement(title: String, sub: String, kidName: String) {
        let card = AchievementCardView(title: title, subtitle: sub, child: kidName)
        achievementsStack.addArrangedSubview(card)
        card.heightAnchor.constraint(equalToConstant: 72).isActive = true
    }
    
    private func addEffort(title: String, prog: Float, text: String) {
        let row = EffortRow(title: title, progress: prog, rightText: text)
        effortsStack.addArrangedSubview(row)
        row.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    // MARK: - Layout Setup
    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 10/255, green: 12/255, blue: 20/255, alpha: 1).cgColor,
            UIColor(red: 28/255, green: 40/255, blue: 70/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func setupHeader() {
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.layer.zPosition = 100
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 98)
        ])
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func setupMainStack() {
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        // 1. Task Card
        taskCompletionCard.heightAnchor.constraint(equalToConstant: 260).isActive = true
        mainStack.addArrangedSubview(taskCompletionCard)
        
        // 2. Points Row
        pointsRow.heightAnchor.constraint(equalToConstant: 110).isActive = true
        mainStack.addArrangedSubview(pointsRow)
        
        // 3. Achievements
        achievementsStack.axis = .vertical
        achievementsStack.spacing = 12
        mainStack.addArrangedSubview(recentLabel)
        mainStack.addArrangedSubview(achievementsStack)
        
        // 4. Efforts
        mainStack.addArrangedSubview(effortsLabel)
        
        effortsCardContainer.addSubview(effortsStack)
        effortsStack.translatesAutoresizingMaskIntoConstraints = false
        effortsStack.axis = .vertical
        effortsStack.spacing = 16
        NSLayoutConstraint.activate([
            effortsStack.topAnchor.constraint(equalTo: effortsCardContainer.topAnchor, constant: 20),
            effortsStack.leadingAnchor.constraint(equalTo: effortsCardContainer.leadingAnchor, constant: 16),
            effortsStack.trailingAnchor.constraint(equalTo: effortsCardContainer.trailingAnchor, constant: -16),
            effortsStack.bottomAnchor.constraint(equalTo: effortsCardContainer.bottomAnchor, constant: -20)
        ])
        mainStack.addArrangedSubview(effortsCardContainer)
    }
}

// ======================================================
// MARK: - HELPER CLASSES
// ======================================================

// 1. Task Completion Card
final class TaskCompletionCard: UIView {
    
    private let glass = GlassView(style: .card, cornerRadius: 28)
    let arcContainer = UIView()
    let arcView = ProgressSemiCircleView()
    let percentageLabel = UILabel()
    
    private let subLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupLayout() {
        addSubview(glass)
        glass.translatesAutoresizingMaskIntoConstraints = false
        
        // Layers
        glass.addSubview(subLabel)
        glass.addSubview(arcContainer)
        arcContainer.addSubview(arcView)
        glass.addSubview(percentageLabel)
        
        // FIX: Interaction disabled on overlapping views so segment works
        arcContainer.isUserInteractionEnabled = false
        percentageLabel.isUserInteractionEnabled = false
        
        percentageLabel.font = .systemFont(ofSize: 46, weight: .heavy)
        percentageLabel.textColor = .white
        percentageLabel.textAlignment = .center
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        arcContainer.translatesAutoresizingMaskIntoConstraints = false
        arcView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            glass.topAnchor.constraint(equalTo: topAnchor),
            glass.bottomAnchor.constraint(equalTo: bottomAnchor),
            glass.leadingAnchor.constraint(equalTo: leadingAnchor),
            glass.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Sublabel (Bottom Text)
            subLabel.bottomAnchor.constraint(equalTo: glass.bottomAnchor, constant: -20),
            subLabel.centerXAnchor.constraint(equalTo: glass.centerXAnchor),
            
            // Arc Container
            arcContainer.centerYAnchor.constraint(equalTo: glass.centerYAnchor, constant: 10),
            arcContainer.centerXAnchor.constraint(equalTo: glass.centerXAnchor),
            arcContainer.widthAnchor.constraint(equalToConstant: 220),
            arcContainer.heightAnchor.constraint(equalToConstant: 110),
            
            // Arc View
            arcView.topAnchor.constraint(equalTo: arcContainer.topAnchor),
            arcView.bottomAnchor.constraint(equalTo: arcContainer.bottomAnchor),
            arcView.leadingAnchor.constraint(equalTo: arcContainer.leadingAnchor),
            arcView.trailingAnchor.constraint(equalTo: arcContainer.trailingAnchor),
            
            percentageLabel.centerXAnchor.constraint(equalTo: arcContainer.centerXAnchor),
            percentageLabel.centerYAnchor.constraint(equalTo: arcContainer.centerYAnchor, constant: 15)
        ])
    }
    
    func embedSegment(_ segment: UIView) {
        addSubview(segment)
        bringSubviewToFront(segment)
        segment.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segment.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            segment.centerXAnchor.constraint(equalTo: centerXAnchor),
            segment.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            segment.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(percentage: CGFloat, tasksDone: Int, totalTasks: Int) {
        arcView.setProgress(percentage)
        percentageLabel.text = "\(Int(percentage * 100))%"
        subLabel.text = "\(tasksDone) of \(totalTasks) Tasks Completed"
    }
}

// 2. Points Overview Row
final class PointsOverviewRow: UIView {
    
    private let glass = GlassView(style: .card, cornerRadius: 24)
    
    private let todayHeaderLabel: UILabel = {
        let l = UILabel()
        l.text = "GOAL PROGRESS"
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = UIColor.white.withAlphaComponent(0.5)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let earnedLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 34, weight: .black)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let goalLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = UIColor.white.withAlphaComponent(0.6)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let progressTrack: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 5
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let progressFill: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.cornerRadius = 5
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        return v
    }()
    
    private let progressGradient = CAGradientLayer()
    
    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let walletIcon = UIImageView(image: UIImage(systemName: "wallet.pass.fill"))
    private let totalLabel = UILabel()
    private let totalHeaderLabel = UILabel()
    
    private var fillWidthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressGradient.frame = CGRect(x: 0, y: 0, width: frame.width, height: 10)
    }
    
    private func setupLayout() {
        addSubview(glass)
        glass.translatesAutoresizingMaskIntoConstraints = false
        
        progressGradient.colors = [
            UIColor(red: 255/255, green: 160/255, blue: 60/255, alpha: 1).cgColor,
            UIColor(red: 255/255, green: 90/255, blue: 40/255, alpha: 1).cgColor
        ]
        progressGradient.startPoint = CGPoint(x: 0, y: 0.5)
        progressGradient.endPoint = CGPoint(x: 1, y: 0.5)
        progressFill.layer.addSublayer(progressGradient)
        
        walletIcon.tintColor = UIColor(red: 100/255, green: 220/255, blue: 150/255, alpha: 1)
        walletIcon.contentMode = .scaleAspectFit
        walletIcon.translatesAutoresizingMaskIntoConstraints = false
        
        totalLabel.font = .systemFont(ofSize: 32, weight: .heavy)
        totalLabel.textColor = .white
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        totalHeaderLabel.text = "BALANCE"
        totalHeaderLabel.font = .systemFont(ofSize: 10, weight: .bold)
        totalHeaderLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        totalHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [glass, todayHeaderLabel, earnedLabel, goalLabel, progressTrack, divider, walletIcon, totalLabel, totalHeaderLabel].forEach {
            if $0 != glass { glass.addSubview($0) }
        }
        progressTrack.addSubview(progressFill)
        
        NSLayoutConstraint.activate([
            glass.topAnchor.constraint(equalTo: topAnchor),
            glass.bottomAnchor.constraint(equalTo: bottomAnchor),
            glass.leadingAnchor.constraint(equalTo: leadingAnchor),
            glass.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.topAnchor.constraint(equalTo: glass.topAnchor, constant: 20),
            divider.bottomAnchor.constraint(equalTo: glass.bottomAnchor, constant: -20),
            divider.trailingAnchor.constraint(equalTo: glass.trailingAnchor, constant: -130),
            
            todayHeaderLabel.topAnchor.constraint(equalTo: glass.topAnchor, constant: 18),
            todayHeaderLabel.leadingAnchor.constraint(equalTo: glass.leadingAnchor, constant: 24),
            
            earnedLabel.topAnchor.constraint(equalTo: todayHeaderLabel.bottomAnchor, constant: 4),
            earnedLabel.leadingAnchor.constraint(equalTo: todayHeaderLabel.leadingAnchor),
            
            goalLabel.bottomAnchor.constraint(equalTo: earnedLabel.firstBaselineAnchor),
            goalLabel.leadingAnchor.constraint(equalTo: earnedLabel.trailingAnchor, constant: 6),
            
            progressTrack.heightAnchor.constraint(equalToConstant: 10),
            progressTrack.leadingAnchor.constraint(equalTo: glass.leadingAnchor, constant: 24),
            progressTrack.trailingAnchor.constraint(equalTo: divider.leadingAnchor, constant: -24),
            progressTrack.bottomAnchor.constraint(equalTo: glass.bottomAnchor, constant: -20),
            
            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),
            
            walletIcon.topAnchor.constraint(equalTo: glass.topAnchor, constant: 24),
            walletIcon.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 16),
            walletIcon.widthAnchor.constraint(equalToConstant: 20),
            walletIcon.heightAnchor.constraint(equalToConstant: 20),
            
            totalHeaderLabel.centerYAnchor.constraint(equalTo: walletIcon.centerYAnchor),
            totalHeaderLabel.leadingAnchor.constraint(equalTo: walletIcon.trailingAnchor, constant: 6),
            
            totalLabel.topAnchor.constraint(equalTo: walletIcon.bottomAnchor, constant: 2),
            totalLabel.leadingAnchor.constraint(equalTo: walletIcon.leadingAnchor)
        ])
        
        fillWidthConstraint = progressFill.widthAnchor.constraint(equalToConstant: 0)
        fillWidthConstraint?.isActive = true
    }
    
    func configure(earned: Int, goal: Int, totalBalance: Int) {
        earnedLabel.text = "\(earned)"
        goalLabel.text = "/ \(goal)"
        totalLabel.text = "\(totalBalance)"
        
        let ratio = goal > 0 ? CGFloat(earned) / CGFloat(goal) : 0
        let clamped = min(max(ratio, 0), 1)
        
        fillWidthConstraint?.isActive = false
        fillWidthConstraint = progressFill.widthAnchor.constraint(equalTo: progressTrack.widthAnchor, multiplier: clamped)
        fillWidthConstraint?.isActive = true
        
        UIView.animate(withDuration: 0.6) { self.layoutIfNeeded() }
    }
}

// 3. Helper: Achievement Card
final class AchievementCardView: UIView {
    private let glass = GlassView(style: .row, cornerRadius: 16)
    
    init(title: String, subtitle: String, child: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(glass)
        glass.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImageView(image: UIImage(systemName: "trophy.fill"))
        icon.tintColor = .systemYellow
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLbl.textColor = .white
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let subLbl = UILabel()
        subLbl.text = "\(subtitle) • \(child)"
        subLbl.font = .systemFont(ofSize: 13)
        subLbl.textColor = UIColor.white.withAlphaComponent(0.6)
        subLbl.translatesAutoresizingMaskIntoConstraints = false
        
        glass.addSubview(icon)
        glass.addSubview(titleLbl)
        glass.addSubview(subLbl)
        
        NSLayoutConstraint.activate([
            glass.topAnchor.constraint(equalTo: topAnchor),
            glass.bottomAnchor.constraint(equalTo: bottomAnchor),
            glass.leadingAnchor.constraint(equalTo: leadingAnchor),
            glass.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            icon.leadingAnchor.constraint(equalTo: glass.leadingAnchor, constant: 16),
            icon.centerYAnchor.constraint(equalTo: glass.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 28),
            icon.heightAnchor.constraint(equalToConstant: 28),
            
            titleLbl.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 16),
            titleLbl.topAnchor.constraint(equalTo: glass.topAnchor, constant: 14),
            titleLbl.trailingAnchor.constraint(equalTo: glass.trailingAnchor, constant: -16),
            
            subLbl.leadingAnchor.constraint(equalTo: titleLbl.leadingAnchor),
            subLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 2),
            subLbl.trailingAnchor.constraint(equalTo: titleLbl.trailingAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// 4. Helper: Effort Row
final class EffortRow: UIView {
    init(title: String, progress: Float, rightText: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.textColor = .white
        titleLbl.font = .systemFont(ofSize: 15, weight: .medium)
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let rightLbl = UILabel()
        rightLbl.text = rightText
        rightLbl.textColor = UIColor.white.withAlphaComponent(0.8)
        rightLbl.font = .systemFont(ofSize: 13)
        rightLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let track = UIView()
        track.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        track.layer.cornerRadius = 3
        track.translatesAutoresizingMaskIntoConstraints = false
        
        let fill = UIView()
        fill.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1)
        fill.layer.cornerRadius = 3
        fill.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLbl)
        addSubview(rightLbl)
        addSubview(track)
        track.addSubview(fill)
        
        NSLayoutConstraint.activate([
            titleLbl.topAnchor.constraint(equalTo: topAnchor),
            titleLbl.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            rightLbl.centerYAnchor.constraint(equalTo: titleLbl.centerYAnchor),
            rightLbl.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            track.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 8),
            track.leadingAnchor.constraint(equalTo: leadingAnchor),
            track.trailingAnchor.constraint(equalTo: trailingAnchor),
            track.heightAnchor.constraint(equalToConstant: 6),
            track.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: CGFloat(progress))
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}
