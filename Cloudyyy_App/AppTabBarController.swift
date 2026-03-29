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

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self   // ✅ REQUIRED to intercept Add tab

        // ❗ DO NOT configure tab bar appearance here
        // Appearance is locked globally in SceneDelegate

        configureTabs(for: SessionManager.shared.currentRole ?? .parent)

        print("🔥 AppTabBarController CREATED")
    }

    deinit {
        print("❌ AppTabBarController DEALLOCATED")
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
            title: "Home",
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

        viewControllers = [home, missions, add, ask, rewards]
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

// MARK: - Tab Bar Delegate (Intercept Add)

extension AppTabBarController {

    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {

        // 🔴 Intercept Add tab (tag = 2)
        if viewController.tabBarItem.tag == 2 {
            openNewTask()
            return false   // ⛔ Prevent switching to dummy tab
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

