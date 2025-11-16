//
//  RewardsViewController.swift
//  Cloudyyy_App (or your app name)
//
import UIKit

final class RewardsViewController: UIViewController {

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
        let lb = PaddingLabel(top: 4, left: 10, bottom: 4, right: 10)
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.backgroundColor = UIColor(red: 1.0, green: 0.82, blue: 0.0, alpha: 1)
        lb.text = "★ 207"
        lb.font = .systemFont(ofSize: 14, weight: .semibold)
        lb.textColor = .black
        lb.layer.cornerRadius = 14
        lb.layer.masksToBounds = true
        return lb
    }()

    private let profileButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        b.tintColor = .white
        b.contentMode = .scaleAspectFit
        // Make button larger to match screenshot
        b.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        return b
    }()
    
    // --- Scrollable Content ---
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
    
    // --- UI Components for ScrollView ---
    private let streakCard: StreakCardView = {
        let v = StreakCardView()
        v.translatesAutoresizingMaskIntoConstraints = false
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

    private let segmentContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 20
        v.backgroundColor = UIColor(white: 1.0, alpha: 0.12)
        return v
    }()

    private let leftSegment: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Dream It", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        b.setTitleColor(.white, for: .normal) // Ensure text is white
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let rightSegment: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Spring On", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14)
        b.setTitleColor(.white.withAlphaComponent(0.7), for: .normal) // Dim unselected text
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let carouselCard: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 18
        iv.backgroundColor = UIColor(white: 1.0, alpha: 0.06)
        return iv
    }()

    private let carouselTitle: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Build a cycle"
        lb.font = .systemFont(ofSize: 16, weight: .semibold)
        lb.textColor = .white
        lb.textAlignment = .center
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

    // --- Bottom Tab Bar ---
    private let customTabBar: CustomTabBar = {
        let tb = CustomTabBar()
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()

    // --- Data ---
    private let carouselImages: [UIImage?] = [
        UIImage(named: "bikePlaceholder"), // replace with your asset
        UIImage(named: "giftPlaceholder"),
        UIImage(named: "toyPlaceholder"),
        UIImage(named: "otherPlaceholder")
    ]

    private let quickItems: [(title: String, image: UIImage?)] = [
        ("Screen time", UIImage(named: "screen_icon")),
        ("Cartoon", UIImage(named: "cartoon_icon")),
        ("Treats", UIImage(named: "treats_icon")),
        ("Family", UIImage(named: "family_icon"))
    ]

    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupViews()
        setupConstraints() // Moved constraints to their own method
        
        customTabBar.delegate = self
        leftSegment.addTarget(self, action: #selector(selectLeft), for: .touchUpInside)
        rightSegment.addTarget(self, action: #selector(selectRight), for: .touchUpInside)
        
        carouselCard.image = carouselImages.first ?? makePlaceholderBike()
        
        // Set initial segment state
        selectLeft()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - setup
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 7/255, green: 23/255, blue: 42/255, alpha: 1).cgColor,
            UIColor(red: 16/255, green: 48/255, blue: 81/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupViews() {
        // Add top bar
        view.addSubview(topBarContainer)
        topBarContainer.addSubview(titleLabel)
        topBarContainer.addSubview(coinBadge)
        topBarContainer.addSubview(profileButton)
        
        // Add bottom tab bar
        view.addSubview(customTabBar)

        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add content to the contentView
        contentView.addSubview(streakCard)
        contentView.addSubview(quickLabel)
        contentView.addSubview(quickCollectionView)
        contentView.addSubview(segmentContainer)
        segmentContainer.addSubview(leftSegment)
        segmentContainer.addSubview(rightSegment)
        contentView.addSubview(carouselCard)
        carouselCard.addSubview(carouselTitle)
        contentView.addSubview(pageControl)
    }

    private func setupConstraints() {
        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // --- Top Bar ---
            topBarContainer.topAnchor.constraint(equalTo: safe.topAnchor, constant: 12),
            topBarContainer.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            topBarContainer.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            topBarContainer.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.leadingAnchor.constraint(equalTo: topBarContainer.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),

            profileButton.trailingAnchor.constraint(equalTo: topBarContainer.trailingAnchor),
            profileButton.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 36),
            profileButton.heightAnchor.constraint(equalToConstant: 36),

            coinBadge.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -12),
            coinBadge.centerYAnchor.constraint(equalTo: topBarContainer.centerYAnchor),
            
            // --- Bottom Tab Bar (floating) ---
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            customTabBar.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -12),
            customTabBar.heightAnchor.constraint(equalToConstant: 64),

            // --- Scroll View ---
            scrollView.topAnchor.constraint(equalTo: topBarContainer.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: customTabBar.topAnchor, constant: -12), // Space above tab bar

            // --- Content View (inside scroll view) ---
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor), // Constrains width
            
            // --- Content constraints (relative to contentView) ---
            streakCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            streakCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            streakCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            streakCard.heightAnchor.constraint(equalToConstant: 110),

            quickLabel.topAnchor.constraint(equalTo: streakCard.bottomAnchor, constant: 18),
            quickLabel.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor),

            quickCollectionView.topAnchor.constraint(equalTo: quickLabel.bottomAnchor, constant: 8),
            quickCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor), // Full width for scrolling
            quickCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            quickCollectionView.heightAnchor.constraint(equalToConstant: 110),

            segmentContainer.topAnchor.constraint(equalTo: quickCollectionView.bottomAnchor, constant: 6),
            segmentContainer.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor),
            segmentContainer.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor),
            segmentContainer.heightAnchor.constraint(equalToConstant: 40),

            leftSegment.leadingAnchor.constraint(equalTo: segmentContainer.leadingAnchor, constant: 6),
            leftSegment.topAnchor.constraint(equalTo: segmentContainer.topAnchor),
            leftSegment.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor),
            leftSegment.widthAnchor.constraint(equalTo: segmentContainer.widthAnchor, multiplier: 0.5, constant: -6),

            rightSegment.trailingAnchor.constraint(equalTo: segmentContainer.trailingAnchor, constant: -6),
            rightSegment.topAnchor.constraint(equalTo: segmentContainer.topAnchor),
            rightSegment.bottomAnchor.constraint(equalTo: segmentContainer.bottomAnchor),
            rightSegment.widthAnchor.constraint(equalTo: segmentContainer.widthAnchor, multiplier: 0.5, constant: -6),

            carouselCard.topAnchor.constraint(equalTo: segmentContainer.bottomAnchor, constant: 18),
            carouselCard.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor),
            carouselCard.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor),
            carouselCard.heightAnchor.constraint(equalToConstant: 160),

            carouselTitle.centerXAnchor.constraint(equalTo: carouselCard.centerXAnchor),
            carouselTitle.bottomAnchor.constraint(equalTo: carouselCard.bottomAnchor, constant: -14),

            pageControl.topAnchor.constraint(equalTo: carouselCard.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            // *** CRITICAL ***: Pin the last element to the bottom of the contentView
            pageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Actions
    @objc private func selectLeft() {
        leftSegment.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        leftSegment.setTitleColor(.white, for: .normal)
        
        rightSegment.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        rightSegment.setTitleColor(.white.withAlphaComponent(0.7), for: .normal)
        // update content for left segment
    }

    @objc private func selectRight() {
        rightSegment.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        rightSegment.setTitleColor(.white, for: .normal)
        
        leftSegment.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        leftSegment.setTitleColor(.white.withAlphaComponent(0.7), for: .normal)
        // update content for right segment
    }

    // helper placeholder image if asset missing
    private func makePlaceholderBike() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 360))
        return renderer.image { ctx in
            UIColor.darkGray.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 600, height: 360))
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            let s = "Bike"
            let size = s.size(withAttributes: attrs)
            s.draw(at: CGPoint(x: (600-size.width)/2, y: (360-size.height)/2), withAttributes: attrs)
        }
    }
}

// MARK: - UICollectionView DataSource & DelegateFlowLayout
extension RewardsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    static let circleSize: CGFloat = 80

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        quickItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = quickCollectionView.dequeueReusableCell(withReuseIdentifier: RewardCell.reuseID, for: indexPath) as? RewardCell else {
            return UICollectionViewCell()
        }
        let item = quickItems[indexPath.item]
        cell.configure(title: item.title, image: item.image)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap
        print("Selected quick reward: \(quickItems[indexPath.item].title)")
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: RewardsViewController.circleSize, height: RewardsViewController.circleSize + 20)
    }
}

// MARK: - CustomTabBarDelegate
extension RewardsViewController: CustomTabBarDelegate {
    func didSelectTab(at index: Int) {
        print("Selected tab \(index)")
        // Handle tab selection, e.g., navigate to a different view controller
    }
}
