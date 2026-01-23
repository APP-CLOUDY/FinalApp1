import UIKit
import Supabase
// MARK: - Main View Controller
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
        // Options: All | To Do | Done
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
    private var allTasksForDate: [ScheduleTaskModelChild] = []
    private var visibleTasks: [ScheduleTaskModelChild] = []

    // MARK: - Helpers
    private let gregorianCalendar = Calendar.current
    private let dayNumberFormatter = DateFormatter()
    private let monthNameFormatter = DateFormatter()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        dayNumberFormatter.dateFormat = "d"
        monthNameFormatter.dateFormat = "MMM"

        configureGradientBackground()
        configureHeaderSection()
        configureDatesStripSection()
        configureFilterControl()
        configureAgendaList()

        populateCurrentMonthDates()
        rebuildDateButtons()
        
        select(date: Date(), animated: false)
        
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleTaskCompletionRefresh),
                name: .taskDidComplete, // This now comes from CloudyTheme.swift
                object: nil)
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    @objc private func handleTaskCompletionRefresh() {
        fetchTasks(for: activeDate)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
        if let index = indexOfDate(activeDate), index < dateSelectionButtons.count {
            center(dateButton: dateSelectionButtons[index], animated: false)
        }
    }

    // MARK: - Data Fetching
    private func fetchTasks(for date: Date) {
        _Concurrency.Task {
            do {
                let tasks = try await ChildHomeService.shared.fetchSchedule(date: date)
                await MainActor.run {
                    self.allTasksForDate = tasks
                    self.applyFilterAndRender()
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
        case 1: // "To Do"
            visibleTasks = allTasksForDate.filter { $0.submission_status == nil }
            
        case 2: // "Done"
            visibleTasks = allTasksForDate.filter {
                $0.submission_status?.lowercased() == "approved"
            }
            
        default: // "All"
            visibleTasks = allTasksForDate
        }
        
        renderAgendaCards()
    }

    private func renderAgendaCards() {
        agendaVerticalStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if visibleTasks.isEmpty {
            noTasksLabel.isHidden = false
            return
        }

        noTasksLabel.isHidden = true

        for task in visibleTasks {
            let card = KidAgendaItemPanel(task: task)
            configureCardAppearance(card: card, task: task)
            card.heightAnchor.constraint(equalToConstant: 84).isActive = true
            agendaVerticalStack.addArrangedSubview(card)
        }

        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        agendaVerticalStack.addArrangedSubview(spacer)
    }
    
    // MARK: - Dynamic Color Logic
    private func configureCardAppearance(card: KidAgendaItemPanel, task: ScheduleTaskModelChild) {
        let status = task.submission_status?.lowercased()
        
        if status == "approved" {
            card.setStatusColor(.systemGreen)
            return
        }
        
        if status == "pending" {
            card.setStatusColor(.systemYellow)
            return
        }
        
        if isPastDue(dateStr: task.due_date, timeStr: task.due_time) {
            card.setStatusColor(.systemRed)
        } else {
            card.setStatusColor(.systemYellow)
        }
    }
    
    private func isPastDue(dateStr: String?, timeStr: String?) -> Bool {
        guard let dateStr = dateStr else { return false }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let timeStr = timeStr {
            let combinedString = "\(dateStr) \(timeStr)"
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let dueDateTime = formatter.date(from: combinedString) {
                return Date() > dueDateTime
            }
        }
        
        formatter.dateFormat = "yyyy-MM-dd"
        if let dueDate = formatter.date(from: dateStr) {
            return Calendar.current.startOfDay(for: Date()) > Calendar.current.startOfDay(for: dueDate)
        }

        return false
    }
    
    // MARK: - Lifecycle Updates
        
        // Add this method to auto-refresh data whenever the screen appears
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Reload data for the currently selected date
            print("🔄 Refreshing schedule data...")
            fetchTasks(for: activeDate)
        }

    // MARK: - Date Logic
    private func populateCurrentMonthDates() {
        currentMonthDates.removeAll()
        let today = Date()
        for i in -2...14 {
            if let date = gregorianCalendar.date(byAdding: .day, value: i, to: today) {
                currentMonthDates.append(date)
            }
        }
    }

    private func rebuildDateButtons() {
        datesHorizontalStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dateSelectionButtons.removeAll()

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

        for (i, btn) in dateSelectionButtons.enumerated() {
            btn.backgroundColor = (i == index) ? UIColor(red: 56/255, green: 123/255, blue: 255/255, alpha: 1) : UIColor.white.withAlphaComponent(0.05)
        }

        if index < dateSelectionButtons.count {
            center(dateButton: dateSelectionButtons[index], animated: animated)
        }

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

    // MARK: - Navigation Actions
    // MARK: - Navigation Actions
    @objc private func didTapApprovalsButton() {
        // 1. Get the ID from your generic Session Manager (matches ChildHomeService logic)
        guard let childId = ChildSessionManager.shared.currentChildId else {
            print("❌ Error: No Child ID found in ChildSessionManager")
            return
        }
        
        print("✅ DEBUG: Found Child ID: \(childId)")
        
        // 2. SAVE the ID to UserDefaults so the next screen can read it
        UserDefaults.standard.set(childId.uuidString, forKey: "selectedChildId")
        
        // 3. Navigate
        let approvalsVC = KidsApprovalsViewController()
        approvalsVC.hidesBottomBarWhenPushed = true
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(approvalsVC, animated: true)
        } else {
            // Fallback if no navigation controller
            present(approvalsVC, animated: true)
        }
    }
    
    @objc private func didTapProfileButton() {
            let profileVC = ProfileViewController()
            
            // 1. Hide the Tab Bar
            profileVC.hidesBottomBarWhenPushed = true
            
            // 2. Unhide Navigation Bar so the "Back" button appears
            navigationController?.setNavigationBarHidden(false, animated: true)
            
            // 3. Push
            navigationController?.pushViewController(profileVC, animated: true)
        }
    

    // MARK: - UI Configuration
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
        
        // ✅ Target added here to link the button to the function
        approvalsIconButton.addTarget(self, action: #selector(didTapApprovalsButton), for: .touchUpInside)
        
        // 👇 ADD THIS LINE: Connect Profile Button
                profileAvatarButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)

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



