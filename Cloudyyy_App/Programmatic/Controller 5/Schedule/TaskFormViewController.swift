import UIKit

// MARK: - Mode
enum TaskFormMode {
    case create
    case edit(ScheduleTaskModel)
}

final class TaskFormViewController: UIViewController {

    // MARK: - Properties
    var mode: TaskFormMode = .create

    private var childrenList: [ChildModel] = []
    private var assignedSelections = Set<UUID>()
    private var selectedDate: Date?
    private var repeatRule: RepeatRule?
    
    private func repeatRuleDisplayString(from value: Any?) -> String {
        // Accepts either String or RepeatRule and returns a string for UI
        if let s = value as? String { return s }
        // Fallback: try common enum names
        if let r = value { return String(describing: r) }
        return "Once"
    }

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()
    private var taskLists: [TaskListModel] = []
    
    private var familyId: UUID?

    private let gradient = CAGradientLayer()

    private let titleNotesView =
        CombinedTitleNotesView(
            titlePlaceholder: "Title *",
            notesPlaceholder: "Description (Optional)"
        )

    private let priorityRow = SelectRow(title: "Priority")
    private let pointsRow = PointsRow()
    private let dateRow = SelectRow(title: "Date & Time")
    private let frequencyRow = SelectRow(title: "Frequency")
    private let listRow = SelectRow(title: "List")
    private let approvalRow = ApprovalToggleRow(title: "Approval Required")
    private let assignedRow = SelectRow(title: "Assigned To")
    private var selectedListId: UUID?


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

        setupNavigationBar()
        setupGradient()
        setupScrollView()
        setupStack()
        setupHeights()
        setupActions()
        setupStaticMenus()
        loadTaskLists()

        fetchChildrenAndAssignments()
        configureForMode()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    // MARK: - Mode
    private func configureForMode() {
        switch mode {
        case .create:
            title = "New Task"
            deleteButton.isHidden = true
            applyDefaults()

        case .edit(let task):
            title = "Edit Task"
            deleteButton.isHidden = false
            populate(task)
        }
    }
 
    private func applyDefaults() {
        priorityRow.setDetail("Medium")
        frequencyRow.setDetail("Once")
        listRow.setDetail("General")
        assignedRow.setDetail("Select Child")
    }
    
    private func populate(_ task: ScheduleTaskModel) {
        titleNotesView.titleText = task.title
        titleNotesView.notesText = task.description ?? ""

        pointsRow.countValue = task.points
        priorityRow.setDetail(task.priority ?? "Medium")
        
        let uiRule = RepeatRule.fromPayload(task.repeat_rule)
        repeatRule = uiRule
        frequencyRow.setDetail(uiRule.displayText)


        listRow.setDetail(task.list_name)
        approvalRow.setOn(task.approval_required ?? false)
        selectedListId = task.list_id
    }
    private func loadTaskLists() {
        guard let familyId else { return }

        _Concurrency.Task {
            do {
                let lists = try await TaskService.shared.fetchTaskLists(familyId: familyId)

                await MainActor.run {
                    self.taskLists = lists
                    self.refreshListMenu()
                }
            } catch {
                print(error)
            }
        }
    }




    // MARK: - Data
    private func fetchChildrenAndAssignments() {
        _Concurrency.Task {
            do {
                let dashboard = try await FamilyService.shared.fetchDashboard()
                var preselected: [UUID] = []

                if case .edit(let task) = mode {
                    preselected = try await TaskService.shared.fetchAssignments(for: task.id)
                }

                await MainActor.run {
                    self.childrenList = dashboard.children
                    self.assignedSelections = Set(preselected)
                    self.handleAssignedVisibility()
                }
            } catch {
                print(error)
            }
        }
    }

    private func handleAssignedVisibility() {
        let count = childrenList.count

        if count == 0 {
            assignedRow.isHidden = true
            return
        }

        if count == 1 {
            assignedSelections = [childrenList[0].id]
            assignedRow.isHidden = true
            return
        }

        assignedRow.isHidden = false
        updateAssignedMenu()
        updateAssignedLabel()
    }

    // MARK: - UI Setup
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        let a = UINavigationBarAppearance()
        a.configureWithTransparentBackground()
        a.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = a
        navigationController?.navigationBar.scrollEdgeAppearance = a

        navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
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
            frequencyRow,
            priorityRow,
            dateRow,
            listRow,
            approvalRow,
            deleteButton
        ].forEach { stack.addArrangedSubview($0) }
    }

    private func setupHeights() {
        [
            priorityRow, pointsRow, dateRow,
            frequencyRow, listRow, approvalRow, assignedRow
        ].forEach {
            $0.heightAnchor.constraint(equalToConstant: 52).isActive = true
        }
    }

    // MARK: - Menus
    private func setupStaticMenus() {

        priorityRow.setMenu(
            UIMenu(children: ["Low", "Medium", "High"].map { value in
                UIAction(title: value) { [weak self] _ in
                    self?.priorityRow.setDetail(value)
                }
            })
        )

        frequencyRow.setMenu(
            UIMenu(children:
                ["Once", "Daily", "Weekly", "Monthly", "Yearly"].map { value in
                    UIAction(title: value) { [weak self] _ in
                        self?.frequencyRow.setDetail(value)
                    }
                }
                + [
                    UIAction(title: "Custom", image: UIImage(systemName: "plus")) { [weak self] _ in
                        self?.openCustomFrequency()
                    }
                ]
            )
        )

        refreshListMenu()
    }

    private func refreshListMenu() {
        let actions = taskLists.map { list in
            UIAction(title: list.name) { [weak self] _ in
                self?.listRow.setDetail(list.name)
                self?.selectedListId = list.id   // ✅ REAL ID
            }
        }

        let custom = UIAction(title: "Custom", image: UIImage(systemName: "plus")) {
            [weak self] _ in self?.openCustomList()
        }

        listRow.setMenu(UIMenu(children: actions + [custom]))
    }


    // MARK: - Assignment
    private func updateAssignedMenu() {
        let allSelected = assignedSelections.count == childrenList.count

        var actions: [UIAction] = [
            UIAction(
                title: allSelected ? "Deselect All" : "Select All",
                state: allSelected ? .on : .off
            ) { [weak self] _ in
                guard let self = self else { return }
                if allSelected {
                    self.assignedSelections.removeAll()
                } else {
                    self.assignedSelections = Set(self.childrenList.map { $0.id })
                }
                self.updateAssignedMenu()
                self.updateAssignedLabel()
            }
        ]

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

                self.updateAssignedMenu()
                self.updateAssignedLabel()
            }

            actions.append(action)
        }

        assignedRow.setMenu(UIMenu(children: actions))
    }

    private func updateAssignedLabel() {
        let names = childrenList
            .filter { assignedSelections.contains($0.id) }
            .map { $0.name }

        assignedRow.setDetail(names.isEmpty ? "Select" : names.joined(separator: ", "))
    }

    // MARK: - Actions
    private func setupActions() {
        dateRow.onTap = { [weak self] in self?.openDatePicker() }
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }

    @objc private func deleteTapped() {
        guard case .edit(let task) = mode else { return }

        let alert = UIAlertController(
            title: "Delete Task?",
            message: "This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            _Concurrency.Task {
                try? await TaskService.shared.deleteTask(taskId: task.id)
                await MainActor.run { self.dismiss(animated: true) }
            }
        })

        present(alert, animated: true)
    }
    @objc private func doneTapped() {
        let title = titleNotesView.titleText.trimmingCharacters(in: .whitespaces)

        guard !title.isEmpty else {
            showAlert("Please enter a title")
            return
        }

        guard let listId = selectedListId else {
            showAlert("Please select a list")
            return
        }

        guard !assignedSelections.isEmpty else {
            showAlert("Assign at least one child")
            return
        }

        let approval = approvalRow.isOn

        _Concurrency.Task {
            do {
                switch mode {
                case .create:
                    _ = try await TaskService.shared.createTask(
                        title: title,
                        description: titleNotesView.notesText,
                        points: pointsRow.countValue,
                        priority: priorityRow.detailText ?? "Medium",
                        repeatRule: repeatRule,          // ✅ RepeatRule?
                        listId: listId,
                        assignTo: Array(assignedSelections),
                        dueDate: selectedDate,
                        approvalRequired: approval
                    )

                case .edit(let task):
                    try await TaskService.shared.updateTask(
                        taskId: task.id,
                        title: title,
                        description: titleNotesView.notesText,
                        points: pointsRow.countValue,
                        priority: priorityRow.detailText ?? "Medium",
                        repeatRule: repeatRule,          // ✅ RepeatRule?
                        listId: listId,
                        childIds: Array(assignedSelections),
                        date: selectedDate ?? Date(),
                        approvalRequired: approval
                    )
                }

                await MainActor.run {
                    self.dismiss(animated: true)
                }

            } catch {
                await MainActor.run {
                    self.showAlert(error.localizedDescription)
                }
            }
        }
    }


    private func openDatePicker() {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.sheetPresentationController?.detents = [.medium()]

        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = false

        vc.view.addSubview(picker)

        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            picker.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        picker.addAction(UIAction { [weak self] _ in
            self?.selectedDate = picker.date
            let f = DateFormatter()
            f.dateFormat = "MMM d, h:mm a"
            self?.dateRow.setDetail(f.string(from: picker.date))
        }, for: .valueChanged)

        present(vc, animated: true)
    }
    private func openCustomFrequency() {
        let vc = CustomClaimLimitViewController()
        vc.onSave = { [weak self] rule, label in
            self?.repeatRule = rule
            self?.frequencyRow.setDetail(label)
        }
        navigationController?.pushViewController(vc, animated: true)
    }


    private func openCustomList() {
        let vc = CustomListViewController()

        vc.onSave = { [weak self] name in
            guard let self = self else { return }
            guard let familyId = self.familyId else {
                self.showAlert("Family not found")
                return
            }

            _Concurrency.Task {
                do {
                    let list = try await TaskService.shared.createTaskList(
                        name: name,
                        familyId: familyId   // ✅ now UUID
                    )

                    await MainActor.run {
                        self.taskLists.append(list)
                        self.selectedListId = list.id
                        self.listRow.setDetail(list.name)
                        self.refreshListMenu()
                    }
                } catch {
                    await MainActor.run {
                        self.showAlert("Failed to create list")
                    }
                }
            }
        }

        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "Info", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

