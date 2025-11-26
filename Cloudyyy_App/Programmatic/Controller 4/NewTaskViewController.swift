//
//  NewTaskViewController.swift
//  Cloudyyy_App
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
        setupMenus()        // Floating menus
        setupActions()       // Extra behaviors like date picker + list page
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
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

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
            UIColor(red: 10/255, green: 13/255, blue: 41/255, alpha: 1).cgColor,
            UIColor(red: 24/255, green: 30/255, blue: 74/255, alpha: 1).cgColor
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
        stack.alignment = .fill
        stack.distribution = .fill

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
    // MARK: - Floating Menus (UIMenu)
    // ===========================================================

    private func setupMenus() {

        // ---------- Priority ----------
        let priorityMenu = UIMenu(children: ["None", "Low", "Medium", "High"].map { name in
            UIAction(title: name) { [weak self] _ in
                self?.priorityRow.setDetail(name)
            }
        })
        priorityRow.setMenu(priorityMenu)

        // ---------- Frequency ----------
        let frequencyMenu = UIMenu(children: ["Doesn't repeat", "Daily", "Weekly", "Monthly"].map { name in
            UIAction(title: name) { [weak self] _ in
                self?.frequencyRow.setDetail(name)
            }
        })
        frequencyRow.setMenu(frequencyMenu)

        // ---------- Multi-select Assigned Row ----------
        updateAssignedMenu()
    }

    private func updateAssignedMenu() {
        let options = ["Bob", "Jonesh", "Aisha", "Ramesh"]

        let actions = options.map { name in
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

                // Refresh menu
                self.updateAssignedMenu()
            }
        }

        assignedRow.setMenu(UIMenu(children: actions))
    }

    // ===========================================================
    // MARK: - Additional Actions
    // ===========================================================

    private func setupActions() {

        // ---------- Date picker ----------
        dateRow.onTap = { [weak self] in
            self?.openDatePicker()
        }

        // ---------- List selection page ----------
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

    // ===========================================================
    // MARK: - Date Picker Popup
    // ===========================================================

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

        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
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
    // MARK: - Save
    // ===========================================================

    @objc private func doneTapped() {

        var missing: [String] = []

        if titleField.textValue.isEmpty { missing.append("Title") }
        if priorityRow.detailText == nil { missing.append("Priority") }
        if dateRow.detailText == nil { missing.append("Date") }
        if frequencyRow.detailText == nil { missing.append("Frequency") }
        if listRow.detailText == nil { missing.append("List") }
        if pointsRow.countValue <= 0 { missing.append("Points") }
        if assignedSelections.isEmpty { missing.append("Assigned To") }

        if !missing.isEmpty {
            let msg = "Please fill: " + missing.joined(separator: ", ")
            let ac = UIAlertController(title: "Missing Fields", message: msg, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }

        print("Saving task…")
        dismiss(animated: true)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

