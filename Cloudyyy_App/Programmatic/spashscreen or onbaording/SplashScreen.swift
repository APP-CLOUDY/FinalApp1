import UIKit

final class SplashViewController: UIViewController {

    // MARK: - UI Elements
    private let titleLabel = UILabel()
    
    // The Page Controller (The swipeable area)
    private var pageViewController: UIPageViewController!
    
    // The Dots indicator
    private let pageControl = UIPageControl()
    
    private let continueContainer = UIView()
    private let continueButton = UIButton(type: .system)
    private let bgGradient = CAGradientLayer()

    // MARK: - Data Source
    // This array holds the pages created in viewDidLoad
    private var pages: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupPages() // 1. Create the data
        setupUI()    // 2. Layout the views
        
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradient.frame = view.bounds
        continueContainer.layer.cornerRadius = 28
    }

    // MARK: - Setup Data
    private func setupPages() {
        // Create the 3 screens in the order you requested
        
        // Page 1
        let page1 = OnboardingContentViewController(
            imageName: "progress", // Replace with your image name e.g. "chart_img"
            text: "Track progress with simple daily & weekly charts."
        )
        
        // Page 2
        let page2 = OnboardingContentViewController(
            imageName: "rewards", // Replace with "reward_img"
            text: "Rewards and fun animations to celebrate growth."
        )
        
        // Page 3
        let page3 = OnboardingContentViewController(
            imageName: "bot", // Replace with "bot_img"
            text: "Conversational bot that guides kids."
        )
        
        pages = [page1, page2, page3]
    }

    // MARK: - UI Setup
    private func setupBackground() {
        bgGradient.colors = [
            UIColor(red: 0/255, green: 135/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 0/255, green: 110/255, blue: 230/255, alpha: 1).cgColor
        ]
        bgGradient.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(bgGradient, at: 0)
    }

    private func setupUI() {
        let safe = view.safeAreaLayoutGuide
        
        // 1. Title Label (Fixed at top)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Cloudyyy"
        titleLabel.font = UIFont.systemFont(ofSize: 44, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        // 2. Setup Page View Controller (The Slider)
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        // Set the first page
        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        
        // Add PageVC as child
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. Page Control (The dots)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        // Add action to tap dots to change page
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        view.addSubview(pageControl)

        // 4. Continue Button
        continueContainer.translatesAutoresizingMaskIntoConstraints = false
        continueContainer.backgroundColor = .white
        continueContainer.layer.shadowColor = UIColor.black.cgColor
        continueContainer.layer.shadowOpacity = 0.15
        continueContainer.layer.shadowOffset = CGSize(width: 0, height: 5)
        continueContainer.layer.shadowRadius = 10
        view.addSubview(continueContainer)

        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle("CONTINUE", for: .normal)
        continueButton.setTitleColor(.black, for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        continueContainer.addSubview(continueButton)

        // --- Layout Constraints ---
        NSLayoutConstraint.activate([
            // Title Top
            titleLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Continue Button Bottom
            continueContainer.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 22),
            continueContainer.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -22),
            continueContainer.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -24),
            continueContainer.heightAnchor.constraint(equalToConstant: 58),
            
            continueButton.leadingAnchor.constraint(equalTo: continueContainer.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: continueContainer.trailingAnchor),
            continueButton.topAnchor.constraint(equalTo: continueContainer.topAnchor),
            continueButton.bottomAnchor.constraint(equalTo: continueContainer.bottomAnchor),
            
            // Page Control (Dots) just above the button
            pageControl.bottomAnchor.constraint(equalTo: continueContainer.topAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Page View Controller (Takes remaining space between Title and Dots)
            pageViewController.view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -10)
        ])
    }

    // MARK: - Actions
    @objc private func didTapContinue() {
        // Your navigation logic
        let next = SelectUserViewController()
        if let nav = navigationController {
            nav.pushViewController(next, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: next)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
    
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        let selectedIndex = sender.currentPage
        // Determine direction based on current index
        let currentVC = pageViewController.viewControllers?.first
        let currentIndex = pages.firstIndex(of: currentVC!) ?? 0
        let direction: UIPageViewController.NavigationDirection = selectedIndex > currentIndex ? .forward : .reverse
        
        pageViewController.setViewControllers([pages[selectedIndex]], direction: direction, animated: true, completion: nil)
    }
}

// MARK: - UIPageViewController Extensions
extension SplashViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // Swipe Left (Previous)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        return pages[index - 1]
    }
    
    // Swipe Right (Next)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else {
            return nil
        }
        return pages[index + 1]
    }
    
    // Update the dots when swipe completes
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let visibleViewController = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: visibleViewController) {
            pageControl.currentPage = index
        }
    }
}
