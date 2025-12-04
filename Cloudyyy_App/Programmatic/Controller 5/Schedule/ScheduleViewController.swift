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
        let c = UISegmentedControl(items: ["All", "To Do", "Done"])
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

    // Data Properties
    private var selectedDate: Date = Date()
    private var currentKid: ChildModel? // Real Supabase Model
    
    // We store the fetched tasks here
    private var allTasksForDate: [ScheduleTaskModel] = []

    // Helpers
    private let calendar = Calendar.current
    private let dateFormatterShort = DateFormatter()
    private let dayFormatter = DateFormatter()
    private let monthFormatter = DateFormatter()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        // Formatters
        dateFormatterShort.dateFormat = "yyyy-MM-dd"
        dayFormatter.dateFormat = "d"
        monthFormatter.dateFormat = "MMM"

        setupGradient()
        setupHeader()
        setupDatesStrip()
        setupFilter()
        setupTasksList()
        
        // Header Actions
        header.onChildTapped = { [weak self] in self?.showKidsMenu() }
        header.showProfileButton(true)
        header.onProfileTapped = { [weak self] in
            let vc = ParentProfileViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }

        // Calendar Setup
        generateDatesForCurrentMonth()
        buildDateButtons()
        
        // Initial Load
        fetchKidsAndLoad()
        
        // Listen for "Task Added" updates
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataChange), name: NSNotification.Name("DataChanged"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Refresh if we have context
        if let kid = currentKid {
            fetchTasks(for: kid, date: selectedDate)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
        
        // Ensure selected date is centered
        if let idx = indexOfDate(selectedDate), idx < dateButtons.count {
            centerDateButton(dateButtons[idx], animated: false)
        }
    }
    
    @objc private func handleDataChange() {
        if let kid = currentKid {
            fetchTasks(for: kid, date: selectedDate)
        }
    }

    // MARK: - Data Logic (Supabase)
    
    private func fetchKidsAndLoad() {
        _Concurrency.Task {
            do {
                let data = try await FamilyService.shared.fetchDashboard()
                await MainActor.run {
                    if let first = data.children.first {
                        self.updateCurrentKid(first)
                    } else {
                        self.header.childButton.setTitle("No Kids", for: .normal)
                    }
                }
            } catch {
                print("Error loading kids: \(error)")
            }
        }
    }
    
    private func updateCurrentKid(_ kid: ChildModel) {
        self.currentKid = kid
        header.childButton.setTitle("\(kid.name) ▾", for: .normal)
        // Load tasks for today/selected date
        select(date: selectedDate, animated: true)
    }
    
    private func fetchTasks(for kid: ChildModel, date: Date) {
        _Concurrency.Task {
            do {
                // Call the service we created
                let tasks = try await TaskService.shared.fetchSchedule(for: kid.id, date: date)
                
                await MainActor.run {
                    self.allTasksForDate = tasks
                    self.applyFilterAndRender()
                }
            } catch {
                print("Error fetching schedule: \(error)")
            }
        }
    }
    
    // MARK: - Filtering & Rendering
    
    @objc private func filterChanged(_ sender: UISegmentedControl) {
        applyFilterAndRender()
    }
    
    private func applyFilterAndRender() {
        let index = filterControl.selectedSegmentIndex
        
        let filteredTasks: [ScheduleTaskModel]
        
        switch index {
        case 1: // "To Do" Tab
            // Show tasks that are NOT completed (submission is nil)
            filteredTasks = allTasksForDate.filter { $0.submission_status == nil }
            
        case 2: // "Done" Tab
            // Show tasks that are Pending OR Approved (Child has finished them)
            filteredTasks = allTasksForDate.filter { $0.submission_status == "pending" || $0.submission_status == "approved" }
            
        default: // "All" Tab
            filteredTasks = allTasksForDate
        }
        
        renderTasks(filteredTasks)
    }

    private func renderTasks(_ tasks: [ScheduleTaskModel]) {
        tasksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if tasks.isEmpty {
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
            for t in tasks {
                // Use the updated Card
                let card = ScheduleTaskCard(task: t)
                tasksStack.addArrangedSubview(card)
                
                card.heightAnchor.constraint(equalToConstant: 90).isActive = true
                
                // Optional: Add tap gesture to edit/delete later
                card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped)))
            }
            
            let spacer = UIView()
            spacer.heightAnchor.constraint(equalToConstant: 30).isActive = true
            tasksStack.addArrangedSubview(spacer)
        }
    }
    
    @objc private func cardTapped() {
        // Logic to open task details
    }

    // MARK: - Kids Menu
    private func showKidsMenu() {
        _Concurrency.Task {
            do {
                let data = try await FamilyService.shared.fetchDashboard()
                await MainActor.run {
                    let uiKids = data.children.map { Kid(id: $0.id.uuidString, name: $0.name) }
                    
                    let menu = FloatingKidsMenu(kids: uiKids)
                    menu.manager = FloatingMenuManager.shared
                    menu.onKidSelected = { [weak self] selectedUiKid in
                        if let realKid = data.children.first(where: { $0.id.uuidString == selectedUiKid.id }) {
                            self?.updateCurrentKid(realKid)
                        }
                    }
                    menu.show(in: self.view, anchor: self.header.childButton)
                }
            } catch { print(error) }
        }
    }

    // MARK: - Date Logic
    
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
        // Spacers to center first/last items
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
        
        // Update UI State
        for (i, btn) in dateButtons.enumerated() {
            if i < allDatesOfMonth.count && calendar.isDate(allDatesOfMonth[i], inSameDayAs: date) {
                btn.backgroundColor = UIColor(red: 56/255, green: 123/255, blue: 255/255, alpha: 1)
            } else {
                btn.backgroundColor = UIColor(white: 1, alpha: 0.03)
            }
        }
        
        if let idx = indexOfDate(date) { centerDateButton(dateButtons[idx], animated: animated) }
        
        // Trigger Fetch
        if let kid = currentKid {
            fetchTasks(for: kid, date: date)
        }
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
            header.heightAnchor.constraint(equalToConstant: 98)
        ])
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
        view.addSubview(filterControl)
        filterControl.addTarget(self, action: #selector(filterChanged(_:)), for: .valueChanged) // ✅ ACTION ADDED
        
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
    
    deinit { NotificationCenter.default.removeObserver(self) }
}

// Helper
private extension Date {
    func weekdayShort() -> String {
        let f = DateFormatter()
        f.dateFormat = "E"
        return f.string(from: self)
    }
}
