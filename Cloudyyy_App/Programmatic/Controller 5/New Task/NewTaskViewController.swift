import UIKit

class NewTaskViewController: UIViewController {

    // MARK: - Properties
    private var childrenList: [ChildModel] = []
    
    // Stores selected Child IDs (Supports Multi-Select)
    private var assignedSelections = Set<UUID>()
    
    private var selectedDate: Date?
    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()
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
        
        // Setup Static Menus (Priority, Frequency, List)
        setupStaticMenus()
        
        // FETCH DATA: Get real children from DB for Dynamic Menu
        fetchChildren()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    // MARK: - Data Logic
    private func fetchChildren() {
        // Use _Concurrency.Task to avoid Main Actor errors
        _Concurrency.Task {
            do {
                let data = try await FamilyService.shared.fetchDashboard()
                
                await MainActor.run {
                    self.childrenList = data.children
                    self.handleAssignedToVisibility()
                }
            } catch {
                print("Error fetching children: \(error)")
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

        // 1️⃣ No children → hide
        if count == 0 {
            assignedRow.isHidden = true
            return
        }

        // 2️⃣ Only one child → auto-select & hide
        if count == 1 {
            let onlyChild = childrenList.first!
            assignedSelections = [onlyChild.id]
            assignedRow.isHidden = true
            return
        }

        // 3️⃣ Multiple children → show selector
        assignedRow.isHidden = false
        updateAssignedMenu()
        updateAssignedLabel()
    }


    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        // ✅ IMPORTANT
        scrollView.backgroundColor = .clear

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // ✅ IMPORTANT
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
        
        let fields: [UIView] = [
            titleNotesView,
            pointsRow,
            assignedRow,
            frequencyRow,   // ✅ Frequency instead of Claim Limit
            priorityRow,
            dateRow,
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

        rows.forEach {
            $0.heightAnchor.constraint(equalToConstant: 52).isActive = true
        }
    }

    
    private func applyDefaultValues() {
        priorityRow.setDetail("Medium")
        frequencyRow.setDetail("Once")
        assignedRow.setDetail("Select Child")
        listRow.setDetail("General")
    }

    // MARK: - Menus
    private func setupStaticMenus() {

        // Priority
        priorityRow.setMenu(
            UIMenu(children: ["None", "Low", "Medium", "High"].map { level in
                UIAction(title: level) { [weak self] _ in
                    self?.priorityRow.setDetail(level)
                }
            })
        )

        // Frequency (with Custom)
        frequencyRow.setMenu(
            UIMenu(children: [
                UIAction(title: "Once") { [weak self] _ in self?.frequencyRow.setDetail("Once") },
                UIAction(title: "Daily") { [weak self] _ in self?.frequencyRow.setDetail("Daily") },
                UIAction(title: "Weekly") { [weak self] _ in self?.frequencyRow.setDetail("Weekly") },
                UIAction(title: "Monthly") { [weak self] _ in self?.frequencyRow.setDetail("Monthly") },
                UIAction(title: "Every 3 Months") { [weak self] _ in self?.frequencyRow.setDetail("Yearly") },
                UIAction(title: "Yearly") { [weak self] _ in self?.frequencyRow.setDetail("Yearly") },

                UIAction(title: "Custom", image: UIImage(systemName: "plus")) { [weak self] _ in
                    self?.openCustomFrequency()
                }
            ])
        )

        // List (with Custom)
        let defaultLists = ["General", "Morning Routine", "Evening Routine", "School", "Chores"]
        let customLists = loadCustomLists()

        let listActions =
            defaultLists.map { name in
                UIAction(title: name) { [weak self] _ in
                    self?.listRow.setDetail(name)
                }
            }
            +
            customLists.map { name in
                UIAction(title: name) { [weak self] _ in
                    self?.listRow.setDetail(name)
                }
            }
            +
            [
                UIAction(title: "Custom", image: UIImage(systemName: "plus")) { [weak self] _ in
                    self?.openCustomList()
                }
            ]

        listRow.setMenu(UIMenu(children: listActions))
    }
    // MARK: - Custom Frequency
    private func openCustomFrequency() {
        let vc = CustomClaimLimitViewController()
        vc.onSave = { [weak self] value in
            self?.frequencyRow.setDetail(value)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    // MARK: - Custom List
    private func openCustomList() {
        let vc = CustomListViewController()
        vc.onSave = { [weak self] name in
            self?.saveListIfNeeded(name)
            self?.listRow.setDetail(name)
            self?.setupStaticMenus() // refresh menu
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func saveListIfNeeded(_ list: String) {
        let key = "custom_task_lists"
        var lists = UserDefaults.standard.stringArray(forKey: key) ?? []
        if !lists.contains(list) {
            lists.append(list)
            UserDefaults.standard.setValue(lists, forKey: key)
        }
    }

    private func loadCustomLists() -> [String] {
        UserDefaults.standard.stringArray(forKey: "custom_task_lists") ?? []
    }

    
    // MARK: - Multi-Select Assignment Logic
    private func updateAssignedMenu() {
        if childrenList.isEmpty { return }

        var items: [UIMenuElement] = []

        // 1️⃣ ALL / DESELECT option
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

        // 2️⃣ Individual children
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

        assignedRow.setMenu(
            UIMenu(title: "Select Children", options: .displayInline, children: items)
        )
    }

    private func updateAssignedLabel() {

        // Hidden when only one child
        if childrenList.count == 1 {
            assignedRow.setDetail("")
            return
        }

        if assignedSelections.isEmpty {
            assignedRow.setDetail("Select")
            return
        }

        let names = childrenList
            .filter { assignedSelections.contains($0.id) }
            .map { $0.name }

        assignedRow.setDetail(names.joined(separator: ", "))
    }


    // MARK: - Actions
    private func setupActions() {
        dateRow.onTap = { [weak self] in self?.openDatePicker() }
    }
    
    private func openDatePicker() {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        if let sheet = vc.sheetPresentationController { sheet.detents = [.medium()] }
        
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(picker)
        
        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            picker.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        picker.addAction(UIAction(handler: { [weak self] _ in
            self?.selectedDate = picker.date
            let df = DateFormatter(); df.dateFormat = "MMM d, h:mm a"
            self?.dateRow.setDetail(df.string(from: picker.date))
        }), for: .valueChanged)
        
        present(vc, animated: true)
    }

    @objc private func doneTapped() {
        view.endEditing(true)
        
        let title = titleNotesView.titleText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty else {
            showAlert("Please enter a title")
            return
        }

        if assignedSelections.isEmpty {
            showAlert("Please assign to at least one child")
            return
        }
        
        // 2. Prep Data
        let points = pointsRow.countValue // ✅ Using countValue from your PointsRow
        let priority = priorityRow.detailText ?? "Medium"
        let frequency = frequencyRow.detailText ?? "Once"
        
        // ✅ 3. Get Approval Status
        let approval = approvalRow.isOn
        
        // 4. UI Loading
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        // 5. API Call
        _Concurrency.Task {
            do {
                let taskId = try await TaskService.shared.createTask(
                    title: title,
                    description: titleNotesView.notesText,
                    points: points,
                    priority: priority,
                    frequency: frequency,
                    assignTo: Array(assignedSelections),
                    dueDate: selectedDate,
                    approvalRequired: approval // ✅ FIXED: Added this parameter
                )
                
                print("Task Created! ID: \(taskId)")
                
                await MainActor.run {
                    self.dismiss(animated: true)
                }
            } catch {
                print("Error: \(error)")
                await MainActor.run {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.showAlert("Failed: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
