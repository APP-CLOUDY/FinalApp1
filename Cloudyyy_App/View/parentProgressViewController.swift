import UIKit

class ParentProgressViewController: UIViewController {
    
    // MARK: - Gradient
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private var kidsStackView: UIStackView!
    private let notificationButton = UIButton(type: .system)
    private let profileButton = UIButton(type: .system)
    
    private let progressCard = UIView()
    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    private let percentageLabel = UILabel()
    private let taskCountLabel = UILabel()
    private let todayPointsTitle = UILabel()
    private let totalPointsTitle = UILabel()
    private let todayPointsValue = UILabel()
    private let totalPointsValue = UILabel()
    
    private let recentLabel = UILabel()
    private let recentBox = UIView()
    
    private let effortsLabel = UILabel()
    private let habitsLabel = UILabel()
    private let homeworkLabel = UILabel()
    private let habitsProgress = UIProgressView()
    private let homeworkProgress = UIProgressView()
    
    // MARK: - State Tracking
    private var lastKnownCardSize: CGSize = .zero
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupUI()
        layoutUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateGradientFrame()
        
        // Redraw circle when size changes
        if progressCard.bounds.size != lastKnownCardSize {
            lastKnownCardSize = progressCard.bounds.size
            setupProgressCircle()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }) { _ in
            self.setupProgressCircle()
        }
    }
    
    // MARK: - Gradient Background
    private func setupGradientBackground() {
        gradientLayer.colors = [
            UIColor(red: 14/255, green: 18/255, blue: 46/255, alpha: 1).cgColor,
            UIColor(red: 5/255, green: 9/255, blue: 30/255, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func updateGradientFrame() {
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    @objc private func kidsTapped() {
        print("Kids dropdown tapped")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Header
        titleLabel.text = "Progress"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = .white
        
        let kidsLabel = UILabel()
        kidsLabel.text = "Kids"
        kidsLabel.textColor = .white
        kidsLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        chevronImageView.tintColor = .white
        chevronImageView.contentMode = .scaleAspectFit
        
        let kidsStack = UIStackView(arrangedSubviews: [kidsLabel, chevronImageView])
        kidsStack.axis = .horizontal
        kidsStack.alignment = .center
        kidsStack.spacing = 4
        kidsStack.isUserInteractionEnabled = true
        kidsStack.translatesAutoresizingMaskIntoConstraints = false
        kidsStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(kidsTapped)))
        kidsStackView = kidsStack
        
        notificationButton.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        notificationButton.tintColor = .white
        
        profileButton.setImage(UIImage(systemName: "person.crop.circle.fill"), for: .normal)
        profileButton.tintColor = .white
        
        // Add views
        [titleLabel, kidsStackView, notificationButton, profileButton,
         progressCard, recentLabel, recentBox, effortsLabel,
         habitsLabel, habitsProgress, homeworkLabel, homeworkProgress].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        // Progress Card
        progressCard.backgroundColor = UIColor(red: 22/255, green: 26/255, blue: 58/255, alpha: 1)
        progressCard.layer.cornerRadius = 20
        progressCard.clipsToBounds = true
        
        [percentageLabel, taskCountLabel, todayPointsTitle, totalPointsTitle,
         todayPointsValue, totalPointsValue].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            progressCard.addSubview($0)
        }
        
        percentageLabel.text = "40%"
        percentageLabel.font = UIFont.boldSystemFont(ofSize: 34)
        percentageLabel.textColor = .white
        percentageLabel.textAlignment = .center
        
        taskCountLabel.text = "4/11 Tasks Done"
        taskCountLabel.font = UIFont.systemFont(ofSize: 14)
        taskCountLabel.textColor = .lightGray
        taskCountLabel.textAlignment = .center
        
        todayPointsTitle.text = "Today Points"
        todayPointsTitle.font = UIFont.systemFont(ofSize: 14)
        todayPointsTitle.textColor = .lightGray
        
        totalPointsTitle.text = "Total Points"
        totalPointsTitle.font = UIFont.systemFont(ofSize: 14)
        totalPointsTitle.textColor = .lightGray
        
        todayPointsValue.text = "220 ⭐️"
        todayPointsValue.font = UIFont.boldSystemFont(ofSize: 22)
        todayPointsValue.textColor = .white
        
        totalPointsValue.text = "550 ⭐️"
        totalPointsValue.font = UIFont.boldSystemFont(ofSize: 22)
        totalPointsValue.textColor = .white
        
        // Recent Achievements
        recentLabel.text = "Recent Achievement"
        recentLabel.font = UIFont.boldSystemFont(ofSize: 18)
        recentLabel.textColor = .white
        
        recentBox.backgroundColor = UIColor(red: 28/255, green: 32/255, blue: 70/255, alpha: 1)
        recentBox.layer.cornerRadius = 15
        
        let cartoonLabel = UILabel()
        cartoonLabel.text = "Cartoon time - 30 minutes"
        cartoonLabel.font = UIFont.boldSystemFont(ofSize: 16)
        cartoonLabel.textColor = .white
        
        let cartoonSub = UILabel()
        cartoonSub.text = "8:51 AM   👤 Bob"
        cartoonSub.font = UIFont.systemFont(ofSize: 13)
        cartoonSub.textColor = .lightGray
        
        let divider = UIView()
        divider.backgroundColor = UIColor.darkGray.withAlphaComponent(0.4)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let cookieLabel = UILabel()
        cookieLabel.text = "Chocolate cookie"
        cookieLabel.font = UIFont.boldSystemFont(ofSize: 16)
        cookieLabel.textColor = .white
        
        let cookieSub = UILabel()
        cookieSub.text = "Thursday   👤 Jonesh"
        cookieSub.font = UIFont.systemFont(ofSize: 13)
        cookieSub.textColor = .lightGray
        
        [cartoonLabel, cartoonSub, divider, cookieLabel, cookieSub].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            recentBox.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            cartoonLabel.topAnchor.constraint(equalTo: recentBox.topAnchor, constant: 12),
            cartoonLabel.leadingAnchor.constraint(equalTo: recentBox.leadingAnchor, constant: 12),
            cartoonSub.topAnchor.constraint(equalTo: cartoonLabel.bottomAnchor, constant: 2),
            cartoonSub.leadingAnchor.constraint(equalTo: cartoonLabel.leadingAnchor),
            divider.topAnchor.constraint(equalTo: cartoonSub.bottomAnchor, constant: 8),
            divider.leadingAnchor.constraint(equalTo: recentBox.leadingAnchor, constant: 12),
            divider.trailingAnchor.constraint(equalTo: recentBox.trailingAnchor, constant: -12),
            cookieLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 8),
            cookieLabel.leadingAnchor.constraint(equalTo: cartoonLabel.leadingAnchor),
            cookieSub.topAnchor.constraint(equalTo: cookieLabel.bottomAnchor, constant: 2),
            cookieSub.leadingAnchor.constraint(equalTo: cartoonLabel.leadingAnchor)
        ])
        
        // Efforts
        effortsLabel.text = "Their Efforts"
        effortsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        effortsLabel.textColor = .white
        
        habitsLabel.text = "Habits 1/5"
        habitsLabel.textColor = .white
        homeworkLabel.text = "Homework 2/3"
        homeworkLabel.textColor = .white
        
        habitsProgress.progress = 0.2
        homeworkProgress.progress = 0.6
        habitsProgress.progressTintColor = .systemBlue
        homeworkProgress.progressTintColor = .systemBlue
        habitsProgress.trackTintColor = .darkGray
        homeworkProgress.trackTintColor = .darkGray
    }
    
    // MARK: - Half-Circle Progress
    private func setupProgressCircle() {
        trackLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()
        
        let cardBounds = progressCard.bounds
        guard cardBounds.width > 0 && cardBounds.height > 0 else { return }
        
        // Center slightly below the top for half-circle look
        let center = CGPoint(x: cardBounds.midX, y: cardBounds.height * 0.55)
        
        // Use half-circle radius
        let radius = min(cardBounds.width, cardBounds.height) / 2.5
        
        // Create half-circle path (bottom arc)
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: .pi,   // start at left
            endAngle: 0,       // end at right
            clockwise: true
        )
        
        // Track layer (background arc)
        trackLayer.path = path.cgPath
        trackLayer.strokeColor = UIColor.darkGray.withAlphaComponent(0.4).cgColor
        trackLayer.lineWidth = 12
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        progressCard.layer.addSublayer(trackLayer)
        
        // Progress layer (foreground arc)
        progressLayer.path = path.cgPath
        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        progressLayer.lineWidth = 12
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0.4
        progressCard.layer.addSublayer(progressLayer)
    }
    
    // MARK: - Layout
    private func layoutUI() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            kidsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -2),
            kidsStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            profileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            profileButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            notificationButton.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -15),
            notificationButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            progressCard.topAnchor.constraint(equalTo: kidsStackView.bottomAnchor, constant: 12),
            progressCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            progressCard.heightAnchor.constraint(equalToConstant: 250),
            
            percentageLabel.centerXAnchor.constraint(equalTo: progressCard.centerXAnchor),
            percentageLabel.topAnchor.constraint(equalTo: progressCard.topAnchor, constant: 60),
            
            taskCountLabel.centerXAnchor.constraint(equalTo: progressCard.centerXAnchor),
            taskCountLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 4),
            
            todayPointsTitle.leadingAnchor.constraint(equalTo: progressCard.leadingAnchor, constant: 50),
            todayPointsTitle.topAnchor.constraint(equalTo: taskCountLabel.bottomAnchor, constant: 30),
            
            todayPointsValue.centerXAnchor.constraint(equalTo: todayPointsTitle.centerXAnchor),
            todayPointsValue.topAnchor.constraint(equalTo: todayPointsTitle.bottomAnchor, constant: 4),
            
            totalPointsTitle.trailingAnchor.constraint(equalTo: progressCard.trailingAnchor, constant: -50),
            totalPointsTitle.topAnchor.constraint(equalTo: todayPointsTitle.topAnchor),
            
            totalPointsValue.centerXAnchor.constraint(equalTo: totalPointsTitle.centerXAnchor),
            totalPointsValue.topAnchor.constraint(equalTo: totalPointsTitle.bottomAnchor, constant: 4),
            
            recentLabel.topAnchor.constraint(equalTo: progressCard.bottomAnchor, constant: 25),
            recentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            recentBox.topAnchor.constraint(equalTo: recentLabel.bottomAnchor, constant: 10),
            recentBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recentBox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            recentBox.heightAnchor.constraint(equalToConstant: 120),
            
            effortsLabel.topAnchor.constraint(equalTo: recentBox.bottomAnchor, constant: 25),
            effortsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            habitsLabel.topAnchor.constraint(equalTo: effortsLabel.bottomAnchor, constant: 15),
            habitsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            habitsProgress.topAnchor.constraint(equalTo: habitsLabel.bottomAnchor, constant: 6),
            habitsProgress.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            habitsProgress.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            homeworkLabel.topAnchor.constraint(equalTo: habitsProgress.bottomAnchor, constant: 15),
            homeworkLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            homeworkProgress.topAnchor.constraint(equalTo: homeworkLabel.bottomAnchor, constant: 6),
            homeworkProgress.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            homeworkProgress.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            homeworkProgress.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
}
