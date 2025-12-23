import UIKit

final class StreakCalendarView: UIView {

    // MARK: - Public API
    func update(month: Int, year: Int, completed: Set<Int>) {
        self.displayMonth = month
        self.displayYear = year
        self.completedDays = completed
        reload()
    }

    // MARK: - State
    private var displayMonth: Int = Calendar.current.component(.month, from: Date())
    private var displayYear: Int = Calendar.current.component(.year, from: Date())
    private var completedDays: Set<Int> = []

    private var todayComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())

    // MARK: - UI
    private let container = UIView()
    private let gridStack = UIStackView()

    private let weekDays = ["Su","Mo","Tu","We","Th","Fr","Sa"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        reload()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup
    private func setup() {
        setupContainer()
        setupWeekdays()
        setupGrid()
    }

    private func setupContainer() {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        container.layer.cornerRadius = 24
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupWeekdays() {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.translatesAutoresizingMaskIntoConstraints = false

        weekDays.forEach {
            let lb = UILabel()
            lb.text = $0
            lb.font = .systemFont(ofSize: 13, weight: .medium)
            lb.textColor = .white.withAlphaComponent(0.55)
            lb.textAlignment = .center
            row.addArrangedSubview(lb)
        }

        container.addSubview(row)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
    }

    private func setupGrid() {
        gridStack.axis = .vertical
        gridStack.spacing = 10
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(gridStack)

        NSLayoutConstraint.activate([
            gridStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 52),
            gridStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            gridStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            gridStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Reload Calendar
    private func reload() {
        gridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let calendar = Calendar.current
        let dateComponents = DateComponents(year: displayYear, month: displayMonth)
        let firstDayDate = calendar.date(from: dateComponents)!

        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayDate)!.count
        let firstWeekday = calendar.component(.weekday, from: firstDayDate) - 1 // Sunday = 0

        let streakSet = calculateStreakDays()

        var day = 1

        for _ in 0..<6 {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.heightAnchor.constraint(equalToConstant: 48).isActive = true

            for column in 0..<7 {
                if day == 1 && column < firstWeekday {
                    row.addArrangedSubview(emptyCell())
                }
                else if day <= daysInMonth {
                    row.addArrangedSubview(dayCell(day, streakSet))
                    day += 1
                }
                else {
                    row.addArrangedSubview(emptyCell())
                }
            }

            gridStack.addArrangedSubview(row)
        }
    }

    // MARK: - Cells
    private func emptyCell() -> UIView {
        let v = UIView()
        v.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return v
    }

    private func dayCell(_ day: Int, _ streakSet: Set<Int>) -> UIView {
        let cell = UIView()
        cell.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let isToday =
            day == todayComponents.day &&
            displayMonth == todayComponents.month &&
            displayYear == todayComponents.year

        let isCompleted = completedDays.contains(day)
        let isInStreak = streakSet.contains(day)

        let content: UIView

        if isInStreak {
            content = fireView()
            cell.backgroundColor = isToday
                ? UIColor.systemOrange.withAlphaComponent(0.32)
                : UIColor.systemOrange.withAlphaComponent(0.20)
            cell.layer.cornerRadius = 16
        }
        else if isCompleted {
            content = dotView()
            cell.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.18)
            cell.layer.cornerRadius = 14
        }
        else {
            content = numberView(day)
        }

        content.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(content)

        NSLayoutConstraint.activate([
            content.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
            content.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            content.heightAnchor.constraint(lessThanOrEqualToConstant: 28)
        ])

        return cell
    }

    // MARK: - Views
    private func numberView(_ day: Int) -> UILabel {
        let lb = UILabel()
        lb.text = "\(day)"
        lb.font = .systemFont(ofSize: 15, weight: .semibold)
        lb.textColor = UIColor(red: 1.0, green: 0.75, blue: 0.3, alpha: 1)
        return lb
    }

    private func dotView() -> UIView {
        let dot = UIView()
        dot.backgroundColor = .systemBlue
        dot.layer.cornerRadius = 6
        dot.widthAnchor.constraint(equalToConstant: 12).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 12).isActive = true
        return dot
    }

    private func fireView() -> UIView {
        let iv = UIImageView(image: UIImage(systemName: "flame.fill"))
        iv.tintColor = .systemOrange
        iv.contentMode = .scaleAspectFit
        return iv
    }

    // MARK: - Streak Logic
    private func calculateStreakDays() -> Set<Int> {
        guard displayMonth == todayComponents.month,
              displayYear == todayComponents.year else { return [] }

        var result = Set<Int>()
        var day = todayComponents.day!

        while completedDays.contains(day) || day == todayComponents.day {
            result.insert(day)
            day -= 1
            if day <= 0 { break }
        }
        return result
    }
}

