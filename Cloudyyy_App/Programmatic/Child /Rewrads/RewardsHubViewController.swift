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

    private let coinBadge: UILabel = {
        let lb = PaddingLabel(top: 4, left: 12, bottom: 4, right: 12) // Use PaddingLabel if available
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.backgroundColor = UIColor(red: 1.0, green: 0.82, blue: 0.0, alpha: 1)
        lb.text = "★ 207"
        lb.font = .systemFont(ofSize: 14, weight: .heavy)
        lb.textColor = .black
        lb.layer.cornerRadius = 14
        lb.layer.masksToBounds = true
        return lb
    }()

    private let profileButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
        b.setImage(UIImage(systemName: "person.circle.fill", withConfiguration: config), for: .normal)
        b.tintColor = .white
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
        // Shadow for depth
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
        v.layer.cornerRadius = 24 // More rounded
        v.backgroundColor = UIColor(white: 1.0, alpha: 0.10) // Darker background
        v.clipsToBounds = true
        return v
    }()

    // The Blue "Bubble" Indicator
    private let segmentIndicator: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // System Blue/Vivid Blue
        v.layer.cornerRadius = 20
        return v
    }()

    private let leftSegment: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Dream It", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        b.setTitleColor(.white, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let rightSegment: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Spring On", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        b.setTitleColor(.lightGray, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // Constraint to animate the indicator
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
        lb.textAlignment = .center
        // Add shadow to text for better visibility over images
        lb.layer.shadowColor = UIColor.black.cgColor
        lb.layer.shadowRadius = 2
        lb.layer.shadowOpacity = 0.5
        lb.layer.shadowOffset = CGSize(width: 0, height: 1)
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
    
    // Padding for bottom scrolling
    private let bottomPaddingView = UIView()

    // --- Data ---
    private let carouselImages: [UIImage?] = [
        UIImage(systemName: "bicycle"), UIImage(systemName: "gift.fill"),
        UIImage(systemName: "gamecontroller.fill"), UIImage(systemName: "headphones")
    ]

    private let quickItems: [(title: String, image: UIImage?)] = [
        ("Screen time", UIImage(systemName: "tv.fill")),
        ("Cartoon", UIImage(systemName: "play.rectangle.fill")),
        ("Treats", UIImage(systemName: "birthday.cake.fill")),
        ("Family", UIImage(systemName: "figure.2.and.child.holdinghands"))
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupGradient()
        setupViews()
        setupConstraints()
        
        leftSegment.addTarget(self, action: #selector(selectLeft), for: .touchUpInside)
        rightSegment.addTarget(self, action: #selector(selectRight), for: .touchUpInside)
        
        carouselCard.image = carouselImages.first ?? UIImage()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        carouselCard.addGestureRecognizer(tapGesture)
        
        // Initial State
        selectLeft()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Setup
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 20/255, green: 25/255, blue: 40/255, alpha: 1).cgColor,
            UIColor(red: 30/255, green: 45/255, blue: 85/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupViews() {
        view.addSubview(topBarContainer)
        topBarContainer.addSubview(titleLabel)
        topBarContainer.addSubview(coinBadge)
        topBarContainer.addSubview(profileButton)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(streakCard)
        contentView.addSubview(quickLabel)
        contentView.addSubview(quickCollectionView)
        
        contentView.addSubview(segmentContainer)
        segmentContainer.addSubview(segmentIndicator) // Add indicator behind buttons
        segmentContainer.addSubview(leftSegment)
        segmentContainer.addSubview(rightSegment)
        
        contentView.addSubview(carouselCard)
        carouselCard.addSubview(carouselTitle)
        contentView.addSubview(pageControl)
        
        bottomPaddingView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomPaddingView)
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

            profileButton.trailingAnchor.constraint(equalTo: topBarContainer.trailingAnchor),
            profileButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 40),
            profileButton.heightAnchor.constraint(equalToConstant: 40),

            coinBadge.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -12),
            coinBadge.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            
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
            
            // --- Streak Card (HERO SIZE) ---
            streakCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            streakCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            streakCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            streakCard.heightAnchor.constraint(equalToConstant: 160), // INCREASED HEIGHT

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
            segmentContainer.heightAnchor.constraint(equalToConstant: 48),

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

            carouselTitle.centerXAnchor.constraint(equalTo: carouselCard.centerXAnchor),
            carouselTitle.bottomAnchor.constraint(equalTo: carouselCard.bottomAnchor, constant: -16),

            pageControl.topAnchor.constraint(equalTo: carouselCard.bottomAnchor, constant: 12),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            bottomPaddingView.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 20),
            bottomPaddingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomPaddingView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Create variable constraint for animation
        indicatorLeadingConstraint = segmentIndicator.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor, constant: 4)
        indicatorLeadingConstraint?.isActive = true
    }

    // MARK: - Actions
    @objc private func selectLeft() {
        isSpringOnActive = false
        animateSegmentChange()
        
        leftSegment.setTitleColor(.white, for: .normal)
        leftSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        
        rightSegment.setTitleColor(.lightGray, for: .normal)
        rightSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
    }

    @objc private func selectRight() {
        isSpringOnActive = true
        animateSegmentChange()
        
        rightSegment.setTitleColor(.white, for: .normal)
        rightSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        
        leftSegment.setTitleColor(.lightGray, for: .normal)
        leftSegment.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
    }
    
    private func animateSegmentChange() {
        // Update constraint
        if isSpringOnActive {
            // Move to right (Total width - indicator width - padding)
            // easier math: Since widths are 50%, right position is just leading anchor at 50% width roughly
            // But we have constraints. Remove leading, add trailing? Or simply use constant.
            // The width is known (container width / 2).
            
            // Best way with constraints defined above:
            segmentContainer.layoutIfNeeded() // Force current
            
            // Remove left constraint
            indicatorLeadingConstraint?.isActive = false
            // Re-create for right side or just update constant if width is fixed.
            // Since width is dynamic, let's clear and anchor to trailing.
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
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = ChildDreamItViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// Extension remains same
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
}
