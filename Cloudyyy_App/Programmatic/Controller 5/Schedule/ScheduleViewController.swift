import UIKit

final class ScheduleViewController: UIViewController {

    // MARK: - UI Components
    private let gradient = CAGradientLayer()
    private let header = HomeHeaderView(title: "Schedule")

    // Dates strip
    private let datesScroll = UIScrollView()
    private let datesStack = UIStackView()
    private var dateButtons: [UIButton] = []
    private var allDatesOfMonth: [Date] = []

    // Filters
    private let filterControl: UISegmentedControl = {
        let c = UISegmentedControl(items: ["All", "Completed", "Not Done"])
        c.selectedSegmentIndex = 0
        c.translatesAutoresizingMaskIntoConstraints = false
        c.selectedSegmentTintColor = .white
        return c
    }()
    
    // NEW: Hint Label
    private let hintLabel: UILabel = {
        let l = UILabel()
        l.text = "Click a task to edit details"
        l.textColor = UIColor.white.withAlphaComponent(0.5)
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .center
        return l
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

    // Data Properties
    private var selectedDate: Date = Date()
    private var allTasksForDate: [ScheduleTaskModel] = []
    private var displayedTasks: [ScheduleTaskModel] = []

    // Helpers
    private let calendar = Calendar.current
    private let dayFormatter = DateFormatter()
    private let monthFormatter = DateFormatter()

    
    private var kids: [ChildModel] = []
    private var selectedKid: ChildModel?
    

    
   
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        dayFormatter.dateFormat = "d"
        monthFormatter.dateFormat = "MMM"

        setupGradient()
        setupHeader()
        setupDatesStrip()
        setupFilter()
        setupHintLabel() // Add Hint Label to layout
        setupTasksList()
        
        // Header Actions
        header.onChildTapped = { [weak self] in self?.showKidsMenu() }
        header.showProfileButton(true)
        header.onProfileTapped = { [weak self] in
            let vc = ParentProfileViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }

        generateDatesForCurrentMonth()
        buildDateButtons()
        select(date: Date(), animated: false)

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
        if let kid = selectedKid { fetchTasks(for: kid, date: selectedDate) }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
        if let idx = indexOfDate(selectedDate), idx < dateButtons.count {
            centerDateButton(dateButtons[idx], animated: false)
        }
    }
    
    @objc private func handleDataChange() {
        if let kid = selectedKid { fetchTasks(for: kid, date: selectedDate) }
    }

    // MARK: - Data Logic
    private func fetchKidsAndLoad() {
        _Concurrency.Task {
            do {
                let data = try await FamilyService.shared.fetchDashboard()

                await MainActor.run {
                    self.kids = data.children

                    let uiKids = kids.map { Kid(id: $0.id.uuidString, name: $0.name) }
                    header.setKids(uiKids)

                    if let first = kids.first {
                        selectKid(first)
                    } else {
                        header.childButton.setTitle("No Kids", for: .normal)
                    }
                }
            } catch {
                print("Error fetching kids: \(error)")
            }
        }
    }
    
    
    private func selectKid(_ kid: ChildModel) {
        self.selectedKid = kid
        
        let uiKid = Kid(id: kid.id.uuidString, name: kid.name)
        header.setSelectedKid(uiKid)

        fetchTasks(for: kid, date: selectedDate)
    }

    @objc private func handleSelectedKidChanged(_ notification: Notification) {
        guard let uiKid = notification.userInfo?["kid"] as? Kid else { return }

        if let realKid = kids.first(where: { $0.id.uuidString == uiKid.id }) {
            selectKid(realKid)
        }
    }
    
    
    private func fetchTasks(for kid: ChildModel, date: Date) {
            _Concurrency.Task {
                do {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"

                    print("🟡 SCHEDULE DEBUG")
                    print("Child ID:", kid.id)
                    print("Target date:", formatter.string(from: date))

                    let tasks = try await TaskService.shared.fetchSchedule(for: kid.id, date: date)

                    print("🟢 Tasks returned:", tasks.count)
                    print(tasks)

                    
                    await MainActor.run {
                        print("✅ Fetched \(tasks.count) tasks") // Check Console
                        self.allTasksForDate = tasks
                        self.applyFilterAndRender()
                    }
                } catch {
                    print("❌ Error fetching schedule: \(error)")
                    await MainActor.run {
                        // Show Alert so you can see the error on screen
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    
    // MARK: - Filtering & Rendering
    @objc private func filterChanged(_ sender: UISegmentedControl) {
        applyFilterAndRender()
    }
    
    private func applyFilterAndRender() {
        let index = filterControl.selectedSegmentIndex

        switch index {

        case 1:
            // ✅ Completed = approved
            displayedTasks = allTasksForDate.filter {
                $0.submission_status?.lowercased() == "approved"
            }

        case 2:
            // ✅ Not done = pending OR not submitted
            displayedTasks = allTasksForDate.filter {
                $0.submission_status == nil ||
                $0.submission_status?.lowercased() == "pending"
            }

        default:
            displayedTasks = allTasksForDate
        }

        renderTasks(displayedTasks)
    }


    private func renderTasks(_ tasks: [ScheduleTaskModel]) {
        tasksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if tasks.isEmpty {
            emptyLabel.isHidden = false
            hintLabel.isHidden = true
        } else {
            emptyLabel.isHidden = true
            hintLabel.isHidden = false
            
            for (index, t) in tasks.enumerated() {
                let card = ScheduleTaskCard(task: t)
                tasksStack.addArrangedSubview(card)
                card.heightAnchor.constraint(equalToConstant: 90).isActive = true
                
                // Add Tap Gesture for Edit
                card.isUserInteractionEnabled = true
                let tap = TaskTapGesture(target: self, action: #selector(cardTapped(_:)))
                tap.taskIndex = index
                card.addGestureRecognizer(tap)
            }
            
            let spacer = UIView()
            spacer.heightAnchor.constraint(equalToConstant: 30).isActive = true
            tasksStack.addArrangedSubview(spacer)
        }
    }
    
    class TaskTapGesture: UITapGestureRecognizer { var taskIndex: Int = 0 }
    
    // MARK: - OPEN EDIT SCREEN
    @objc private func cardTapped(_ sender: TaskTapGesture) {
        let task = displayedTasks[sender.taskIndex]
        
        let vc = TaskFormViewController()
        vc.mode = .edit(task) // Enable Edit Mode
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    // MARK: - Kids Menu & Date Logic (Standard)
    private func showKidsMenu() {
        guard !kids.isEmpty else { return }

        let uiKids = kids.map { Kid(id: $0.id.uuidString, name: $0.name) }

        let menu = FloatingKidsMenu(kids: uiKids)
        menu.manager = FloatingMenuManager.shared

        menu.onKidSelected = { selectedUiKid in
            SelectedKidStore.shared.updateKid(selectedUiKid)
        }


        menu.show(in: self.view, anchor: header.childButton)
    }


    private func generateDatesForCurrentMonth() {
        allDatesOfMonth.removeAll()
        let today = Date()
        guard let monthRange = calendar.range(of: .day, in: .month, for: today),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else { return }
        for d in monthRange {
            if let date = calendar.date(byAdding: .day, value: d - 1, to: firstOfMonth) { allDatesOfMonth.append(date) }
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
        label.numberOfLines = 0; label.textAlignment = .center; label.translatesAutoresizingMaskIntoConstraints = false
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
        selectedDate = Calendar.current.startOfDay(for: date)
        for (i, btn) in dateButtons.enumerated() {
            if i < allDatesOfMonth.count && calendar.isDate(allDatesOfMonth[i], inSameDayAs: date) {
                btn.backgroundColor = UIColor(red: 56/255, green: 123/255, blue: 255/255, alpha: 1)
            } else { btn.backgroundColor = UIColor(white: 1, alpha: 0.03) }
        }
        if let idx = indexOfDate(date) { centerDateButton(dateButtons[idx], animated: animated) }
        if let kid = selectedKid { fetchTasks(for: kid, date: date) }
    }

    private func centerDateButton(_ button: UIButton, animated: Bool) {
        guard let superview = button.superview else { return }
        let btnFrame = superview.convert(button.frame, to: datesScroll)
        let scrollCenter = datesScroll.bounds.width / 2
        var offsetX = btnFrame.midX - scrollCenter
        offsetX = max(0, min(offsetX, datesScroll.contentSize.width - datesScroll.bounds.width))
        datesScroll.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
    }
    
    @objc private func dateTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx < allDatesOfMonth.count else { return }
        select(date: allDatesOfMonth[idx], animated: true)
    }

    // MARK: - UI Setup
    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0); gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func setupHeader() {
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.showNotificationButton(true); header.showProfileButton(true); header.showPlusButton(false)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 98)
        ])
    }

    private func setupDatesStrip() {
        datesScroll.showsHorizontalScrollIndicator = false; datesScroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datesScroll)
        datesStack.axis = .horizontal; datesStack.alignment = .center; datesStack.spacing = 12; datesStack.translatesAutoresizingMaskIntoConstraints = false
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
        view.addSubview(filterControl)
        filterControl.addTarget(self, action: #selector(filterChanged(_:)), for: .valueChanged)
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
        filterControl.layer.cornerRadius = 19; filterControl.clipsToBounds = true
    }
    
    private func setupHintLabel() {
        view.addSubview(hintLabel)
        NSLayoutConstraint.activate([
            hintLabel.topAnchor.constraint(equalTo: filterControl.bottomAnchor, constant: 8),
            hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hintLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    private func setupTasksList() {
        tasksContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tasksContainer)
        tasksStack.axis = .vertical; tasksStack.spacing = 12; tasksStack.alignment = .fill; tasksStack.translatesAutoresizingMaskIntoConstraints = false
        tasksContainer.addSubview(tasksStack)
        view.addSubview(emptyLabel); emptyLabel.isHidden = true

        NSLayoutConstraint.activate([
            // Layout relative to Hint Label now
            tasksContainer.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 8),
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
    
    deinit { NotificationCenter.default.removeObserver(self) }
}

private extension Date {
    func weekdayShort() -> String {
        let f = DateFormatter()
        f.dateFormat = "E"
        return f.string(from: self)
    }
}
