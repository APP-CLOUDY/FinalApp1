import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        // 1. Apply the NEW Styling (Solid Gray Background)
        setupTabBarAppearance()
        
        // 2. Keep the ORIGINAL Tabs (Parent Dashboard + Middle Button)
        setupViewControllers()
    }

    // MARK: - 1. Setup New UI Appearance
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

        // Apply appearance to standard and scroll edge
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        // Fallback for older iOS versions
        tabBar.tintColor = UIColor.systemBlue
        tabBar.unselectedItemTintColor = UIColor.gray
    }

    // MARK: - 2. Setup Original View Controllers
    private func setupViewControllers() {

        // Tab 0: Home
        let homeVC = ParentDashboardViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Home",
                                         image: UIImage(systemName: "house.fill"),
                                         tag: 0)

        // Tab 1: Progress
        let progressVC = ProgressViewController()
        progressVC.tabBarItem = UITabBarItem(title: "Progress",
                                             image: UIImage(systemName: "chart.bar.fill"),
                                             tag: 1)

        // Tab 2: Middle Add Button (Dummy)
        let addDummyVC = UIViewController()
        addDummyVC.tabBarItem = UITabBarItem(title: "Add Task",
                                             image: UIImage(systemName: "plus.circle.fill"),
                                             tag: 2)

        // Tab 3: Schedule
        let scheduleVC = ScheduleViewController()
        scheduleVC.tabBarItem = UITabBarItem(title: "Schedule",
                                             image: UIImage(systemName: "calendar"),
                                             tag: 3)

        // Tab 4: Reward
        let rewardVC = RewardHomeViewController()
        rewardVC.tabBarItem = UITabBarItem(title: "Reward",
                                           image: UIImage(systemName: "star.fill"),
                                           tag: 4)

        // Wrap them in Navigation Controllers (except dummy)
        viewControllers = [
            UINavigationController(rootViewController: homeVC),
            UINavigationController(rootViewController: progressVC),
            addDummyVC, // No Nav controller needed for the dummy
            UINavigationController(rootViewController: scheduleVC),
            UINavigationController(rootViewController: rewardVC),
        ]
    }

    // MARK: - Handle Tab Selection (Middle Button Logic)
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {

        if viewController.tabBarItem.tag == 2 {
            // ⭐ Middle tab tapped - Present Modal
            let newTaskVC = NewTaskViewController()
            let nav = UINavigationController(rootViewController: newTaskVC)
            nav.modalPresentationStyle = .pageSheet
            present(nav, animated: true)

            return false // Prevent switching to the dummy tab
        }

        return true
    }
}
