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

    private let titleField = StyledTextField(placeholder: "Title *")
    private let descriptionView = StyledTextView(placeholder: "Description (Optional)")

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
                    self.updateAssignedMenu() // Rebuild menu with real names
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

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
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
            titleField, descriptionView, pointsRow, assignedRow,
            priorityRow, dateRow, frequencyRow, listRow, approvalRow
        ]

        fields.forEach { stack.addArrangedSubview($0) }
    }

    private func setupHeights() {
        let rows = [titleField, priorityRow, pointsRow, dateRow, frequencyRow, listRow, approvalRow, assignedRow]
        rows.forEach { $0.heightAnchor.constraint(equalToConstant: 52).isActive = true }
        descriptionView.heightAnchor.constraint(equalToConstant: 140).isActive = true
    }
    
    private func applyDefaultValues() {
        priorityRow.setDetail("Medium")
        frequencyRow.setDetail("Once")
        assignedRow.setDetail("Select Child")
        listRow.setDetail("General")
    }

    // MARK: - Menus
    private func setupStaticMenus() {
        // Priority Menu
        priorityRow.setMenu(UIMenu(children: ["Low", "Medium", "High", "Critical"].map { name in
            UIAction(title: name) { [weak self] _ in self?.priorityRow.setDetail(name) }
        }))

        // Frequency Menu
        frequencyRow.setMenu(UIMenu(children: ["Once", "Daily", "Weekly", "Monthly"].map { name in
            UIAction(title: name) { [weak self] _ in self?.frequencyRow.setDetail(name) }
        }))
        
        // List Menu (Static for now)
        listRow.setMenu(UIMenu(children: ["General", "Morning Routine", "Evening Routine", "School", "Chores"].map { name in
            UIAction(title: name) { [weak self] _ in self?.listRow.setDetail(name) }
        }))
    }
    
    // MARK: - Multi-Select Assignment Logic
    private func updateAssignedMenu() {
        // Create an action for each child
        let menuItems = childrenList.map { child in
            UIAction(
                title: child.name,
                // Show a checkmark if this child is already selected
                state: assignedSelections.contains(child.id) ? .on : .off
            ) { [weak self] _ in
                guard let self = self else { return }
                
                // Toggle Selection logic
                if self.assignedSelections.contains(child.id) {
                    self.assignedSelections.remove(child.id)
                } else {
                    self.assignedSelections.insert(child.id)
                }
                
                // Update the Display Text
                self.updateAssignedLabel()
                
                // Re-generate the menu so the checkmarks update
                self.updateAssignedMenu()
            }
        }
        
        assignedRow.setMenu(UIMenu(title: "Select Children", options: .displayInline, children: menuItems))
    }
    
    private func updateAssignedLabel() {
        if assignedSelections.isEmpty {
            assignedRow.setDetail("Select Child")
            return
        }
        
        // Map IDs back to Names for display
        let selectedNames = childrenList
            .filter { assignedSelections.contains($0.id) }
            .map { $0.name }
        
        assignedRow.setDetail(selectedNames.joined(separator: ", "))
    }

    // MARK: - Actions
    private func setupActions() {
        dateRow.onTap = { [weak self] in self?.openDatePicker() }
        // Note: List row is now handled by setupStaticMenus(), so we don't need onTap logic for it anymore.
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
        
        // 1. Validation
        guard let title = titleField.textValue.isEmpty ? nil : titleField.textValue else {
            showAlert("Please enter a title")
            return
        }
        
        if assignedSelections.isEmpty {
            showAlert("Please assign to at least one child")
            return
        }
        
        // 2. Prep Data
        let points = 10
        let priority = priorityRow.detailText ?? "Medium"
        let frequency = frequencyRow.detailText ?? "Once"
        
        // 3. UI Loading
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        // 4. API Call
        _Concurrency.Task {
            do {
                let taskId = try await TaskService.shared.createTask(
                    title: title,
                    description: descriptionView.textValue,
                    points: points,
                    priority: priority,
                    frequency: frequency,
                    // Send the Array of selected IDs
                    assignTo: Array(assignedSelections),
                    dueDate: selectedDate
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
