import UIKit

// MARK: - Models

enum RepeatFrequency: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

enum Weekday: String, CaseIterable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
}

// MARK: - Controller

final class CustomClaimLimitViewController: UITableViewController {

    // Callback
    var onSave: ((String) -> Void)?

    // State
    private var frequency: RepeatFrequency = .daily
    private var interval: Int = 1
    private var selectedWeekdays: Set<Weekday> = []
    private var selectedMonthDay: Int = 1
    private var selectedMonth: Int = Calendar.current.component(.month, from: Date())

    // Gradient
    private let gradient = CAGradientLayer()

    // MARK: - Init (Inset grouped like Reminders)

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Custom"

        setupGradient()
        setupNavigation()
        setupTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    // MARK: - Setup

    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }

    private func setupTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 56
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func doneTapped() {
        onSave?(buildResultString())
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Sections

    override func numberOfSections(in tableView: UITableView) -> Int {
        switch frequency {
        case .daily:
            return 2
        case .weekly, .monthly, .yearly:
            return 3
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return RepeatFrequency.allCases.count
        case 1:
            return 1
        case 2:
            switch frequency {
            case .weekly:
                return Weekday.allCases.count
            case .monthly:
                return 31
            case .yearly:
                return 12
            default:
                return 0
            }
        default:
            return 0
        }
    }

    // MARK: - Cells

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.12)
        cell.layer.cornerRadius = 14
        cell.layer.masksToBounds = true
        cell.contentView.backgroundColor = .clear

        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .systemBlue
        cell.selectionStyle = .none

        switch indexPath.section {

        // Frequency
        case 0:
            let freq = RepeatFrequency.allCases[indexPath.row]
            cell.textLabel?.text = freq.rawValue
            cell.accessoryType = freq == frequency ? .checkmark : .none
            cell.tintColor = .systemBlue

        // Every
        case 1:
            cell.textLabel?.text = "Every"
            cell.detailTextLabel?.text =
                interval == 1
                ? frequency.rawValue.dropLast().capitalized
                : "\(interval) \(frequency.rawValue.lowercased())"
            cell.accessoryType = .disclosureIndicator

        // Details
        case 2:
            configureDetailCell(cell, indexPath: indexPath)

        default:
            break
        }

        return cell
    }

    private func configureDetailCell(_ cell: UITableViewCell, indexPath: IndexPath) {

        switch frequency {

        case .weekly:
            let day = Weekday.allCases[indexPath.row]
            cell.textLabel?.text = day.rawValue
            cell.accessoryType = selectedWeekdays.contains(day) ? .checkmark : .none
            cell.tintColor = .systemBlue

        case .monthly:
            let day = indexPath.row + 1
            cell.textLabel?.text = "\(day)"
            cell.accessoryType = day == selectedMonthDay ? .checkmark : .none
            cell.tintColor = .systemBlue

        case .yearly:
            let month = indexPath.row + 1
            cell.textLabel?.text = DateFormatter().monthSymbols[month - 1]
            cell.accessoryType = month == selectedMonth ? .checkmark : .none
            cell.tintColor = .systemBlue

        default:
            break
        }
    }

    // MARK: - Headers

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Frequency"
        case 1: return "Every"
        case 2:
            switch frequency {
            case .weekly: return "Days of Week"
            case .monthly: return "Day of Month"
            case .yearly: return "Month"
            default: return nil
            }
        default:
            return nil
        }
    }

    override func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.white.withAlphaComponent(0.6)
        header.contentView.backgroundColor = .clear
    }

    // MARK: - Selection

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {

        case 0:
            frequency = RepeatFrequency.allCases[indexPath.row]
            selectedWeekdays.removeAll()
            tableView.reloadData()

        case 1:
            openIntervalPicker()

        case 2:
            handleDetailSelection(indexPath)

        default:
            break
        }
    }

    private func openIntervalPicker() {
        let alert = UIAlertController(
            title: "Repeat Every",
            message: nil,
            preferredStyle: .actionSheet
        )

        for i in 1...30 {
            alert.addAction(UIAlertAction(title: "\(i)", style: .default) { [weak self] _ in
                self?.interval = i
                self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func handleDetailSelection(_ indexPath: IndexPath) {

        switch frequency {

        case .weekly:
            let day = Weekday.allCases[indexPath.row]
            selectedWeekdays.toggle(day)

        case .monthly:
            selectedMonthDay = indexPath.row + 1

        case .yearly:
            selectedMonth = indexPath.row + 1

        default:
            break
        }

        tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
    }

    // MARK: - Result Builder

    private func buildResultString() -> String {

        let every = interval == 1 ? "Every" : "Every \(interval)"

        switch frequency {

        case .daily:
            return interval == 1 ? "Every day" : "\(every) days"

        case .weekly:
            if selectedWeekdays.isEmpty {
                return interval == 1 ? "Every week" : "\(every) weeks"
            }
            let days = selectedWeekdays
                .map { $0.rawValue }
                .sorted()
                .joined(separator: ", ")
            return "\(every) weeks on \(days)"

        case .monthly:
            return "\(every) months on \(selectedMonthDay)"

        case .yearly:
            let monthName = DateFormatter().monthSymbols[selectedMonth - 1]
            return "\(every) years in \(monthName)"
        }
    }
}

// MARK: - Helpers
private extension Set where Element == Weekday {
    mutating func toggle(_ value: Weekday) {
        if contains(value) {
            remove(value)
        } else {
            insert(value)
        }
    }
}

