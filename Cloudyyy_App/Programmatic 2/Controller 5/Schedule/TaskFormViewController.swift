import UIKit

final class TaskFormViewController: UIViewController {

    // MARK: - Properties
    // ✅ CHANGED: Direct property for the task we are editing
    var taskToEdit: ScheduleTaskModel?

    private var childrenList: [ChildModel] = []
    private var assignedSelections = Set<UUID>()
    
    // Task Data
    private var selectedDate: Date?
    private var taskLists: [TaskListModel] = []
    private var selectedListId: UUID?
    private var familyId: UUID?

    // Repeat Data
    private var selectedFrequency: String = "Once"
    private var repeatInterval: Int = 1
    private var repeatEndDate: Date?
    private var repeatDays: Set<Int> = [] // 1=Mon, 7=Sun

    // MARK: - UI Elements
    private let gradient = CAGradientLayer()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()

    private let titleNotesView = CombinedTitleNotesView(
        titlePlaceholder: "Title *",
        notesPlaceholder: "Description (Optional)"
    )

    private let priorityRow = SelectRow(title: "Priority")
    private let pointsRow = PointsRow()
    
    // --- Date Section ---
    private let dateRow = SelectRow(title: "Due Date & Time")
    private lazy var dateSectionStack: UIStackView = makeDatePickerStack(action: #selector(dueDatePickerChanged))
    private lazy var dueDatePicker: UIDatePicker = extractDatePicker(from: dateSectionStack)
    
    // --- Repeat Section ---
    private let frequencyRow = SelectRow(title: "Frequency")
    private let intervalRow = SelectRow(title: "Repeat Interval")
    private let endRepeatRow = SelectRow(title: "End Repeat")
    private lazy var endRepeatSectionStack: UIStackView = makeDatePickerStack(action: #selector(endDatePickerChanged), mode: .date)
    private lazy var endRepeatPicker: UIDatePicker = extractDatePicker(from: endRepeatSectionStack)
    private let daysRow = SelectRow(title: "On Days")

    // --- Bottom Section ---
    private let listRow = SelectRow(title: "List")
    private let approvalRow = ApprovalToggleRow(title: "Approval")
    private let assignedRow = SelectRow(title: "Assigned To")

    // ✅ Delete button is now standard property (always visible)
    private let deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Delete Task", for: .normal)
        b.setTitleColor(.systemRed, for: .normal)
        b.backgroundColor = UIColor.red.withAlphaComponent(0.12)
        b.layer.cornerRadius = 12
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return b
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Edit Task" // ✅ Always Edit

        setupNavigationBar()
        setupGradient()
        setupScrollView()
        setupStack()
        setupHeights()
        
        setupActions()
        setupStaticMenus()
        
        // 1. Load data
        loadTaskLists()
        fetchChildrenAndAssignments()
        
        // 2. Populate UI
        if let task = taskToEdit {
            populate(task)
        } else {
            // Fallback if no task passed (shouldn't happen)
            print("Error: No task to edit provided")
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    // MARK: - Population Logic
    private func populate(_ task: ScheduleTaskModel) {
        titleNotesView.titleText = task.title
        titleNotesView.notesText = task.description ?? ""
        pointsRow.countValue = task.points
        priorityRow.setDetail(task.priority ?? "Medium")
        approvalRow.setOn(task.approval_required ?? false)
        listRow.setDetail(task.list_name ?? "General")

        // 1. Due Date
        if let dateString = task.due_date {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            if let date = df.date(from: dateString) {
                self.selectedDate = date
                self.dueDatePicker.date = date
                let displayDF = DateFormatter()
                displayDF.dateFormat = "MMM d, h:mm a"
                self.dateRow.setDetail(displayDF.string(from: date))
            }
        }
        
        // 2. Repeat Logic
        self.selectedFrequency = task.frequency ?? "Once"
        
        self.repeatInterval = task.repeat_interval ?? 1
        self.intervalRow.setDetail("Every \(self.repeatInterval)")
        
        if let endStr = task.repeat_end_date {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            if let date = df.date(from: endStr) {
                self.repeatEndDate = date
                self.endRepeatPicker.date = date
                let disp = DateFormatter()
                disp.dateFormat = "MMM d, yyyy"
                self.endRepeatRow.setDetail(disp.string(from: date))
            }
        } else {
            self.endRepeatRow.setDetail("Never")
        }
        
        if let days = task.repeat_on_days {
            self.repeatDays = Set(days)
            updateDaysLabel()
        }
        
        // Update UI State & Smart Label
        updateRepeatVisibility()
        updateDynamicFrequencyLabel()
    }

    // MARK: - Data Loading
    private func loadTaskLists() {
        guard let familyId else { return }
        Task {
            do {
                let lists = try await TaskService.shared.fetchTaskLists(familyId: familyId)
                await MainActor.run {
                    self.taskLists = lists
                    self.refreshListMenu()
                    
                    // Preselect list if matching name found
                    if let task = self.taskToEdit {
                        if let match = lists.first(where: { $0.name == task.list_name }) {
                            self.selectedListId = match.id
                        } else if let general = lists.first(where: { $0.name == "General" }) {
                            self.selectedListId = general.id
                            self.listRow.setDetail(general.name)
                        }
                    }
                }
            } catch { print(error) }
        }
    }

    private func fetchChildrenAndAssignments() {
        Task {
            do {
                let dashboard = try await FamilyService.shared.fetchDashboard()
                
                var preselected: [UUID] = []
                // Load existing assignments from DB
                if let taskId = taskToEdit?.id {
                    preselected = try await TaskService.shared.fetchAssignments(for: taskId)
                }

                await MainActor.run {
                    self.childrenList = dashboard.children
                    self.familyId = dashboard.family_id
                    
                    if preselected.isEmpty {
                        self.assignedSelections = []
                    } else {
                        self.assignedSelections = Set(preselected)
                    }
                    
                    self.handleAssignedVisibility()
                    if self.taskLists.isEmpty { self.loadTaskLists() }
                }
            } catch { print(error) }
        }
    }

    private func handleAssignedVisibility() {
        let count = childrenList.count
        if count <= 1 {
            if count == 1 && assignedSelections.isEmpty {
                assignedSelections = [childrenList.first!.id]
            }
            assignedRow.isHidden = true
        } else {
            assignedRow.isHidden = false
            updateAssignedMenu()
            updateAssignedLabel()
        }
    }

    // MARK: - UI Setup
    private func setupStack() {
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])

        [
            titleNotesView,
            pointsRow,
            assignedRow,
            priorityRow,
            dateRow,
            dateSectionStack,
            frequencyRow,
            intervalRow,
            daysRow,
            endRepeatRow,
            endRepeatSectionStack,
            listRow,
            approvalRow,
            deleteButton
        ].forEach { stack.addArrangedSubview($0) }
    }
    
    private func setupHeights() {
        [priorityRow, pointsRow, dateRow, frequencyRow, intervalRow, daysRow, endRepeatRow, listRow, approvalRow, assignedRow].forEach {
            $0.heightAnchor.constraint(equalToConstant: 52).isActive = true
        }
    }

    // MARK: - Helper: Date Pickers
    private func makeDatePickerStack(action: Selector, mode: UIDatePicker.Mode = .dateAndTime) -> UIStackView {
        let picker = UIDatePicker()
        picker.datePickerMode = mode
        picker.preferredDatePickerStyle = .inline
        picker.tintColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1)
        picker.overrideUserInterfaceStyle = .dark
        picker.backgroundColor = UIColor(white: 1, alpha: 0.1)
        picker.layer.cornerRadius = 12
        picker.layer.masksToBounds = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: action, for: .valueChanged)
        
        var config = UIButton.Configuration.filled()
        config.title = "Done"
        config.baseBackgroundColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1)
        config.cornerStyle = .capsule
        
        let btn = UIButton(configuration: config)
        btn.addAction(UIAction(handler: { [weak self] _ in self?.closeAllDatePickers() }), for: .touchUpInside)
        
        let wrapper = UIStackView(arrangedSubviews: [UIView(), btn])
        wrapper.axis = .horizontal
        
        let s = UIStackView(arrangedSubviews: [picker, wrapper])
        s.axis = .vertical
        s.spacing = 12
        s.isHidden = true
        s.alpha = 0
        return s
    }
    
    private func extractDatePicker(from stack: UIStackView) -> UIDatePicker {
        return stack.arrangedSubviews.first as! UIDatePicker
    }

    // MARK: - Menus & Actions
    private func setupStaticMenus() {
        priorityRow.setMenu(UIMenu(children: ["Low", "Medium", "High"].map { value in
            UIAction(title: value) { [weak self] _ in self?.priorityRow.setDetail(value) }
        }))

        // Frequency Menu
        frequencyRow.setMenu(UIMenu(children: [
            UIAction(title: "Once") { [weak self] _ in self?.updateFrequency(value: "Once") },
            UIAction(title: "Daily") { [weak self] _ in self?.updateFrequency(value: "Daily") },
            UIAction(title: "Weekly") { [weak self] _ in self?.updateFrequency(value: "Weekly") },
            UIAction(title: "Monthly") { [weak self] _ in self?.updateFrequency(value: "Monthly") },
            UIAction(title: "Yearly") { [weak self] _ in self?.updateFrequency(value: "Yearly") },
            UIMenu(options: .displayInline, children: [
                UIAction(title: "Custom...", image: UIImage(systemName: "repeat")) { [weak self] _ in
                    self?.openCustomRepeat()
                }
            ])
        ]))
        
        // Interval Menu
        let intervalActions = (1...30).map { i in
            UIAction(title: "\(i)") { [weak self] _ in
                self?.repeatInterval = i
                self?.intervalRow.setDetail("Every \(i)")
                self?.updateDynamicFrequencyLabel()
            }
        }
        intervalRow.setMenu(UIMenu(children: intervalActions))
    }
    
    // Updates state and triggers Smart Label
    private func updateFrequency(value: String) {
        self.selectedFrequency = value
        
        if value != "Custom" {
            self.repeatInterval = 1
            self.repeatEndDate = nil
            self.repeatDays = []
        }
        
        updateRepeatVisibility()
        updateDynamicFrequencyLabel()
    }
    
    // Generates "Every 2 Weeks on Mon, Fri"
    private func updateDynamicFrequencyLabel() {
        if selectedFrequency == "Once" {
            frequencyRow.setDetail("Once")
            return
        }
        
        var summary = ""
        
        // 1. Interval
        if repeatInterval == 1 {
            summary = selectedFrequency
        } else {
            var unit = selectedFrequency
            if unit.hasSuffix("ly") { unit = String(unit.dropLast(2)) + "s" }
            if unit == "Dais" { unit = "Days" }
            summary = "Every \(repeatInterval) \(unit)"
        }
        
        // 2. Days (Weekly only)
        if selectedFrequency == "Weekly" && !repeatDays.isEmpty {
            let daysMap = [1:"Mon", 2:"Tue", 3:"Wed", 4:"Thu", 5:"Fri", 6:"Sat", 7:"Sun"]
            let sortedDays = repeatDays.sorted().compactMap { daysMap[$0] }
            summary += " on " + sortedDays.joined(separator: ", ")
        }
        
        frequencyRow.setDetail(summary)
    }
    
    private func openCustomRepeat() {
        let vc = CustomRepeatViewController()
        
        vc.onSave = { [weak self] (freqValue, interval, days, endDate, _) in
            self?.selectedFrequency = freqValue
            self?.repeatInterval = interval
            self?.repeatDays = Set(days)
            self?.repeatEndDate = endDate
            
            // Updates rows and label
            self?.updateRepeatVisibility()
            self?.updateDaysLabel()
            self?.updateDynamicFrequencyLabel()
        }
        
        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        present(nav, animated: true)
    }
    
    private func openDaysMenu() {
        let alert = UIAlertController(title: "Repeat on Days", message: nil, preferredStyle: .actionSheet)
        let days = [(1, "Monday"), (2, "Tuesday"), (3, "Wednesday"), (4, "Thursday"), (5, "Friday"), (6, "Saturday"), (7, "Sunday")]
        
        for (id, name) in days {
            let isSelected = repeatDays.contains(id)
            let title = isSelected ? "✓ \(name)" : name
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { [weak self] _ in
                if isSelected { self?.repeatDays.remove(id) }
                else { self?.repeatDays.insert(id) }
                self?.updateDaysLabel()
                self?.updateDynamicFrequencyLabel()
                self?.openDaysMenu()
            }))
        }
        alert.addAction(UIAlertAction(title: "Done", style: .cancel))
        present(alert, animated: true)
    }
    
    private func updateDaysLabel() {
        if repeatDays.isEmpty { daysRow.setDetail("Select Days"); return }
        let daysMap = [1:"Mon", 2:"Tue", 3:"Wed", 4:"Thu", 5:"Fri", 6:"Sat", 7:"Sun"]
        let sorted = repeatDays.sorted().compactMap { daysMap[$0] }
        daysRow.setDetail(sorted.joined(separator: ", "))
    }
    
    private func updateRepeatVisibility() {
        UIView.animate(withDuration: 0.3) {
            let isRepeating = self.selectedFrequency != "Once"
            let isWeekly = self.selectedFrequency == "Weekly"
            self.intervalRow.isHidden = !isRepeating
            self.intervalRow.alpha = isRepeating ? 1 : 0
            self.endRepeatRow.isHidden = !isRepeating
            self.endRepeatRow.alpha = isRepeating ? 1 : 0
            self.daysRow.isHidden = !isWeekly
            self.daysRow.alpha = isWeekly ? 1 : 0
            self.stack.layoutIfNeeded()
        }
    }
    
    private func setupActions() {
        dateRow.onTap = { [weak self] in self?.toggleDateSection(isStart: true) }
        endRepeatRow.onTap = { [weak self] in self?.toggleDateSection(isStart: false) }
        daysRow.onTap = { [weak self] in self?.openDaysMenu() }
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }

    private func toggleDateSection(isStart: Bool) {
        let stackToToggle = isStart ? dateSectionStack : endRepeatSectionStack
        let otherStack = isStart ? endRepeatSectionStack : dateSectionStack
        otherStack.isHidden = true
        otherStack.alpha = 0
        
        let shouldShow = stackToToggle.isHidden
        if shouldShow && isStart && selectedDate == nil {
            dueDatePicker.date = Date()
            dueDatePickerChanged()
        }
        
        UIView.animate(withDuration: 0.3) {
            stackToToggle.isHidden = !shouldShow
            stackToToggle.alpha = shouldShow ? 1 : 0
            self.stack.layoutIfNeeded()
        }
    }
    
    private func closeAllDatePickers() {
        UIView.animate(withDuration: 0.3) {
            self.dateSectionStack.isHidden = true
            self.dateSectionStack.alpha = 0
            self.endRepeatSectionStack.isHidden = true
            self.endRepeatSectionStack.alpha = 0
            self.stack.layoutIfNeeded()
        }
    }

    @objc private func dueDatePickerChanged() {
        self.selectedDate = dueDatePicker.date
        let df = DateFormatter()
        df.dateFormat = "MMM d, h:mm a"
        self.dateRow.setDetail(df.string(from: dueDatePicker.date))
    }
    
    @objc private func endDatePickerChanged() {
        self.repeatEndDate = endRepeatPicker.date
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        self.endRepeatRow.setDetail(df.string(from: endRepeatPicker.date))
        updateDynamicFrequencyLabel()
    }

    // MARK: - Save Logic (Edit Only)
    @objc private func doneTapped() {
        // ✅ Ensure we have a task to edit
        guard let task = taskToEdit else {
            showAlert("No task to edit")
            return
        }
        
        let title = titleNotesView.titleText.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { showAlert("Enter a title"); return }
        guard let listId = selectedListId else { showAlert("Select a list"); return }

        var targetChildren: [UUID] = []
        if childrenList.count == 1 { targetChildren = [childrenList[0].id] }
        else { targetChildren = Array(assignedSelections) }
        guard !targetChildren.isEmpty else { showAlert("Assign a child"); return }

        // Logic
        let daysArray = repeatDays.isEmpty ? nil : Array(repeatDays).sorted()
        let interval = (selectedFrequency == "Once") ? 1 : repeatInterval

        Task {
            do {
                // ✅ Strictly calls updateTask
                try await TaskService.shared.updateTask(
                    taskId: task.id,
                    title: title,
                    description: titleNotesView.notesText,
                    points: pointsRow.countValue,
                    priority: priorityRow.detailText ?? "Medium",
                    frequency_input: selectedFrequency,
                    
                    repeatInterval: interval,
                    repeatEndDate: repeatEndDate,
                    repeatDays: (selectedFrequency == "Weekly") ? daysArray : nil,
                    
                    listId: listId,
                    childIds: targetChildren,
                    date: selectedDate ?? Date(),
                    approvalRequired: approvalRow.isOn
                )
                
                await MainActor.run { self.dismiss(animated: true) }
            } catch {
                await MainActor.run { self.showAlert(error.localizedDescription) }
            }
        }
    }
    
    // MARK: - Standard Methods
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        let a = UINavigationBarAppearance()
        a.configureWithTransparentBackground()
        a.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = a
        navigationController?.navigationBar.scrollEdgeAppearance = a
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
    }

    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    @objc private func deleteTapped() {
        // ✅ Delete always available since we are always editing
        guard let task = taskToEdit else { return }
        
        let alert = UIAlertController(title: "Delete Task?", message: "Cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            Task {
                try? await TaskService.shared.deleteTask(taskId: task.id)
                await MainActor.run { self.dismiss(animated: true) }
            }
        })
        present(alert, animated: true)
    }
    
    private func refreshListMenu() {
        let actions = taskLists.map { list in
            UIAction(title: list.name) { [weak self] _ in
                self?.listRow.setDetail(list.name)
                self?.selectedListId = list.id
            }
        }
        let custom = UIAction(title: "Custom", image: UIImage(systemName: "plus")) { [weak self] _ in self?.openCustomList() }
        listRow.setMenu(UIMenu(children: actions + [custom]))
    }
    
    private func updateAssignedMenu() {
        if childrenList.isEmpty { return }
        let allSelected = assignedSelections.count == childrenList.count
        var actions: [UIAction] = [
            UIAction(title: allSelected ? "Deselect All" : "Select All", state: allSelected ? .on : .off) { [weak self] _ in
                guard let self = self else { return }
                if allSelected { self.assignedSelections.removeAll() }
                else { self.assignedSelections = Set(self.childrenList.map { $0.id }) }
                self.updateAssignedMenu(); self.updateAssignedLabel()
            }
        ]
        for child in childrenList {
            let selected = assignedSelections.contains(child.id)
            let action = UIAction(title: child.name, state: selected ? .on : .off) { [weak self] _ in
                guard let self = self else { return }
                if selected { self.assignedSelections.remove(child.id) }
                else { self.assignedSelections.insert(child.id) }
                self.updateAssignedMenu(); self.updateAssignedLabel()
            }
            actions.append(action)
        }
        assignedRow.setMenu(UIMenu(children: actions))
    }
    
    private func updateAssignedLabel() {
        let names = childrenList.filter { assignedSelections.contains($0.id) }.map { $0.name }
        assignedRow.setDetail(names.isEmpty ? "Select" : names.joined(separator: ", "))
    }
    
    private func openCustomList() {
        let vc = CustomListViewController()
        vc.familyId = self.familyId
        vc.onSelect = { [weak self] list in
            self?.selectedListId = list.id
            self?.listRow.setDetail(list.name)
        }
        vc.onListChange = { [weak self] in self?.loadTaskLists() }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func cancelTapped() { dismiss(animated: true) }
    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "Info", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
