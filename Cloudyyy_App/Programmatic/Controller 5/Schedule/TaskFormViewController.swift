//
//  TaskFormViewController.swift
//  Cloudyyy_App
//
//  Created by user@5 on 07/12/25.
//

import UIKit

// Define Modes
enum TaskFormMode {
    case create
    case edit(ScheduleTaskModel)
}

class TaskFormViewController: UIViewController {

    // MARK: - Properties
    var mode: TaskFormMode = .create
    
    private var childrenList: [ChildModel] = []
    private var assignedSelections = Set<UUID>()
    private var selectedDate: Date?

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

    // Delete Button (Hidden by default)
    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Delete Task", for: .normal)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIBasedOnMode()
        
        setupNavigationBar()
        setupGradient()
        setupScrollView()
        setupStack()
        setupHeights()
        
        setupActions()
        setupStaticMenus()
        
        // Load Data
        fetchChildrenAndAssignments()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    // MARK: - Mode Setup
    private func setupUIBasedOnMode() {
        view.backgroundColor = .black
        
        switch mode {
        case .create:
            title = "New Task"
            deleteButton.isHidden = true
            applyDefaultValues()
            
        case .edit(let task):
            title = "Edit Task"
            deleteButton.isHidden = false
            populateExistingData(task)
        }
    }
    
    private func applyDefaultValues() {
        priorityRow.setDetail("Medium")
        frequencyRow.setDetail("Once")
        assignedRow.setDetail("Select Child")
        listRow.setDetail("General")
    }
    
    private func populateExistingData(_ task: ScheduleTaskModel) {
            // 1. Title & Description
            titleField.textValue = task.title
            descriptionView.textValue = task.description ?? ""
            
            // 2. Priority & Frequency
            priorityRow.setDetail(task.priority ?? "Medium")
            frequencyRow.setDetail(task.frequency)
            
            // 3. Points (✅ NEW)
            pointsRow.countValue = task.points
            
            // 4. Approval (✅ NEW)
            // Defaults to false if nil
            approvalRow.setOn(task.approval_required ?? false)
            
            // 5. List (✅ NEW)
            listRow.setDetail(task.list_name ?? "General")
            
            // 6. Date
            if let dateStr = task.due_date {
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                if let date = df.date(from: dateStr) {
                    self.selectedDate = date
                    let displayF = DateFormatter(); displayF.dateFormat = "MMM d, h:mm a"
                    dateRow.setDetail(displayF.string(from: date))
                }
            }
        }
    
    // MARK: - Data Logic
    private func fetchChildrenAndAssignments() {
        _Concurrency.Task {
            do {
                // 1. Fetch Children
                let dashboardData = try await FamilyService.shared.fetchDashboard()
                
                // 2. If Editing, Fetch Assignments to see who is assigned
                var existingAssignments: [UUID] = []
                if case .edit(let task) = mode {
                    existingAssignments = try await TaskService.shared.fetchAssignments(for: task.id)
                }
                
                await MainActor.run {
                    self.childrenList = dashboardData.children
                    
                    // Pre-select children in Edit Mode
                    if case .edit = mode {
                        self.assignedSelections = Set(existingAssignments)
                    }
                    
                    self.updateAssignedMenu()
                    self.updateAssignedLabel()
                }
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }

    // MARK: - Actions
    private func setupActions() {
        dateRow.onTap = { [weak self] in self?.openDatePicker() }
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    @objc private func deleteTapped() {
        guard case .edit(let task) = mode else { return }
        
        let alert = UIAlertController(title: "Delete Task?", message: "This will remove this task permanently.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.performDelete(taskId: task.id)
        }))
        present(alert, animated: true)
    }
    
    private func performDelete(taskId: UUID) {
        _Concurrency.Task {
            do {
                try await TaskService.shared.deleteTask(taskId: taskId)
                await MainActor.run { self.dismiss(animated: true) }
            } catch {
                await MainActor.run { self.showAlert("Delete failed: \(error.localizedDescription)") }
            }
        }
    }

    @objc private func doneTapped() {
            view.endEditing(true)
            
            guard let title = titleField.textValue.isEmpty ? nil : titleField.textValue else {
                showAlert("Please enter a title"); return
            }
            if assignedSelections.isEmpty {
                showAlert("Please assign to at least one child"); return
            }
            
            let points = pointsRow.countValue
            let priority = priorityRow.detailText ?? "Medium"
            let frequency = frequencyRow.detailText ?? "Once"
            let approval = approvalRow.isOn // ✅ Capture Toggle
            
            navigationItem.rightBarButtonItem?.isEnabled = false
            
            _Concurrency.Task {
                do {
                    switch mode {
                    case .create:
                        _ = try await TaskService.shared.createTask(
                            title: title, description: descriptionView.textValue, points: points, priority: priority, frequency: frequency,
                            assignTo: Array(assignedSelections), dueDate: selectedDate,
                            approvalRequired: approval // ✅ Send Toggle
                        )
                    case .edit(let task):
                        try await TaskService.shared.updateTask(
                            taskId: task.id, title: title, description: descriptionView.textValue, points: points, priority: priority, frequency: frequency,
                            childIds: Array(assignedSelections), date: selectedDate ?? Date(),
                            approvalRequired: approval // ✅ Send Toggle
                        )
                    }
                    await MainActor.run { self.dismiss(animated: true) }
                } catch {
                    await MainActor.run {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        self.showAlert("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    // MARK: - Setup Boilerplate
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
        gradient.startPoint = CGPoint(x: 0, y: 0); gradient.endPoint = CGPoint(x: 1, y: 1)
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
        stack.axis = .vertical; stack.spacing = 16; stack.alignment = .fill; stack.distribution = .fill

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])

        let fields: [UIView] = [
            titleField, descriptionView, pointsRow, assignedRow,
            priorityRow, dateRow, frequencyRow, listRow, approvalRow,
            deleteButton
        ]
        fields.forEach { stack.addArrangedSubview($0) }
    }

    private func setupHeights() {
        let rows = [titleField, priorityRow, pointsRow, dateRow, frequencyRow, listRow, approvalRow, assignedRow, deleteButton]
        rows.forEach { $0.heightAnchor.constraint(equalToConstant: 52).isActive = true }
        descriptionView.heightAnchor.constraint(equalToConstant: 140).isActive = true
    }

    private func setupStaticMenus() {
        priorityRow.setMenu(UIMenu(children: ["Low", "Medium", "High", "Critical"].map { name in
            UIAction(title: name) { [weak self] _ in self?.priorityRow.setDetail(name) }
        }))
        frequencyRow.setMenu(UIMenu(children: ["Once", "Daily", "Weekly", "Monthly"].map { name in
            UIAction(title: name) { [weak self] _ in self?.frequencyRow.setDetail(name) }
        }))
        listRow.setMenu(UIMenu(children: ["General", "Morning Routine", "Evening Routine", "School", "Chores"].map { name in
            UIAction(title: name) { [weak self] _ in self?.listRow.setDetail(name) }
        }))
    }
    
    private func updateAssignedMenu() {
        let menuItems = childrenList.map { child in
            UIAction(title: child.name, state: assignedSelections.contains(child.id) ? .on : .off) { [weak self] _ in
                guard let self = self else { return }
                if self.assignedSelections.contains(child.id) { self.assignedSelections.remove(child.id) }
                else { self.assignedSelections.insert(child.id) }
                self.updateAssignedLabel()
                self.updateAssignedMenu()
            }
        }
        assignedRow.setMenu(UIMenu(title: "Select Children", options: .displayInline, children: menuItems))
    }
    
    private func updateAssignedLabel() {
        if assignedSelections.isEmpty { assignedRow.setDetail("Select Child"); return }
        let selectedNames = childrenList.filter { assignedSelections.contains($0.id) }.map { $0.name }
        assignedRow.setDetail(selectedNames.joined(separator: ", "))
    }
    
    private func openDatePicker() {
        let vc = UIViewController(); vc.view.backgroundColor = .systemBackground
        if let sheet = vc.sheetPresentationController { sheet.detents = [.medium()] }
        let picker = UIDatePicker(); picker.datePickerMode = .dateAndTime; picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = false; vc.view.addSubview(picker)
        NSLayoutConstraint.activate([
            picker.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            picker.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        if let date = selectedDate { picker.date = date }
        picker.addAction(UIAction(handler: { [weak self] _ in
            self?.selectedDate = picker.date
            let df = DateFormatter(); df.dateFormat = "MMM d, h:mm a"
            self?.dateRow.setDetail(df.string(from: picker.date))
        }), for: .valueChanged)
        present(vc, animated: true)
    }

    @objc private func cancelTapped() { dismiss(animated: true) }
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
