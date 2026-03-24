import UIKit

final class StreakPageView: UIViewController {

    // MARK: - Month State
    private var currentMonth = Calendar.current.component(.month, from: Date())
    private var currentYear = Calendar.current.component(.year, from: Date())

    // MARK: - UI
    private let monthHeader = MonthHeaderView()
    private let calendarView = StreakCalendarView()
    private let gradientLayer = CAGradientLayer()

    private var completedDays: Set<Int> = []
    private var currentStreakCount: Int = 0


    // MARK: - Subtitle
    private let subtitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Keep your streak alive!"
        lb.font = .systemFont(ofSize: 16, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.7)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradient()
        setupLayout()
        setupMonthHeader()
        loadInitialMonth()
        setupNavigationBar()
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    private func setupNavigationBar() {
        navigationItem.title = "Streak 🔥"

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear   // important
        appearance.shadowColor = .clear       // 🔥 removes the line
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 22, weight: .bold)
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = true
    }


    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(subtitleLabel)
        view.addSubview(monthHeader)
        view.addSubview(calendarView)

        monthHeader.translatesAutoresizingMaskIntoConstraints = false
        calendarView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Subtitle (below nav bar)
            subtitleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 8
            ),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // Month Header
            monthHeader.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            monthHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            monthHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            monthHeader.heightAnchor.constraint(equalToConstant: 40),

            // Calendar
            calendarView.topAnchor.constraint(equalTo: monthHeader.bottomAnchor, constant: 12),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendarView.heightAnchor.constraint(equalToConstant: 390)
        ])
    }

    // MARK: - Month Header Logic
    private func setupMonthHeader() {
        monthHeader.onPrevious = { [weak self] in
            self?.changeMonth(by: -1)
        }

        monthHeader.onNext = { [weak self] in
            self?.changeMonth(by: 1)
        }
    }

    private func loadInitialMonth() {
        monthHeader.set(month: currentMonth, year: currentYear)
        
        Task {
            guard let childId = ChildSessionManager.shared.currentChildId else {
                print("❌ No child logged in")
                return
            }
            
            do {
                async let daysTask = StreakService.shared.getMonthStreak(
                    childId: childId,
                    month: currentMonth,
                    year: currentYear
                )
                async let streakTask = StreakService.shared.getCurrentStreak(childId: childId)

                let days = try await daysTask
                let streakCount = try await streakTask

                completedDays = days
                currentStreakCount = streakCount

                print("🔥 Streak detail debug -> completed days for month:", days.sorted())
                print("🔥 Streak detail debug -> current streak count:", streakCount)

                calendarView.update(
                    month: currentMonth,
                    year: currentYear,
                    completed: days,
                    currentStreakCount: streakCount
                )
            } catch {
                print("❌ Failed to load streak month:", error)
            }
        }
    }

    private func changeMonth(by offset: Int) {
        currentMonth += offset

        if currentMonth == 0 {
            currentMonth = 12
            currentYear -= 1
        } else if currentMonth == 13 {
            currentMonth = 1
            currentYear += 1
        }

        monthHeader.set(month: currentMonth, year: currentYear)

        Task {
            guard let childId = ChildSessionManager.shared.currentChildId else {
                print("❌ No child logged in")
                return
            }

            do {
                async let daysTask = StreakService.shared.getMonthStreak(
                    childId: childId,
                    month: currentMonth,
                    year: currentYear
                )
                async let streakTask = StreakService.shared.getCurrentStreak(childId: childId)

                let days = try await daysTask
                let streakCount = try await streakTask

                completedDays = days
                currentStreakCount = streakCount

                print("🔥 Streak detail debug -> completed days for month:", days.sorted())
                print("🔥 Streak detail debug -> current streak count:", streakCount)

                calendarView.update(
                    month: currentMonth,
                    year: currentYear,
                    completed: days,
                    currentStreakCount: streakCount
                )
            } catch {
                print("❌ Failed to load streak month:", error)
            }
        }
    }

    // MARK: - Gradient
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}
