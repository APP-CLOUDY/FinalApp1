import UIKit
import ImagePlayground // Required for the AI features (iOS 18.2+)

final class RewardsViewController: UIViewController {

    // MARK: - Properties
    private var isSpringOnActive: Bool = false
    
    // Playground State
    private var isPlaygroundExpanded: Bool = false
    private var playgroundWidthConstraint: NSLayoutConstraint?

    // MARK: - UI Elements
    private let gradientLayer = CAGradientLayer()

    // --- Top Bar ---
    private let topBarContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Rewards Hub"
        lb.font = .systemFont(ofSize: 28, weight: .bold)
        lb.textColor = .white
        return lb
    }()

    // Coin Badge Container
    private let coinBadgeView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(red: 253/255, green: 186/255, blue: 70/255, alpha: 1.0)
        v.layer.cornerRadius = 12.5
        return v
    }()
    
    private let starIcon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .black)
        iv.image = UIImage(systemName: "star.fill", withConfiguration: config)
        iv.tintColor = UIColor(red: 62/255, green: 52/255, blue: 37/255, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let coinLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "207"
        lb.font = .systemFont(ofSize: 13, weight: .bold)
        lb.textColor = UIColor(red: 62/255, green: 52/255, blue: 37/255, alpha: 1.0)
        return lb
    }()

    // Notification Button
    private let bellButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .light)
        b.setImage(UIImage(systemName: "bell", withConfiguration: config), for: .normal)
        b.tintColor = .white
        b.imageView?.contentMode = .scaleAspectFit
        return b
    }()

    private let profileButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .light)
        b.setImage(UIImage(systemName: "person.circle", withConfiguration: config), for: .normal)
        b.tintColor = .white
        b.imageView?.contentMode = .scaleAspectFit
        return b
    }()
    
    // --- Scroll View ---
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        // Important: Dismiss keyboard when dragging scrollview
        sv.keyboardDismissMode = .onDrag
        return sv
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // --- Content Elements ---
    // Note: Assuming StreakCardView is defined in your project
    private let streakCard: StreakCardView = {
        let v = StreakCardView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.2
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 8
        return v
    }()

    private let quickLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Quick Rewards"
        lb.font = .systemFont(ofSize: 18, weight: .semibold)
        lb.textColor = .white
        return lb
    }()

    private lazy var quickCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        // Note: Ensure RewardCell is defined in your project
        cv.register(RewardCell.self, forCellWithReuseIdentifier: RewardCell.reuseID)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    // --- Segment Control Elements ---
    private let segmentContainer: UIView = {
            let v = UIView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.layer.cornerRadius = 24
            v.backgroundColor = UIColor(red: 37/255, green: 42/255, blue: 64/255, alpha: 1.0)
            v.clipsToBounds = true
            return v
        }()

        private let segmentIndicator: UIView = {
            let v = UIView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.backgroundColor = .white
            v.layer.cornerRadius = 20
            v.layer.shadowColor = UIColor.black.cgColor
            v.layer.shadowOffset = CGSize(width: 0, height: 2)
            v.layer.shadowRadius = 4
            v.layer.shadowOpacity = 0.2
            v.layer.masksToBounds = false
            return v
        }()

        private let leftSegment: UIButton = {
            let b = UIButton(type: .system)
            b.setTitle("Dream It", for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
            b.setTitleColor(.black, for: .normal)
            b.translatesAutoresizingMaskIntoConstraints = false
            return b
        }()

        private let rightSegment: UIButton = {
            let b = UIButton(type: .system)
            b.setTitle("Spring On", for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            b.setTitleColor(.white, for: .normal)
            b.translatesAutoresizingMaskIntoConstraints = false
            return b
        }()
    
    private var indicatorLeadingConstraint: NSLayoutConstraint?

    // --- Carousel ---
    private let carouselCard: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 24
        iv.backgroundColor = UIColor(white: 1.0, alpha: 0.06)
        iv.isUserInteractionEnabled = true
        return iv
    }()

    private let carouselTitle: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Build a cycle"
        lb.font = .systemFont(ofSize: 18, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .left
        return lb
    }()

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.numberOfPages = 4
        pc.currentPage = 0
        pc.pageIndicatorTintColor = UIColor(white: 1.0, alpha: 0.3)
        pc.currentPageIndicatorTintColor = .white
        return pc
    }()
    
    private let bottomPaddingView = UIView()

    // --- PLAYGROUND UI (The Magic Button) ---
    
    private let playgroundContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(white: 0.1, alpha: 0.95) // Dark background
        v.layer.cornerRadius = 25 // Height will be 50
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(white: 1, alpha: 0.2).cgColor
        v.clipsToBounds = true
        return v
    }()

    private let playgroundButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        b.setImage(UIImage(systemName: "sparkles", withConfiguration: config), for: .normal)
        b.tintColor = .systemYellow
        b.isUserInteractionEnabled = false // Let container handle the tap
        return b
    }()

    private let playgroundTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Imagine a dragon..."
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(
            string: "Imagine a dragon...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        tf.font = .systemFont(ofSize: 16)
        tf.alpha = 0 // Hidden initially
        tf.returnKeyType = .done
        tf.autocorrectionType = .no
        return tf
    }()

    private let playgroundSendButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        b.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config), for: .normal)
        b.tintColor = .white
        b.alpha = 0 // Hidden initially
        return b
    }()

    // --- Data ---
    private let carouselImages: [UIImage?] = [
        UIImage(named:"Cycle"),
        UIImage(named: "springon"),
        UIImage(systemName: "gift.fill"),
        UIImage(systemName: "headphones")
    ]

    private let quickItems: [(title: String, image: UIImage?)] = [
        ("Screen Time", UIImage( named: "ScreenTime")),
        ("Cartoon", UIImage(named: "cartoon 1")),
        ("Treats", UIImage(named: "treat")),
        ("Family", UIImage(named: "f-1"))
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupViews()
        
        // 1. CRITICAL: Setup playground UI *BEFORE* constraints to prevent crash
        setupPlaygroundUI()
        
        // 2. Setup Constraints (now safe)
        setupConstraints()
        
        setupActions()
        
        // 3. Ensure Floating Button is on top
        view.bringSubviewToFront(playgroundContainer)
        
        carouselCard.image = carouselImages.first ?? UIImage()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        carouselCard.addGestureRecognizer(tapGesture)
        
        selectLeft()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentIndicator.layer.cornerRadius = 14
        gradientLayer.frame = view.bounds
    }

    // MARK: - Setup
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor

        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupViews() {
        view.addSubview(topBarContainer)
        topBarContainer.addSubview(titleLabel)
        
        topBarContainer.addSubview(coinBadgeView)
        coinBadgeView.addSubview(starIcon)
        coinBadgeView.addSubview(coinLabel)
        
        topBarContainer.addSubview(bellButton)
        topBarContainer.addSubview(profileButton)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(streakCard)
        contentView.addSubview(quickLabel)
        contentView.addSubview(quickCollectionView)
        
        contentView.addSubview(segmentContainer)
        segmentContainer.addSubview(segmentIndicator)
        segmentContainer.addSubview(leftSegment)
        segmentContainer.addSubview(rightSegment)
        
        contentView.addSubview(carouselCard)
        contentView.addSubview(carouselTitle)
        contentView.addSubview(pageControl)
        
        bottomPaddingView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomPaddingView)
        
        quickCollectionView.delegate = self
    }

    private func setupPlaygroundUI() {
        // Add to main view so it floats above scrollview
        view.addSubview(playgroundContainer)
        playgroundContainer.addSubview(playgroundButton)
        playgroundContainer.addSubview(playgroundTextField)
        playgroundContainer.addSubview(playgroundSendButton)
        
        // Delegate for keyboard return
        playgroundTextField.delegate = self
        
        // 4. FIX: Add tap gesture to the entire black circle
        let containerTap = UITapGestureRecognizer(target: self, action: #selector(togglePlaygroundInput))
        playgroundContainer.addGestureRecognizer(containerTap)
        playgroundContainer.isUserInteractionEnabled = true
    }

    private func setupConstraints() {
        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // --- Top Bar ---
            topBarContainer.topAnchor.constraint(equalTo: safe.topAnchor, constant: 12),
            topBarContainer.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            topBarContainer.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            topBarContainer.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.leadingAnchor.constraint(equalTo: topBarContainer.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),

            // Profile
            profileButton.trailingAnchor.constraint(equalTo: topBarContainer.trailingAnchor),
            profileButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 25),
            profileButton.heightAnchor.constraint(equalToConstant: 25),

            // Bell
            bellButton.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -16),
            bellButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            bellButton.widthAnchor.constraint(equalToConstant: 25),
            bellButton.heightAnchor.constraint(equalToConstant: 25),
 
            // Coin Badge
            coinBadgeView.trailingAnchor.constraint(equalTo: bellButton.leadingAnchor, constant: -12),
            coinBadgeView.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            coinBadgeView.heightAnchor.constraint(equalToConstant: 25),
            coinBadgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            starIcon.leadingAnchor.constraint(equalTo: coinBadgeView.leadingAnchor, constant: 10),
            starIcon.centerYAnchor.constraint(equalTo: coinBadgeView.centerYAnchor),
            starIcon.widthAnchor.constraint(equalToConstant: 12),
            starIcon.heightAnchor.constraint(equalToConstant: 12),
            
            coinLabel.leadingAnchor.constraint(equalTo: starIcon.trailingAnchor, constant: 4),
            coinLabel.trailingAnchor.constraint(equalTo: coinBadgeView.trailingAnchor, constant: -10),
            coinLabel.centerYAnchor.constraint(equalTo: coinBadgeView.centerYAnchor),
            
            // --- Scroll View ---
            scrollView.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // --- Streak Card ---
            streakCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            streakCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            streakCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            streakCard.heightAnchor.constraint(equalToConstant: 143),

            // --- Quick Rewards ---
            quickLabel.topAnchor.constraint(equalTo: streakCard.bottomAnchor, constant: 24),
            quickLabel.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor),

            quickCollectionView.topAnchor.constraint(equalTo: quickLabel.bottomAnchor, constant: 12),
            quickCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            quickCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quickCollectionView.heightAnchor.constraint(equalToConstant: 110),

            // --- Segment Control ---
            segmentContainer.topAnchor.constraint(equalTo: quickCollectionView.bottomAnchor, constant: 16),
            segmentContainer.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor),
            segmentContainer.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor),
            segmentContainer.heightAnchor.constraint(equalToConstant: 36),

            segmentIndicator.topAnchor.constraint(equalTo: segmentContainer.topAnchor, constant: 4),
            segmentIndicator.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor, constant: -4),
            segmentIndicator.widthAnchor.constraint(equalTo: segmentContainer.widthAnchor, multiplier: 0.5, constant: -4),
            
            leftSegment.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor),
            leftSegment.topAnchor.constraint(equalTo: segmentContainer.topAnchor),
            leftSegment.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor),
            leftSegment.widthAnchor.constraint(equalTo: segmentContainer.widthAnchor, multiplier: 0.5),

            rightSegment.trailingAnchor.constraint(equalTo: segmentContainer.trailingAnchor),
            rightSegment.topAnchor.constraint(equalTo: segmentContainer.topAnchor),
            rightSegment.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor),
            rightSegment.widthAnchor.constraint(equalTo: segmentContainer.widthAnchor, multiplier: 0.5),

            // --- Carousel ---
            carouselCard.topAnchor.constraint(equalTo: segmentContainer.bottomAnchor, constant: 24),
            carouselCard.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor),
            carouselCard.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor),
            carouselCard.heightAnchor.constraint(equalToConstant: 180),

            carouselTitle.topAnchor.constraint(equalTo: carouselCard.bottomAnchor, constant: 16),
            carouselTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            pageControl.topAnchor.constraint(equalTo: carouselTitle.bottomAnchor, constant: 5),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Bottom padding
            bottomPaddingView.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 20),
            bottomPaddingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomPaddingView.heightAnchor.constraint(equalToConstant: 100), // Extra space for FAB
            
            // --- PLAYGROUND CONSTRAINTS ---
            // Attached to keyboardLayoutGuide to move up when keyboard shows
            playgroundContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -20),
            playgroundContainer.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            playgroundContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // Icon (Sparkles)
            playgroundButton.trailingAnchor.constraint(equalTo: playgroundContainer.trailingAnchor, constant: -3),
            playgroundButton.centerYAnchor.constraint(equalTo: playgroundContainer.centerYAnchor),
            playgroundButton.widthAnchor.constraint(equalToConstant: 44),
            playgroundButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Send Button
            playgroundSendButton.trailingAnchor.constraint(equalTo: playgroundButton.leadingAnchor, constant: -4),
            playgroundSendButton.centerYAnchor.constraint(equalTo: playgroundContainer.centerYAnchor),
            playgroundSendButton.widthAnchor.constraint(equalToConstant: 30),
            playgroundSendButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Text Field
            playgroundTextField.leadingAnchor.constraint(equalTo: playgroundContainer.leadingAnchor, constant: 20),
            playgroundTextField.trailingAnchor.constraint(equalTo: playgroundSendButton.leadingAnchor, constant: -8),
            playgroundTextField.centerYAnchor.constraint(equalTo: playgroundContainer.centerYAnchor),
            playgroundTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Initial Width Constraint (Circle size)
        playgroundWidthConstraint = playgroundContainer.widthAnchor.constraint(equalToConstant: 50)
        playgroundWidthConstraint?.isActive = true
        
        indicatorLeadingConstraint = segmentIndicator.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor, constant: 4)
        indicatorLeadingConstraint?.isActive = true
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        leftSegment.addTarget(self, action: #selector(selectLeft), for: .touchUpInside)
        rightSegment.addTarget(self, action: #selector(selectRight), for: .touchUpInside)
        
        bellButton.addTarget(self, action: #selector(bellTapped), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        
        // Playground Actions (Send button only)
        playgroundSendButton.addTarget(self, action: #selector(generateImageTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func selectLeft() {
        isSpringOnActive = false
        animateSegmentChange()
        
        leftSegment.setTitleColor(.black, for: .normal)
        leftSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        
        rightSegment.setTitleColor(.white, for: .normal)
        rightSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        
        let image = carouselImages.first ?? UIImage(systemName: "bicycle")
        updateCarouselContent(title: "Build a cycle", image: image)
    }

    @objc private func selectRight() {
        isSpringOnActive = true
        animateSegmentChange()
        
        rightSegment.setTitleColor(.black, for: .normal)
        rightSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        
        leftSegment.setTitleColor(.white, for: .normal)
        leftSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        
        var image: UIImage?
        if carouselImages.count > 1 {
            image = carouselImages[1]
        } else {
            image = UIImage(systemName: "sun.max.fill")
        }
        
        updateCarouselContent(title: "Spring Rewards", image: image)
    }
    
    @objc private func bellTapped() {
        print("Navigating to Notifications")
        let vc = NotificationViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func profileTapped() {
        print("Navigating to Profile")
        let vc = ProfileViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Playground Actions
    
    @objc private func togglePlaygroundInput() {
        isPlaygroundExpanded.toggle()
        
        // Expand to fit screen width minus padding, or collapse to circle
        let expandedWidth = view.frame.width - 40 // 20 padding each side
        let newWidth: CGFloat = isPlaygroundExpanded ? expandedWidth : 50
        
        playgroundWidthConstraint?.constant = newWidth
        
        // Animate
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            // Reveal text field and send button
            self.playgroundTextField.alpha = self.isPlaygroundExpanded ? 1.0 : 0.0
            self.playgroundSendButton.alpha = self.isPlaygroundExpanded ? 1.0 : 0.0
            
            // Rotate the sparkles icon for effect
            let angle = self.isPlaygroundExpanded ? CGFloat.pi / 2 : 0
            self.playgroundButton.transform = CGAffineTransform(rotationAngle: angle)
            
        } completion: { _ in
            if self.isPlaygroundExpanded {
                self.playgroundTextField.becomeFirstResponder()
            } else {
                self.playgroundTextField.resignFirstResponder()
                self.playgroundTextField.text = "" // Clear text
            }
        }
    }

    @objc private func generateImageTapped() {
            guard let text = playgroundTextField.text, !text.isEmpty else { return }
            
            togglePlaygroundInput()
            
            // 1. Real Device Check
            if #available(iOS 18.2, *), ImagePlaygroundViewController.isAvailable {
                 let playgroundVC = ImagePlaygroundViewController()
                 playgroundVC.delegate = self
                 playgroundVC.concepts = [.text(text)]
                 present(playgroundVC, animated: true)
            }
            // 2. Simulator: Search for the keyword!
            else {
                print("⚠️ Simulator: Searching for '\(text)'...")
                let alert = UIAlertController(title: "Mocking AI...", message: "Searching for '\(text)'...", preferredStyle: .alert)
                present(alert, animated: true)
                
                // CLEAN THE TEXT: Remove spaces so URL works (e.g. "Cute Dragon" -> "Cute,Dragon")
                let safeText = text.replacingOccurrences(of: " ", with: ",")
                
                // USE LOREMFLICKR: It finds images based on keywords
                // URL Structure: https://loremflickr.com/width/height/keywords
                guard let searchURL = URL(string: "https://loremflickr.com/800/600/\(safeText)") else { return }
                
                // Add a cache buster so we don't get the same image twice
                let finalURL = URL(string: "\(searchURL.absoluteString)?random=\(Int.random(in: 1...1000))")!
                
                URLSession.shared.dataTask(with: finalURL) { [weak self] data, response, error in
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true)
                        
                        if let data = data, let realImage = UIImage(data: data) {
                            
                            self?.updateCarouselContent(title: "Mock: \(text)", image: realImage)
                            
                            // Save to Simulator Gallery
                            UIImageWriteToSavedPhotosAlbum(realImage, nil, nil, nil)
                            
                        } else {
                            // Fallback if no image found
                            let fallback = UIImage(systemName: "photo.badge.exclamationmark")
                            self?.updateCarouselContent(title: "Not Found", image: fallback)
                        }
                    }
                }.resume()
            }
        }
    
    // MARK: - Helpers
    private func updateCarouselContent(title: String, image: UIImage?) {
        self.carouselTitle.text = title
        UIView.transition(with: carouselCard, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.carouselCard.image = image
        }, completion: nil)
    }
    
    private func animateSegmentChange() {
        if isSpringOnActive {
            segmentContainer.layoutIfNeeded()
            indicatorLeadingConstraint?.isActive = false
            indicatorLeadingConstraint = segmentIndicator.trailingAnchor.constraint(equalTo: segmentContainer.trailingAnchor, constant: -4)
            indicatorLeadingConstraint?.isActive = true
        } else {
            segmentContainer.layoutIfNeeded()
            indicatorLeadingConstraint?.isActive = false
            indicatorLeadingConstraint = segmentIndicator.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor, constant: 4)
            indicatorLeadingConstraint?.isActive = true
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.segmentContainer.layoutIfNeeded()
        }
    }
    
    @objc private func handleCardTap() {
        if isSpringOnActive {
            let vc = SpringOnChildViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = ChildDreamItViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Image Playground Delegate
extension RewardsViewController: ImagePlaygroundViewController.Delegate {
    
    // This runs ONLY on a Real Device when AI finishes
    func imagePlaygroundViewController(_ viewController: ImagePlaygroundViewController, didCreateImageAt imageURL: URL) {
        
        viewController.dismiss(animated: true)

        if let data = try? Data(contentsOf: imageURL), let aiImage = UIImage(data: data) {
            
            // 1. Show in App
            self.updateCarouselContent(title: "Magic Creation", image: aiImage)
            
            // 2. SAVE TO REAL DEVICE GALLERY
            UIImageWriteToSavedPhotosAlbum(aiImage, nil, nil, nil)
            
            print("AI Image saved to Gallery successfully.")
        }
    }

    func imagePlaygroundViewControllerDidCancel(_ viewController: ImagePlaygroundViewController) {
        viewController.dismiss(animated: true)
    }
}

// MARK: - TextField Delegate
extension RewardsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        generateImageTapped()
        return true
    }
}

// MARK: - Collection View Extension
extension RewardsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    static let circleSize: CGFloat = 80

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        quickItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = quickCollectionView.dequeueReusableCell(withReuseIdentifier: RewardCell.reuseID, for: indexPath) as? RewardCell else {
            return UICollectionViewCell()
        }
        cell.configure(title: quickItems[indexPath.item].title, image: quickItems[indexPath.item].image)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: RewardsViewController.circleSize, height: RewardsViewController.circleSize + 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            let selectedItem = quickItems[indexPath.item]
            
            let popupVC = QuickRewardPopupViewController()
            popupVC.rewardName = selectedItem.title
            popupVC.cost = 100
            
            popupVC.modalPresentationStyle = .overFullScreen
            popupVC.modalTransitionStyle = .crossDissolve
            
            present(popupVC, animated: true, completion: nil)
        }
}

