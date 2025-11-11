import UIKit

final class ChildHomeViewController: UIViewController {

    // MARK: - UI Elements
    private let bgView = UIView()
    private let gradientLayer = CAGradientLayer()

    private let greetingLabel = UILabel()
    private let subGreetingLabel = UILabel()
    private let bellButton = UIButton(type: .system)
    private let profileButton = UIButton(type: .system)

    private let quoteBubble = UIView()
    private let quoteLabel = UILabel()
    private let mascotImageView = UIImageView()

    private let achievementCard = UIView()
    private let guitarCloud = UIImageView()
    private let powerLabel = UILabel()
    private let powerSubLabel = UILabel()

    private let achievementsTitle = UILabel()
    private let habitIcon = UIImageView()
    private let habitLabel = UILabel()
    private let habitProgress = UIProgressView(progressViewStyle: .default)
    private let habitPercentLabel = UILabel()

    private let extraIcon = UIImageView()
    private let extraLabel = UILabel()
    private let extraProgress = UIProgressView(progressViewStyle: .default)
    private let extraPercentLabel = UILabel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupUI()
        setupLayout()
        setupActions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = bgView.bounds
    }

    // MARK: - Setup Gradient
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        bgView.layer.insertSublayer(gradientLayer, at: 0)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgView)

        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: view.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Setup UI
    private func setupUI() {
        // Greeting
        greetingLabel.text = "Hello Jo."
        greetingLabel.font = UIFont.boldSystemFont(ofSize: 32)
        greetingLabel.textColor = .white

        subGreetingLabel.text = "We hope you have a Great day !!"
        subGreetingLabel.font = UIFont.systemFont(ofSize: 16)
        subGreetingLabel.textColor = UIColor(white: 0.9, alpha: 1)

        // Notification and Profile buttons
        bellButton.setImage(UIImage(systemName: "bell.badge"), for: .normal)
        bellButton.tintColor = .white

        profileButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
        profileButton.tintColor = .white

        // Quote bubble
        quoteBubble.backgroundColor = UIColor(red: 240/255, green: 228/255, blue: 241/255, alpha: 1)
        quoteBubble.layer.cornerRadius = 20
        quoteBubble.layer.masksToBounds = true
        quoteBubble.layer.shadowColor = UIColor.black.cgColor
        quoteBubble.layer.shadowOpacity = 0.1
        quoteBubble.layer.shadowRadius = 4
        quoteBubble.layer.shadowOffset = CGSize(width: 0, height: 2)

        quoteLabel.text = "Let’s Finish our Missions today !!"
        quoteLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        quoteLabel.textColor = .black
        quoteLabel.numberOfLines = 0
        quoteLabel.textAlignment = .center
        quoteLabel.lineBreakMode = .byWordWrapping

        quoteBubble.addSubview(quoteLabel)
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                quoteLabel.topAnchor.constraint(equalTo: quoteBubble.topAnchor, constant: 12),
                quoteLabel.leadingAnchor.constraint(equalTo: quoteBubble.leadingAnchor, constant: 16),
                quoteLabel.trailingAnchor.constraint(equalTo: quoteBubble.trailingAnchor, constant: -16),
                quoteLabel.bottomAnchor.constraint(equalTo: quoteBubble.bottomAnchor, constant: -12)
            ])

        // Mascot
        mascotImageView.image = UIImage(named: "imgCloudMain")
        mascotImageView.contentMode = .scaleAspectFit
        mascotImageView.isUserInteractionEnabled = true

        // Power card
        achievementCard.backgroundColor = UIColor(white: 0.96, alpha: 0.95)
        achievementCard.layer.cornerRadius = 16
        achievementCard.layer.shadowColor = UIColor.black.cgColor
        achievementCard.layer.shadowOpacity = 0.1
        achievementCard.layer.shadowRadius = 6
        achievementCard.layer.shadowOffset = CGSize(width: 0, height: 2)

        guitarCloud.image = UIImage(named: "imgCloudGuitar")
        guitarCloud.contentMode = .scaleAspectFit

        powerLabel.text = "Your cleanup yesterday created\n15 minutes of calm for Mom."
        powerLabel.font = UIFont.systemFont(ofSize: 14)
        powerLabel.numberOfLines = 2
        powerLabel.textColor = .black

        powerSubLabel.text = "That's your power!"
        powerSubLabel.font = UIFont.boldSystemFont(ofSize: 16)
        powerSubLabel.textColor = .black

        achievementCard.addSubview(guitarCloud)
        achievementCard.addSubview(powerLabel)
        achievementCard.addSubview(powerSubLabel)

        guitarCloud.translatesAutoresizingMaskIntoConstraints = false
        powerLabel.translatesAutoresizingMaskIntoConstraints = false
        powerSubLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            guitarCloud.leadingAnchor.constraint(equalTo: achievementCard.leadingAnchor, constant: 12),
            guitarCloud.centerYAnchor.constraint(equalTo: achievementCard.centerYAnchor),
            guitarCloud.widthAnchor.constraint(equalToConstant: 50),
            guitarCloud.heightAnchor.constraint(equalToConstant: 50),

            powerLabel.leadingAnchor.constraint(equalTo: guitarCloud.trailingAnchor, constant: 36),
            powerLabel.topAnchor.constraint(equalTo: achievementCard.topAnchor, constant: 20),
            powerLabel.trailingAnchor.constraint(equalTo: achievementCard.trailingAnchor, constant: -12),

            powerSubLabel.leadingAnchor.constraint(equalTo: powerLabel.leadingAnchor),
            powerSubLabel.topAnchor.constraint(equalTo: powerLabel.bottomAnchor, constant: 4),
            powerSubLabel.trailingAnchor.constraint(equalTo: powerLabel.trailingAnchor)
        ])

        // Achievements
        achievementsTitle.text = "Your achievements :"
        achievementsTitle.font = UIFont.systemFont(ofSize: 22, weight: .bold)

        achievementsTitle.textColor = .white

        habitIcon.image = UIImage(named: "imgCloudGuitar")
        habitLabel.text = "Habits"
        habitLabel.textColor = .white

        habitProgress.progress = 0.6
        habitProgress.progressTintColor = UIColor.systemBlue
        habitProgress.trackTintColor = UIColor(white: 1, alpha: 0.3)

        habitPercentLabel.text = "60%"
        habitPercentLabel.textColor = .white

        extraIcon.image = UIImage(named: "imgCloudGuitar")
        extraLabel.text = "Extracurricular"
        extraLabel.textColor = .white

        extraProgress.progress = 0.6
        extraProgress.progressTintColor = UIColor.systemBlue
        extraProgress.trackTintColor = UIColor(white: 1, alpha: 0.3)

        extraPercentLabel.text = "60%"
        extraPercentLabel.textColor = .white

        // Add all to view
        [greetingLabel, subGreetingLabel, bellButton, profileButton,
         quoteBubble, mascotImageView, achievementCard,
         achievementsTitle, habitIcon, habitLabel, habitProgress, habitPercentLabel,
         extraIcon, extraLabel, extraProgress, extraPercentLabel
        ].forEach { view.addSubview($0) }
    }

    // MARK: - Layout
    private func setupLayout() {
        [greetingLabel, subGreetingLabel, bellButton, profileButton,
         quoteBubble, mascotImageView, achievementCard,
         achievementsTitle, habitIcon, habitLabel, habitProgress, habitPercentLabel,
         extraIcon, extraLabel, extraProgress, extraPercentLabel
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            greetingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            subGreetingLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 6),
            subGreetingLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),

            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileButton.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 26),
            profileButton.heightAnchor.constraint(equalToConstant: 26),

            bellButton.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -16),
            bellButton.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor),
            bellButton.widthAnchor.constraint(equalToConstant: 26),
            bellButton.heightAnchor.constraint(equalToConstant: 26),

            quoteBubble.bottomAnchor.constraint(equalTo: mascotImageView.topAnchor, constant: 70),
            quoteBubble.leadingAnchor.constraint(equalTo: mascotImageView.leadingAnchor, constant: -60),
            quoteBubble.widthAnchor.constraint(equalToConstant: 180),
            quoteBubble.heightAnchor.constraint(equalToConstant: 80),
            
            

            mascotImageView.topAnchor.constraint(equalTo: subGreetingLabel.bottomAnchor, constant: 60),
            mascotImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            mascotImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.66),
            mascotImageView.heightAnchor.constraint(equalTo: mascotImageView.widthAnchor),

            achievementCard.topAnchor.constraint(equalTo: mascotImageView.bottomAnchor, constant: 20),
            achievementCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            achievementCard.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            achievementCard.heightAnchor.constraint(equalToConstant: 100),

            achievementsTitle.topAnchor.constraint(equalTo: achievementCard.bottomAnchor, constant: 28),
            achievementsTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // Habits layout (vertical)
           
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
                habitPercentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
           


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
                extraPercentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openChat))
        mascotImageView.addGestureRecognizer(tap)
    }

    @objc private func openChat() {
        let chatVC = ChatBotViewController()
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
