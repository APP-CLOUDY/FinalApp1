import UIKit

final class ProgressViewController: UIViewController {
    
    // MARK: - Properties
    private var kids: [ChildModel] = []
    private var selectedKid: ChildModel?
    
    // MARK: - UI Components
    private let gradient = CAGradientLayer()
    private let header = HomeHeaderView(title: "Progress")
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private var achievementsToEffortsConstraint: NSLayoutConstraint!
    private var achievementsToBottomSpacerConstraint: NSLayoutConstraint!

    // 1. Stats Card
    private let statsCard = StatsCardView()
    
    private let recentLabel: UILabel = {
        let l = UILabel()
        l.text = "Recent Achievement"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .white
        return l
    }()
    
    private let achievementsStack = UIStackView()
    
    private let effortsLabel: UILabel = {
        let l = UILabel()
        l.text = "Efforts"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .white
        return l
    }()
    
    // Container for Efforts
    private let effortsCardContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 40/255, green: 45/255, blue: 65/255, alpha: 1)
        v.layer.cornerRadius = 16
        return v
    }()
    
    private let effortsStack = UIStackView()
    private let bottomSpacer = UIView()
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupGradient()
        setupHeader()
        setupScrollAndContent()
        
        header.onChildTapped = { [weak self] in self?.showKidsMenu() }
        
        // INITIAL LOAD
        fetchKidsAndLoad()
        
        // Auto-refresh on changes
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataChange), name: NSNotification.Name("DataChanged"), object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSelectedKidChanged(_:)),
            name: .selectedKidChanged,
            object: nil
        )

    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if let kid = selectedKid {
            reloadForKid(kid)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    @objc private func handleDataChange() {
        if let kid = selectedKid {
            reloadForKid(kid)
        }
    }
    
    // MARK: - Data Logic
    
    private func fetchKidsAndLoad() {
        _Concurrency.Task {
            do {
                let data = try await FamilyService.shared.fetchDashboard()

                await MainActor.run {
                    self.kids = data.children

                    // Convert to UI Kids
                    let uiKids = self.kids.map { Kid(id: $0.id.uuidString, name: $0.name) }

                    // ⬇️ TELL HEADER ABOUT KIDS
                    self.header.setKids(uiKids)

                    if let first = self.kids.first {
                        self.selectKid(first)
                    } else {
                        self.header.childButton.setTitle("No Kids", for: .normal)
                    }
                }

            } catch {
                print("Error fetching kids: \(error)")
            }
        }
    }

    private func selectKid(_ kid: ChildModel) {
        selectedKid = kid

        // Notify header
        let uiKid = Kid(id: kid.id.uuidString, name: kid.name)
        header.setSelectedKid(uiKid)

        reloadForKid(kid)
    }

    
    private func reloadForKid(_ kid: ChildModel) {
        _Concurrency.Task {
            do {
                let data = try await ProgressService.shared.fetchProgress(for: kid.id)
                
                await MainActor.run {
                    // 1. Stats Card
                    let progress = data.missions_total > 0 ? CGFloat(data.missions_done) / CGFloat(data.missions_total) : 0
                    self.view.layoutIfNeeded()
                    self.statsCard.configure(
                        percentage: progress,
                        tasksDone: "\(data.missions_done)/\(data.missions_total)",
                        todayPoints: "\(data.today_points)",
                        totalPoints: "\(data.total_points)")
                    self.achievementsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

                    if data.achievements.isEmpty {

                        self.recentLabel.isHidden = false

                        let emptyLabel = UILabel()
                        emptyLabel.text = "No recent achievements yet"
                        emptyLabel.textColor = UIColor.white.withAlphaComponent(0.6)
                        emptyLabel.font = .systemFont(ofSize: 14)
                        emptyLabel.textAlignment = .center
                        emptyLabel.numberOfLines = 0

                        self.achievementsStack.addArrangedSubview(emptyLabel)

                    } else {

                        self.recentLabel.isHidden = false

                        for item in data.achievements {
                            let card = AchievementCardView(
                                title: item.title,
                                subtitle: item.subtitle,
                                child: kid.name
                            )
                            card.heightAnchor.constraint(equalToConstant: 72).isActive = true
                            self.achievementsStack.addArrangedSubview(card)
                        }
                    }
                    
                    self.effortsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

                    if data.efforts.isEmpty {
                        self.effortsLabel.isHidden = true
                        self.effortsCardContainer.isHidden = true

                        self.achievementsToEffortsConstraint.isActive = false
                        self.achievementsToBottomSpacerConstraint.isActive = true


                    } else {
                        self.effortsLabel.isHidden = false
                        self.effortsCardContainer.isHidden = false

                        self.achievementsToBottomSpacerConstraint.isActive = false
                        self.achievementsToEffortsConstraint.isActive = true


                        for e in data.efforts {
                            let prog = e.total_count > 0
                                ? Float(e.done_count) / Float(e.total_count)
                                : 0

                            let row = EffortRow(
                                title: e.title,
                                progress: prog,
                                rightText: "\(e.done_count)/\(e.total_count)"
                            )

                            row.heightAnchor.constraint(equalToConstant: 44).isActive = true
                            self.effortsStack.addArrangedSubview(row)
                        }
                    }

                }
            } catch { print("Error fetching progress: \(error)") }
        }
        

    }
    
    // MARK: - Kids Menu
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
    
    // MARK: - Layouts
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
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 98)
        ])
    }
    
    private func setupScrollAndContent() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
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
        
        achievementsStack.axis = .vertical
        achievementsStack.spacing = 12
        
        effortsStack.axis = .vertical
        effortsStack.spacing = 20
        
        [statsCard, recentLabel, achievementsStack, effortsLabel, effortsCardContainer, bottomSpacer]
            .forEach { contentView.addSubview($0) }
        
        effortsCardContainer.addSubview(effortsStack)
        
        [statsCard, recentLabel, achievementsStack, effortsLabel, effortsCardContainer, effortsStack, bottomSpacer]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        achievementsToEffortsConstraint =
            achievementsStack.bottomAnchor.constraint(
                equalTo: effortsLabel.topAnchor,
                constant: -24
            )

        achievementsToBottomSpacerConstraint =
            achievementsStack.bottomAnchor.constraint(
                equalTo: bottomSpacer.topAnchor,
                constant: -24
            )
        NSLayoutConstraint.activate([
            statsCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            statsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            statsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            statsCard.heightAnchor.constraint(equalToConstant: 260),

            recentLabel.topAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: 28),
            recentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            achievementsStack.topAnchor.constraint(equalTo: recentLabel.bottomAnchor, constant: 12),
            achievementsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            achievementsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),

            effortsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            effortsCardContainer.topAnchor.constraint(equalTo: effortsLabel.bottomAnchor, constant: 12),
            effortsCardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            effortsCardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),

            effortsStack.topAnchor.constraint(equalTo: effortsCardContainer.topAnchor, constant: 20),
            effortsStack.leadingAnchor.constraint(equalTo: effortsCardContainer.leadingAnchor, constant: 16),
            effortsStack.trailingAnchor.constraint(equalTo: effortsCardContainer.trailingAnchor, constant: -16),
            effortsStack.bottomAnchor.constraint(equalTo: effortsCardContainer.bottomAnchor, constant: -20),

            bottomSpacer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomSpacer.heightAnchor.constraint(equalToConstant: 80)
        ])

        // Initial hidden states
        effortsLabel.isHidden = true
        effortsCardContainer.isHidden = true
        achievementsToBottomSpacerConstraint.isActive = true


    }
    
    @objc private func handleSelectedKidChanged(_ notification: Notification) {
        guard let uiKid = notification.userInfo?["kid"] as? Kid else { return }

        // Convert UI → real model
        if let realKid = kids.first(where: { $0.id.uuidString == uiKid.id }) {
            selectKid(realKid)    // 🔥 Updates header + reloads API + updates UI
        }
    }

}

// ======================================================
// MARK: - 1. Stats Card
// ======================================================
private final class StatsCardView: UIView {

    // MARK: - Glass
    private let glass = GlassView(style: .card, cornerRadius: 24)

    // MARK: - UI
    private let arcView = HomeProgressArcView()

    private let percentageLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 42, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let tasksLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let todayValue = StatsCardView.bigValue("0")
    private let totalValue = StatsCardView.bigValue("0")

    private static func smallTitle(_ t: String) -> UILabel {
        let l = UILabel()
        l.text = t
        l.textColor = UIColor.white.withAlphaComponent(0.6)
        l.font = .systemFont(ofSize: 13)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private static func bigValue(_ t: String) -> UILabel {
        let l = UILabel()
        l.text = t
        l.textColor = .white
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        glass.translatesAutoresizingMaskIntoConstraints = false
        addSubview(glass)

        glass.addSubview(arcView)
        glass.addSubview(percentageLabel)
        glass.addSubview(tasksLabel)

        let todayTitle = StatsCardView.smallTitle("Today Points")
        let totalTitle = StatsCardView.smallTitle("Total Points")

        let todayStar = UIImageView(image: UIImage(systemName: "star.fill"))
        let totalStar = UIImageView(image: UIImage(systemName: "star.fill"))
        [todayStar, totalStar].forEach {
            $0.tintColor = .systemYellow
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode = .scaleAspectFit
        }

        let divider = UIView()
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        divider.translatesAutoresizingMaskIntoConstraints = false

        glass.addSubview(divider)
        glass.addSubview(todayTitle)
        glass.addSubview(todayValue)
        glass.addSubview(todayStar)
        glass.addSubview(totalTitle)
        glass.addSubview(totalValue)
        glass.addSubview(totalStar)

        arcView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Glass
            glass.topAnchor.constraint(equalTo: topAnchor),
            glass.bottomAnchor.constraint(equalTo: bottomAnchor),
            glass.leadingAnchor.constraint(equalTo: leadingAnchor),
            glass.trailingAnchor.constraint(equalTo: trailingAnchor),

            // Arc
            arcView.centerXAnchor.constraint(equalTo: glass.centerXAnchor),
            arcView.topAnchor.constraint(equalTo: glass.topAnchor, constant: 24),
            arcView.widthAnchor.constraint(equalToConstant: 240),
            arcView.heightAnchor.constraint(equalToConstant: 130),

            percentageLabel.centerXAnchor.constraint(equalTo: glass.centerXAnchor),
            percentageLabel.topAnchor.constraint(equalTo: arcView.topAnchor, constant: 45),

            tasksLabel.centerXAnchor.constraint(equalTo: glass.centerXAnchor),
            tasksLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 4),

            // Divider
            divider.centerXAnchor.constraint(equalTo: glass.centerXAnchor),
            divider.bottomAnchor.constraint(equalTo: glass.bottomAnchor, constant: -20),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 40),

            // Today
            todayValue.trailingAnchor.constraint(equalTo: divider.leadingAnchor, constant: -30),
            todayValue.centerYAnchor.constraint(equalTo: divider.centerYAnchor),
            todayTitle.centerXAnchor.constraint(equalTo: todayValue.centerXAnchor),
            todayTitle.bottomAnchor.constraint(equalTo: todayValue.topAnchor, constant: -4),
            todayStar.leadingAnchor.constraint(equalTo: todayValue.trailingAnchor, constant: 4),
            todayStar.centerYAnchor.constraint(equalTo: todayValue.centerYAnchor),
            todayStar.widthAnchor.constraint(equalToConstant: 16),
            todayStar.heightAnchor.constraint(equalToConstant: 16),

            // Total
            totalValue.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 30),
            totalValue.centerYAnchor.constraint(equalTo: divider.centerYAnchor),
            totalTitle.centerXAnchor.constraint(equalTo: totalValue.centerXAnchor),
            totalTitle.bottomAnchor.constraint(equalTo: totalValue.topAnchor, constant: -4),
            totalStar.leadingAnchor.constraint(equalTo: totalValue.trailingAnchor, constant: 4),
            totalStar.centerYAnchor.constraint(equalTo: totalValue.centerYAnchor),
            totalStar.widthAnchor.constraint(equalToConstant: 16),
            totalStar.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure
    func configure(percentage: CGFloat, tasksDone: String, todayPoints: String, totalPoints: String) {
        arcView.setProgress(percentage)
        percentageLabel.text = "\(Int(percentage * 100))%"
        tasksLabel.text = "\(tasksDone) Tasks Done"
        todayValue.text = todayPoints
        totalValue.text = totalPoints
    }
}

// MARK: - 3. Achievement Card
private final class AchievementCardView: UIView {

    private let glass = GlassView(style: .row, cornerRadius: 14)

    private let icon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.circle.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    init(title: String, subtitle: String, child: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        glass.translatesAutoresizingMaskIntoConstraints = false
        addSubview(glass)

        glass.addSubview(icon)
        glass.addSubview(titleLabel)
        glass.addSubview(subtitleLabel)

        titleLabel.text = title
        subtitleLabel.text = "\(subtitle) • \(child)"

        NSLayoutConstraint.activate([
            // Glass
            glass.topAnchor.constraint(equalTo: topAnchor),
            glass.bottomAnchor.constraint(equalTo: bottomAnchor),
            glass.leadingAnchor.constraint(equalTo: leadingAnchor),
            glass.trailingAnchor.constraint(equalTo: trailingAnchor),

            // Icon
            icon.leadingAnchor.constraint(equalTo: glass.leadingAnchor, constant: 16),
            icon.centerYAnchor.constraint(equalTo: glass.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 32),
            icon.heightAnchor.constraint(equalToConstant: 32),

            // Text
            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: glass.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: glass.topAnchor, constant: 14),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: glass.bottomAnchor, constant: -14)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}


// MARK: - 4. Effort Row
private final class EffortRow: UIView {
    
    private let titleLabel = UILabel()
    private let rightLabel = UILabel()
    private let track = UIView()
    private let fill = UIView()
    
    init(title: String, progress: Float, rightText: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        rightLabel.text = rightText
        rightLabel.font = .systemFont(ofSize: 13, weight: .regular)
        rightLabel.textColor = .white
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        
        track.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        track.layer.cornerRadius = 4
        track.translatesAutoresizingMaskIntoConstraints = false
        
        fill.backgroundColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1) // Blue
        fill.layer.cornerRadius = 4
        fill.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(rightLabel)
        addSubview(track)
        track.addSubview(fill)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            
            rightLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            rightLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            track.leadingAnchor.constraint(equalTo: leadingAnchor),
            track.trailingAnchor.constraint(equalTo: trailingAnchor),
            track.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            track.heightAnchor.constraint(equalToConstant: 8),
            track.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: CGFloat(progress))
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    
    
}
