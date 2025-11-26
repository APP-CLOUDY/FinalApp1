import UIKit

final class DreamItViewController: UIViewController {

    // MARK: - UI
    private let header = HomeHeaderView(title: "Dream It")
    private let gradient = CAGradientLayer()
    private let searchBar = SimpleSearchBar()

    private let scrollView = UIScrollView()
    private let content = UIView()

    // Active
    private let activeLabel = SectionLabel(text: "Active")
    private let activeScroll = UIScrollView()
    private let activeStack = UIStackView()

    // Completed
    private let completedLabel = SectionLabel(text: "Completed")
    private let completedStack = UIStackView()

    private let bottomSpacer = UIView()

    // MARK: - Data
    private var activeItems: [RewardDetailItem] = []
    private var completedItems: [RewardDetailItem] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupGradient()
        setupHeader()
        setupScroll()
        setupContentLayout()
        setupPlusButton()

        header.onChildTapped = { [weak self] in self?.showKidsMenu() }
        header.onPlusTapped = { [weak self] in self?.openNewReward() }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onKidChanged(_:)),
            name: ChildManager.kidChangedNotification,
            object: nil
        )

        if let kid = ChildManager.shared.selectedKid {
            header.childButton.setTitle("\(kid.name) ▾", for: .normal)
            reloadForKid(kid)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    // MARK: - UI Setup
    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
                        UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func setupHeader() {
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false

        // remove bell + profile
        header.showNotificationButton(false)
        header.showProfileButton(false)
        header.showPlusButton(false)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 110)
        ])
    }

    private func setupPlusButton() {
        let add = UIButton(type: .system)
        add.setImage(UIImage(systemName: "plus"), for: .normal)
        add.tintColor = .white
        add.translatesAutoresizingMaskIntoConstraints = false
        add.addTarget(self, action: #selector(openNewReward), for: .touchUpInside)
        view.addSubview(add)

        NSLayoutConstraint.activate([
            add.centerYAnchor.constraint(equalTo: header.topAnchor, constant: 30),
            add.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            add.widthAnchor.constraint(equalToConstant: 28),
            add.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    private func setupScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(content)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupContentLayout() {
        content.addSubview(searchBar)

        activeScroll.showsHorizontalScrollIndicator = false
        activeScroll.translatesAutoresizingMaskIntoConstraints = false

        activeStack.axis = .horizontal
        activeStack.spacing = 12
        activeStack.alignment = .center
        activeStack.translatesAutoresizingMaskIntoConstraints = false
        activeScroll.addSubview(activeStack)

        completedStack.axis = .vertical
        completedStack.spacing = 12
        completedStack.translatesAutoresizingMaskIntoConstraints = false

        for v in [activeLabel, activeScroll, completedLabel, completedStack, bottomSpacer] {
            v.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview(v)
        }

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            searchBar.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
            searchBar.topAnchor.constraint(equalTo: content.topAnchor, constant: 12),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

            activeLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 18),
            activeLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),

            activeScroll.topAnchor.constraint(equalTo: activeLabel.bottomAnchor, constant: 10),
            activeScroll.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            activeScroll.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
            activeScroll.heightAnchor.constraint(equalToConstant: 220),

            activeStack.leadingAnchor.constraint(equalTo: activeScroll.contentLayoutGuide.leadingAnchor),
            activeStack.trailingAnchor.constraint(equalTo: activeScroll.contentLayoutGuide.trailingAnchor),
            activeStack.topAnchor.constraint(equalTo: activeScroll.contentLayoutGuide.topAnchor),
            activeStack.bottomAnchor.constraint(equalTo: activeScroll.contentLayoutGuide.bottomAnchor),
            activeStack.heightAnchor.constraint(equalTo: activeScroll.frameLayoutGuide.heightAnchor),

            completedLabel.topAnchor.constraint(equalTo: activeScroll.bottomAnchor, constant: 20),
            completedLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),

            completedStack.topAnchor.constraint(equalTo: completedLabel.bottomAnchor, constant: 12),
            completedStack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            completedStack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),

            bottomSpacer.topAnchor.constraint(equalTo: completedStack.bottomAnchor, constant: 20),
            bottomSpacer.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            bottomSpacer.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            bottomSpacer.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            bottomSpacer.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    // MARK: - Data Handling
    @objc private func onKidChanged(_ n: Notification) {
        guard let kid = n.object as? Kid else { return }
        header.childButton.setTitle("\(kid.name) ▾", for: .normal)
        reloadForKid(kid)
    }

    private func reloadForKid(_ kid: Kid) {
        let all = ChildManager.shared.dreamItRewards(for: kid.id) ?? []
        activeItems = all.filter { $0.isActive }
        completedItems = all.filter { !$0.isActive }

        populateActive(activeItems)
        populateCompleted(completedItems)
    }

    private func populateActive(_ arr: [RewardDetailItem]) {
        activeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for item in arr {
            let card = RewardLargeCard(item: item)
            card.widthAnchor.constraint(equalToConstant: 300).isActive = true
            card.heightAnchor.constraint(equalToConstant: 200).isActive = true

            card.onTap = { [weak self] in
                self?.navigationController?.pushViewController(
                    RewardDetailViewController(item: item),
                    animated: true
                )
            }

            activeStack.addArrangedSubview(card)
        }

        let trailing = UIView()
        trailing.widthAnchor.constraint(equalToConstant: 18).isActive = true
        activeStack.addArrangedSubview(trailing)
    }

    private func populateCompleted(_ arr: [RewardDetailItem]) {
        completedStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for item in arr {
            let row = RewardSmallCard(item: item)
            row.heightAnchor.constraint(equalToConstant: 88).isActive = true

            row.onTap = { [weak self] in
                self?.navigationController?.pushViewController(
                    RewardDetailViewController(item: item),
                    animated: true
                )
            }
            completedStack.addArrangedSubview(row)
        }
    }

    // MARK: - Actions
    @objc private func openNewReward() {
        navigationController?.pushViewController(NewRewardViewController(), animated: true)
    }

    private func showKidsMenu() {
        let kids = ChildManager.shared.kids
        guard !kids.isEmpty else { return }

        let menu = FloatingKidsMenu(kids: kids)
        menu.onKidSelected = { ChildManager.shared.selectedKid = $0 }
        menu.show(in: view, anchor: header.childButton)
    }
}

