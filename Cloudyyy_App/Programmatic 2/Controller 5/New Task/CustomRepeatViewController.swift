import UIKit

class CustomRepeatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Callback
    // Updated to return: Frequency, Interval, Days Array, End Date, and Summary Text
    var onSave: ((_ frequency: String, _ interval: Int, _ days: [Int], _ endDate: Date?, _ summary: String) -> Void)?

    // MARK: - State
    private let frequencies = ["Daily", "Weekly", "Monthly", "Yearly"]
    private var selectedFrequencyIndex = 1 // Default to Weekly
    private var interval: Int = 1
    private var selectedWeekdays: Set<Int> = [] // 1 = Sun, 2 = Mon, etc.
    private var endDate: Date? = nil // nil = Never

    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let weekDaysStack = UIStackView()
    
    override func viewDidLoad() {
            super.viewDidLoad()
            title = "Custom"
            view.backgroundColor = .systemGroupedBackground
            
            setupNavBar()
            setupTableView()
            setupWeekdays()
            
            // Default to current day if nothing selected
            if selectedWeekdays.isEmpty {
                let gregDay = Calendar.current.component(.weekday, from: Date()) // Sun=1, Mon=2...
                
                // ✅ CONVERT: Gregorian -> ISO (Mon=1 ... Sun=7)
                let isoDay = (gregDay == 1) ? 7 : gregDay - 1
                
                selectedWeekdays.insert(isoDay)
            }
        }

    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(IntervalCell.self, forCellReuseIdentifier: "interval")
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    // MARK: - Weekday Buttons (Apple Style)
    private func setupWeekdays() {
            weekDaysStack.axis = .horizontal
            weekDaysStack.distribution = .equalSpacing
            weekDaysStack.alignment = .center
            
            // ✅ CHANGED: Start with Monday (M) to match your App's logic (1=Mon)
            let days = ["M", "T", "W", "T", "F", "S", "S"]
            
            for (index, title) in days.enumerated() {
                let btn = UIButton(type: .custom)
                btn.setTitle(title, for: .normal)
                btn.setTitleColor(.black, for: .normal)
                btn.setTitleColor(.white, for: .selected)
                btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
                btn.backgroundColor = .systemGray5
                btn.layer.cornerRadius = 18
                
                // ✅ Tag 1 = Mon, Tag 7 = Sun
                btn.tag = index + 1
                
                btn.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    btn.widthAnchor.constraint(equalToConstant: 36),
                    btn.heightAnchor.constraint(equalToConstant: 36)
                ])
                
                btn.addTarget(self, action: #selector(weekdayTapped(_:)), for: .touchUpInside)
                weekDaysStack.addArrangedSubview(btn)
            }
        }

    @objc private func weekdayTapped(_ sender: UIButton) {
        let day = sender.tag
        if selectedWeekdays.contains(day) {
            // Prevent deselecting if it's the last one
            if selectedWeekdays.count > 1 {
                selectedWeekdays.remove(day)
            }
        } else {
            selectedWeekdays.insert(day)
        }
        updateWeekdayButtons()
    }
    
    private func updateWeekdayButtons() {
        for view in weekDaysStack.arrangedSubviews {
            if let btn = view as? UIButton {
                let isSelected = selectedWeekdays.contains(btn.tag)
                btn.isSelected = isSelected
                btn.backgroundColor = isSelected ? .systemBlue : .systemGray5
            }
        }
    }

    // MARK: - TableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        // Section 0: Frequency
        // Section 1: Interval
        // Section 2: Weekdays (Only if Weekly)
        // Section 3: End Repeat (Always at bottom)
        return frequencies[selectedFrequencyIndex] == "Weekly" ? 4 : 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let isWeekly = frequencies[selectedFrequencyIndex] == "Weekly"
        
        // Section Mapping
        // 0 -> Frequency
        // 1 -> Interval
        // 2 -> Weekdays (if Weekly) OR End Repeat (if not Weekly)
        // 3 -> End Repeat (if Weekly)
        
        if indexPath.section == 0 {
            // --- Frequency Section ---
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.textLabel?.text = "Frequency"
            cell.detailTextLabel?.text = frequencies[selectedFrequencyIndex]
            cell.accessoryType = .disclosureIndicator
            return cell
            
        } else if indexPath.section == 1 {
            // --- Interval Section ---
            let cell = IntervalCell()
            cell.configure(value: interval, type: frequencies[selectedFrequencyIndex])
            cell.onValueChange = { [weak self] newVal in
                self?.interval = newVal
            }
            return cell
            
        } else if isWeekly && indexPath.section == 2 {
            // --- Weekdays Section ---
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.contentView.addSubview(weekDaysStack)
            weekDaysStack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                weekDaysStack.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
                weekDaysStack.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10),
                weekDaysStack.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                weekDaysStack.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
            ])
            updateWeekdayButtons()
            return cell
            
        } else {
            // --- End Repeat Section ---
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.textLabel?.text = "End Repeat"
            
            if let date = endDate {
                let df = DateFormatter()
                df.dateStyle = .medium
                df.timeStyle = .none
                cell.detailTextLabel?.text = df.string(from: date)
                cell.detailTextLabel?.textColor = .label
            } else {
                cell.detailTextLabel?.text = "Never"
                cell.detailTextLabel?.textColor = .secondaryLabel
            }
            
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let isWeekly = frequencies[selectedFrequencyIndex] == "Weekly"
        
        if indexPath.section == 0 {
            // Frequency Action Sheet
            let ac = UIAlertController(title: "Frequency", message: nil, preferredStyle: .actionSheet)
            for (index, name) in frequencies.enumerated() {
                ac.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                    self.selectedFrequencyIndex = index
                    self.tableView.reloadData()
                }))
            }
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
            
        } else {
            // Handle "End Repeat" tap
            let endRepeatSection = isWeekly ? 3 : 2
            
            if indexPath.section == endRepeatSection {
                showEndRepeatOptions()
            }
        }
    }

    // MARK: - End Repeat Logic
    private func showEndRepeatOptions() {
        let ac = UIAlertController(title: "End Repeat", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Never", style: .default, handler: { _ in
            self.endDate = nil
            self.tableView.reloadData()
        }))
        
        ac.addAction(UIAlertAction(title: "On Date...", style: .default, handler: { _ in
            self.pickEndDate()
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func pickEndDate() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 300, height: 400)
        
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.translatesAutoresizingMaskIntoConstraints = false
        // Default to tomorrow if not set
        picker.date = endDate ?? Date().addingTimeInterval(86400)
        
        vc.view.addSubview(picker)
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 20),
            picker.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            picker.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20),
            picker.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: -20)
        ])
        
        let alert = UIAlertController(title: "Select End Date", message: nil, preferredStyle: .alert)
        alert.setValue(vc, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            self.endDate = picker.date
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func doneTapped() {
        let freq = frequencies[selectedFrequencyIndex]
        
        // Build Summary String
        var summary = "Every"
        if interval > 1 {
            summary += " \(interval)"
        }
        
        let unit = interval == 1 ? String(freq.dropLast(2)) : String(freq.dropLast(2)) + "s"
        var cleanUnit = ""
        switch freq {
        case "Daily": cleanUnit = interval == 1 ? "Day" : "Days"
        case "Weekly": cleanUnit = interval == 1 ? "Week" : "Weeks"
        case "Monthly": cleanUnit = interval == 1 ? "Month" : "Months"
        case "Yearly": cleanUnit = interval == 1 ? "Year" : "Years"
        default: cleanUnit = ""
        }
        
        summary += " \(cleanUnit)"
        
        if let end = endDate {
            let df = DateFormatter()
            df.dateStyle = .short
            summary += ", until \(df.string(from: end))"
        }
        
        // ✅ Call onSave with all data: Frequency, Interval, Days, EndDate, and Summary
        // Convert Set<Int> to [Int] for easier handling
        let daysArray = Array(selectedWeekdays).sorted()
        
        onSave?(freq, interval, daysArray, endDate, summary)
        
        dismiss(animated: true)
    }
}

// MARK: - Helper Cell for Interval
class IntervalCell: UITableViewCell {
    
    var onValueChange: ((Int) -> Void)?
    
    private let label: UILabel = {
        let l = UILabel()
        l.text = "Every"
        return l
    }()
    
    private let numberField: UITextField = {
        let t = UITextField()
        t.keyboardType = .numberPad
        t.textAlignment = .center
        t.backgroundColor = .systemGray6
        t.layer.cornerRadius = 8
        t.text = "1"
        return t
    }()
    
    private let unitLabel: UILabel = {
        let l = UILabel()
        l.textColor = .secondaryLabel
        return l
    }()
    
    private let stepper: UIStepper = {
        let s = UIStepper()
        s.minimumValue = 1
        s.maximumValue = 999
        s.value = 1
        return s
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [label, numberField, unitLabel, UIView(), stepper])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            numberField.widthAnchor.constraint(equalToConstant: 50),
            numberField.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        numberField.isEnabled = false // User uses stepper
    }
    
    func configure(value: Int, type: String) {
        stepper.value = Double(value)
        numberField.text = "\(value)"
        
        var base = ""
        switch type {
        case "Daily": base = "Day"
        case "Weekly": base = "Week"
        case "Monthly": base = "Month"
        case "Yearly": base = "Year"
        default: base = ""
        }
        unitLabel.text = value == 1 ? base : base + "s"
    }
    
    @objc private func stepperChanged() {
        let val = Int(stepper.value)
        numberField.text = "\(val)"
        
        let currentText = unitLabel.text ?? ""
        // Simple pluralization logic for labels
        if val == 1 && currentText.hasSuffix("s") {
            unitLabel.text = String(currentText.dropLast())
        } else if val > 1 && !currentText.hasSuffix("s") {
            unitLabel.text = currentText + "s"
        }
        
        onValueChange?(val)
    }
}
