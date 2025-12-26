import UIKit

final class ChildHomeViewController: UIViewController {

    // MARK: - UI Elements
    
    // 1. Scroll View & Content Container
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 2. Background Gradient
    private let gradientLayer = CAGradientLayer()

    // 3. Header Elements
    private let greetingLabel = UILabel()
    private let subGreetingLabel = UILabel()
    private let bellButton = UIButton(type: .system)
    private let profileButton = UIButton(type: .system)

    // 4. Mascot & Quote
    private let quoteBubble = UIView()
    private let quoteLabel = UILabel()
    private let mascotImageView = UIImageView()

    // 5. Achievement Card
    private let achievementCard = UIView()
    private let guitarCloud = UIImageView()
    private let powerLabel = UILabel()
    private let powerSubLabel = UILabel()

    // 6. Dynamic Progress Section
    private let achievementsTitle = UILabel()
    
    // ⚡️ NEW: StackView to hold dynamic task categories
    private let achievementsStackView = UIStackView()
    
    // 7. Padding View
    private let bottomPaddingView = UIView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupUI()
        setupLayout()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startFloatingAnimation()
        
        // Fetch Real Data when view appears
        fetchAndDisplayData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        scrollView.contentSize = contentView.bounds.size
    }
    
    // MARK: - Data Logic (Backend Connection)
    private func fetchAndDisplayData() {
        // 1. Update Name
        if let name = ChildSessionManager.shared.currentChildName {
            greetingLabel.text = "Hello \(name)."
        }
        
        // 2. Fetch Tasks to build Dynamic Progress Bars
        Task {
            do {
                // We fetch the SCHEDULE (List of tasks) instead of just Stats
                // This lets us calculate progress per Category (List Name)
                let tasks = try await ChildHomeService.shared.fetchSchedule(date: Date())
                
                await MainActor.run {
                    self.updateDynamicProgressUI(tasks: tasks)
                }
            } catch {
                print("Error loading schedule: \(error)")
            }
        }
    }
    
    // ⚡️ NEW: Group tasks by list name and render progress bars
    private func updateDynamicProgressUI(tasks: [ScheduleTaskModelChild]) {
        // 1. Clear previous rows (if any)
        achievementsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if tasks.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No tasks assigned today! 🎉"
            emptyLabel.textColor = .white.withAlphaComponent(0.7)
            emptyLabel.textAlignment = .center
            achievementsStackView.addArrangedSubview(emptyLabel)
            return
        }
        
        // 2. Group by List Name (e.g., "Chore", "Homework")
        // Dictionary: ["Chore": [Task1, Task2], "Homework": [Task3]]
        let groupedTasks = Dictionary(grouping: tasks) { $0.list_name ?? "General" }
        
        // 3. Create a Row for each Group
        for (categoryName, categoryTasks) in groupedTasks {
            let total = Float(categoryTasks.count)
            // Count Completed (Status is 'approved' or 'pending' means child did it)
            let completed = Float(categoryTasks.filter {
                let s = $0.submission_status ?? "new"
                return s == "approved" || s == "pending"
            }.count)
            
            let progress = total > 0 ? (completed / total) : 0.0
            
            // Generate the Row View
            let rowView = createProgressRow(
                title: categoryName,
                progress: progress,
                color: getColorForCategory(categoryName),
                iconName: getIconForCategory(categoryName)
            )
            
            achievementsStackView.addArrangedSubview(rowView)
        }
    }

    // MARK: - Helper: Create Single Progress Row
    private func createProgressRow(title: String, progress: Float, color: UIColor, iconName: String) -> UIView {
        let container = UIView()
        container.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Icon
        let iconImg = UIImageView()
        iconImg.image = UIImage(systemName: iconName)
        iconImg.tintColor = color
        iconImg.contentMode = .scaleAspectFit
        iconImg.translatesAutoresizingMaskIntoConstraints = false
        
        // Label
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Progress Bar
        let progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = progress
        progressBar.progressTintColor = color
        progressBar.trackTintColor = UIColor(white: 1, alpha: 0.2)
        progressBar.layer.cornerRadius = 4
        progressBar.clipsToBounds = true
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Percent Label
        let percentLabel = UILabel()
        percentLabel.text = "\(Int(progress * 100))%"
        percentLabel.textColor = .white
        percentLabel.font = .systemFont(ofSize: 14, weight: .bold)
        percentLabel.textAlignment = .right
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconImg)
        container.addSubview(label)
        container.addSubview(progressBar)
        container.addSubview(percentLabel)
        
        NSLayoutConstraint.activate([
            // Icon
            iconImg.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconImg.topAnchor.constraint(equalTo: container.topAnchor),
            iconImg.widthAnchor.constraint(equalToConstant: 30),
            iconImg.heightAnchor.constraint(equalToConstant: 30),
            
            // Label
            label.centerYAnchor.constraint(equalTo: iconImg.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: iconImg.trailingAnchor, constant: 12),
            
            // Percent Label
            percentLabel.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor),
            percentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            percentLabel.widthAnchor.constraint(equalToConstant: 40),
            
            // Progress Bar
            progressBar.leadingAnchor.constraint(equalTo: iconImg.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: percentLabel.leadingAnchor, constant: -10),
            progressBar.topAnchor.constraint(equalTo: iconImg.bottomAnchor, constant: 12),
            progressBar.heightAnchor.constraint(equalToConstant: 8)
        ])
        
        return container
    }

    // MARK: - Helper: Utilities
    private func getIconForCategory(_ name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("math") || lower.contains("study") { return "book.fill" }
        if lower.contains("chore") || lower.contains("clean") { return "sparkles" }
        if lower.contains("music") || lower.contains("piano") { return "music.note" }
        if lower.contains("sport") || lower.contains("soccer") { return "figure.run" }
        if lower.contains("art") { return "paintbrush.fill" }
        return "star.fill" // Default
    }
    
    private func getColorForCategory(_ name: String) -> UIColor {
        let lower = name.lowercased()
        if lower.contains("math") { return .systemBlue }
        if lower.contains("chore") { return .systemOrange }
        if lower.contains("music") { return .systemPurple }
        if lower.contains("sport") { return .systemGreen }
        return .systemPink // Default
    }

    // MARK: - Setup Gradient
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - Setup UI Components
    private func setupUI() {
        // Greeting
        greetingLabel.text = "Hello Child."
        greetingLabel.font = UIFont.boldSystemFont(ofSize: 32)
        greetingLabel.textColor = .white

        subGreetingLabel.text = "We hope you have a Great day !!"
        subGreetingLabel.font = UIFont.systemFont(ofSize: 16)
        subGreetingLabel.textColor = UIColor(white: 0.9, alpha: 1)

        // Header Buttons
        bellButton.setImage(UIImage(systemName: "bell"), for: .normal)
        bellButton.tintColor = .white
        
        profileButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
        profileButton.tintColor = .white

        // Quote Bubble
        quoteBubble.backgroundColor = UIColor(red: 240/255, green: 228/255, blue: 241/255, alpha: 1)
        quoteBubble.layer.cornerRadius = 20
        quoteBubble.layer.masksToBounds = true
        
        quoteLabel.text = "Let’s Finish our Missions today !!"
        quoteLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        quoteLabel.textColor = .black
        quoteLabel.numberOfLines = 0
        quoteLabel.textAlignment = .center
        quoteBubble.addSubview(quoteLabel)

        // Mascot
        mascotImageView.image = UIImage(named: "cloudyy_logo") ?? UIImage(systemName: "cloud.rain.fill")
        mascotImageView.contentMode = .scaleAspectFit
        mascotImageView.isUserInteractionEnabled = true

        // Achievement Card
        achievementCard.backgroundColor = UIColor(white: 0.96, alpha: 0.95)
        achievementCard.layer.cornerRadius = 16
        
        guitarCloud.image = UIImage(named: "cloudyy_guitar") ?? UIImage(systemName: "guitars.fill")
        guitarCloud.contentMode = .scaleAspectFit
        guitarCloud.tintColor = .systemBlue

        powerLabel.text = "Your cleanup yesterday created\n15 minutes of calm for Mom."
        powerLabel.font = UIFont.systemFont(ofSize: 14)
        powerLabel.numberOfLines = 0
        powerLabel.textColor = .black

        powerSubLabel.text = "That's your power!"
        powerSubLabel.font = UIFont.boldSystemFont(ofSize: 16)
        powerSubLabel.textColor = .black

        achievementCard.addSubview(guitarCloud)
        achievementCard.addSubview(powerLabel)
        achievementCard.addSubview(powerSubLabel)

        // Progress Section Title
        achievementsTitle.text = "Your achievements :"
        achievementsTitle.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        achievementsTitle.textColor = .white
        
        // ⚡️ NEW: StackView Configuration
        achievementsStackView.axis = .vertical
        achievementsStackView.spacing = 15
        achievementsStackView.distribution = .fill
        achievementsStackView.alignment = .fill

        // --- Adding to View Hierarchy ---
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [greetingLabel, subGreetingLabel, bellButton, profileButton,
         quoteBubble, mascotImageView, achievementCard,
         achievementsTitle, achievementsStackView, // 👈 Added StackView
         bottomPaddingView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        guitarCloud.translatesAutoresizingMaskIntoConstraints = false
        powerLabel.translatesAutoresizingMaskIntoConstraints = false
        powerSubLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Setup Layout
    private func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // --- Header ---
            greetingLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            subGreetingLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 6),
            subGreetingLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),

            profileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            profileButton.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 30),
            profileButton.heightAnchor.constraint(equalToConstant: 30),

            bellButton.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -16),
            bellButton.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor),
            bellButton.widthAnchor.constraint(equalToConstant: 30),
            bellButton.heightAnchor.constraint(equalToConstant: 30),

            // --- Mascot & Quote ---
            mascotImageView.topAnchor.constraint(equalTo: subGreetingLabel.bottomAnchor, constant: 65),
            mascotImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 40),
            mascotImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            mascotImageView.heightAnchor.constraint(equalTo: mascotImageView.widthAnchor),

            quoteBubble.topAnchor.constraint(equalTo: subGreetingLabel.bottomAnchor, constant: 59),
            quoteBubble.trailingAnchor.constraint(equalTo: mascotImageView.centerXAnchor, constant: -20),
            quoteBubble.widthAnchor.constraint(equalToConstant: 180),
            quoteBubble.heightAnchor.constraint(equalToConstant: 70),
            
            quoteLabel.topAnchor.constraint(equalTo: quoteBubble.topAnchor, constant: 12),
            quoteLabel.leadingAnchor.constraint(equalTo: quoteBubble.leadingAnchor, constant: 16),
            quoteLabel.trailingAnchor.constraint(equalTo: quoteBubble.trailingAnchor, constant: -16),
            quoteLabel.bottomAnchor.constraint(equalTo: quoteBubble.bottomAnchor, constant: -12),

            // --- Achievement Card ---
            achievementCard.topAnchor.constraint(equalTo: mascotImageView.bottomAnchor, constant: 20),
            achievementCard.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            achievementCard.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            
            guitarCloud.leadingAnchor.constraint(equalTo: achievementCard.leadingAnchor, constant: 12),
            guitarCloud.topAnchor.constraint(equalTo: achievementCard.topAnchor, constant: 20),
            guitarCloud.widthAnchor.constraint(equalToConstant: 50),
            guitarCloud.heightAnchor.constraint(equalToConstant: 50),
            guitarCloud.bottomAnchor.constraint(lessThanOrEqualTo: achievementCard.bottomAnchor, constant: -20),

            powerLabel.leadingAnchor.constraint(equalTo: guitarCloud.trailingAnchor, constant: 12),
            powerLabel.topAnchor.constraint(equalTo: guitarCloud.topAnchor),
            powerLabel.trailingAnchor.constraint(equalTo: achievementCard.trailingAnchor, constant: -12),

            powerSubLabel.leadingAnchor.constraint(equalTo: powerLabel.leadingAnchor),
            powerSubLabel.topAnchor.constraint(equalTo: powerLabel.bottomAnchor, constant: 4),
            powerSubLabel.trailingAnchor.constraint(equalTo: powerLabel.trailingAnchor),
            powerSubLabel.bottomAnchor.constraint(equalTo: achievementCard.bottomAnchor, constant: -20),

            // --- Achievements List (Dynamic) ---
            achievementsTitle.topAnchor.constraint(equalTo: achievementCard.bottomAnchor, constant: 28),
            achievementsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            // ⚡️ NEW: StackView Constraints
            achievementsStackView.topAnchor.constraint(equalTo: achievementsTitle.bottomAnchor, constant: 20),
            achievementsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            achievementsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // --- BOTTOM PADDING ---
            bottomPaddingView.topAnchor.constraint(equalTo: achievementsStackView.bottomAnchor, constant: 20),
            bottomPaddingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomPaddingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomPaddingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomPaddingView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func startFloatingAnimation() {
        let floatAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        floatAnimation.fromValue = 0
        floatAnimation.toValue = -12
        floatAnimation.duration = 2.5
        floatAnimation.autoreverses = true
        floatAnimation.repeatCount = .infinity
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        mascotImageView.layer.add(floatAnimation, forKey: "floating")
    }
    
    // MARK: - Actions
    private func setupActions() {
        // Mascot Tap - Navigates to Cloudy Tab (Index 3 assuming that's where the AI tab is)
        let tap = UITapGestureRecognizer(target: self, action: #selector(mascotTapped))
        mascotImageView.addGestureRecognizer(tap)
        
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        bellButton.addTarget(self, action: #selector(bellButtonTapped), for: .touchUpInside)
    }

    @objc private func mascotTapped() {
        // Switch to the Cloudy AI Tab
        self.tabBarController?.selectedIndex = 3
    }

    @objc private func profileButtonTapped() {
        print("Navigating to Profile")
    }
    
    @objc private func bellButtonTapped() {
        print("Navigating to Notifications")
    }
}
