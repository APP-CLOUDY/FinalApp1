import UIKit

// MARK: - Models

enum RepeatFrequency: String, CaseIterable {
    case daily
    case weekly
    case monthly
    case yearly

    var title: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}

enum Weekday: String, CaseIterable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"

    var calendarIndex: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
}
// MARK: - Controller

final class CustomClaimLimitViewController: UITableViewController {

    // Callback
    var onSave: ((RepeatRule, String) -> Void)?

    // MARK: - State

    private var frequency: RepeatFrequency = .daily {
        didSet {
            resetStateForFrequency()
            clampInterval()
            updatePreview()
        }
    }

    private var interval: Int = 1 {
        didSet { updatePreview() }
    }

    private var selectedWeekdays = Set<Weekday>() {
        didSet { updatePreview() }
    }

    private var selectedMonthDay: Int = 1 {
        didSet { updatePreview() }
    }

    private var selectedMonth: Int = Calendar.current.component(.month, from: Date()) {
        didSet { updatePreview() }
    }

    // MARK: - UI

    private let gradient = CAGradientLayer()

    private let previewLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.numberOfLines = 2
        l.textAlignment = .center
        return l
    }()

    // MARK: - Init

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
        setupPreviewFooter()
        updatePreview()
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

    // MARK: - Preview Footer

    private func setupPreviewFooter() {
        let container = UIView()
        container.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.15)
        container.layer.cornerRadius = 14

        container.addSubview(previewLabel)
        previewLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            previewLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            previewLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            previewLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            previewLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])

        container.frame.size.height = 60
        tableView.tableFooterView = container
    }

    private func updatePreview() {
        previewLabel.text = "🔁 " + buildResultString()
    }

    // MARK: - Logic

    private func maxInterval(for frequency: RepeatFrequency) -> Int {
        switch frequency {
        case .daily: return 7
        case .weekly: return 4
        case .monthly: return 6
        case .yearly: return 5
        }
    }

    private func clampInterval() {
        interval = min(interval, maxInterval(for: frequency))
    }

    private func resetStateForFrequency() {
        selectedWeekdays.removeAll()
        selectedMonthDay = 1
        selectedMonth = Calendar.current.component(.month, from: Date())
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func doneTapped() {
        let payload = RepeatRulePayload(
            type: "weekly",
            interval: 1,
            weekdays: selectedWeekdays.map { $0.calendarIndex },
            day: nil,
            month: nil
        )

        let rule = RepeatRule.custom(
            CustomRepeatRule(
                label: "Weekly",
                payload: payload
            )
        )


        onSave?(rule, buildResultString())
        navigationController?.popViewController(animated: true)
    }


    // MARK: - Table

    override func numberOfSections(in tableView: UITableView) -> Int {
        frequency == .daily ? 2 : 3
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return RepeatFrequency.allCases.count
        case 1: return 1
        case 2:
            switch frequency {
            case .weekly: return Weekday.allCases.count
            case .monthly: return 31
            case .yearly: return 12
            default: return 0
            }
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.12)
        cell.layer.cornerRadius = 14
        cell.layer.masksToBounds = true
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .systemBlue
        cell.selectionStyle = .none

        switch indexPath.section {
        case 0:
            let freq = RepeatFrequency.allCases[indexPath.row]
            cell.textLabel?.text = freq.title
            cell.accessoryType = freq == frequency ? .checkmark : .none

        case 1:
            cell.textLabel?.text = "Every"
            cell.detailTextLabel?.text = "\(interval)"
            cell.accessoryView = stepperView()

        case 2:
            configureDetailCell(cell, indexPath)

        default:
            break
        }

        return cell
    }

    private func stepperView() -> UIView {
        let minus = UIButton(type: .system)
        let plus = UIButton(type: .system)

        minus.setTitle("−", for: .normal)
        plus.setTitle("+", for: .normal)

        minus.addTarget(self, action: #selector(decInterval), for: .touchUpInside)
        plus.addTarget(self, action: #selector(incInterval), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [minus, plus])
        stack.spacing = 12
        return stack
    }

    private func configureDetailCell(_ cell: UITableViewCell,
                                     _ indexPath: IndexPath) {

        switch frequency {
        case .weekly:
            let day = Weekday.allCases[indexPath.row]
            cell.textLabel?.text = day.rawValue
            cell.accessoryType = selectedWeekdays.contains(day) ? .checkmark : .none

        case .monthly:
            let day = indexPath.row + 1
            cell.textLabel?.text = "\(day)"
            cell.accessoryType = day == selectedMonthDay ? .checkmark : .none

        case .yearly:
            let month = indexPath.row + 1
            cell.textLabel?.text = DateFormatter().monthSymbols[month - 1]
            cell.accessoryType = month == selectedMonth ? .checkmark : .none

        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {
        case 0:
            frequency = RepeatFrequency.allCases[indexPath.row]
            tableView.reloadData()

        case 2:
            handleDetailSelection(indexPath)
            tableView.reloadSections([2], with: .automatic)

        default:
            break
        }
    }

    @objc private func decInterval() {
        guard interval > 1 else { return }
        interval -= 1
        tableView.reloadSections([1], with: .none)
    }

    @objc private func incInterval() {
        guard interval < maxInterval(for: frequency) else { return }
        interval += 1
        tableView.reloadSections([1], with: .none)
    }

    private func handleDetailSelection(_ indexPath: IndexPath) {
        switch frequency {
        case .weekly:
            selectedWeekdays.toggle(Weekday.allCases[indexPath.row])
        case .monthly:
            selectedMonthDay = indexPath.row + 1
        case .yearly:
            selectedMonth = indexPath.row + 1
        default:
            break
        }
    }

    private func buildResultString() -> String {

        let every = interval == 1 ? "Every" : "Every \(interval)"

        switch frequency {
        case .daily:
            return interval == 1 ? "Every day" : "\(every) days"
        case .weekly:
            if selectedWeekdays.isEmpty {
                return interval == 1 ? "Every week" : "\(every) weeks"
            }
            let days = selectedWeekdays.map { $0.rawValue }.sorted().joined(separator: ", ")
            return "\(every) weeks on \(days)"
        case .monthly:
            return "\(every) months on \(selectedMonthDay)"
        case .yearly:
            let name = DateFormatter().monthSymbols[selectedMonth - 1]
            return "\(every) years in \(name)"
        }
    }
}

// MARK: - Helper
private extension Set where Element == Weekday {
    mutating func toggle(_ value: Weekday) {
        if contains(value) {
            remove(value)
        } else {
            insert(value)
        }
    }
}

