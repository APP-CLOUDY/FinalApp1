//
//  NewTaskViewController.swift
//  Cloudyyy_App
//
//  Minimal fix + dynamic tracking for home dashboard.
//


import UIKit

class NewTaskViewController: UIViewController {

    // ===========================================================
    // MARK: - UI Base Containers
    // ===========================================================

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()
    private let gradient = CAGradientLayer()

    // ===========================================================
    // MARK: - Form Fields
    // ===========================================================

    private let titleField = StyledTextField(placeholder: "Title *")
    private let descriptionView = StyledTextView(placeholder: "Description (Optional)")

    private let priorityRow = SelectRow(title: "Priority")
    private let pointsRow = PointsRow()
    private let dateRow = SelectRow(title: "Date & Time")
    private let frequencyRow = SelectRow(title: "Frequency")
    private let listRow = SelectRow(title: "List")
    private let approvalRow = ApprovalToggleRow(title: "Approval Required")
    private let assignedRow = SelectRow(title: "Assigned To")

    // Date storage
    private var selectedDate: Date?

    // Multi-select storage
    private var assignedSelections = Set<String>()

    private func todayString() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: Date())
    }

    // ===========================================================
    // MARK: - Lifecycle
    // ===========================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Task"
        view.backgroundColor = .black

        setupNavigationBar()
        setupGradient()
        setupScrollView()
        setupStack()
        setupHeights()
        setupMenus()
        setupActions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    // ===========================================================
    // MARK: - Navigation Bar
    // ===========================================================

    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }

    // ===========================================================
    // MARK: - Background Gradient
    // ===========================================================

    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
                        UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    // ===========================================================
    // MARK: - ScrollView & Stack
    // ===========================================================

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

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])

        let fields: [UIView] = [
            titleField,
            descriptionView,
            priorityRow,
            pointsRow,
            dateRow,
            frequencyRow,
            listRow,
            approvalRow,
            assignedRow
        ]

        fields.forEach {
            $0.alpha = 0
            stack.addArrangedSubview($0)
        }

        UIView.animate(withDuration: 0.25) {
            fields.forEach { $0.alpha = 1 }
        }
    }

    // ===========================================================
    // MARK: - Heights
    // ===========================================================

    private func setupHeights() {
        titleField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        descriptionView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        priorityRow.heightAnchor.constraint(equalToConstant: 52).isActive = true
        pointsRow.heightAnchor.constraint(equalToConstant: 52).isActive = true
        dateRow.heightAnchor.constraint(equalToConstant: 52).isActive = true
        frequencyRow.heightAnchor.constraint(equalToConstant: 52).isActive = true
        listRow.heightAnchor.constraint(equalToConstant: 52).isActive = true
        approvalRow.heightAnchor.constraint(equalToConstant: 52).isActive = true
        assignedRow.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    // ===========================================================
    // MARK: - Floating Menus
    // ===========================================================

    private func setupMenus() {
        let priorityMenu = UIMenu(children: ["None", "Low", "Medium", "High"].map { name in
            UIAction(title: name) { [weak self] _ in
                self?.priorityRow.setDetail(name)
            }
        })
        priorityRow.setMenu(priorityMenu)

        let frequencyMenu = UIMenu(children: ["Doesn't repeat", "Daily", "Weekly", "Monthly"].map { name in
            UIAction(title: name) { [weak self] _ in
                self?.frequencyRow.setDetail(name)
            }
        })
        frequencyRow.setMenu(frequencyMenu)

        updateAssignedMenu()
    }

    private func updateAssignedMenu() {
        let people = ["Bob", "Jonesh", "Aisha", "Ramesh"]

        let actions = people.map { name in
            UIAction(
                title: name,
                state: assignedSelections.contains(name) ? .on : .off
            ) { [weak self] _ in
                guard let self else { return }

                if self.assignedSelections.contains(name) {
                    self.assignedSelections.remove(name)
                } else {
                    self.assignedSelections.insert(name)
                }

                let final = self.assignedSelections.sorted().joined(separator: ", ")
                self.assignedRow.setDetail(final.isEmpty ? "None" : final)

                self.updateAssignedMenu()
            }
        }

        assignedRow.setMenu(UIMenu(children: actions))
    }

    // ===========================================================
    // MARK: - Date Picker
    // ===========================================================

    private func setupActions() {
        dateRow.onTap = { [weak self] in
            self?.openDatePicker()
        }

        listRow.onTap = { [weak self] in
            let vc = ListsViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            nav.navigationBar.tintColor = .white
            self?.present(nav, animated: true)

            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("ListSelected"),
                object: nil,
                queue: .main
            ) { notif in
                if let name = notif.object as? String {
                    self?.listRow.setDetail(name)
                }
            }
        }
    }

    private func openDatePicker() {
        let vc = UIViewController()
        vc.modalPresentationStyle = .pageSheet
        vc.view.backgroundColor = .systemBackground

        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(picker)

        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            picker.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 20),
            picker.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: -80)
        ])

        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: nil,
            action: nil
        )

        vc.navigationItem.rightBarButtonItem?.primaryAction = UIAction(handler: { _ in
            let df = DateFormatter()
            df.dateFormat = "MMM d, h:mm a"

            self.selectedDate = picker.date
            self.dateRow.setDetail(df.string(from: picker.date))

            vc.dismiss(animated: true)
        })

        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    // ===========================================================
    // MARK: - SAVE TASK
    // ===========================================================
    
    @objc private func doneTapped() {

        // --- Validate ---
        var missing: [String] = []

        if titleField.textValue.isEmpty      { missing.append("Title") }
        if priorityRow.detailText == nil    { missing.append("Priority") }
        if dateRow.detailText == nil        { missing.append("Date") }
        if frequencyRow.detailText == nil   { missing.append("Frequency") }
        if listRow.detailText == nil        { missing.append("List") }
        if pointsRow.countValue <= 0        { missing.append("Points") }
        if assignedSelections.isEmpty       { missing.append("Assigned To") }

        if !missing.isEmpty {
            let ac = UIAlertController(
                title: "Missing Fields",
                message: "Please fill: \(missing.joined(separator: ", "))",
                preferredStyle: .alert
            )
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }

        guard let kid = ChildManager.shared.selectedKid else {
            let ac = UIAlertController(title: "No kid selected", message: "Select a kid and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }

        // ====================================================
        // BUILD NEW TASK
        // ====================================================

        let id = UUID().uuidString
        let createdAtISO = ISO8601DateFormatter().string(from: Date())

        // Use a fixed calendar/timezone so "yyyy-MM-dd" won't shift by timezone
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.timeZone = TimeZone(secondsFromGMT: 0)        // <- IMPORTANT: normalize to UTC
        df.dateFormat = "yyyy-MM-dd"

        // If user picked a date → store selected date
        // Else fallback to TODAY (also normalized)
        let dateOnly = selectedDate != nil ? df.string(from: selectedDate!) : df.string(from: Date())


        let newTask = TaskItem(
            id: id,
            title: titleField.textValue,
            description: descriptionView.textValue.isEmpty ? nil : descriptionView.textValue,
            points: pointsRow.countValue,
            dateTimeISO: selectedDate != nil ? ISO8601DateFormatter().string(from: selectedDate!) : nil,
            dateOnly: dateOnly,
            priority: priorityRow.detailText,
            frequency: frequencyRow.detailText,
            assignedTo: Array(assignedSelections),
            approvalRequired: approvalRow.isOn,
            isDone: false,
            createdAtISO: createdAtISO
        )

        // Add into Task Storage (THIS AUTOMATICALLY UPDATES Schedule)
        ChildManager.shared.addTask(newTask, for: kid.id)

        // First-time user flag
        UserDefaults.standard.set(false, forKey: "isFirstTimeUser")

        dismiss(animated: true)
    }
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

}

