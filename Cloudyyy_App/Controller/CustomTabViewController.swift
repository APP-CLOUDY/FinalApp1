import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    private let centerButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupTabBarAppearance()
        setupViewControllers()
        setupCenterButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionCenterButton()   // ✅ Correctly repositions after layout
    }

    private func setupTabBarAppearance() {
        tabBar.tintColor = UIColor.systemBlue
        tabBar.unselectedItemTintColor = UIColor.gray
        tabBar.backgroundColor = UIColor.systemGray6
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 4
    }

    private func setupViewControllers() {
        let homeVC = ParentDashboardViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)

        let progressVC = ProgressViewController()
        progressVC.tabBarItem = UITabBarItem(title: "Progress", image: UIImage(systemName: "chart.bar.fill"), tag: 1)

        let scheduleVC = ScheduleViewController()
        scheduleVC.tabBarItem = UITabBarItem(title: "Schedule", image: UIImage(systemName: "calendar"), tag: 2)

        let rewardVC = RewardHomeViewController()
        rewardVC.tabBarItem = UITabBarItem(title: "Reward", image: UIImage(systemName: "star.fill"), tag: 3)

        viewControllers = [
            UINavigationController(rootViewController: homeVC),
            UINavigationController(rootViewController: progressVC),
            UINavigationController(rootViewController: scheduleVC),
            UINavigationController(rootViewController: rewardVC)
        ]
    }

    private func setupCenterButton() {
        centerButton.translatesAutoresizingMaskIntoConstraints = false
        centerButton.setImage(UIImage(systemName: "plus"), for: .normal)
        centerButton.tintColor = .white
        centerButton.backgroundColor = .darkGray
        centerButton.layer.cornerRadius = 32
        centerButton.layer.shadowColor = UIColor.black.cgColor
        centerButton.layer.shadowOpacity = 0.25
        centerButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        centerButton.layer.shadowRadius = 6

        view.addSubview(centerButton)
        view.bringSubviewToFront(centerButton)

        NSLayoutConstraint.activate([
            centerButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            // ✅ This one lifts it above tab bar safely across all devices
            centerButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor, constant: 4),
            centerButton.widthAnchor.constraint(equalToConstant: 64),
            centerButton.heightAnchor.constraint(equalToConstant: 64)
        ])

        centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
    }

    private func positionCenterButton() {
        view.bringSubviewToFront(centerButton)
    }

    @objc private func centerButtonTapped() {
        print("Center button tapped")
        let newTaskVC = NewTaskViewController()
        newTaskVC.modalPresentationStyle = .pageSheet
        present(newTaskVC, animated: true)
    }
}
