import UIKit

final class ChildHomeViewController: UIViewController {

    // MARK: - UI Elements
    
    // 1. Scroll View & Content Container (Essential for scrolling)
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

    // 6. Progress Section
    private let achievementsTitle = UILabel()
    
    private let habitIcon = UIImageView()
    private let habitLabel = UILabel()
    private let habitProgress = UIProgressView(progressViewStyle: .default)
    private let habitPercentLabel = UILabel()

    private let extraIcon = UIImageView()
    private let extraLabel = UILabel()
    private let extraProgress = UIProgressView(progressViewStyle: .default)
    private let extraPercentLabel = UILabel()
    
    // 7. Padding View (Prevents content from being hidden behind Tab Bar)
    private let bottomPaddingView = UIView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Remove default navigation bar title to use our custom greeting
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupGradient()
        setupUI()
        setupLayout()
        setupActions()
    }

    // CRITICAL: Updates gradient frame when device rotates or layout changes
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        
        // Ensure the scroll view knows how big its content is
        scrollView.contentSize = contentView.bounds.size
    }

    // MARK: - Setup Gradient
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor, // Dark Top
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor  // Blue Bottom
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - Setup UI Components
    private func setupUI() {
        // Greeting
        greetingLabel.text = "Hello Jo."
        greetingLabel.font = UIFont.boldSystemFont(ofSize: 32)
        greetingLabel.textColor = .white

        subGreetingLabel.text = "We hope you have a Great day !!"
        subGreetingLabel.font = UIFont.systemFont(ofSize: 16)
        subGreetingLabel.textColor = UIColor(white: 0.9, alpha: 1)

        // Header Buttons
        bellButton.setImage(UIImage(systemName: "bell.badge"), for: .normal)
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
        // Using system image as fallback if "cloudyy_logo" isn't in Assets
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

        // Progress Section Titles
        achievementsTitle.text = "Your achievements :"
        achievementsTitle.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        achievementsTitle.textColor = .white

        // Habit Row
        habitIcon.image = UIImage(named: "cloudyy_market") ?? UIImage(systemName: "guitars.fill")
        habitIcon.tintColor = .systemYellow
        
        habitLabel.text = "Habits"
        habitLabel.textColor = .white
        
        habitProgress.progress = 0.6
        habitProgress.progressTintColor = UIColor.systemBlue
        habitProgress.trackTintColor = UIColor(white: 1, alpha: 0.3)
        habitProgress.layer.cornerRadius = 4
        habitProgress.clipsToBounds = true
        
        habitPercentLabel.text = "60%"
        habitPercentLabel.textColor = .white

        // Extracurricular Row
        extraIcon.image = UIImage(named: "cloudyy_paint") ?? UIImage(systemName: "guitars.fill")
        extraIcon.tintColor = .systemPink
        
        extraLabel.text = "Extracurricular"
        extraLabel.textColor = .white
        
        extraProgress.progress = 0.6
        extraProgress.progressTintColor = UIColor.systemBlue
        extraProgress.trackTintColor = UIColor(white: 1, alpha: 0.3)
        extraProgress.layer.cornerRadius = 4
        extraProgress.clipsToBounds = true
        
        extraPercentLabel.text = "60%"
        extraPercentLabel.textColor = .white

        // --- Adding to View Hierarchy ---
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add all content elements to ContentView
        [greetingLabel, subGreetingLabel, bellButton, profileButton,
         quoteBubble, mascotImageView, achievementCard,
         achievementsTitle, habitIcon, habitLabel, habitProgress, habitPercentLabel,
         extraIcon, extraLabel, extraProgress, extraPercentLabel,
         bottomPaddingView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // Prepare Layout properties
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        guitarCloud.translatesAutoresizingMaskIntoConstraints = false
        powerLabel.translatesAutoresizingMaskIntoConstraints = false
        powerSubLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Setup Layout (AutoLayout Constraints)
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // 1. ScrollView fills the entire screen
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // 2. ContentView fills ScrollView AND matches width (Vertical Scroll Only)
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
            // Mascot width scales with screen (66%), centered
            mascotImageView.topAnchor.constraint(equalTo: subGreetingLabel.bottomAnchor, constant: 65),
                      mascotImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 40),
                      mascotImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
                      mascotImageView.heightAnchor.constraint(equalTo: mascotImageView.widthAnchor),


            // Quote overlaps mascot slightly
            
            quoteBubble.topAnchor.constraint(equalTo: subGreetingLabel.bottomAnchor, constant: 59),
                       quoteBubble.trailingAnchor.constraint(equalTo: mascotImageView.centerXAnchor, constant: -20),
                       quoteBubble.widthAnchor.constraint(equalToConstant: 180),
                       quoteBubble.heightAnchor.constraint(equalToConstant: 70),

            
            // Quote Text Constraints
            quoteLabel.topAnchor.constraint(equalTo: quoteBubble.topAnchor, constant: 12),
            quoteLabel.leadingAnchor.constraint(equalTo: quoteBubble.leadingAnchor, constant: 16),
            quoteLabel.trailingAnchor.constraint(equalTo: quoteBubble.trailingAnchor, constant: -16),
            quoteLabel.bottomAnchor.constraint(equalTo: quoteBubble.bottomAnchor, constant: -12),

            // --- Achievement Card ---
            achievementCard.topAnchor.constraint(equalTo: mascotImageView.bottomAnchor, constant: 20),
            achievementCard.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            achievementCard.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            
            // Card Internals
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

            // --- Achievements List ---
            achievementsTitle.topAnchor.constraint(equalTo: achievementCard.bottomAnchor, constant: 28),
            achievementsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            // Habit Row
            habitIcon.leadingAnchor.constraint(equalTo: achievementsTitle.leadingAnchor),
            habitIcon.topAnchor.constraint(equalTo: achievementsTitle.bottomAnchor, constant: 20),
            habitIcon.widthAnchor.constraint(equalToConstant: 36),
            habitIcon.heightAnchor.constraint(equalToConstant: 36),

            habitLabel.topAnchor.constraint(equalTo: habitIcon.topAnchor),
            habitLabel.leadingAnchor.constraint(equalTo: habitIcon.trailingAnchor, constant: 10),

            habitProgress.topAnchor.constraint(equalTo: habitLabel.bottomAnchor, constant: 8),
            habitProgress.leadingAnchor.constraint(equalTo: habitLabel.leadingAnchor),
            habitProgress.trailingAnchor.constraint(equalTo: habitPercentLabel.leadingAnchor, constant: -10),
            habitProgress.heightAnchor.constraint(equalToConstant: 8),

            habitPercentLabel.centerYAnchor.constraint(equalTo: habitProgress.centerYAnchor),
            habitPercentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            habitPercentLabel.widthAnchor.constraint(equalToConstant: 40),

            // Extra Row
            extraIcon.leadingAnchor.constraint(equalTo: achievementsTitle.leadingAnchor),
            extraIcon.topAnchor.constraint(equalTo: habitProgress.bottomAnchor, constant: 30),
            extraIcon.widthAnchor.constraint(equalToConstant: 36),
            extraIcon.heightAnchor.constraint(equalToConstant: 36),

            extraLabel.topAnchor.constraint(equalTo: extraIcon.topAnchor),
            extraLabel.leadingAnchor.constraint(equalTo: extraIcon.trailingAnchor, constant: 10),

            extraProgress.topAnchor.constraint(equalTo: extraLabel.bottomAnchor, constant: 8),
            extraProgress.leadingAnchor.constraint(equalTo: extraLabel.leadingAnchor),
            extraProgress.trailingAnchor.constraint(equalTo: extraPercentLabel.leadingAnchor, constant: -10),
            extraProgress.heightAnchor.constraint(equalToConstant: 8),

            extraPercentLabel.centerYAnchor.constraint(equalTo: extraProgress.centerYAnchor),
            extraPercentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            extraPercentLabel.widthAnchor.constraint(equalToConstant: 40),

            // --- BOTTOM PADDING (Fix for Tab Bar Overlap) ---
            // This empty view sits at the bottom and pushes content up by 100 points.
            bottomPaddingView.topAnchor.constraint(equalTo: extraProgress.bottomAnchor, constant: 20),
            bottomPaddingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomPaddingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomPaddingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomPaddingView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    
    private func startFloatingAnimation() {
            // Simple up/down floating animation
            let floatAnimation = CABasicAnimation(keyPath: "transform.translation.y")
            floatAnimation.fromValue = 0
            floatAnimation.toValue = -12 // Move up by 12 points
            floatAnimation.duration = 2.0 // Time for one direction
            floatAnimation.autoreverses = true // Go back down
            floatAnimation.repeatCount = .infinity // Loop forever
            floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut) // Smooth start/stop
            
            mascotImageView.layer.add(floatAnimation, forKey: "floating")
        }
    // MARK: - Actions
    private func setupActions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(mascotTapped))
        mascotImageView.addGestureRecognizer(tap)
    }

    @objc private func mascotTapped() {
        // If you want to open the ChatBot tab (Index 3) programmatically:
        self.tabBarController?.selectedIndex = 3
    }
}
