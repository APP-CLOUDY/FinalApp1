//
//  ScheduleViewController.swift
//  Cloudyyy_App
//
//  Updated: show only dynamic tasks; glass empty-state when no runtime tasks.
//  Mock schedule remains inside ChildManager but is NOT shown until user adds tasks.
//

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

    // Centered empty label fallback (unused when using glass empty card)
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No tasks for this date"
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .center
        return l
    }()

    // Glass empty state (matches Progress style)
    private let emptyStateContainer = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    private let emptyStateLabel: UILabel = {
        let l = UILabel()
        l.text = "No Tasks Assigned"
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let emptyStateButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Add New Task", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        b.backgroundColor = UIColor(red: 35/255, green: 129/255, blue: 255/255, alpha: 1)
        b.tintColor = .white
        b.layer.cornerRadius = 22
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return b
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

        // 🔥 Wait for layout before scrolling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.select(date: self.selectedDate, animated: true)
        }


        if let kid = ChildManager.shared.selectedKid {
            header.childButton.setTitle("\(kid.name) ▾", for: .normal)
            reloadForKid(kid)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds

        if dateButtons.count > 0,
           let idx = indexOfDate(selectedDate),
           idx < dateButtons.count
        {
            DispatchQueue.main.async {
                self.centerDateButton(self.dateButtons[idx], animated: false)
            }
        }

    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup UI
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

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 110)
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
            datesScroll.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
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

        filterControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white.withAlphaComponent(0.75),
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ], for: .normal)

        filterControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ], for: .selected)

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

        // --- Glass empty state card (centered under filter) ---
        view.addSubview(emptyStateContainer)
        emptyStateContainer.contentView.addSubview(emptyStateLabel)
        emptyStateContainer.contentView.addSubview(emptyStateButton)

        emptyStateContainer.layer.cornerRadius = 18
        emptyStateContainer.clipsToBounds = true
        emptyStateContainer.translatesAutoresizingMaskIntoConstraints = false
        emptyStateContainer.isHidden = true

        emptyStateButton.addTarget(self, action: #selector(openNewTaskPage), for: .touchUpInside)

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
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),

            // EmptyState constraints
            emptyStateContainer.topAnchor.constraint(equalTo: filterControl.bottomAnchor, constant: 30),
            emptyStateContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            emptyStateContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateContainer.topAnchor, constant: 20),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateContainer.leadingAnchor, constant: 12),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateContainer.trailingAnchor, constant: -12),

            emptyStateButton.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 16),
            emptyStateButton.leadingAnchor.constraint(equalTo: emptyStateContainer.leadingAnchor, constant: 20),
            emptyStateButton.trailingAnchor.constraint(equalTo: emptyStateContainer.trailingAnchor, constant: -20),
            emptyStateButton.bottomAnchor.constraint(equalTo: emptyStateContainer.bottomAnchor, constant: -20)
        ])
    }

    private func setupListeners() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(onKidChanged(_:)),
            name: ChildManager.kidChangedNotification,
            object: nil
        )

        // 🔥 NEW LISTENERS — updates schedule when tasks change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTaskStorageChanged(_:)),
            name: ChildManager.taskAddedNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTaskStorageChanged(_:)),
            name: ChildManager.taskUpdatedNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTaskStorageChanged(_:)),
            name: ChildManager.taskRemovedNotification,
            object: nil
        )
    }
    
    @objc private func onTaskStorageChanged(_ n: Notification) {
        guard let kid = visibleKid else { return }
        if let last = ChildManager.shared.dynamicSchedule(for: kid.id).last {
            if let d = dateFormatterShort.date(from: last.date) {
                selectedDate = d
            }
        }
        reloadForKid(kid)

    }


    // MARK: - Dates helpers
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

        let leftSpacer = UIView()
        leftSpacer.widthAnchor.constraint(equalToConstant: view.bounds.width / 2 - 44).isActive = true
        datesStack.insertArrangedSubview(leftSpacer, at: 0)

        let rightSpacer = UIView()
        rightSpacer.widthAnchor.constraint(equalToConstant: view.bounds.width / 2 - 44).isActive = true
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
        attr.append(NSAttributedString(string: "\(month)\n", attributes: [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]))
        attr.append(NSAttributedString(string: "\(day)\n", attributes: [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor.white
        ]))
        attr.append(NSAttributedString(string: weekday, attributes: [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]))
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
            if calendar.isDate(allDatesOfMonth[i], inSameDayAs: date) {
                btn.backgroundColor = UIColor(red: 56/255, green: 123/255, blue: 255/255, alpha: 1)
            } else {
                btn.backgroundColor = UIColor(white: 1, alpha: 0.03)
            }
        }

        if let idx = indexOfDate(date) {
            centerDateButton(dateButtons[idx], animated: animated)
        }

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

    // MARK: - Filter & Tasks
    @objc private func filterChanged(_ sender: UISegmentedControl) {
        reloadTasksForDate(selectedDate)
    }

    /// This function now shows only dynamic tasks (runtime tasks added by user).
    private func reloadTasksForDate(_ date: Date) {
        guard let kid = visibleKid else {
            tasksForSelectedDate = []
            renderTasks()
            return
        }

        // ALWAYS use dynamic tasks only (these already include all user-created tasks)
        let dynamicTasks = ChildManager.shared.dynamicSchedule(for: kid.id)

        // map only tasks for this selected date
        let dateString = dateFormatterShort.string(from: date)
        let tasksOnDate = dynamicTasks.filter { $0.date == dateString }

        // filter segment
        let filtered: [ScheduleTask]
        switch filterControl.selectedSegmentIndex {
        case 1:
            filtered = tasksOnDate.filter { $0.status.lowercased().contains("progress") }
        case 2:
            filtered = tasksOnDate.filter { $0.status.lowercased().contains("completed") }
        default:
            filtered = tasksOnDate
        }

        tasksForSelectedDate = filtered
        renderTasks()
    }


    private func renderTasks() {
        tasksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // If a kid has NO runtime tasks at all, we show the glass empty card (and hide tasksContainer)
        if let kid = visibleKid, ChildManager.shared.tasks(for: kid.id).isEmpty {
            // Show empty state card and hide list
            emptyStateContainer.isHidden = false
            tasksContainer.isHidden = true
            emptyLabel.isHidden = true
            return
        }

        // Otherwise show tasksContainer and hide the empty state card
        emptyStateContainer.isHidden = true
        tasksContainer.isHidden = false

        if tasksForSelectedDate.isEmpty {
            // no tasks for that chosen date (but dynamic tasks exist on other dates)
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
            for t in tasksForSelectedDate {
                let card = ScheduleTaskCard(task: t)
                tasksStack.addArrangedSubview(card)
                card.heightAnchor.constraint(equalToConstant: 84).isActive = true
            }

            let spacer = UIView()
            spacer.heightAnchor.constraint(equalToConstant: 30).isActive = true
            tasksStack.addArrangedSubview(spacer)
        }
    }

    // MARK: - Actions
    @objc private func dateTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx < allDatesOfMonth.count else { return }
        select(date: allDatesOfMonth[idx], animated: true)
    }

    @objc private func openNewTaskPage() {
        let newTaskVC = NewTaskViewController()
        let nav = UINavigationController(rootViewController: newTaskVC)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    // MARK: - Notifications
    @objc private func onKidChanged(_ n: Notification) {
        guard let kid = n.object as? Kid else { return }
        header.childButton.setTitle("\(kid.name) ▾", for: .normal)
        reloadForKid(kid)
    }

    @objc private func onTaskChanged(_ n: Notification) {
        guard let kid = visibleKid else { return }
        // Ensure UI updates reflect the new runtime tasks immediately
        reloadForKid(kid)
    }

    private func reloadForKid(_ kid: Kid) {
        // If there are no runtime tasks at all -> show empty card (first-time experience)
        let runtimeTasks = ChildManager.shared.tasks(for: kid.id)
        let isEmpty = runtimeTasks.isEmpty

        if isEmpty {
            // first-time (no runtime tasks) — hide tasks list and show glass empty state
            emptyStateContainer.isHidden = false
            tasksContainer.isHidden = true
            emptyLabel.isHidden = true
            tasksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            // keep selected date as today
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.select(date: self.selectedDate, animated: true)
            }

            return
        }

        // there are runtime tasks — normal mode: hide empty card, show dynamic tasks for selected date
        emptyStateContainer.isHidden = true
        tasksContainer.isHidden = false
        emptyLabel.isHidden = true

        // Rebuild date buttons (in case month view changed) and reload tasks for the selected date
        generateDatesForCurrentMonth()
        dateButtons.forEach { $0.removeFromSuperview() }
        datesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buildDateButtons()
        select(date: selectedDate, animated: false)
    }

    // MARK: - Kids Menu
    private func showKidsMenu() {
        let menu = FloatingKidsMenu(kids: ChildManager.shared.kids)
        menu.manager = FloatingMenuManager.shared
        menu.onKidSelected = { kid in
            ChildManager.shared.selectedKid = kid
        }
        menu.show(in: view, anchor: header.childButton)
    }
}

// MARK: - Date extension
private extension Date {
    func weekdayShort() -> String {
        let f = DateFormatter()
        f.dateFormat = "E"
        return f.string(from: self)
    }
}

