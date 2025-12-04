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
        l.text = "Their Efforts"
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
                    if let first = self.kids.first {
                        self.selectKid(first)
                    } else {
                        self.header.childButton.setTitle("No Kids", for: .normal)
                    }
                }
            } catch { print("Error fetching kids: \(error)") }
        }
    }
    
    private func selectKid(_ kid: ChildModel) {
        selectedKid = kid
        header.childButton.setTitle("\(kid.name) ▾", for: .normal)
        reloadForKid(kid)
    }
    
    private func reloadForKid(_ kid: ChildModel) {
        _Concurrency.Task {
            do {
                let data = try await ProgressService.shared.fetchProgress(for: kid.id)
                
                await MainActor.run {
                    // 1. Stats Card
                    let progress = data.missions_total > 0 ? CGFloat(data.missions_done) / CGFloat(data.missions_total) : 0
                    self.statsCard.configure(
                        percentage: progress,
                        tasksDone: "\(data.missions_done)/\(data.missions_total)",
                        todayPoints: "\(data.today_points)",
                        totalPoints: "\(data.total_points)"
                    )
                    
                    // 2. Achievements
                    self.achievementsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
                    if data.achievements.isEmpty {
                        let lbl = UILabel()
                        lbl.text = "No recent achievements yet"
                        lbl.textColor = UIColor.white.withAlphaComponent(0.6)
                        self.achievementsStack.addArrangedSubview(lbl)
                    } else {
                        for item in data.achievements {
                            let card = AchievementCardView(title: item.title, subtitle: item.subtitle, child: kid.name)
                            card.heightAnchor.constraint(equalToConstant: 72).isActive = true
                            self.achievementsStack.addArrangedSubview(card)
                        }
                    }
                    
                    // 3. Efforts
                    self.effortsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
                    if data.efforts.isEmpty {
                        let lbl = UILabel()
                        lbl.text = "No category data available"
                        lbl.textColor = UIColor.white.withAlphaComponent(0.6)
                        lbl.textAlignment = .center
                        self.effortsStack.addArrangedSubview(lbl)
                    } else {
                        for e in data.efforts {
                            let prog = e.total_count > 0 ? Float(e.done_count) / Float(e.total_count) : 0
                            let row = EffortRow(title: e.title, progress: prog, rightText: "\(e.done_count)/\(e.total_count)")
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
        menu.onKidSelected = { [weak self] selectedUiKid in
            if let realKid = self?.kids.first(where: { $0.id.uuidString == selectedUiKid.id }) {
                self?.selectKid(realKid)
            }
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
            header.heightAnchor.constraint(equalToConstant: 110)
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
            
            effortsLabel.topAnchor.constraint(equalTo: achievementsStack.bottomAnchor, constant: 24),
            effortsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            effortsCardContainer.topAnchor.constraint(equalTo: effortsLabel.bottomAnchor, constant: 12),
            effortsCardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            effortsCardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            
            effortsStack.topAnchor.constraint(equalTo: effortsCardContainer.topAnchor, constant: 20),
            effortsStack.leadingAnchor.constraint(equalTo: effortsCardContainer.leadingAnchor, constant: 16),
            effortsStack.trailingAnchor.constraint(equalTo: effortsCardContainer.trailingAnchor, constant: -16),
            effortsStack.bottomAnchor.constraint(equalTo: effortsCardContainer.bottomAnchor, constant: -20),
            
            bottomSpacer.topAnchor.constraint(equalTo: effortsCardContainer.bottomAnchor, constant: 28),
            bottomSpacer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomSpacer.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}

// ======================================================
// MARK: - 1. Stats Card
// ======================================================
private final class StatsCardView: UIView {
    
    private let blur: UIVisualEffectView = {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        v.layer.cornerRadius = 24
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let container = UIView()
    private let arcView = ProgressSemiCircleView()
    
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
        l.font = .systemFont(ofSize: 13, weight: .regular)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        
        let bg = UIView()
        bg.backgroundColor = UIColor(red: 40/255, green: 45/255, blue: 65/255, alpha: 0.7)
        bg.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(blur)
        blur.contentView.addSubview(bg)
        blur.contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let todayTitle = StatsCardView.smallTitle("Today Points")
        let totalTitle = StatsCardView.smallTitle("Total Points")
        let todayStar = UIImageView(image: UIImage(systemName: "star.fill"))
        let totalStar = UIImageView(image: UIImage(systemName: "star.fill"))
        [todayStar, totalStar].forEach { $0.tintColor = .systemYellow; $0.translatesAutoresizingMaskIntoConstraints = false; $0.contentMode = .scaleAspectFit }
        
        let divider = UIView()
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(arcView)
        container.addSubview(percentageLabel)
        container.addSubview(tasksLabel)
        container.addSubview(divider)
        container.addSubview(todayTitle)
        container.addSubview(todayValue)
        container.addSubview(todayStar)
        container.addSubview(totalTitle)
        container.addSubview(totalValue)
        container.addSubview(totalStar)
        
        arcView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            bg.topAnchor.constraint(equalTo: blur.topAnchor),
            bg.bottomAnchor.constraint(equalTo: blur.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
            
            container.topAnchor.constraint(equalTo: blur.contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor),
            
            arcView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            arcView.topAnchor.constraint(equalTo: container.topAnchor, constant: 25),
            arcView.widthAnchor.constraint(equalToConstant: 240),
            arcView.heightAnchor.constraint(equalToConstant: 130),
            
            percentageLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            percentageLabel.topAnchor.constraint(equalTo: arcView.topAnchor, constant: 45),
            
            tasksLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            tasksLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 4),
            
            divider.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            divider.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 40),
            
            todayValue.trailingAnchor.constraint(equalTo: divider.leadingAnchor, constant: -30),
            todayValue.centerYAnchor.constraint(equalTo: divider.centerYAnchor, constant: 2),
            todayTitle.centerXAnchor.constraint(equalTo: todayValue.centerXAnchor),
            todayTitle.bottomAnchor.constraint(equalTo: todayValue.topAnchor, constant: -4),
            todayStar.leadingAnchor.constraint(equalTo: todayValue.trailingAnchor, constant: 4),
            todayStar.centerYAnchor.constraint(equalTo: todayValue.centerYAnchor),
            todayStar.widthAnchor.constraint(equalToConstant: 16),
            todayStar.heightAnchor.constraint(equalToConstant: 16),
            
            totalValue.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 30),
            totalValue.centerYAnchor.constraint(equalTo: divider.centerYAnchor, constant: 2),
            totalTitle.centerXAnchor.constraint(equalTo: totalValue.centerXAnchor),
            totalTitle.bottomAnchor.constraint(equalTo: totalValue.topAnchor, constant: -4),
            totalStar.leadingAnchor.constraint(equalTo: totalValue.trailingAnchor, constant: 4),
            totalStar.centerYAnchor.constraint(equalTo: totalValue.centerYAnchor),
            totalStar.widthAnchor.constraint(equalToConstant: 16),
            totalStar.heightAnchor.constraint(equalToConstant: 16),
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(percentage: CGFloat, tasksDone: String, todayPoints: String, totalPoints: String) {
        arcView.setProgress(percentage)
        percentageLabel.text = "\(Int(percentage * 100))%"
        tasksLabel.text = "\(tasksDone) Tasks Done"
        todayValue.text = todayPoints
        totalValue.text = totalPoints
    }
}

// MARK: - 2. Progress Semi-Circle View
private final class ProgressSemiCircleView: UIView {
    private let track = CAShapeLayer()
    private let progress = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        track.fillColor = UIColor.clear.cgColor
        track.strokeColor = UIColor.white.withAlphaComponent(0.1).cgColor
        track.lineWidth = 14
        track.lineCap = .round
        
        progress.fillColor = UIColor.clear.cgColor
        progress.strokeColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1).cgColor
        progress.lineWidth = 14
        progress.lineCap = .round
        progress.strokeEnd = 0
        
        layer.addSublayer(track)
        layer.addSublayer(progress)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.maxY - 10)
        let radius = bounds.width / 2 - 10
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: .pi,
            endAngle: 0,
            clockwise: true
        )
        track.path = path.cgPath
        progress.path = path.cgPath
    }
    
    func setProgress(_ val: CGFloat) {
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = progress.strokeEnd
        anim.toValue = val
        anim.duration = 0.5
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        progress.strokeEnd = val
        progress.add(anim, forKey: "anim")
    }
}

// MARK: - 3. Achievement Card
private final class AchievementCardView: UIView {
    
    private let container = UIView()
    private let icon = UIImageView(image: UIImage(systemName: "person.circle"))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    init(title: String, subtitle: String, child: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        container.backgroundColor = UIColor(red: 40/255, green: 45/255, blue: 65/255, alpha: 1)
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.text = "\(subtitle) • \(child)"
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(icon)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 32),
            icon.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
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
