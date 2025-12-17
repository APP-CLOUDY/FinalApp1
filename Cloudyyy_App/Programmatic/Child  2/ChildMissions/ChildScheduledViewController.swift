import UIKit

final class KidAgendaViewController: UIViewController {

    // MARK: - UI Properties
    private let backgroundGradientLayer = CAGradientLayer()

    // --- Header UI ---
    private let titleHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Schedules"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let approvalsIconButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        button.setImage(UIImage(systemName: "checkmark.seal", withConfiguration: config), for: .normal)
        return button
    }()
    
    private let notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        return button
    }()
    
    private let profileAvatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
        return button
    }()

    // --- Dates Strip ---
    private let datesScrollView = UIScrollView()
    private let datesHorizontalStack = UIStackView()
    private var dateSelectionButtons: [UIButton] = []
    private var currentMonthDates: [Date] = []

    // --- Filters ---
    private let statusFilterControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["All", "To Do", "Done"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    // --- Tasks List ---
    private let agendaScrollView = UIScrollView()
    private let agendaVerticalStack = UIStackView()

    private let noTasksLabel: UILabel = {
        let label = UILabel()
        label.text = "No tasks for this date"
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Data Properties
    private var activeDate: Date = Date()
    
    // Stores all tasks fetched from DB for the selected date
    private var allTasksForDate: [ScheduleTaskModel] = []
    
    // Stores the tasks currently visible based on the Filter (All/To Do/Done)
    private var visibleTasks: [ScheduleTaskModel] = []

    // MARK: - Helpers
    private let gregorianCalendar = Calendar.current
    private let dayNumberFormatter = DateFormatter()
    private let monthNameFormatter = DateFormatter()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        // Formatters Setup
        dayNumberFormatter.dateFormat = "d"
        monthNameFormatter.dateFormat = "MMM"

        // UI Setup
        configureGradientBackground()
        configureHeaderSection()
        configureDatesStripSection()
        configureFilterControl()
        configureAgendaList()

        // Initial Data Setup
        populateCurrentMonthDates()
        rebuildDateButtons()
        
        // Select Today by default
        select(date: Date(), animated: false)
        
        // ✅ NEW: Listen for Chatbot Completion
        NotificationCenter.default.addObserver(self, selector: #selector(handleTaskCompletionRefresh), name: .taskDidComplete, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // ✅ NEW: Refresh when Chatbot finishes a task
    @objc private func handleTaskCompletionRefresh() {
        print("🔄 Schedule Screen received update notification")
        fetchTasks(for: activeDate)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds

        // Keep selected date centered
        if let index = indexOfDate(activeDate), index < dateSelectionButtons.count {
            center(dateButton: dateSelectionButtons[index], animated: false)
        }
    }

    // MARK: - Data Fetching
    private func fetchTasks(for date: Date) {
        // Fetch from Backend using the Service
        _Concurrency.Task {
            do {
                let tasks = try await ChildHomeService.shared.fetchSchedule(date: date)
                
                await MainActor.run {
                    self.allTasksForDate = tasks
                    self.applyFilterAndRender() // Apply current filter (All/To Do/Done)
                }
            } catch {
                print("Error fetching schedule: \(error)")
                await MainActor.run {
                    self.allTasksForDate = []
                    self.renderAgendaCards()
                }
            }
        }
    }

    // MARK: - Filtering Logic
    @objc private func filterSegmentChanged() {
        applyFilterAndRender()
    }

    private func applyFilterAndRender() {
        let index = statusFilterControl.selectedSegmentIndex
        
        switch index {
        case 1: // "To Do" Tab
            // Show only items that have NOT been submitted
            visibleTasks = allTasksForDate.filter {
                $0.submission_status == nil
            }
            
        case 2: // "Done" Tab
            // ✅ CHANGED: Show Approved OR Pending (Waiting for parent)
            visibleTasks = allTasksForDate.filter {
                let status = $0.submission_status?.lowercased()
                return status == "approved" || status == "pending"
            }
            
        default: // "All" Tab
            visibleTasks = allTasksForDate
        }
        
        renderAgendaCards()
    }

    private func renderAgendaCards() {
        // Clear previous cards
        agendaVerticalStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if visibleTasks.isEmpty {
            noTasksLabel.isHidden = false
            return
        }

        noTasksLabel.isHidden = true

        for task in visibleTasks {
            // Initialize the Panel with the task model
            let card = KidAgendaItemPanel(task: task)
            
            // Layout constraints for the card
            card.heightAnchor.constraint(equalToConstant: 84).isActive = true
            agendaVerticalStack.addArrangedSubview(card)
        }

        // Bottom spacer to ensure last item isn't hidden behind tab bar
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        agendaVerticalStack.addArrangedSubview(spacer)
    }

    // MARK: - Date Logic
    private func populateCurrentMonthDates() {
        currentMonthDates.removeAll()
        let today = Date()
        // Generate dates for -2 days to +14 days
        for i in -2...14 {
            if let date = gregorianCalendar.date(byAdding: .day, value: i, to: today) {
                currentMonthDates.append(date)
            }
        }
    }

    private func rebuildDateButtons() {
        datesHorizontalStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dateSelectionButtons.removeAll()

        // Spacers for centering
        let leftSpace = UIView(); leftSpace.widthAnchor.constraint(equalToConstant: view.bounds.width/2 - 44).isActive = true
        datesHorizontalStack.addArrangedSubview(leftSpace)

        for (index, date) in currentMonthDates.enumerated() {
            let btn = createDateButton(for: date)
            btn.tag = index
            dateSelectionButtons.append(btn)
            datesHorizontalStack.addArrangedSubview(btn)
        }

        let rightSpace = UIView(); rightSpace.widthAnchor.constraint(equalToConstant: view.bounds.width/2 - 44).isActive = true
        datesHorizontalStack.addArrangedSubview(rightSpace)
    }

    private func createDateButton(for date: Date) -> UIButton {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 88).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 72).isActive = true
        btn.layer.cornerRadius = 12
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.05)

        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let dayName = date.shortWeekdaySymbol()
        label.attributedText = NSAttributedString(
            string: "\(monthNameFormatter.string(from: date))\n\(dayNumberFormatter.string(from: date))\n\(dayName)",
            attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 15, weight: .semibold)]
        )

        btn.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: btn.centerYAnchor)
        ])

        btn.addTarget(self, action: #selector(dateButtonTapped(_:)), for: .touchUpInside)
        return btn
    }

    private func select(date: Date, animated: Bool) {
        activeDate = date
        guard let index = indexOfDate(date) else { return }

        // Update Selection UI
        for (i, btn) in dateSelectionButtons.enumerated() {
            btn.backgroundColor = (i == index) ? UIColor(red: 56/255, green: 123/255, blue: 255/255, alpha: 1) : UIColor.white.withAlphaComponent(0.05)
        }

        // Scroll to center
        if index < dateSelectionButtons.count {
            center(dateButton: dateSelectionButtons[index], animated: animated)
        }

        // Fetch Data
        fetchTasks(for: date)
    }

    private func indexOfDate(_ date: Date) -> Int? {
        return currentMonthDates.firstIndex { gregorianCalendar.isDate($0, inSameDayAs: date) }
    }

    private func center(dateButton: UIButton, animated: Bool) {
        guard let parent = dateButton.superview else { return }
        let frame = parent.convert(dateButton.frame, to: datesScrollView)
        let centerX = datesScrollView.bounds.width / 2
        let offset = frame.midX - centerX
        datesScrollView.setContentOffset(CGPoint(x: max(0, offset), y: 0), animated: animated)
    }

    @objc private func dateButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < currentMonthDates.count else { return }
        select(date: currentMonthDates[index], animated: true)
    }

    // MARK: - Navigation Actions (Placeholders)
    @objc private func didTapApprovals() {
        print("Approvals Tapped")
    }
    
    @objc private func didTapNotifications() {
        print("Notifications Tapped")
    }
    
    @objc private func didTapProfile() {
        print("Profile Tapped")
    }

    // MARK: - UI Configuration Boilerplate
    private func configureGradientBackground() {
        backgroundGradientLayer.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }

    private func configureHeaderSection() {
        view.addSubview(titleHeaderLabel)
        view.addSubview(notificationButton)
        view.addSubview(profileAvatarButton)
        view.addSubview(approvalsIconButton)

        NSLayoutConstraint.activate([
            titleHeaderLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -10),
            titleHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            profileAvatarButton.centerYAnchor.constraint(equalTo: titleHeaderLabel.centerYAnchor),
            profileAvatarButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileAvatarButton.widthAnchor.constraint(equalToConstant: 30),
            profileAvatarButton.heightAnchor.constraint(equalToConstant: 30),

            notificationButton.centerYAnchor.constraint(equalTo: titleHeaderLabel.centerYAnchor),
            notificationButton.trailingAnchor.constraint(equalTo: profileAvatarButton.leadingAnchor, constant: -16),
            notificationButton.widthAnchor.constraint(equalToConstant: 28),
            notificationButton.heightAnchor.constraint(equalToConstant: 28),
            
            approvalsIconButton.centerYAnchor.constraint(equalTo: titleHeaderLabel.centerYAnchor),
            approvalsIconButton.trailingAnchor.constraint(equalTo: notificationButton.leadingAnchor, constant: -16),
            approvalsIconButton.widthAnchor.constraint(equalToConstant: 30),
            approvalsIconButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func configureDatesStripSection() {
        datesScrollView.showsHorizontalScrollIndicator = false
        datesScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datesScrollView)

        datesHorizontalStack.axis = .horizontal
        datesHorizontalStack.spacing = 12
        datesHorizontalStack.alignment = .center
        datesHorizontalStack.translatesAutoresizingMaskIntoConstraints = false
        datesScrollView.addSubview(datesHorizontalStack)

        NSLayoutConstraint.activate([
            datesScrollView.topAnchor.constraint(equalTo: titleHeaderLabel.bottomAnchor, constant: 20),
            datesScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            datesScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            datesScrollView.heightAnchor.constraint(equalToConstant: 84),

            datesHorizontalStack.leadingAnchor.constraint(equalTo: datesScrollView.contentLayoutGuide.leadingAnchor),
            datesHorizontalStack.trailingAnchor.constraint(equalTo: datesScrollView.contentLayoutGuide.trailingAnchor),
            datesHorizontalStack.topAnchor.constraint(equalTo: datesScrollView.contentLayoutGuide.topAnchor),
            datesHorizontalStack.bottomAnchor.constraint(equalTo: datesScrollView.contentLayoutGuide.bottomAnchor),
            datesHorizontalStack.heightAnchor.constraint(equalTo: datesScrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    private func configureFilterControl() {
        statusFilterControl.addTarget(self, action: #selector(filterSegmentChanged), for: .valueChanged)
        view.addSubview(statusFilterControl)
        statusFilterControl.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        statusFilterControl.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.20)
        statusFilterControl.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.7), .font: UIFont.systemFont(ofSize: 15)], for: .normal)
        statusFilterControl.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 15, weight: .semibold)], for: .selected)
        
        NSLayoutConstraint.activate([
            statusFilterControl.topAnchor.constraint(equalTo: datesScrollView.bottomAnchor, constant: 14),
            statusFilterControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            statusFilterControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            statusFilterControl.heightAnchor.constraint(equalToConstant: 38)
        ])
    }

    private func configureAgendaList() {
        agendaScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(agendaScrollView)

        agendaVerticalStack.axis = .vertical
        agendaVerticalStack.spacing = 12
        agendaVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        agendaScrollView.addSubview(agendaVerticalStack)

        view.addSubview(noTasksLabel)
        noTasksLabel.isHidden = true

        NSLayoutConstraint.activate([
            agendaScrollView.topAnchor.constraint(equalTo: statusFilterControl.bottomAnchor, constant: 14),
            agendaScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            agendaScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            agendaScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),

            agendaVerticalStack.leadingAnchor.constraint(equalTo: agendaScrollView.contentLayoutGuide.leadingAnchor),
            agendaVerticalStack.trailingAnchor.constraint(equalTo: agendaScrollView.contentLayoutGuide.trailingAnchor),
            agendaVerticalStack.topAnchor.constraint(equalTo: agendaScrollView.contentLayoutGuide.topAnchor),
            agendaVerticalStack.bottomAnchor.constraint(equalTo: agendaScrollView.contentLayoutGuide.bottomAnchor),
            agendaVerticalStack.widthAnchor.constraint(equalTo: agendaScrollView.frameLayoutGuide.widthAnchor),

            noTasksLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noTasksLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40)
        ])
    }
}

// MARK: - Date Extension
private extension Date {
    func shortWeekdaySymbol() -> String {
        let df = DateFormatter()
        df.dateFormat = "E"
        return df.string(from: self)
    }
}
