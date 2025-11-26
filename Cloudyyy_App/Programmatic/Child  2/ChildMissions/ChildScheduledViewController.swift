// KidAgendaViewController.swift
// Cloudyyy_App

import UIKit

// MARK: - KidAgendaViewController

final class KidAgendaViewController: UIViewController {

    // MARK: - UI
    private let backgroundGradientLayer = CAGradientLayer()
 
    // ------ HEADER ------
    private let titleHeaderLabel: UILabel = {
        let title = UILabel()
        title.text = "Schedules"
        title.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()

    private let approvalsIconButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        // SF Symbol for "Approvals" / "Official Requests"
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        button.setImage(UIImage(systemName: "checkmark.seal", withConfiguration: config), for: .normal)
        return button
    }()
    
    private let notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        button.setImage(UIImage(systemName: "bell", withConfiguration: config), for: .normal)
        return button
    }()
    
    private let notificationIndicatorDot: UIView = {
        let indicator = UIView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = UIColor(red: 1, green: 0.23, blue: 0.22, alpha: 1)
        indicator.layer.cornerRadius = 4
        indicator.isHidden = false
        return indicator
    }()
    
    private let profileAvatarButton: UIButton = {
        let avatarButton = UIButton(type: .system)
        avatarButton.translatesAutoresizingMaskIntoConstraints = false
        avatarButton.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        avatarButton.setImage(UIImage(systemName: "person.circle", withConfiguration: config), for: .normal)
        return avatarButton
    }()
    
    // Dates strip UI
    private let datesScrollView = UIScrollView()
    private let datesHorizontalStack = UIStackView()
    private var dateSelectionButtons: [UIButton] = []
    private var currentMonthDates: [Date] = []

    // Filters
    private let statusFilterControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["All", "In progress", "Completed"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    // Tasks list
    private let agendaScrollView = UIScrollView()
    private let agendaVerticalStack = UIStackView()

    // Empty message
    private let noTasksLabel: UILabel = {
        let label = UILabel()
        label.text = "No tasks for this date"
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Data
    private var activeDate: Date = Date()
    private var activeChild: KidProfile? { KidCoordinator.shared.focusedChild }
    private var agendaItemsForActiveDate: [AgendaEntry] = []

    // Helpers
    private let gregorianCalendar = Calendar.current
    private let shortDateFormatter = DateFormatter()
    private let dayNumberFormatter = DateFormatter()
    private let monthNameFormatter = DateFormatter()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        // formatters
        shortDateFormatter.dateFormat = "yyyy-MM-dd"
        dayNumberFormatter.dateFormat = "d"
        monthNameFormatter.dateFormat = "MMM"

        configureGradientBackground()
        configureHeaderSection()
        configureDatesStripSection()
        configureFilterControl()
        configureAgendaList()
        configureChildChangeListener()

        populateCurrentMonthDates()
        rebuildDateButtons()
        select(date: Date(), animated: false)

        if let initialChild = KidCoordinator.shared.focusedChild {
            refreshForChild(initialChild)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure nav bar is hidden on this main screen
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds

        // recenter selected date
        if let index = indexOfDate(activeDate), index + 1 < dateSelectionButtons.count {
            center(dateButton: dateSelectionButtons[index + 1], animated: false)
        }
    }

    // MARK: - Gradient
    private func configureGradientBackground() {
        backgroundGradientLayer.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }

    // MARK: - Header Configuration
    private func configureHeaderSection() {
        view.addSubview(titleHeaderLabel)
        view.addSubview(notificationButton)
        notificationButton.addSubview(notificationIndicatorDot)
        view.addSubview(profileAvatarButton)
        view.addSubview(approvalsIconButton)
        
        // --- Add Targets for Buttons ---
        approvalsIconButton.addTarget(self, action: #selector(didTapApprovals), for: .touchUpInside)
        notificationButton.addTarget(self, action: #selector(didTapNotification), for: .touchUpInside)
        profileAvatarButton.addTarget(self, action: #selector(didTapProfile), for: .touchUpInside)

        NSLayoutConstraint.activate([
            // 1. Title (Top Left)
            titleHeaderLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -10),
            titleHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // 2. Profile Icon (Far Right)
            profileAvatarButton.centerYAnchor.constraint(equalTo: titleHeaderLabel.centerYAnchor),
            profileAvatarButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileAvatarButton.widthAnchor.constraint(equalToConstant: 30),
            profileAvatarButton.heightAnchor.constraint(equalToConstant: 30),

            // 3. Notification Bell (Left of Profile)
            notificationButton.centerYAnchor.constraint(equalTo: titleHeaderLabel.centerYAnchor),
            notificationButton.trailingAnchor.constraint(equalTo: profileAvatarButton.leadingAnchor, constant: -16),
            notificationButton.widthAnchor.constraint(equalToConstant: 28),
            notificationButton.heightAnchor.constraint(equalToConstant: 28),

            // Notification Dot logic
            notificationIndicatorDot.topAnchor.constraint(equalTo: notificationButton.topAnchor, constant: 2),
            notificationIndicatorDot.trailingAnchor.constraint(equalTo: notificationButton.trailingAnchor, constant: 2),
            notificationIndicatorDot.widthAnchor.constraint(equalToConstant: 8),
            notificationIndicatorDot.heightAnchor.constraint(equalToConstant: 8),
          
            // 4. Approvals Icon (Left of Notification Bell)
            approvalsIconButton.centerYAnchor.constraint(equalTo: titleHeaderLabel.centerYAnchor),
            approvalsIconButton.trailingAnchor.constraint(equalTo: notificationButton.leadingAnchor, constant: -16),
            approvalsIconButton.widthAnchor.constraint(equalToConstant: 30),
            approvalsIconButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // MARK: - Dates Strip UI
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

            datesHorizontalStack.leadingAnchor.constraint(equalTo: datesScrollView.contentLayoutGuide.leadingAnchor, constant: 12),
            datesHorizontalStack.trailingAnchor.constraint(equalTo: datesScrollView.contentLayoutGuide.trailingAnchor, constant: -12),
            datesHorizontalStack.topAnchor.constraint(equalTo: datesScrollView.contentLayoutGuide.topAnchor),
            datesHorizontalStack.bottomAnchor.constraint(equalTo: datesScrollView.contentLayoutGuide.bottomAnchor),
            datesHorizontalStack.heightAnchor.constraint(equalTo: datesScrollView.frameLayoutGuide.heightAnchor)
        ])
    }
    
    private func configureFilterControl() {
        statusFilterControl.addTarget(self, action: #selector(filterSegmentChanged), for: .valueChanged)

        view.addSubview(statusFilterControl)

        NSLayoutConstraint.activate([
            statusFilterControl.topAnchor.constraint(equalTo: datesScrollView.bottomAnchor, constant: 14),
            statusFilterControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            statusFilterControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            statusFilterControl.heightAnchor.constraint(equalToConstant: 38)
        ])

        statusFilterControl.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        statusFilterControl.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.20)

        statusFilterControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white.withAlphaComponent(0.7),
            .font: UIFont.systemFont(ofSize: 15)
        ], for: .normal)

        statusFilterControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ], for: .selected)

        statusFilterControl.layer.cornerRadius = 19
        statusFilterControl.clipsToBounds = true
    }

    // MARK: - Tasks UI
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

    // MARK: - Date generation
    private func populateCurrentMonthDates() {
        currentMonthDates.removeAll()

        let todayReference = Date()
        guard
            let dayRange = gregorianCalendar.range(of: .day, in: .month, for: todayReference),
            let firstDayOfMonth = gregorianCalendar.date(from: gregorianCalendar.dateComponents([.year, .month], from: todayReference))
        else { return }

        for dayIndex in dayRange {
            if let computedDate = gregorianCalendar.date(byAdding: .day, value: dayIndex - 1, to: firstDayOfMonth) {
                currentMonthDates.append(computedDate)
            }
        }
    }

    private func rebuildDateButtons() {
        datesHorizontalStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dateSelectionButtons.removeAll()

        // Leading spacer
        let leadingSpacer = UIView()
        leadingSpacer.widthAnchor.constraint(equalToConstant: view.bounds.width / 2 - 44).isActive = true
        datesHorizontalStack.addArrangedSubview(leadingSpacer)

        // Buttons
        for (index, currentDate) in currentMonthDates.enumerated() {
            let dateButton = createDateButton(for: currentDate)
            dateButton.tag = index
            dateSelectionButtons.append(dateButton)
            datesHorizontalStack.addArrangedSubview(dateButton)
        }

        // Trailing spacer
        let trailingSpacer = UIView()
        trailingSpacer.widthAnchor.constraint(equalToConstant: view.bounds.width / 2 - 44).isActive = true
        datesHorizontalStack.addArrangedSubview(trailingSpacer)
    }

    private func createDateButton(for date: Date) -> UIButton {
        let dateButton = UIButton(type: .system)
        dateButton.translatesAutoresizingMaskIntoConstraints = false
        dateButton.widthAnchor.constraint(equalToConstant: 88).isActive = true
        dateButton.heightAnchor.constraint(equalToConstant: 72).isActive = true
        dateButton.layer.cornerRadius = 12

        // Month-day-week text
        let dateLabel = UILabel()
        dateLabel.numberOfLines = 0
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.attributedText = NSAttributedString(
            string: "\(monthNameFormatter.string(from: date))\n\(dayNumberFormatter.string(from: date))\n\(date.shortWeekdaySymbol())",
            attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 15, weight: .semibold)]
        )

        dateButton.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: dateButton.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: dateButton.centerYAnchor)
        ])

        dateButton.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        dateButton.addTarget(self, action: #selector(dateButtonTapped(_:)), for: .touchUpInside)

        return dateButton
    }

    private func indexOfDate(_ date: Date) -> Int? {
        return currentMonthDates.firstIndex { gregorianCalendar.isDate($0, inSameDayAs: date) }
    }

    private func select(date: Date, animated: Bool) {
        activeDate = date
        guard let dateIndex = indexOfDate(date) else { return }

        for (buttonIndex, dateButton) in dateSelectionButtons.enumerated() {
            let isCurrentlySelected = buttonIndex - 1 == dateIndex
            if buttonIndex > 0 && buttonIndex < dateSelectionButtons.count - 1 {
                dateButton.backgroundColor = isCurrentlySelected
                    ? UIColor(red: 56/255, green: 123/255, blue: 255/255, alpha: 1)
                    : UIColor.white.withAlphaComponent(0.05)
            }
        }

        let arrayButtonIndex = dateIndex + 1
        if arrayButtonIndex < dateSelectionButtons.count - 1 {
            center(dateButton: dateSelectionButtons[arrayButtonIndex], animated: animated)
        }

        reloadAgendaFor(date: date)
    }

    private func center(dateButton: UIButton, animated: Bool) {
        guard let parentView = dateButton.superview else { return }
        let convertedFrame = parentView.convert(dateButton.frame, to: datesScrollView)
        let centerX = datesScrollView.bounds.width / 2
        
        var newOffsetX = convertedFrame.midX - centerX
        newOffsetX = max(0, min(newOffsetX, datesScrollView.contentSize.width - datesScrollView.bounds.width))

        datesScrollView.setContentOffset(CGPoint(x: newOffsetX, y: 0), animated: animated)
    }

    // MARK: - Filters + Tasks
    @objc private func filterSegmentChanged() {
        reloadAgendaFor(date: activeDate)
    }

    private func reloadAgendaFor(date: Date) {
        guard let focusedChild = activeChild else {
            agendaItemsForActiveDate = []
            renderAgendaCards()
            return
        }

        let fullSchedule = KidCoordinator.shared.schedule(for: focusedChild.id)
        let keyForDate = shortDateFormatter.string(from: date)
        let agendaForDate = fullSchedule.filter { $0.date == keyForDate }

        switch statusFilterControl.selectedSegmentIndex {
        case 1:
            agendaItemsForActiveDate = agendaForDate.filter { $0.status.lowercased().contains("progress") }
        case 2:
            agendaItemsForActiveDate = agendaForDate.filter { $0.status.lowercased().contains("completed") }
        default:
            agendaItemsForActiveDate = agendaForDate
        }

        renderAgendaCards()
    }

    private func renderAgendaCards() {
        agendaVerticalStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if agendaItemsForActiveDate.isEmpty {
            noTasksLabel.isHidden = false
            return
        }

        noTasksLabel.isHidden = true

        for agendaEntry in agendaItemsForActiveDate {
            let agendaCard = KidAgendaItemPanel(entry: agendaEntry)
            agendaCard.heightAnchor.constraint(equalToConstant: 84).isActive = true
            agendaVerticalStack.addArrangedSubview(agendaCard)
        }

        let bottomSpacer = UIView()
        bottomSpacer.heightAnchor.constraint(equalToConstant: 30).isActive = true
        agendaVerticalStack.addArrangedSubview(bottomSpacer)
    }

    // MARK: - Actions
    @objc private func dateButtonTapped(_ sender: UIButton) {
        let dateIndex = sender.tag
        guard dateIndex < currentMonthDates.count else { return }
        select(date: currentMonthDates[dateIndex], animated: true)
    }
    
    // --- Navigation Actions ---
    @objc private func didTapApprovals() {
        let approvalsVC = ApprovalsViewController()
        approvalsVC.modalPresentationStyle = .fullScreen
        present(approvalsVC, animated: true)
    }
    
    @objc private func didTapNotification() {
        let vc = NotificationViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapProfile() {
        let vc = ProfileViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Kid changes
    private func configureChildChangeListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(childDidChange(_:)), name: KidCoordinator.childDidChangeNotification, object: nil)
    }

    @objc private func childDidChange(_ note: Notification) {
        guard let updatedChild = note.object as? KidProfile else { return }
        refreshForChild(updatedChild)
    }

    private func refreshForChild(_ child: KidProfile) {
        select(date: Date(), animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Date Helper
private extension Date {
    func shortWeekdaySymbol() -> String {
        let df = DateFormatter()
        df.dateFormat = "E"
        return df.string(from: self)
    }
}
