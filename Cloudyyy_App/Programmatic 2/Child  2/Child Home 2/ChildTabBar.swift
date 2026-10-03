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

    private var darkGlassBar: DarkGlassTabBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        // 1. Setup the 4 Tabs (Home, Rewards, Missions, Ask)
        setupViewControllers()

        // 2. Setup custom dark glass bar
        setupDarkGlassBar()
    }

    // MARK: - Dark Glass Tab Bar
    private func setupDarkGlassBar() {
        tabBar.isHidden = true
        
        // Hide iOS 18 native tab bar artifacts
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil
        appearance.shadowColor = .clear
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        let items: [DarkGlassTabItem] = [
            DarkGlassTabItem(title: "Home",     icon: "house.fill"),
            DarkGlassTabItem(title: "Rewards",  icon: "star.fill"),
            DarkGlassTabItem(title: "Missions", icon: "list.bullet.clipboard"),
            DarkGlassTabItem(title: "Ask",      icon: "cloud.fill"),
        ]

        darkGlassBar = DarkGlassTabBar(items: items)
        darkGlassBar.delegate = self
        view.addSubview(darkGlassBar)

        NSLayoutConstraint.activate([
            darkGlassBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            darkGlassBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            darkGlassBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            darkGlassBar.heightAnchor.constraint(equalToConstant: 56),
        ])

        darkGlassBar.selectTab(at: 0, animated: false)
    }

    // MARK: - Setup Tabs
    private func setupViewControllers() {

        // --- Tab 1: Home ---
        let homeVC = ChildHomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)

        // --- Tab 2: Rewards ---
        let rewardsVC = RewardsViewController()
        let rewardsNav = UINavigationController(rootViewController: rewardsVC)

        // --- Tab 3: Missions (Kid Agenda) ---
        let missionsVC = KidAgendaViewController()
        let missionsNav = UINavigationController(rootViewController: missionsVC)

        // --- Tab 4: Ask (Cloud) ---
        let askHosting = UIHostingController(rootView: CloudyFlowView())
        let askNav = UINavigationController(rootViewController: askHosting)

        // Assign view controllers
        self.viewControllers = [homeNav, rewardsNav, missionsNav, askNav]
    }

    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let _ = viewController as? UINavigationController {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}

// MARK: - Dark Glass Delegate
extension ChildTabBarController: DarkGlassTabBarDelegate {
    func darkGlassTabBar(_ tabBar: DarkGlassTabBar, didSelectIndex index: Int) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        self.selectedIndex = index
    }
}

// MARK: - Placeholder View Controllers (Remove if you already have real implementations)
//final class ChildHomeViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor.systemBackground
//        title = "Home"
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
