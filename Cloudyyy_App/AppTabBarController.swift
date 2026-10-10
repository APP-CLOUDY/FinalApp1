//
//  AppTabBarController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 14/12/25.
//

import UIKit
import SwiftUI

// UserRole and UserSession removed, using SessionManager instead

// MARK: - Main Tab Bar Controller

final class AppTabBarController: UITabBarController, UITabBarControllerDelegate {

    private var darkGlassBar: DarkGlassTabBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self   // ✅ REQUIRED to intercept Add tab
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0) // Match dark theme to hide white shade at bottom

        configureTabs(for: SessionManager.shared.currentRole ?? .parent)
        setupDarkGlassBar(for: SessionManager.shared.currentRole ?? .parent)

        print("🔥 AppTabBarController CREATED")
    }

    deinit {
        print("❌ AppTabBarController DEALLOCATED")
    }

    // MARK: - Dark Glass Tab Bar Setup

    private func setupDarkGlassBar(for role: UserRole) {
        // 1. Hide the native tab bar (the snowy white one)
        tabBar.isHidden = true
        
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil
        appearance.shadowColor = .clear
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        // 2. Build custom dark glass bar matching GlassView card style
        let items: [DarkGlassTabItem]
        if role == .parent {
            items = [
                DarkGlassTabItem(title: "Home",     icon: "house.fill"),
                DarkGlassTabItem(title: "Progress", icon: "chart.bar.fill"),
                DarkGlassTabItem(title: "Add",      icon: "plus.circle.fill"),
                DarkGlassTabItem(title: "Schedule", icon: "calendar"),
                DarkGlassTabItem(title: "Reward",   icon: "star.fill"),
            ]
        } else {
            items = [
                DarkGlassTabItem(title: "Tasks",     icon: "house.fill"),
                // DarkGlassTabItem(title: "Missions", icon: "list.bullet.clipboard"),
                // DarkGlassTabItem(title: "Add",      icon: "plus.circle.fill"),
                DarkGlassTabItem(title: "Ask",      icon: "cloud.fill"),
                DarkGlassTabItem(title: "Rewards",  icon: "star.fill"),
            ]
        }

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
}

// MARK: - Tab Configuration

private extension AppTabBarController {

    func configureTabs(for role: UserRole) {
        switch role {
        case .parent:
            setupParentTabs()
        case .child:
            setupChildTabs()
        }
    }
}

// MARK: - Parent Tabs

private extension AppTabBarController {

    func setupParentTabs() {

        let home = nav(
            ParentDashboardViewController(),
            title: "Home",
            icon: "house.fill",
            tag: 0
        )

        let progress = nav(
            ProgressViewController(),
            title: "Progress",
            icon: "chart.bar.fill",
            tag: 1
        )

        let add = dummyAddTab()

        let schedule = nav(
            ScheduleViewController(),
            title: "Schedule",
            icon: "calendar",
            tag: 3
        )

        let reward = nav(
            RewardHomeViewController(),
            title: "Reward",
            icon: "star.fill",
            tag: 4
        )

        viewControllers = [home, progress, add, schedule, reward]
    }
}

// MARK: - Child Tabs

private extension AppTabBarController {

    func setupChildTabs() {

        let home = nav(
            ChildHomeViewController(),
            title: "Tasks",
            icon: "house.fill",
            tag: 0
        )

        let missions = nav(
            KidAgendaViewController(),
            title: "Missions",
            icon: "list.bullet.clipboard",
            tag: 1
        )

        let add = dummyAddTab()

        let ask = nav(
            UIHostingController(rootView: CloudyFlowView()),
            title: "Ask",
            icon: "cloud.fill",
            tag: 3
        )

        let rewards = nav(
            RewardsViewController(),
            title: "Rewards",
            icon: "star.fill",
            tag: 4
        )

        // viewControllers = [home, missions, add, ask, rewards]
        viewControllers = [home, ask, rewards]
    }
}

// MARK: - Helpers

private extension AppTabBarController {

    func nav(
        _ vc: UIViewController,
        title: String,
        icon: String,
        tag: Int
    ) -> UINavigationController {

        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true

        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            tag: tag
        )

        return nav
    }

    func dummyAddTab() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear

        vc.tabBarItem = UITabBarItem(
            title: "Add",
            image: UIImage(systemName: "plus.circle.fill"),
            tag: 2
        )

        return vc
    }
}

// MARK: - Tab Bar Delegate (Intercept native — kept as safety)

extension AppTabBarController {

    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {

        if viewController.tabBarItem.tag == 2 {
            openNewTask()
            return false
        }

        return true
    }

    private func openNewTask() {
        let vc = NewTaskViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

// MARK: - Dark Glass Tab Bar Delegate

extension AppTabBarController: DarkGlassTabBarDelegate {

    func darkGlassTabBar(_ tabBar: DarkGlassTabBar, didSelectIndex index: Int) {
        // Intercept Add button
        if SessionManager.shared.currentRole == .parent && index == 2 {
            openNewTask()
            // Reset pill back to current tab
            darkGlassBar.selectTab(at: self.selectedIndex, animated: true)
            return
        }

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        // Switch the actual tab
        self.selectedIndex = index
    }
}
