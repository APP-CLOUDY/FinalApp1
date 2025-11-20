//
// ProgressViewController.swift
//

import UIKit

final class ProgressViewController: UIViewController {
    
    // MARK: - UI Components
    private let gradient = CAGradientLayer()
    private let header = HomeHeaderView(title: "Progress")
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let statsCard = StatsCardView()
    
    private let recentLabel: UILabel = {
        let l = UILabel()
        l.text = "Recent Achievement"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .white
        return l
    }()
    
    private let achievementsStack = UIStackView()
    private let effortsStack = UIStackView()
    
    private let effortsLabel: UILabel = {
        let l = UILabel()
        l.text = "Efforts"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .white
        return l
    }()
    
    private let bottomSpacer = UIView()
    private var bottomSpacerHeightConstraint: NSLayoutConstraint?
    
    // ======================================================
    // MARK: - Lifecycle
    // ======================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupGradient()
        setupHeader()
        setupScrollAndContent()
        
        // Handle dropdown tap
        header.onChildTapped = { [weak self] in
            self?.showKidsMenu()
        }
        
        // Observe change from ChildManager (sync across all pages)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onKidChanged(_:)),
            name: ChildManager.kidChangedNotification,
            object: nil
        )
        
        // INITIAL LOAD
        if let kid = ChildManager.shared.selectedKid {
            header.childButton.setTitle("\(kid.name) ▾", for: .normal)
            reloadForKid(kid)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
        bottomSpacerHeightConstraint?.constant = max(24, view.safeAreaInsets.bottom + 12)
    }
    
    // ======================================================
    // MARK: - Gradient
    // ======================================================
    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 8/255, green: 12/255, blue: 48/255, alpha: 1).cgColor,
            UIColor(red: 10/255, green: 18/255, blue: 60/255, alpha: 1).cgColor,
            UIColor(red: 17/255, green: 41/255, blue: 87/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    // ======================================================
    // MARK: - Header
    // ======================================================
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
    
    // ======================================================
    // MARK: - Scroll + Content Layout
    // ======================================================
    private func setupScrollAndContent() {
        
        // SCROLLVIEW
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
        
        // STACKS
        achievementsStack.axis = .vertical
        achievementsStack.spacing = 12
        effortsStack.axis = .vertical
        effortsStack.spacing = 12
        
        // ADD SUBVIEWS
        [statsCard, recentLabel, achievementsStack, effortsLabel, effortsStack, bottomSpacer]
            .forEach { contentView.addSubview($0) }
        
        statsCard.translatesAutoresizingMaskIntoConstraints = false
        recentLabel.translatesAutoresizingMaskIntoConstraints = false
        achievementsStack.translatesAutoresizingMaskIntoConstraints = false
        effortsLabel.translatesAutoresizingMaskIntoConstraints = false
        effortsStack.translatesAutoresizingMaskIntoConstraints = false
        bottomSpacer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            statsCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            statsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            statsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            statsCard.heightAnchor.constraint(equalToConstant: 270),
            
            recentLabel.topAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: 28),
            recentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            achievementsStack.topAnchor.constraint(equalTo: recentLabel.bottomAnchor, constant: 12),
            achievementsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            achievementsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            
            effortsLabel.topAnchor.constraint(equalTo: achievementsStack.bottomAnchor, constant: 20),
            effortsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            effortsStack.topAnchor.constraint(equalTo: effortsLabel.bottomAnchor, constant: 12),
            effortsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            effortsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            
            bottomSpacer.topAnchor.constraint(equalTo: effortsStack.bottomAnchor, constant: 28),
            bottomSpacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomSpacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomSpacer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        bottomSpacerHeightConstraint = bottomSpacer.heightAnchor.constraint(equalToConstant: 80)
        bottomSpacerHeightConstraint?.isActive = true
    }
    
    // ======================================================
    // MARK: - Floating Dropdown
    // ======================================================
    private func showKidsMenu() {
        let kids = ChildManager.shared.kids
        guard !kids.isEmpty else { return }
        let menu = FloatingKidsMenu(kids: ChildManager.shared.kids)
        menu.manager = FloatingMenuManager.shared
        menu.onKidSelected = { kid in
            ChildManager.shared.selectedKid = kid
        }
        menu.show(in: view, anchor: header.childButton)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FloatingMenuManager.shared.pageDidChange()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FloatingMenuManager.shared.pageDidChange()   // <-- closes the dropdown
    }
    
    // ======================================================
    // MARK: - Notification Sync
    // ======================================================
    @objc private func onKidChanged(_ n: Notification) {
        guard let kid = n.object as? Kid else { return }
        header.childButton.setTitle("\(kid.name) ▾", for: .normal)
        reloadForKid(kid)
    }
    
    // ======================================================
    // MARK: - UI Refresh
    // ======================================================
    private func reloadForKid(_ kid: Kid) {
        
        let data = ChildManager.shared.dataForKid(kid.id)

        
        statsCard.configure(
            percentage: data.progress,
            tasksDone: data.tasksDoneText,
            todayPoints: data.todayPoints,
            totalPoints: data.totalPoints
        )
        
        // ACHIEVEMENTS
        achievementsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if data.achievements.isEmpty {
            let lbl = UILabel()
            lbl.text = "No recent achievements"
            lbl.textColor = UIColor.white.withAlphaComponent(0.6)
            lbl.font = .systemFont(ofSize: 14)
            achievementsStack.addArrangedSubview(lbl)
        } else {
            data.achievements.forEach { item in
                let card = AchievementCardView(
                    title: item.title,
                    subtitle: item.subtitle,
                    child: kid.name
                )
                achievementsStack.addArrangedSubview(card)
                card.heightAnchor.constraint(equalToConstant: 88).isActive = true
            }
        }
        
        // EFFORTS
        effortsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        data.efforts.forEach { e in
            let row = EffortRow(title: e.title, progress: e.progress, rightText: e.rightText)
            effortsStack.addArrangedSubview(row)
            row.heightAnchor.constraint(equalToConstant: 64).isActive = true
        }
    }
}
// MARK: - Glass Card: StatsCardView (Apple-style blur)
// MARK: - Exact Match StatsCardView (as per screenshot)
private final class StatsCardView: UIView {

    private let blur: UIVisualEffectView = {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        v.layer.cornerRadius = 22
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let container = UIView()

    // ARC
    private let arcView = ProgressArcView()

    // CENTER TEXT
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
        l.textColor = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // BOTTOM LABELS
    private let todayTitle = StatsCardView.smallTitle("Today Points")
    private let totalTitle = StatsCardView.smallTitle("Total Points")

    private let todayValue = StatsCardView.bigValue("0")
    private let totalValue = StatsCardView.bigValue("0")

    private let todayStar = UIImageView(image: UIImage(systemName: "star.fill"))
    private let totalStar = UIImageView(image: UIImage(systemName: "star.fill"))

    private let divider = UIView()

    private static func smallTitle(_ t: String) -> UILabel {
        let l = UILabel()
        l.text = t
        l.textColor = UIColor.white.withAlphaComponent(0.75)
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private static func bigValue(_ t: String) -> UILabel {
        let l = UILabel()
        l.text = t
        l.textColor = .white
        l.font = .systemFont(ofSize: 30, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(blur)
        blur.contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false

        // star icons style
        [todayStar, totalStar].forEach {
            $0.tintColor = .systemYellow
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // divider style
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        divider.translatesAutoresizingMaskIntoConstraints = false

        // ARC + CENTER TEXT
        arcView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(arcView)
        container.addSubview(percentageLabel)
        container.addSubview(tasksLabel)

        // bottom
        container.addSubview(divider)
        container.addSubview(todayTitle)
        container.addSubview(totalTitle)
        container.addSubview(todayValue)
        container.addSubview(totalValue)
        container.addSubview(todayStar)
        container.addSubview(totalStar)

        // layout
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),

            container.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor),
            container.topAnchor.constraint(equalTo: blur.contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor),

            // ARC
            arcView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            arcView.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            arcView.widthAnchor.constraint(equalToConstant: 260),
            arcView.heightAnchor.constraint(equalToConstant: 140),

            // CENTER TEXT
            percentageLabel.centerXAnchor.constraint(equalTo: arcView.centerXAnchor),
            percentageLabel.topAnchor.constraint(equalTo: arcView.topAnchor, constant: 38),

            tasksLabel.centerXAnchor.constraint(equalTo: arcView.centerXAnchor),
            tasksLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 6),

            // DIVIDER
            divider.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            divider.topAnchor.constraint(equalTo: arcView.bottomAnchor, constant: 20),
            divider.heightAnchor.constraint(equalToConstant: 1),

            // TODAY
            todayTitle.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 40),
            todayTitle.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),

            todayValue.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 40),
            todayValue.topAnchor.constraint(equalTo: todayTitle.bottomAnchor, constant: 4),

            todayStar.leadingAnchor.constraint(equalTo: todayValue.trailingAnchor, constant: 6),
            todayStar.centerYAnchor.constraint(equalTo: todayValue.centerYAnchor),
            todayStar.widthAnchor.constraint(equalToConstant: 18),
            todayStar.heightAnchor.constraint(equalToConstant: 18),

            // TOTAL
            totalTitle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -34),
            totalTitle.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),

            totalValue.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -34),
            totalValue.topAnchor.constraint(equalTo: totalTitle.bottomAnchor, constant: 4),

            totalStar.leadingAnchor.constraint(equalTo: totalValue.trailingAnchor, constant: 6),
            totalStar.centerYAnchor.constraint(equalTo: totalValue.centerYAnchor),
            totalStar.widthAnchor.constraint(equalToConstant: 18),
            totalStar.heightAnchor.constraint(equalToConstant: 18),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(percentage: CGFloat, tasksDone: String, todayPoints: String, totalPoints: String) {
        arcView.setProgress(percentage, animated: true)
        percentageLabel.text = "\(Int(percentage * 100))%"
        tasksLabel.text = "\(tasksDone) Tasks Done"
        todayValue.text = todayPoints
        totalValue.text = totalPoints
    }
}


// MARK: - ProgressArcView (semi-circle) using CAShapeLayer
// MARK: - Precise Arc View (matching screenshot colors)
private final class ProgressArcView: UIView {

    private let track = CAShapeLayer()
    private let progress = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        // track
        track.fillColor = UIColor.clear.cgColor
        track.strokeColor = UIColor.white.withAlphaComponent(0.10).cgColor
        track.lineWidth = 16
        track.lineCap = .round

        // progress
        progress.fillColor = UIColor.clear.cgColor
        progress.strokeColor = UIColor.systemBlue.cgColor
        progress.lineWidth = 16
        progress.lineCap = .round
        progress.strokeEnd = 0

        layer.addSublayer(track)
        layer.addSublayer(progress)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()

        let center = CGPoint(x: bounds.midX, y: bounds.maxY - 10)
        let radius = min(bounds.width / 2 - 12, bounds.height)

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

    func setProgress(_ value: CGFloat, animated: Bool = true) {
        let clamped = max(0, min(1, value))
        if animated {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = progress.presentation()?.strokeEnd ?? progress.strokeEnd
            anim.toValue = clamped
            anim.duration = 0.5
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progress.strokeEnd = clamped
            progress.add(anim, forKey: "progress")
        } else {
            progress.strokeEnd = clamped
        }
    }
}

// MARK: - AchievementCardView (glass small card)
private final class AchievementCardView: UIView {
    private let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let avatar = UIImageView(image: UIImage(systemName: "person.circle"))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    init(title: String, subtitle: String, child: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 12
        blur.layer.masksToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blur)

        avatar.tintColor = UIColor.white.withAlphaComponent(0.8)
        avatar.contentMode = .scaleAspectFit
        avatar.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.text = "\(subtitle) • \(child)"
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        blur.contentView.addSubview(avatar)
        blur.contentView.addSubview(titleLabel)
        blur.contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),

            avatar.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor, constant: 12),
            avatar.centerYAnchor.constraint(equalTo: blur.contentView.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 26),
            avatar.heightAnchor.constraint(equalToConstant: 26),

            titleLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: blur.contentView.topAnchor, constant: 10),

            subtitleLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -12),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor, constant: -10)
        ])


    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - EffortRow (glass row + progress bar)
private final class EffortRow: UIView {
    private let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let titleLabel = UILabel()
    private let rightLabel = UILabel()
    private let track = UIView()
    private let fill = UIView()
    private var fillWidthConstraint: NSLayoutConstraint?

    init(title: String, progress: Float, rightText: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 12
        blur.layer.masksToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blur)

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        rightLabel.text = rightText
        rightLabel.font = .systemFont(ofSize: 13)
        rightLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        rightLabel.translatesAutoresizingMaskIntoConstraints = false

        track.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        track.layer.cornerRadius = 6
        track.translatesAutoresizingMaskIntoConstraints = false

        fill.backgroundColor = UIColor.systemBlue
        fill.layer.cornerRadius = 6
        fill.translatesAutoresizingMaskIntoConstraints = false

        blur.contentView.addSubview(titleLabel)
        blur.contentView.addSubview(rightLabel)
        blur.contentView.addSubview(track)
        track.addSubview(fill)

        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: blur.contentView.topAnchor, constant: 10),

            rightLabel.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -12),
            rightLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            track.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor, constant: 12),
            track.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -12),
            track.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            track.heightAnchor.constraint(equalToConstant: 12),
            track.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor, constant: -12),

            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor)
        ])

        // width constraint for fill (initially zero)
        fillWidthConstraint = fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: CGFloat(progress))
        fillWidthConstraint?.isActive = true

        // animate fill
        animateFill(to: CGFloat(progress))
    }

    required init?(coder: NSCoder) { fatalError() }

    private func animateFill(to multiplier: CGFloat) {
        // Ensure layout
        layoutIfNeeded()
        fillWidthConstraint?.isActive = false
        fillWidthConstraint = fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: multiplier)
        fillWidthConstraint?.isActive = true
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseInOut], animations: {
            self.layoutIfNeeded()
        })
    }
}

