import UIKit

final class RewardsViewController: UIViewController {

    // MARK: - Properties
    private var isSpringOnActive: Bool = false

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

    // NEW: Coin Badge Container
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

    // --- NEW: Notification Button ---
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
        return sv
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // --- Content Elements ---
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
        lb.textAlignment = .left // Align left since it's outside
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

    // --- Data ---
    private let carouselImages: [UIImage?] = [
        UIImage(named:"Cycle"),      // Index 0: Dream It
        UIImage(named: "springon"),  // Index 1: Spring On (Beach Image)
        UIImage(systemName: "gift.fill"),
        UIImage(systemName: "headphones")
    ]

    private let quickItems: [(title: String, image: UIImage?)] = [
        ("Screen Time", UIImage( named: "ScreenTime")),
        ("Cartoon", UIImage(named: "cartoon 1")),
        ("Treats", UIImage(named: "ScreenTime")),
        ("Family", UIImage(named: "ScreenTime"))
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupViews()
        setupConstraints()
        setupActions()
       
        // Load initial image
        carouselCard.image = carouselImages.first ?? UIImage()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        carouselCard.addGestureRecognizer(tapGesture)
        
        // Initial State
        selectLeft()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure nav bar is hidden on this screen, but allows it to show when we push other screens
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
        
        // Add new badge view and subviews
        topBarContainer.addSubview(coinBadgeView)
        coinBadgeView.addSubview(starIcon)
        coinBadgeView.addSubview(coinLabel)
        
        // Add Buttons
        topBarContainer.addSubview(bellButton) // Added Bell
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

            // 1. Profile Button (Rightmost)
            profileButton.trailingAnchor.constraint(equalTo: topBarContainer.trailingAnchor),
            profileButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 25),
            profileButton.heightAnchor.constraint(equalToConstant: 25),

            // 2. Bell Button (Left of Profile)
            bellButton.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -16),
            bellButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            bellButton.widthAnchor.constraint(equalToConstant: 25),
            bellButton.heightAnchor.constraint(equalToConstant: 25),
 
            // 3. Coin Badge (Left of Bell)
            coinBadgeView.trailingAnchor.constraint(equalTo: bellButton.leadingAnchor, constant: -12),
            coinBadgeView.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            coinBadgeView.heightAnchor.constraint(equalToConstant: 25),
            coinBadgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            // Contents inside Badge
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

            // Indicator Logic
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

            // TITLE CENTERED
            carouselTitle.topAnchor.constraint(equalTo: carouselCard.bottomAnchor, constant: 16),
            carouselTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // PAGE CONTROL CENTERED BELOW TITLE
            pageControl.topAnchor.constraint(equalTo: carouselTitle.bottomAnchor, constant: 5),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Bottom padding
            bottomPaddingView.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 20),
            bottomPaddingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomPaddingView.heightAnchor.constraint(equalToConstant: 50)

        ])
        
        indicatorLeadingConstraint = segmentIndicator.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor, constant: 4)
        indicatorLeadingConstraint?.isActive = true
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        // Segments
        leftSegment.addTarget(self, action: #selector(selectLeft), for: .touchUpInside)
        rightSegment.addTarget(self, action: #selector(selectRight), for: .touchUpInside)
        
        // Navigation Buttons
        bellButton.addTarget(self, action: #selector(bellTapped), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func selectLeft() {
        // 1. Force state update
        isSpringOnActive = false
        animateSegmentChange()
        
        // 2. Button Styling
        leftSegment.setTitleColor(.black, for: .normal)
        leftSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        
        rightSegment.setTitleColor(.white, for: .normal)
        rightSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        
        // 3. Update Content -> "Dream It"
        let image = carouselImages.first ?? UIImage(systemName: "bicycle")
        updateCarouselContent(title: "Build a cycle", image: image)
    }

    @objc private func selectRight() {
        // 1. Force state update
        isSpringOnActive = true
        animateSegmentChange()
        
        // 2. Button Styling
        rightSegment.setTitleColor(.black, for: .normal)
        rightSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        
        leftSegment.setTitleColor(.white, for: .normal)
        leftSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        
        // 3. Update Content -> "Spring On"
        var image: UIImage?
        if carouselImages.count > 1 {
            image = carouselImages[1]
        } else {
            image = UIImage(systemName: "sun.max.fill")
        }
        
        updateCarouselContent(title: "Spring Rewards", image: image)
    }
    
    // MARK: - Navigation Actions
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
    
    // MARK: - Content Update Helper
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
            navigationController?.setNavigationBarHidden(false, animated: true) // Assuming these screens have nav bars
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = ChildDreamItViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Collection View Extension
extension RewardsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            // 1. Get the data for the tapped item
            let selectedItem = quickItems[indexPath.item]
            
            // 2. Create the popup
            let popupVC = QuickRewardPopupViewController()
            popupVC.rewardName = selectedItem.title
            popupVC.cost = 100 // Or fetch dynamic cost if you have it
            
            // 3. Set presentation style to 'overFullScreen' to keep the background visible
            popupVC.modalPresentationStyle = .overFullScreen
            popupVC.modalTransitionStyle = .crossDissolve
            
            // 4. Present it
            present(popupVC, animated: true, completion: nil)
        }
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
}
