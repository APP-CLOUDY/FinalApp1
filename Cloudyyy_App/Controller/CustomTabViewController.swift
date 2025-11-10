//
//  CustomTabViewController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 09/11/25.
//


import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - Center Button
    private let centerButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        setupViewControllers()
        setupTabBarAppearance()
        setupCenterButton()
    }
    
    // MARK: - Setup Tabs
    private func setupViewControllers() {
        
        // Create each View Controller
        let homeVC = ParentDashboardViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Home",
                                         image: UIImage(systemName: "house.fill"),
                                         selectedImage: UIImage(systemName: "house.fill"))
        
        let progressVC = ProgressViewController()
        progressVC.tabBarItem = UITabBarItem(title: "Progress",
                                             image: UIImage(systemName: "chart.bar.fill"),
                                             selectedImage: UIImage(systemName: "chart.bar.fill"))
        
        let scheduleVC = ScheduleViewController()
        scheduleVC.tabBarItem = UITabBarItem(title: "Schedule",
                                             image: UIImage(systemName: "calendar"),
                                             selectedImage: UIImage(systemName: "calendar"))
        
        let rewardVC = RewardHomeViewController()
        rewardVC.tabBarItem = UITabBarItem(title: "Reward",
                                           image: UIImage(systemName: "star.fill"),
                                           selectedImage: UIImage(systemName: "star.fill"))
        
        // Assign to tab bar
        viewControllers = [homeVC, progressVC, scheduleVC, rewardVC]
    }
    
    // MARK: - Tab Bar UI
    private func setupTabBarAppearance() {
        tabBar.backgroundColor = UIColor(red: 240/255, green: 242/255, blue: 247/255, alpha: 1)
        tabBar.tintColor = UIColor.systemBlue           // Active icon
        tabBar.unselectedItemTintColor = UIColor.darkGray
        tabBar.isTranslucent = false
        
        // Remove default shadow line
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = tabBar.backgroundColor
        appearance.shadowColor = .clear
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - Center Floating Button
    private func setupCenterButton() {
        centerButton.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        centerButton.layer.cornerRadius = 32
        centerButton.backgroundColor = UIColor.darkGray
        centerButton.tintColor = .white
        centerButton.setImage(UIImage(systemName: "plus"), for: .normal)
        
        // Add shadow for depth
        centerButton.layer.shadowColor = UIColor.black.cgColor
        centerButton.layer.shadowOpacity = 0.25
        centerButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        centerButton.layer.shadowRadius = 5
        
        // Action
        centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
        
        // Add to view
        view.addSubview(centerButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Bring button above the tab bar
        view.bringSubviewToFront(centerButton)
        
        // Center button positioning
        let tabBarHeight = tabBar.frame.height
        centerButton.center = CGPoint(
            x: tabBar.center.x,
            y: view.bounds.height - tabBarHeight / 2 - 10
        )
    }
    
    // MARK: - Center Button Action
    @objc private func centerButtonTapped() {
        print("➕ Center button tapped")
        
        // Example: open "New Task" or "Add Reward"
        let newVC = NewTaskViewController()
        newVC.modalPresentationStyle = .overFullScreen
        present(newVC, animated: true)
    }
    
    // MARK: - Tab Selection Highlight
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.9
        animation.toValue = 1.0
        animation.damping = 5
        animation.initialVelocity = 0.5
        animation.duration = 0.4
        
        if let imageView = (item.value(forKey: "view") as? UIView)?
            .subviews.compactMap({ $0 as? UIImageView }).first {
            imageView.layer.add(animation, forKey: nil)
        }
    }
}
