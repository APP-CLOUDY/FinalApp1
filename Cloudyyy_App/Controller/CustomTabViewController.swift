import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupTabBarAppearance()
        setupViewControllers()
    }

    private func setupTabBarAppearance() {
        tabBar.tintColor = UIColor.systemBlue
        tabBar.unselectedItemTintColor = UIColor.gray
        tabBar.backgroundColor = UIColor.systemGray6
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

