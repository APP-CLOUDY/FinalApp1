
import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupTabBarAppearance() // <-- This function is now updated
        setupViewControllers()
    }

    // --- FIX: Replaced with modern UITabBarAppearance for solid background ---
    private func setupTabBarAppearance() {
        
        // This is the new, modern way (iOS 15+)
        let appearance = UITabBarAppearance()
        
        // 1. Configure it to be opaque (not transparent)
        appearance.configureWithOpaqueBackground()
        
        // 2. Set your solid background color
        appearance.backgroundColor = UIColor.systemGray6
        
        // 3. Set the icon colors for selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        
        // 4. Set the icon colors for normal (unselected) state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]

        // 5. Apply this appearance to both standard and scrolled states
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        // These legacy properties can still be set as a fallback
        // but 'appearance' is now the primary source of truth.
        tabBar.tintColor = UIColor.systemBlue
        tabBar.unselectedItemTintColor = UIColor.gray
    }
    
    private func setupViewControllers() {

        let homeVC = ParentDashboardViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Home",
                                         image: UIImage(systemName: "house.fill"),
                                         tag: 0)

        let progressVC = ProgressViewController()
        progressVC.tabBarItem = UITabBarItem(title: "Progress",
                                             image: UIImage(systemName: "chart.bar.fill"),
                                             tag: 1)

        // ⭐ MIDDLE TAB (Add Task)
        let addDummyVC = UIViewController() // not used — just placeholder
        addDummyVC.tabBarItem = UITabBarItem(title: "Add Task",
                                             image: UIImage(systemName: "plus.circle.fill"),
                                             tag: 2)

        let scheduleVC = ScheduleViewController()
        scheduleVC.tabBarItem = UITabBarItem(title: "Schedule",
                                             image: UIImage(systemName: "calendar"),
                                             tag: 3)

        let rewardVC = RewardHomeViewController()
        rewardVC.tabBarItem = UITabBarItem(title: "Reward",
                                           image: UIImage(systemName: "star.fill"),
                                           tag: 4)
        
        // Make sure the tags here match your other VCs
        // Your code `self.tabBarController?.selectedIndex = 3`
        // was trying to open the *Schedule* tab (index 3), not the Reward tab (index 4).
        // I've kept your setup, but double-check those numbers.
        
        viewControllers = [
            UINavigationController(rootViewController: homeVC),
            UINavigationController(rootViewController: progressVC),
            addDummyVC,  // ⭐ Middle “+” tab
            UINavigationController(rootViewController: scheduleVC),
            UINavigationController(rootViewController: rewardVC),
        ]
    }

    // MARK: - Handle Tab Selection
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {

        if viewController.tabBarItem.tag == 2 {
            // ⭐ Middle tab tapped
            let newTaskVC = NewTaskViewController()
            newTaskVC.modalPresentationStyle = .pageSheet
            present(newTaskVC, animated: true)

            return false // prevent switching to placeholder tab
        }

        return true
    }
}
