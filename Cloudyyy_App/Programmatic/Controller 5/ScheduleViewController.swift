import UIKit

final class ScheduleViewController: UIViewController {

    // MARK: - UI
    private let gradient = CAGradientLayer()
    private let header = HomeHeaderView(title: "Schedule")

    // Dates strip
    private let datesScroll = UIScrollView()
    private let datesStack = UIStackView()
    private var dateButtons: [UIButton] = []
    private var allDatesOfMonth: [Date] = []

    // Filters
    private let filterControl: UISegmentedControl = {
        let c = UISegmentedControl(items: ["All", "In progress", "Completed"])
        c.selectedSegmentIndex = 0
        c.translatesAutoresizingMaskIntoConstraints = false
        c.selectedSegmentTintColor = .white
        return c
    }()

    // Tasks list
    private let tasksContainer = UIScrollView()
    private let tasksStack = UIStackView()

    // Empty label
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No tasks for this date"
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .center
        return l
    }()

    // Data
    private var selectedDate: Date = Date()
    private var visibleKid: Kid? { ChildManager.shared.selectedKid }
    private var tasksForSelectedDate: [ScheduleTask] = []

    // Helpers
    private let calendar = Calendar.current
    private let dateFormatterShort = DateFormatter()
    private let dayFormatter = DateFormatter()
    private let monthFormatter = DateFormatter()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        // formatters
        dateFormatterShort.dateFormat = "yyyy-MM-dd"
        dayFormatter.dateFormat = "d"
        monthFormatter.dateFormat = "MMM"

        setupGradient()
        setupHeader()
        setupDatesStrip()
        setupFilter()
        setupTasksList()
        setupListeners()

        generateDatesForCurrentMonth()
        buildDateButtons()
        select(date: Date(), animated: false)

        if let kid = ChildManager.shared.selectedKid {
            header.childButton.setTitle("\(kid.name) ▾", for: .normal)
            reloadForKid(kid)
        }
    }
    
    // ✅ FIX: Force Navigation Bar Hidden when returning to this tab
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
        
        // Ensure selected date is centered
        if let idx = indexOfDate(selectedDate), idx < dateButtons.count {
            centerDateButton(dateButtons[idx], animated: false)
        }
    }

    // MARK: - Setup
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
        header.showNotificationButton(true)
        header.showProfileButton(true)
        header.showPlusButton(false)
        
        // Profile Action (Navigates away)
        header.onProfileTapped = { [weak self] in
            let vc = ParentProfileViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 98)
        ])

        header.onChildTapped = { [weak self] in self?.showKidsMenu() }
    }

    private func setupDatesStrip() {
        datesScroll.showsHorizontalScrollIndicator = false
        datesScroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datesScroll)

        datesStack.axis = .horizontal
        datesStack.alignment = .center
        datesStack.spacing = 12
        datesStack.translatesAutoresizingMaskIntoConstraints = false
        datesScroll.addSubview(datesStack)

        NSLayoutConstraint.activate([
            datesScroll.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 20),
            datesScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            datesScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            datesScroll.heightAnchor.constraint(equalToConstant: 84),

            datesStack.leadingAnchor.constraint(equalTo: datesScroll.contentLayoutGuide.leadingAnchor, constant: 12),
            datesStack.trailingAnchor.constraint(equalTo: datesScroll.contentLayoutGuide.trailingAnchor, constant: -12),
            datesStack.topAnchor.constraint(equalTo: datesScroll.contentLayoutGuide.topAnchor),
            datesStack.bottomAnchor.constraint(equalTo: datesScroll.contentLayoutGuide.bottomAnchor),
            datesStack.heightAnchor.constraint(equalTo: datesScroll.frameLayoutGuide.heightAnchor)
        ])
    }

    private func setupFilter() {
        filterControl.addTarget(self, action: #selector(filterChanged(_:)), for: .valueChanged)
        view.addSubview(filterControl)
        NSLayoutConstraint.activate([
            filterControl.topAnchor.constraint(equalTo: datesScroll.bottomAnchor, constant: 14),
            filterControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            filterControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            filterControl.heightAnchor.constraint(equalToConstant: 38)
        ])
        filterControl.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        filterControl.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.20)
        filterControl.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.75), .font: UIFont.systemFont(ofSize: 15, weight: .medium)], for: .normal)
        filterControl.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 15, weight: .semibold)], for: .selected)
        filterControl.layer.cornerRadius = 19
        filterControl.clipsToBounds = true
    }

    private func setupTasksList() {
        tasksContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tasksContainer)

        tasksStack.axis = .vertical
        tasksStack.spacing = 12
        tasksStack.alignment = .fill
        tasksStack.translatesAutoresizingMaskIntoConstraints = false
        tasksContainer.addSubview(tasksStack)

        view.addSubview(emptyLabel)
        emptyLabel.isHidden = true

        NSLayoutConstraint.activate([
            tasksContainer.topAnchor.constraint(equalTo: filterControl.bottomAnchor, constant: 14),
            tasksContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            tasksContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            tasksContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),

            tasksStack.leadingAnchor.constraint(equalTo: tasksContainer.contentLayoutGuide.leadingAnchor),
            tasksStack.trailingAnchor.constraint(equalTo: tasksContainer.contentLayoutGuide.trailingAnchor),
            tasksStack.topAnchor.constraint(equalTo: tasksContainer.contentLayoutGuide.topAnchor),
            tasksStack.bottomAnchor.constraint(equalTo: tasksContainer.contentLayoutGuide.bottomAnchor),
            tasksStack.widthAnchor.constraint(equalTo: tasksContainer.frameLayoutGuide.widthAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40)
        ])
    }

    private func setupListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKidChanged(_:)), name: ChildManager.kidChangedNotification, object: nil)
    }

    // MARK: - Logic
    private func generateDatesForCurrentMonth() {
        allDatesOfMonth.removeAll()
        let today = Date()
        guard let monthRange = calendar.range(of: .day, in: .month, for: today),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else { return }
        for d in monthRange {
            if let date = calendar.date(byAdding: .day, value: d - 1, to: firstOfMonth) {
                allDatesOfMonth.append(date)
            }
        }
    }

    private func buildDateButtons() {
        dateButtons.forEach { $0.removeFromSuperview() }
        dateButtons = []
        for date in allDatesOfMonth {
            let button = makeDateButton(for: date)
            dateButtons.append(button)
            datesStack.addArrangedSubview(button)
        }
        let leftSpacer = UIView(); leftSpacer.widthAnchor.constraint(equalToConstant: view.bounds.width / 2 - 44).isActive = true
        datesStack.insertArrangedSubview(leftSpacer, at: 0)
        let rightSpacer = UIView(); rightSpacer.widthAnchor.constraint(equalToConstant: view.bounds.width / 2 - 44).isActive = true
        datesStack.addArrangedSubview(rightSpacer)
    }

    private func makeDateButton(for date: Date) -> UIButton {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 88).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 72).isActive = true
        btn.layer.cornerRadius = 12
        btn.clipsToBounds = true
        
        let month = monthFormatter.string(from: date)
        let day = dayFormatter.string(from: date)
        let weekday = date.weekdayShort()
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        let attr = NSMutableAttributedString()
        attr.append(NSAttributedString(string: "\(month)\n", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium), .foregroundColor: UIColor.white.withAlphaComponent(0.8)]))
        attr.append(NSAttributedString(string: "\(day)\n", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor.white]))
        attr.append(NSAttributedString(string: weekday, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular), .foregroundColor: UIColor.white.withAlphaComponent(0.8)]))
        label.attributedText = attr
        
        btn.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: btn.centerYAnchor)
        ])
        
        btn.backgroundColor = UIColor(white: 1, alpha: 0.03)
        btn.addTarget(self, action: #selector(dateTapped(_:)), for: .touchUpInside)
        btn.tag = allDatesOfMonth.firstIndex(of: date) ?? 0
        return btn
    }

    private func indexOfDate(_ date: Date) -> Int? {
        return allDatesOfMonth.firstIndex { calendar.isDate($0, inSameDayAs: date) }
    }

    private func select(date: Date, animated: Bool) {
        selectedDate = date
        for (i, btn) in dateButtons.enumerated() {
            if i < allDatesOfMonth.count && calendar.isDate(allDatesOfMonth[i], inSameDayAs: date) {
                btn.backgroundColor = UIColor(red: 56/255, green: 123/255, blue: 255/255, alpha: 1)
            } else {
                btn.backgroundColor = UIColor(white: 1, alpha: 0.03)
            }
        }
        if let idx = indexOfDate(date) { centerDateButton(dateButtons[idx], animated: animated) }
        reloadTasksForDate(date)
    }

    private func centerDateButton(_ button: UIButton, animated: Bool) {
        guard let superview = button.superview else { return }
        let btnFrame = superview.convert(button.frame, to: datesScroll)
        let scrollCenter = datesScroll.bounds.width / 2
        var offsetX = btnFrame.midX - scrollCenter
        offsetX = max(0, min(offsetX, datesScroll.contentSize.width - datesScroll.bounds.width))
        datesScroll.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
    }

    @objc private func filterChanged(_ sender: UISegmentedControl) {
        reloadTasksForDate(selectedDate)
    }

    private func reloadTasksForDate(_ date: Date) {
        guard let kid = visibleKid else {
            tasksForSelectedDate = []; renderTasks(); return
        }
        let all = ChildManager.shared.schedule(for: kid.id)
        let requestedDateString = dateFormatterShort.string(from: date)
        let tasksOnDate = all.filter { $0.date == requestedDateString }
        
        let filtered: [ScheduleTask]
        switch filterControl.selectedSegmentIndex {
        case 1: filtered = tasksOnDate.filter { $0.status.lowercased().contains("progress") }
        case 2: filtered = tasksOnDate.filter { $0.status.lowercased().contains("completed") }
        default: filtered = tasksOnDate
        }
        tasksForSelectedDate = filtered
        renderTasks()
    }

    private func renderTasks() {
        tasksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if tasksForSelectedDate.isEmpty {
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
            for t in tasksForSelectedDate {
                let card = ScheduleTaskCard(task: t)
                tasksStack.addArrangedSubview(card)
                // Height adjusted to fit "Habits" row
                card.heightAnchor.constraint(equalToConstant: 90).isActive = true
            }
            let spacer = UIView()
            spacer.heightAnchor.constraint(equalToConstant: 30).isActive = true
            tasksStack.addArrangedSubview(spacer)
        }
    }

    @objc private func dateTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx < allDatesOfMonth.count else { return }
        select(date: allDatesOfMonth[idx], animated: true)
    }

    @objc private func onKidChanged(_ n: Notification) {
        guard let kid = n.object as? Kid else { return }
        header.childButton.setTitle("\(kid.name) ▾", for: .normal)
        reloadForKid(kid)
    }

    private func reloadForKid(_ kid: Kid) {
        select(date: Date(), animated: true)
    }

    private func showKidsMenu() {
        let kids = ChildManager.shared.kids
        guard !kids.isEmpty else { return }
        let menu = FloatingKidsMenu(kids: ChildManager.shared.kids)
        menu.manager = FloatingMenuManager.shared
        menu.onKidSelected = { [weak self] kid in ChildManager.shared.selectedKid = kid }
        menu.show(in: view, anchor: header.childButton)
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

private extension Date {
    func weekdayShort() -> String {
        let f = DateFormatter()
        f.dateFormat = "E"
        return f.string(from: self)
    }
}
