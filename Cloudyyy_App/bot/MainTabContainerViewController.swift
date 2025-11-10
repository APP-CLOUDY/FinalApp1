import UIKit

final class MainTabContainerViewController: UIViewController {

    // child view controllers (replace placeholders with your real VCs)
    private lazy var homeVC: UIViewController = ChildHomeViewController()
    private lazy var rewardsVC: UIViewController = RewardsPlaceholderViewController()
    private lazy var schedulesVC: UIViewController = SchedulesPlaceholderViewController()
    private lazy var cloudyyVC: UIViewController = ChatBotViewController()

    private let contentContainer = UIView()
    private var currentChild: UIViewController?

    private var bottomNav: BottomCapsuleNavView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupContentContainer()
        setupBottomNav()
        switchTo(index: 0) // start on Home
    }

    private func setupContentContainer() {
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentContainer)
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: view.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor) // bottom will be covered by nav view
        ])
    }

    private func setupBottomNav() {
        let items = [
            BottomCapsuleNavView.Item(title: "Home", icon: UIImage(systemName: "house.fill")),
            BottomCapsuleNavView.Item(title: "Rewards", icon: UIImage(systemName: "rosette")),
            BottomCapsuleNavView.Item(title: "Schedules", icon: UIImage(systemName: "calendar")),
            BottomCapsuleNavView.Item(title: "Cloudyy", icon: UIImage(systemName: "icloud.fill"))
        ]
        bottomNav = BottomCapsuleNavView(items: items)
        bottomNav.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomNav)

        // Place nav slightly above safe area and centered horizontally as capsule
        NSLayoutConstraint.activate([
            bottomNav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomNav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomNav.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            bottomNav.heightAnchor.constraint(equalToConstant: 70)
        ])

        bottomNav.didSelectIndex = { [weak self] idx in
            self?.switchTo(index: idx)
        }
    }

    private func switchTo(index: Int) {
        // pick VC
        let next: UIViewController
        switch index {
        case 0: next = homeVC
        case 1: next = rewardsVC
        case 2: next = schedulesVC
        default: next = cloudyyVC
        }
        // swap children
        currentChild?.willMove(toParent: nil)
        currentChild?.view.removeFromSuperview()
        currentChild?.removeFromParent()

        addChild(next)
        next.view.frame = contentContainer.bounds
        next.view.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(next.view)
        NSLayoutConstraint.activate([
            next.view.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            next.view.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            next.view.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            next.view.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
        next.didMove(toParent: self)
        currentChild = next
    }
}
