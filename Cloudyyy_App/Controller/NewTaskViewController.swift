import UIKit

class NewTaskViewController: UIViewController {

    // MARK: UI Base
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()
    private let gradient = CAGradientLayer()

    // MARK: Fields
    private let titleField = StyledTextField(placeholder: "Title *")
    private let descriptionView = StyledTextView(placeholder: "Description (Optional)")

    private let priorityRow = SelectRow(title: "Priority")
    private let pointsRow = PointsRow()
    private let dateRow = SelectRow(title: "Date & Time")
    private let frequencyRow = SelectRow(title: "Frequency")
    private let listRow = SelectRow(title: "List")
    private let approvalRow = ApprovalToggleRow(title: "Approval Required")
    private let assignedRow = SelectRow(title: "Assigned To")

    private var selectedDate: Date?
    private var assignedSelections = Set<String>()

    // Use MenuManager for persistence + menus
    private let mm = MenuManager.shared

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Task"
        view.backgroundColor = .black

        setupNavigationBar()
        setupGradient()
        setupScroll()
        setupStack()
        setupHeights()
        configureMenusAndActions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    // MARK: Layout
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
    }

    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 10/255, green: 13/255, blue: 41/255, alpha: 1).cgColor,
            UIColor(red: 24/255, green: 30/255, blue: 74/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func setupScroll() {
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

        // Add fields in order
        [titleField, descriptionView, priorityRow, pointsRow, dateRow, frequencyRow, listRow, approvalRow, assignedRow]
            .forEach { v in
                v.alpha = 0
                stack.addArrangedSubview(v)
            }

        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let s = self else { return }
            s.stack.arrangedSubviews.forEach { $0.alpha = 1 }
        }
    }

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

    // MARK: - Menus & Actions
    private func configureMenusAndActions() {

        // Priority: simple static menu (no "Add New" requested for priority)
        let priorityMenu = UIMenu(title: "", children: [
            UIAction(title: "None", handler: { _ in self.priorityRow.setDetail("None") }),
            UIAction(title: "Low", handler: { _ in self.priorityRow.setDetail("Low") }),
            UIAction(title: "Medium", handler: { _ in self.priorityRow.setDetail("Medium") }),
            UIAction(title: "High", handler: { _ in self.priorityRow.setDetail("High") })
        ])
        priorityRow.setMenu(priorityMenu)

        // Points are manual via PointsRow (already interactive)

        // Date row: open date picker on tap
        dateRow.onTap = { [weak self] in self?.openDatePicker() }

        // Frequency (has Add New)
        let freqMenu = mm.menu(title: "", key: .frequency, selectionHandler: { val in
            self.frequencyRow.setDetail(val)
        }, addNewHandler: { [weak self] in
            self?.presentAddNewAlert(for: .frequency, title: "Add Frequency", placeholder: "e.g. Every 2 days") { newVal in
                self?.frequencyRow.setDetail(newVal)
                self?.updateFrequencyMenu()
            }
        })
        frequencyRow.setMenu(freqMenu)

        // List (has Add New)
        let listMenu = mm.menu(title: "", key: .lists, selectionHandler: { val in
            self.listRow.setDetail(val)
        }, addNewHandler: { [weak self] in
            self?.presentAddNewAlert(for: .lists, title: "Add List", placeholder: "List name") { newVal in
                self?.listRow.setDetail(newVal)
                self?.updateListMenu()
            }
        })
        listRow.setMenu(listMenu)

        // Assigned To (multi-select capable)
        updateAssignedMenu()

        // Approval toggle left as-is (ApprovalToggleRow)
    }

    // Rebuild frequency menu after adding new item
    private func updateFrequencyMenu() {
        let newMenu = mm.menu(title: "", key: .frequency, selectionHandler: { val in
            self.frequencyRow.setDetail(val)
        }, addNewHandler: { [weak self] in
            self?.presentAddNewAlert(for: .frequency, title: "Add Frequency", placeholder: "e.g. Every 2 days") { newVal in
                self?.frequencyRow.setDetail(newVal)
                self?.updateFrequencyMenu()
            }
        })
        frequencyRow.setMenu(newMenu)
    }

    // Rebuild list menu after adding new item
    private func updateListMenu() {
        let newMenu = mm.menu(title: "", key: .lists, selectionHandler: { val in
            self.listRow.setDetail(val)
        }, addNewHandler: { [weak self] in
            self?.presentAddNewAlert(for: .lists, title: "Add List", placeholder: "List name") { newVal in
                self?.listRow.setDetail(newVal)
                self?.updateListMenu()
            }
        })
        listRow.setMenu(newMenu)
    }

    // Assigned menu is special: allow multi-select. We present a menu where each person toggles selection.
    private func updateAssignedMenu() {
        let options = mm.values(for: .assigned)
        var actions: [UIMenuElement] = options.map { name -> UIAction in
            let isSelected = assignedSelections.contains(name)
            return UIAction(title: name, state: isSelected ? .on : .off, handler: { [weak self] a in
                guard let self = self else { return }
                if self.assignedSelections.contains(name) {
                    self.assignedSelections.remove(name)
                } else {
                    self.assignedSelections.insert(name)
                }
                // Show combined detail like "Bob, Aisha"
                let text = self.assignedSelections.sorted().joined(separator: ", ")
                self.assignedRow.setDetail(text.isEmpty ? "Select" : text)
                self.updateAssignedMenu() // refresh menu to update checkmarks
            })
        }

        let add = UIAction(title: "➕ Add New...", handler: { [weak self] _ in
            self?.presentAddNewAlert(for: .assigned, title: "Add Person", placeholder: "Name") { newVal in
                // auto-select newly added
                self?.mm.add(newVal, to: .assigned)
                self?.assignedSelections.insert(newVal)
                self?.assignedRow.setDetail(self?.assignedSelections.sorted().joined(separator: ", ") ?? newVal)
                self?.updateAssignedMenu()
            }
        })

        actions.append(UIMenu(title: "", options: .displayInline, children: [add]))

        let menu = UIMenu(title: "", children: actions)
        assignedRow.setMenu(menu)
    }

    // MARK: - Add New Alert
    private func presentAddNewAlert(for key: MenuManager.Key, title: String, placeholder: String, completion: @escaping (String)->Void) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        ac.addTextField { tf in
            tf.placeholder = placeholder
            tf.autocapitalizationType = .words
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            if let text = ac.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
                self.mm.add(text, to: key)
                completion(text)
            }
        }))
        present(ac, animated: true)
    }

    // MARK: - Date Picker sheet (safe from clipping)
    private func openDatePicker() {
        let pickerVC = UIViewController()
        pickerVC.title = "Select Date & Time"
        pickerVC.view.backgroundColor = .systemBackground

        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = false

        pickerVC.view.addSubview(picker)
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: pickerVC.view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: pickerVC.view.trailingAnchor),
            picker.topAnchor.constraint(equalTo: pickerVC.view.topAnchor, constant: 16),
            picker.heightAnchor.constraint(equalToConstant: 220)
        ])

        // Done button as right bar button to capture selection
        let done = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        done.primaryAction = UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            let df = DateFormatter()
            df.dateFormat = "MMM d, h:mm a"
            self.selectedDate = picker.date
            self.dateRow.setDetail(df.string(from: picker.date))
            pickerVC.dismiss(animated: true)
        })
        pickerVC.navigationItem.rightBarButtonItem = done

        let nav = UINavigationController(rootViewController: pickerVC)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    // MARK: Save / Cancel
    @objc private func cancelTapped() { dismiss(animated: true) }

    @objc private func doneTapped() {
        // validate
        var missing: [String] = []
        if titleField.textValue.trimmingCharacters(in: .whitespaces).isEmpty { missing.append("Title") }
        if pointsRow.countValue <= 0 { missing.append("Points") }
        if frequencyRow.detailText == nil { missing.append("Frequency") }
        if listRow.detailText == nil { missing.append("List") }
        if assignedRow.detailText == nil { missing.append("Assigned To") }

        if !missing.isEmpty {
            let ac = UIAlertController(title: "Missing", message: "Please fill: " + missing.joined(separator: ", "), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }

        print("Saving task…")
        dismiss(animated: true)
    }
}

