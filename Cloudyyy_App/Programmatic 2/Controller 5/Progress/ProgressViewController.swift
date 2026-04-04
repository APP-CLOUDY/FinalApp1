import UIKit
import SwiftUI

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
    private var chartPoints: [DashboardChartPoint] = []
    private var chartHostingController: UIHostingController<AnyView>?
    private var latestDataRequestID = UUID()

    // MARK: - UI Components
    private let gradient = CAGradientLayer()
    private let header = HomeHeaderView(title: "Progress")
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStack = UIStackView()
    
    // 1. Segment Control (Updated Style to match Dashboard)
    private lazy var scopeSegment: UISegmentedControl = {
        let items = ["Weekly", "Monthly"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        
        // --- 🎨 NEW STYLE START ---
        sc.selectedSegmentTintColor = .white
        sc.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        
        let normalAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.7)
        ]
        let selectedAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
        ]
        // --- 🎨 NEW STYLE END ---
        
        sc.setTitleTextAttributes(normalAttr, for: .normal)
        sc.setTitleTextAttributes(selectedAttr, for: .selected)
        sc.addTarget(self, action: #selector(handleScopeChange(_:)), for: .valueChanged)
        return sc
    }()
    
    private let trendCard = GlassView(style: .card, cornerRadius: 24)
    private let trendTitleLabel = UILabel()
    private let trendSubtitleLabel = UILabel()
    private let chartHolder = UIView()

    private let summaryRow = UIStackView()
    private let completedCard = SummaryStatCardView(title: "Completed")
    private let consistencyCard = SummaryStatCardView(title: "Consistency")
    private let bestCategoryCard = SummaryStatCardView(title: "Best Category")

    private let consistencySummaryCard = InsightCardView(title: "Consistency Summary")
    private let consistencySummaryStack = UIStackView()

    // 3. Section Headers
    private func createSectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }
    
    private lazy var highlightsLabel = createSectionHeader("This Period Insights")
    private lazy var effortsLabel = createSectionHeader("Effort Breakdown")
    
    // 4. Stacks
    private let insightsCard = InsightCardView(title: "Highlights")
    private let insightsStack = UIStackView()
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
        view.backgroundColor = .clear // Changed to clear to show gradient
        
        setupGradient()
        setupHeader()
        setupScrollView()
        setupMainStack()
        
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
        
        UIView.animate(withDuration: 0.15, animations: {
            self.trendCard.alpha = 0.55
            self.summaryRow.alpha = 0.55
            self.consistencySummaryCard.alpha = 0.55
            self.effortsCardContainer.alpha = 0.55
            self.insightsCard.alpha = 0.55
        }) { _ in
            if let kid = self.selectedKid {
                self.updateDataView(for: kid)
            }
            UIView.animate(withDuration: 0.25) {
                self.trendCard.alpha = 1.0
                self.summaryRow.alpha = 1.0
                self.consistencySummaryCard.alpha = 1.0
                self.effortsCardContainer.alpha = 1.0
                self.insightsCard.alpha = 1.0
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
        consistencySummaryStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        insightsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        effortsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let childId = UUID(uuidString: kid.id.uuidString) else { return }
        let requestID = UUID()
        latestDataRequestID = requestID
        let requestedScope = currentScope
        
        Task {
            do {
                async let statsTask = ProgressService.shared.fetchStats(childId: childId, scope: requestedScope)
                async let chartDataTask = HomeService.shared.fetchChartData(
                    for: childId,
                    range: requestedScope == .weekly ? "weekly" : "monthly"
                )
                let stats = try await statsTask
                let chartData = try await chartDataTask
                
                await MainActor.run {
                    guard self.latestDataRequestID == requestID,
                          self.selectedKid?.id == kid.id,
                          self.currentScope == requestedScope else {
                        return
                    }

                    let orderedChartPoints = self.makeOrderedChartPoints(from: chartData)
                    self.chartPoints = orderedChartPoints
                    self.updateChart()

                    let periodCompleted = max(orderedChartPoints.reduce(0) { $0 + $1.completed }, 0)
                    let periodPending = max(orderedChartPoints.reduce(0) { $0 + $1.assigned }, 0)
                    let periodTotal = periodCompleted + periodPending
                    let completionRate = periodTotal > 0
                        ? Int((Double(periodCompleted) / Double(periodTotal)) * 100)
                        : 0
                    let activeDays = orderedChartPoints.filter { $0.completed > 0 }.count
                    let totalPeriodDays = orderedChartPoints.count

                    let bestCategory = stats.breakdown?
                        .max(by: { $0.count < $1.count })?
                        .name ?? "No activity"

                    self.completedCard.configure(
                        value: "\(periodCompleted)",
                        detail: periodTotal > 0
                            ? "of \(periodTotal) tasks"
                            : "No tasks"
                    )
                    self.consistencyCard.configure(
                        value: "\(activeDays)/\(max(totalPeriodDays, 1))",
                        detail: requestedScope == .weekly ? "days active" : "weeks active"
                    )
                    self.bestCategoryCard.configure(
                        value: bestCategory,
                        detail: "top category"
                    )

                    self.populateConsistencySummary(
                        activeDays: activeDays,
                        totalDays: totalPeriodDays,
                        completionRate: completionRate,
                        chartPoints: orderedChartPoints
                    )

                    if let breakdown = stats.breakdown, !breakdown.isEmpty {
                        for item in breakdown.sorted(by: { $0.count > $1.count }) {
                            let catTotal = max(item.total, 1)
                            let prog = Float(item.count) / Float(catTotal)

                            self.addEffort(
                                title: item.name,
                                prog: prog,
                                text: "\(item.count)/\(item.total)"
                            )
                        }
                    } else {
                        self.addEffort(title: "No activity yet", prog: 0.0, text: "0/0")
                    }

                    self.populateInsights(
                        stats: stats,
                        chartPoints: orderedChartPoints,
                        bestCategory: bestCategory
                    )
                }
            } catch {
                print("❌ Error fetching progress stats: \(error)")
            }
        }
    }

    private func makeOrderedChartPoints(from rawPoints: [ChartDataPoint]) -> [DashboardChartPoint] {
        if currentScope == .weekly {
            let allDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            let lookup = Dictionary(uniqueKeysWithValues: rawPoints.map { ($0.day, $0) })
            return allDays.map { day in
                let point = lookup[day]
                return DashboardChartPoint(
                    label: day,
                    completed: point?.completed_count ?? 0,
                    assigned: point?.pending_count ?? 0
                )
            }
        }

        let explicitWeekLookup = Dictionary(uniqueKeysWithValues: rawPoints.map { ($0.day, $0) })
        let explicitMaxWeeks = rawPoints
            .compactMap { Self.parseWeekIndex(from: $0.day) }
            .max()

        if let explicitMaxWeeks {
            return (1...explicitMaxWeeks).map { index in
                let label = "Week \(index)"
                let point = explicitWeekLookup[label]
                return DashboardChartPoint(
                    label: label,
                    completed: point?.completed_count ?? 0,
                    assigned: point?.pending_count ?? 0
                )
            }
        }

        let groupedMonthlyPoints = Self.groupMonthlyPointsIntoWeeks(rawPoints)
        if !groupedMonthlyPoints.isEmpty {
            return groupedMonthlyPoints
        }

        return []
    }

    private func populateConsistencySummary(
        activeDays: Int,
        totalDays: Int,
        completionRate: Int,
        chartPoints: [DashboardChartPoint]
    ) {
        let bestDay = chartPoints.max(by: { $0.completed < $1.completed })?.label ?? "-"
        let missedDays = chartPoints.filter { $0.completed == 0 }.map(\.label)
        let missedText = missedDays.isEmpty ? "None" : missedDays.joined(separator: ", ")

        [
            "Completed at least one task on \(activeDays) of \(max(totalDays, 1)) \(currentScope == .weekly ? "days" : "weeks").",
            "Completion rate: \(completionRate)%.",
            "Best \(currentScope == .weekly ? "day" : "week"): \(bestDay).",
            "No completion on: \(missedText)."
        ].forEach { line in
            let row = InsightLineView(text: line)
            consistencySummaryStack.addArrangedSubview(row)
        }
    }

    private func populateInsights(
        stats: ProgressReport,
        chartPoints: [DashboardChartPoint],
        bestCategory: String
    ) {
        let totalPending = chartPoints.reduce(0) { $0 + $1.assigned }
        let strongestPoint = chartPoints.max(by: { $0.completed < $1.completed })
        let weakestPoint = chartPoints
            .filter { $0.completed == 0 && $0.assigned > 0 }
            .first

        var lines: [String] = []
        lines.append("Most active category: \(bestCategory).")
        lines.append("Points earned this \(currentScope == .weekly ? "week" : "month"): \(stats.points_earned).")

        if let strongestPoint, strongestPoint.completed > 0 {
            lines.append("Strongest \(currentScope == .weekly ? "day" : "week"): \(strongestPoint.label) with \(strongestPoint.completed) completed.")
        }

        if let weakestPoint {
            lines.append("Needs attention: \(weakestPoint.label) had \(weakestPoint.assigned) pending and no completions.")
        } else if totalPending == 0 {
            lines.append("No pending backlog in this period.")
        } else {
            lines.append("Pending workload in this period: \(totalPending) tasks.")
        }

        lines.forEach { line in
            let row = InsightLineView(text: line)
            insightsStack.addArrangedSubview(row)
        }
    }
    
    private func addEffort(title: String, prog: Float, text: String) {
        let row = EffortRow(title: title, progress: prog, rightText: text)
        effortsStack.addArrangedSubview(row)
        row.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    // MARK: - Layout Setup
    private func setupGradient() {
        // --- 🎨 NEW GRADIENT START (Matches Dashboard) ---
        gradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        // --- 🎨 NEW GRADIENT END ---
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
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
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

        setupTrendCard()
        setupSummaryRow()
        setupConsistencyCard()

        mainStack.addArrangedSubview(effortsLabel)
        setupEffortsCard()
        mainStack.addArrangedSubview(highlightsLabel)
        setupInsightsCard()
    }

    private func setupTrendCard() {
        trendCard.heightAnchor.constraint(equalToConstant: 310).isActive = true
        mainStack.addArrangedSubview(trendCard)

        [trendTitleLabel, trendSubtitleLabel, scopeSegment, chartHolder].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            trendCard.addSubview($0)
        }

        trendTitleLabel.text = "Completion Trend"
        trendTitleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        trendTitleLabel.textColor = .white

        trendSubtitleLabel.text = "Track how completion changes over time"
        trendSubtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        trendSubtitleLabel.textColor = UIColor.white.withAlphaComponent(0.68)
        trendSubtitleLabel.numberOfLines = 0

        chartHolder.backgroundColor = .clear

        NSLayoutConstraint.activate([
            trendTitleLabel.topAnchor.constraint(equalTo: trendCard.topAnchor, constant: 20),
            trendTitleLabel.leadingAnchor.constraint(equalTo: trendCard.leadingAnchor, constant: 20),
            trendTitleLabel.trailingAnchor.constraint(equalTo: trendCard.trailingAnchor, constant: -20),

            trendSubtitleLabel.topAnchor.constraint(equalTo: trendTitleLabel.bottomAnchor, constant: 4),
            trendSubtitleLabel.leadingAnchor.constraint(equalTo: trendTitleLabel.leadingAnchor),
            trendSubtitleLabel.trailingAnchor.constraint(equalTo: trendTitleLabel.trailingAnchor),

            scopeSegment.topAnchor.constraint(equalTo: trendSubtitleLabel.bottomAnchor, constant: 16),
            scopeSegment.leadingAnchor.constraint(equalTo: trendCard.leadingAnchor, constant: 20),
            scopeSegment.trailingAnchor.constraint(equalTo: trendCard.trailingAnchor, constant: -20),
            scopeSegment.heightAnchor.constraint(equalToConstant: 34),

            chartHolder.topAnchor.constraint(equalTo: scopeSegment.bottomAnchor, constant: 16),
            chartHolder.leadingAnchor.constraint(equalTo: trendCard.leadingAnchor, constant: 8),
            chartHolder.trailingAnchor.constraint(equalTo: trendCard.trailingAnchor, constant: -8),
            chartHolder.bottomAnchor.constraint(equalTo: trendCard.bottomAnchor, constant: -10)
        ])

        if #available(iOS 16.0, *) {
            let hosting = UIHostingController(rootView: AnyView(DashboardChartView(points: [])))
            hosting.view.backgroundColor = .clear
            addChild(hosting)
            chartHolder.addSubview(hosting.view)
            hosting.view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                hosting.view.topAnchor.constraint(equalTo: chartHolder.topAnchor),
                hosting.view.leadingAnchor.constraint(equalTo: chartHolder.leadingAnchor),
                hosting.view.trailingAnchor.constraint(equalTo: chartHolder.trailingAnchor),
                hosting.view.bottomAnchor.constraint(equalTo: chartHolder.bottomAnchor)
            ])

            hosting.didMove(toParent: self)
            chartHostingController = hosting
        }
    }

    private func setupSummaryRow() {
        summaryRow.axis = .horizontal
        summaryRow.spacing = 10
        summaryRow.distribution = .fillEqually
        summaryRow.alignment = .fill
        summaryRow.translatesAutoresizingMaskIntoConstraints = false

        [completedCard, consistencyCard, bestCategoryCard].forEach {
            $0.heightAnchor.constraint(equalToConstant: 118).isActive = true
            summaryRow.addArrangedSubview($0)
        }

        mainStack.addArrangedSubview(summaryRow)
    }

    private func setupConsistencyCard() {
        consistencySummaryCard.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(consistencySummaryCard)

        consistencySummaryStack.axis = .vertical
        consistencySummaryStack.spacing = 10
        consistencySummaryStack.translatesAutoresizingMaskIntoConstraints = false
        consistencySummaryCard.contentView.addSubview(consistencySummaryStack)

        NSLayoutConstraint.activate([
            consistencySummaryStack.topAnchor.constraint(equalTo: consistencySummaryCard.contentView.topAnchor, constant: 18),
            consistencySummaryStack.leadingAnchor.constraint(equalTo: consistencySummaryCard.contentView.leadingAnchor, constant: 18),
            consistencySummaryStack.trailingAnchor.constraint(equalTo: consistencySummaryCard.contentView.trailingAnchor, constant: -18),
            consistencySummaryStack.bottomAnchor.constraint(equalTo: consistencySummaryCard.contentView.bottomAnchor, constant: -18)
        ])
    }

    private func setupEffortsCard() {
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

    private func setupInsightsCard() {
        insightsCard.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(insightsCard)

        insightsStack.axis = .vertical
        insightsStack.spacing = 10
        insightsStack.translatesAutoresizingMaskIntoConstraints = false
        insightsCard.contentView.addSubview(insightsStack)

        NSLayoutConstraint.activate([
            insightsStack.topAnchor.constraint(equalTo: insightsCard.contentView.topAnchor, constant: 18),
            insightsStack.leadingAnchor.constraint(equalTo: insightsCard.contentView.leadingAnchor, constant: 18),
            insightsStack.trailingAnchor.constraint(equalTo: insightsCard.contentView.trailingAnchor, constant: -18),
            insightsStack.bottomAnchor.constraint(equalTo: insightsCard.contentView.bottomAnchor, constant: -18)
        ])
    }

    private func updateChart() {
        if #available(iOS 16.0, *) {
            chartHostingController?.rootView = AnyView(DashboardChartView(points: chartPoints))
        }
    }
}

private extension ProgressViewController {
    static func parseWeekIndex(from label: String) -> Int? {
        let normalized = label
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard normalized.hasPrefix("week ") else { return nil }
        return Int(normalized.replacingOccurrences(of: "week ", with: ""))
    }

    static func groupMonthlyPointsIntoWeeks(_ rawPoints: [ChartDataPoint]) -> [DashboardChartPoint] {
        guard !rawPoints.isEmpty else { return [] }

        let datedPoints = rawPoints.compactMap { point -> (Date, ChartDataPoint)? in
            guard let date = parseChartDate(point.day) else { return nil }
            return (date, point)
        }

        if !datedPoints.isEmpty {
            let calendar = Calendar(identifier: .gregorian)
            let sorted = datedPoints.sorted { $0.0 < $1.0 }
            let startDate = calendar.startOfDay(for: sorted[0].0)
            var buckets: [Int: (completed: Int, pending: Int)] = [:]

            for (date, point) in sorted {
                let days = calendar.dateComponents([.day], from: startDate, to: calendar.startOfDay(for: date)).day ?? 0
                let weekIndex = max(0, days / 7) + 1
                var bucket = buckets[weekIndex] ?? (0, 0)
                bucket.completed += point.completed_count
                bucket.pending += point.pending_count
                buckets[weekIndex] = bucket
            }

            let maxWeek = buckets.keys.max() ?? 1
            return (1...maxWeek).map { index in
                let bucket = buckets[index] ?? (0, 0)
                return DashboardChartPoint(
                    label: "Week \(index)",
                    completed: bucket.completed,
                    assigned: bucket.pending
                )
            }
        }

        var grouped: [DashboardChartPoint] = []
        let chunks = stride(from: 0, to: rawPoints.count, by: 7).map {
            Array(rawPoints[$0..<min($0 + 7, rawPoints.count)])
        }

        for (offset, chunk) in chunks.enumerated() {
            grouped.append(
                DashboardChartPoint(
                    label: "Week \(offset + 1)",
                    completed: chunk.reduce(0) { $0 + $1.completed_count },
                    assigned: chunk.reduce(0) { $0 + $1.pending_count }
                )
            )
        }

        return grouped
    }

    static func parseChartDate(_ value: String) -> Date? {
        let formats = [
            "yyyy-MM-dd",
            "yyyy/MM/dd",
            "dd-MM-yyyy",
            "dd/MM/yyyy",
            "MMM d",
            "d MMM",
            "MMM d, yyyy",
            "d MMM yyyy"
        ]

        for format in formats {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = format

            if let date = formatter.date(from: value) {
                return date
            }
        }

        return nil
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

final class SummaryStatCardView: UIView {
    private let glass = GlassView(style: .card, cornerRadius: 18)
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let detailLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(glass)
        glass.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title.uppercased()
        titleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.55)
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.72
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.font = .systemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = .white
        valueLabel.numberOfLines = 2
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.75
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        detailLabel.font = .systemFont(ofSize: 13, weight: .medium)
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.72)
        detailLabel.numberOfLines = 2
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.minimumScaleFactor = 0.85
        detailLabel.translatesAutoresizingMaskIntoConstraints = false

        glass.addSubview(titleLabel)
        glass.addSubview(valueLabel)
        glass.addSubview(detailLabel)

        NSLayoutConstraint.activate([
            glass.topAnchor.constraint(equalTo: topAnchor),
            glass.leadingAnchor.constraint(equalTo: leadingAnchor),
            glass.trailingAnchor.constraint(equalTo: trailingAnchor),
            glass.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: glass.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: glass.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: glass.trailingAnchor, constant: -16),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            detailLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailLabel.bottomAnchor.constraint(lessThanOrEqualTo: glass.bottomAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(value: String, detail: String) {
        valueLabel.text = value
        detailLabel.text = detail
    }
}

final class InsightCardView: UIView {
    let glass = GlassView(style: .card, cornerRadius: 20)
    let contentView = UIView()

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(glass)
        glass.translatesAutoresizingMaskIntoConstraints = false
        glass.addSubview(titleLabel)
        glass.addSubview(contentView)

        NSLayoutConstraint.activate([
            glass.topAnchor.constraint(equalTo: topAnchor),
            glass.leadingAnchor.constraint(equalTo: leadingAnchor),
            glass.trailingAnchor.constraint(equalTo: trailingAnchor),
            glass.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: glass.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: glass.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: glass.trailingAnchor, constant: -18),

            contentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            contentView.leadingAnchor.constraint(equalTo: glass.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: glass.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: glass.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

final class InsightLineView: UIView {
    init(text: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let bullet = UIView()
        bullet.translatesAutoresizingMaskIntoConstraints = false
        bullet.backgroundColor = UIColor(red: 115/255, green: 185/255, blue: 255/255, alpha: 1)
        bullet.layer.cornerRadius = 4

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.86)

        addSubview(bullet)
        addSubview(label)

        NSLayoutConstraint.activate([
            bullet.leadingAnchor.constraint(equalTo: leadingAnchor),
            bullet.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            bullet.widthAnchor.constraint(equalToConstant: 8),
            bullet.heightAnchor.constraint(equalToConstant: 8),

            label.leadingAnchor.constraint(equalTo: bullet.trailingAnchor, constant: 12),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}
