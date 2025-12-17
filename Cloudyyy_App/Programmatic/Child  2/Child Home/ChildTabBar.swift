//
//  ChildTabBar.swift
//  Cloudyyy_App
//
//  Created by user@5 on 17/12/25.
//

import UIKit
import SwiftUI

// MARK: - ChildTabBarController
final class ChildTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        // 1. Setup the Appearance (Solid Gray Background, Blue Icons)
        setupTabBarAppearance()

        // 2. Setup the 4 Tabs (Home, Rewards, Missions, Ask)
        setupViewControllers()
    }

    // MARK: - 1. UI Appearance (Matches Parent Dashboard)
    private func setupTabBarAppearance() {

        let appearance = UITabBarAppearance()

        // Configure opaque background (Solid, not transparent)
        appearance.configureWithOpaqueBackground()

        // Set background color (Light Gray to match system standard)
        appearance.backgroundColor = UIColor.systemGray6

        // Set Selected Icon/Text Color (System Blue)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]

        // Set Unselected Icon/Text Color (Gray)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]

        // Apply appearance
        if #available(iOS 15.0, *) {
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        } else {
            // Fallback for earlier iOS: apply basic tint/unselected colors
            tabBar.barTintColor = UIColor.systemGray6
            tabBar.tintColor = UIColor.systemBlue
            tabBar.unselectedItemTintColor = UIColor.gray
        }

        // Fallback for older iOS versions (keeps behavior consistent)
        tabBar.tintColor = UIColor.systemBlue
        tabBar.unselectedItemTintColor = UIColor.gray
    }

    // MARK: - 2. Setup Tabs
    private func setupViewControllers() {

        // --- Tab 1: Home ---
        let homeVC = ChildHomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "Home",
                                          image: UIImage(systemName: "house.fill"),
                                          tag: 0)

        // --- Tab 2: Rewards ---
        let rewardsVC = RewardsViewController()
        let rewardsNav = UINavigationController(rootViewController: rewardsVC)
        rewardsNav.tabBarItem = UITabBarItem(title: "Rewards",
                                             image: UIImage(systemName: "star.fill"),
                                             tag: 1)

        // --- Tab 3: Missions (Kid Agenda) ---
        let missionsVC = KidAgendaViewController()
        let missionsNav = UINavigationController(rootViewController: missionsVC)
        missionsNav.tabBarItem = UITabBarItem(title: "Missions",
                                              image: UIImage(systemName: "list.bullet.clipboard"),
                                              tag: 2)

        // --- Tab 4: Ask (Cloud) ---
        // Wrap your SwiftUI CloudyFlowView in a UIHostingController so UIKit can host it.
        // If you prefer no navigation bar for Ask, you can use `askHosting` directly instead of embedding in a UINavigationController.
        let askHosting = UIHostingController(rootView: CloudyFlowView())
        // Optionally set a custom large title or navigation bar config here:
        let askNav = UINavigationController(rootViewController: askHosting)
        askNav.tabBarItem = UITabBarItem(title: "Ask",
                                         image: UIImage(systemName: "cloud.fill"),
                                         tag: 3)

        // Assign view controllers
        self.viewControllers = [homeNav, rewardsNav, missionsNav, askNav]

        // Optional: default selected tab
        self.selectedIndex = 0
    }

    // MARK: - UITabBarControllerDelegate (Optional)
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Example: analytics or haptic feedback
        if let _ = viewController as? UINavigationController {
            // simple haptic
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}

// MARK: - Placeholder View Controllers (Remove if you already have real implementations)
//final class ChildHomeViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor.systemBackground
//        title = "Home"
//        // Example content:
//        let label = UILabel()
//        label.text = "Child Home"
//        label.font = .systemFont(ofSize: 20, weight: .semibold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(label)
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//}
//
//final class RewardsViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor.systemBackground
//        title = "Rewards"
//        let label = UILabel()
//        label.text = "Rewards"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(label)
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//}
//
//final class KidAgendaViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor.systemBackground
//        title = "Missions"
//        let label = UILabel()
//        label.text = "Kid Agenda / Missions"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(label)
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//}
//
//// If you previously had a ChatBotViewController and still want to keep it, remove this placeholder.
//// We still include it here so the project compiles if you don't have the real class yet.
//final class ChatBotViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor.systemBackground
//        title = "Ask"
//        let label = UILabel()
//        label.text = "Legacy ChatBot (if used)"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(label)
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//}
