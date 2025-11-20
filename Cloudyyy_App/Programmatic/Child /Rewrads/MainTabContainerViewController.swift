import UIKit

// MARK: - Child Tab Bar Controller
class ChildTabBarController: UITabBarController, UITabBarControllerDelegate {

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
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        // Fallback for older iOS versions
        tabBar.tintColor = UIColor.systemBlue
        tabBar.unselectedItemTintColor = UIColor.gray
    }
    
    // MARK: - 2. Setup Tabs
    private func setupViewControllers() {

        // --- Tab 1: Home ---
        let homeVC = ChildHomeViewController()
        // We wrap in UINavigationController so you can have a nav bar if needed
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeVC.tabBarItem = UITabBarItem(title: "Home",
                                         image: UIImage(systemName: "house.fill"),
                                         tag: 0)

        // --- Tab 2: Rewards ---
        let rewardsVC = RewardsViewController()
        let rewardsNav = UINavigationController(rootViewController: rewardsVC)
        rewardsVC.tabBarItem = UITabBarItem(title: "Rewards",
                                            image: UIImage(systemName: "star.fill"),
                                            tag: 1)

        // --- Tab 3: Missions ---
        // Mapped to NotificationViewController as per your request
        let missionsVC = KidAgendaViewController()
        let missionsNav = UINavigationController(rootViewController: missionsVC)
        missionsVC.tabBarItem = UITabBarItem(title: "Missions",
                                             image: UIImage(systemName: "list.bullet.clipboard"),
                                             tag: 2)

        // --- Tab 4: Ask (Cloud) ---
        let askVC = ChatBotViewController()
        let askNav = UINavigationController(rootViewController: askVC)
        // Using the Cloud icon as requested
        askVC.tabBarItem = UITabBarItem(title: "Ask",
                                        image: UIImage(systemName: "cloud.fill"),
                                        tag: 3)
        
        // Set the controllers for the Tab Bar
        self.viewControllers = [homeNav, rewardsNav, missionsNav, askNav]
    }
}

// MARK: - Placeholder View Controllers
// (Delete these bottom classes if you already have these files in your project)


