import UIKit

class NewTaskViewController: UIViewController {

    // MARK: - Properties
    private var childrenList: [ChildModel] = []
    
    // Stores selected Child IDs (Supports Multi-Select)
    private var assignedSelections = Set<UUID>()
    
    private var selectedDate: Date?
    private var frequency: String = "Once"
    
    // ✅ Custom Repeat Variables
    private var repeatInterval: Int = 1
    private var repeatEndDate: Date? = nil
    private var repeatDays: [Int]? = nil
    
    private var familyId: UUID?

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()
    private let gradient = CAGradientLayer()
    
    // Data Source for Lists
    private var selectedListId: UUID?
    private var taskLists: [TaskListModel] = []
    
    // Form Rows
    private let titleNotesView = CombinedTitleNotesView(
        titlePlaceholder: "Title *",
        notesPlaceholder: "Description (Optional)"
    )

    private let priorityRow = SelectRow(title: "Priority")
    private let pointsRow = PointsRow(minPoints: 10)
    
    private let dateRow = SelectRow(title: "Date & Time")
    
    private lazy var dateSectionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.isHidden = true
        stack.alpha = 0
        return stack
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .inline
        picker.tintColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1)
        picker.overrideUserInterfaceStyle = .dark
        picker.backgroundColor = UIColor(white: 1, alpha: 0.1)
        picker.layer.cornerRadius = 12
        picker.layer.masksToBounds = true
        picker.layer.borderWidth = 1
        picker.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        picker.addAction(UIAction(handler: { [weak self] _ in
            self?.handleDateChanged()
        }), for: .valueChanged)
        
        return picker
    }()
    
    private lazy var dateDoneButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Done"
        config.baseBackgroundColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1)
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20)
        
        let btn = UIButton(configuration: config)
        btn.addAction(UIAction(handler: { [weak self] _ in
            self?.toggleDateSection(show: false)
        }), for: .touchUpInside)
        
        return btn
    }()
    
    // --- Other Rows ---
    private let frequencyRow = SelectRow(title: "Frequency")
    private let listRow = SelectRow(title: "List")
    private let approvalRow = ApprovalToggleRow(title: "Approval")
    private let assignedRow = SelectRow(title: "Assigned To")
    
    private func setupInitialListMenu() {
        listRow.setMenu(
            UIMenu(children: [
                UIAction(title: "Loading...", attributes: .disabled) { _ in }
            ])
        )
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Task"
        view.backgroundColor = .black

        setupNavigationBar()
        setupGradient()
        setupScrollView()
        setupStack()
        setupHeights()
        
        applyDefaultValues()
        setupActions()
        
        // Setup Static Menus (Priority & Frequency)
        setupStaticMenus()
        setupInitialListMenu()
        
        // FETCH DATA
        fetchChildren()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    // MARK: - Data Logic
    private func fetchChildren() {
        _Concurrency.Task {
            do {
                let data = try await FamilyService.shared.fetchDashboard()

                await MainActor.run {
                    self.childrenList = data.children
                    self.familyId = data.family_id
                    self.handleAssignedToVisibility()
                }

                await self.loadTaskLists()

            } catch {
                print("Error fetching children:", error)
            }
        }
    }

    // MARK: - UI Setup
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

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
    
    private func handleAssignedToVisibility() {
        let count = childrenList.count
        if count == 0 {
            assignedRow.isHidden = true
            return
        }
        if count == 1 {
            let onlyChild = childrenList.first!
            assignedSelections = [onlyChild.id]
            assignedRow.isHidden = true
            return
        }
        assignedRow.isHidden = false
        updateAssignedMenu()
        updateAssignedLabel()
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

    private func setupStack() {
            contentView.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis = .vertical
            stack.spacing = 16
            stack.alignment = .fill
            stack.distribution = .fill

            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
            ])
            
            // Date Picker Button Wrapper (Done Button)
            let buttonWrapper = UIStackView(arrangedSubviews: [UIView(), dateDoneButton])
            buttonWrapper.axis = .horizontal
            buttonWrapper.distribution = .fill
            
            dateSectionStack.addArrangedSubview(datePicker)
            dateSectionStack.addArrangedSubview(buttonWrapper)
            
            // ✅ CHANGED ORDER: Date/Time is now before Frequency
            let fields: [UIView] = [
                titleNotesView,
                pointsRow,
                assignedRow,
                
                // 1. Date Row & Picker moved UP
                dateRow,
                dateSectionStack,
                
                // 2. Frequency moved DOWN
                frequencyRow,
                
                priorityRow,
                listRow,
                approvalRow
            ]
            
            fields.forEach { stack.addArrangedSubview($0) }
        }

    private func setupHeights() {
        let rows = [
            priorityRow,
            pointsRow,
            dateRow,
            frequencyRow,
            listRow,
            approvalRow,
            assignedRow
        ]
        rows.forEach { $0.heightAnchor.constraint(equalToConstant: 52).isActive = true }
    }
    
    private func applyDefaultValues() {
        priorityRow.setDetail("Medium")
        frequencyRow.setDetail("Once")
    }

    // MARK: - List Data Management
    private func loadTaskLists() async {
        guard let familyId else { return }

        do {
            let lists = try await TaskService.shared.fetchTaskLists(familyId: familyId)

            await MainActor.run {
                self.taskLists = lists
                self.refreshListMenu()

                if self.selectedListId == nil {
                    if let routine = lists.first(where: { $0.name == "Routine" }) {
                        self.selectedListId = routine.id
                        self.listRow.setDetail("Routine")
                    } else if let general = lists.first(where: { $0.name == "General" }) {
                        self.selectedListId = general.id
                        self.listRow.setDetail("General")
                    }
                }
            }
        } catch {
            print("Failed to load task lists:", error)
        }
    }

    private func refreshListMenu() {
        let standardNames = ["Routine", "Learning", "Health"]
        
        let standardActions = standardNames.map { name in
            UIAction(title: name) { [weak self] _ in
                self?.handleStandardListSelection(name: name)
            }
        }

        let customAction = UIAction(
            title: "Custom...",
            image: UIImage(systemName: "list.bullet.rectangle"),
            handler: { [weak self] _ in
                self?.openCustomListManager()
            }
        )
        
        let menuItems: [UIMenuElement] = standardActions + [UIMenu(options: .displayInline, children: [customAction])]
        listRow.setMenu(UIMenu(children: menuItems))
    }
    
    private func handleStandardListSelection(name: String) {
        self.listRow.setDetail(name)
        
        if let existing = taskLists.first(where: { $0.name == name }) {
            self.selectedListId = existing.id
        } else {
            createListSilently(name: name)
        }
    }
    
    private func createListSilently(name: String) {
        guard let familyId else { return }
        Task {
            do {
                let list = try await TaskService.shared.createTaskList(name: name, familyId: familyId)
                await MainActor.run {
                    self.taskLists.append(list)
                    self.selectedListId = list.id
                }
            } catch {
                print("Error creating standard list:", error)
            }
        }
    }

    private func openCustomListManager() {
        let vc = CustomListViewController()
        vc.familyId = self.familyId
        
        vc.onSelect = { [weak self] list in
            self?.selectedListId = list.id
            self?.listRow.setDetail(list.name)
        }
        
        vc.onListChange = { [weak self] in
            Task { await self?.loadTaskLists() }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Frequency & Smart Label Logic
    private func setupStaticMenus() {
        priorityRow.setMenu(
            UIMenu(children: ["None", "Low", "Medium", "High"].map { value in
                UIAction(title: value) { [weak self] _ in
                    self?.priorityRow.setDetail(value)
                }
            })
        )
        
        frequencyRow.setMenu(
            UIMenu(children: [
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
            ])
        )
    }
    
    // Updates frequency and resets custom fields if a standard option is picked
    private func updateFrequency(value: String) {
        self.frequency = value
        
        // Reset custom values when user picks standard "Daily" or "Weekly"
        if value != "Custom" {
            self.repeatInterval = 1
            self.repeatEndDate = nil
            self.repeatDays = nil
        }
        
        updateDynamicFrequencyLabel()
    }
    
    // ✅ Generates the "Smart Label" (e.g. "Every 2 Weeks on Mon, Fri")
    private func updateDynamicFrequencyLabel() {
        if frequency == "Once" {
            frequencyRow.setDetail("Once")
            return
        }
        
        var summary = ""
        
        // 1. Handle Interval
        if repeatInterval == 1 {
            summary = frequency // "Daily", "Weekly"
        } else {
            var unit = frequency
            if unit.hasSuffix("ly") { unit = String(unit.dropLast(2)) + "s" } // Weekly -> Weeks
            if unit == "Dais" { unit = "Days" }
            summary = "Every \(repeatInterval) \(unit)"
        }
        
        // 2. Handle Days (Only if Weekly)
        if frequency == "Weekly", let days = repeatDays, !days.isEmpty {
            let daysMap = [1:"Mon", 2:"Tue", 3:"Wed", 4:"Thu", 5:"Fri", 6:"Sat", 7:"Sun"]
            let sortedDays = days.sorted().compactMap { daysMap[$0] }
            summary += " on " + sortedDays.joined(separator: ", ")
        }
        
        // 3. Set the text
        frequencyRow.setDetail(summary)
    }

    private func openCustomRepeat() {
        let vc = CustomRepeatViewController()
        
        // ✅ Capture data from Custom Screen
        vc.onSave = { [weak self] (freqValue, interval, days, endDate, _) in
            self?.frequency = freqValue
            self?.repeatInterval = interval
            self?.repeatDays = days
            self?.repeatEndDate = endDate
            
            // Generate the smart label
            self?.updateDynamicFrequencyLabel()
        }
        
        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        present(nav, animated: true)
    }
    
    // MARK: - Actions
    private func setupActions() {
        dateRow.onTap = { [weak self] in
            guard let self = self else { return }
            let shouldShow = self.dateSectionStack.isHidden
            self.toggleDateSection(show: shouldShow)
        }
    }
    
    private func toggleDateSection(show: Bool) {
        if show && self.selectedDate == nil {
            self.datePicker.date = Date()
            self.handleDateChanged()
        }
        UIView.animate(withDuration: 0.3) {
            self.dateSectionStack.isHidden = !show
            self.dateSectionStack.alpha = show ? 1 : 0
            self.stack.layoutIfNeeded()
        }
    }
    
    private func handleDateChanged() {
        self.selectedDate = datePicker.date
        let df = DateFormatter()
        df.dateFormat = "MMM d, h:mm a"
        self.dateRow.setDetail(df.string(from: datePicker.date))
    }
    
    // MARK: - Multi-Select Assignment Logic
    private func updateAssignedMenu() {
        if childrenList.isEmpty { return }

        var items: [UIMenuElement] = []
        let allSelected = assignedSelections.count == childrenList.count

        let allAction = UIAction(
            title: allSelected ? "Deselect" : "All",
            state: allSelected ? .on : .off
        ) { [weak self] _ in
            guard let self = self else { return }
            if allSelected {
                self.assignedSelections.removeAll()
            } else {
                self.assignedSelections = Set(self.childrenList.map { $0.id })
            }
            self.updateAssignedLabel()
            self.updateAssignedMenu()
        }
        items.append(allAction)

        for child in childrenList {
            let selected = assignedSelections.contains(child.id)
            let action = UIAction(
                title: child.name,
                state: selected ? .on : .off
            ) { [weak self] _ in
                guard let self = self else { return }
                if selected {
                    self.assignedSelections.remove(child.id)
                } else {
                    self.assignedSelections.insert(child.id)
                }
                self.updateAssignedLabel()
                self.updateAssignedMenu()
            }
            items.append(action)
        }
        assignedRow.setMenu(UIMenu(title: "Select Children", options: .displayInline, children: items))
    }

    private func updateAssignedLabel() {
        if childrenList.count == 1 {
            assignedRow.setDetail("")
            return
        }
        if assignedSelections.isEmpty {
            assignedRow.setDetail("Select")
            return
        }
        let names = childrenList.filter { assignedSelections.contains($0.id) }.map { $0.name }
        assignedRow.setDetail(names.joined(separator: ", "))
    }

    // MARK: - Final Submit
    @objc private func doneTapped() {
        let title = titleNotesView.titleText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            showAlert("Please enter a title")
            return
        }
        
        if selectedListId == nil {
            if let routine = taskLists.first(where: { $0.name == "Routine" }) {
                selectedListId = routine.id
            } else {
                selectedListId = taskLists.first?.id
            }
        }

        guard let listId = selectedListId else {
            showAlert("No Task List available")
            return
        }
        
        if assignedSelections.isEmpty, let firstChild = childrenList.first {
            assignedSelections = [firstChild.id]
        }
        
        if assignedSelections.isEmpty {
            showAlert("Please assign to at least one child")
            return
        }
        
        // ✅ CRITICAL FIX: Ensure valid start date for Charts/Overview
        // -----------------------------------------------------------
        var finalDueDate = selectedDate
        
        if finalDueDate == nil {
            if frequency.lowercased() == "once" {
                // For "Once", user MUST pick a date manually.
                self.showAlert("Please select a date")
                return
            } else {
                // ✅ For Recurring (Daily/Weekly/Custom), default to TODAY
                // This prevents 'NULL' in the database and ensures 0/0 chart math works.
                finalDueDate = Date()
            }
        }
        // -----------------------------------------------------------

        print("Creating task...")
        
        _Concurrency.Task {
            do {
                let taskId = try await TaskService.shared.createTask(
                    title: title,
                    description: titleNotesView.notesText,
                    points: pointsRow.countValue,
                    priority: priorityRow.detailText ?? "Medium",
                    frequency: self.frequency,
                    
                    // New Custom Fields
                    repeatInterval: self.repeatInterval,
                    repeatEndDate: self.repeatEndDate,
                    repeatDays: self.repeatDays,
                    
                    listId: listId,
                    assignTo: Array(assignedSelections),
                    dueDate: finalDueDate, // ✅ Using the corrected date variable
                    approvalRequired: approvalRow.isOn
                )

                print("Created task:", taskId)
                await MainActor.run {
                    self.dismiss(animated: true)
                }

            } catch {
                print("Create task failed:", error)
                await MainActor.run {
                    self.showAlert("Failed to create task")
                }
            }
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    private func showAlert(_ msg: String) {
        let a = UIAlertController(title: "Info", message: msg, preferredStyle: .alert)
        a.addAction(.init(title: "OK", style: .default))
        present(a, animated: true)
    }
}
