import UIKit

final class StreakPageView: UIViewController {

    // MARK: - Month State
    private var currentMonth = Calendar.current.component(.month, from: Date())
    private var currentYear = Calendar.current.component(.year, from: Date())

    // MARK: - UI
    private let monthHeader = MonthHeaderView()
    private let calendarView = StreakCalendarView()
    private let gradientLayer = CAGradientLayer()

    // MARK: - Streak Data (TEMP / MOCK)
    private var completedDays: Set<Int> = [
        3,4,6,9,11,12,14,15,16,17,18,19,20,23,24,26,27,29,30
    ]

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
        setupCompactBackTitle()
        setupLayout()
        setupMonthHeader()
        loadInitialMonth()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    private func setupCompactBackTitle() {

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white

        // 🔥 IMPORTANT (THIS REMOVES THE CAPSULE)
        backButton.configuration = .plain()
        backButton.configuration?.baseBackgroundColor = .clear
        backButton.configuration?.contentInsets = NSDirectionalEdgeInsets(
            top: 8, leading: 0, bottom: 8, trailing: 4
        )

        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.text = "Streak 🔥"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white

        let stack = UIStackView(arrangedSubviews: [backButton, titleLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4

        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: container)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.backgroundImage = UIImage()
        buttonAppearance.highlighted.backgroundImage = UIImage()
        buttonAppearance.focused.backgroundImage = UIImage()

        appearance.buttonAppearance = buttonAppearance

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }




    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
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
            calendarView.heightAnchor.constraint(equalToConstant: 360)
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

        calendarView.update(
            month: currentMonth,
            year: currentYear,
            completed: completedDays
        )
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

        calendarView.update(
            month: currentMonth,
            year: currentYear,
            completed: completedDays
        )
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
}

