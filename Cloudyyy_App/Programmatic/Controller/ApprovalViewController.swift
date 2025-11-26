import UIKit

class ApprovalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let nameLabel = UILabel()
    private let segmentControl = UISegmentedControl(items: ["Pending", "Approved", "Redeemed"])
    private let tableView = UITableView()
    private var backgroundGradientLayer: CAGradientLayer!
    private var currentData: [[String: String]] = []

    // -------------------------------
    // MARK: - SAMPLE DATA (KEEP THIS)
    // -------------------------------
    private let pendingTasks = [
        ["title": "Quick Reward", "subtitle": "Water Your Plant", "date": "Requested on 24/10/2020", "points": "100 ⭐️"],
        ["title": "Task", "subtitle": "Clean Your Room", "date": "Requested on 23/10/2020", "points": "80 ⭐️"]
    ]

    private let approvedTasks = [
        ["title": "Task", "subtitle": "Finish Homework", "date": "Approved on 22/10/2020", "points": "100 ⭐️"]
    ]

    private let redeemedTasks = [
        ["title": "DREAM IT", "subtitle": "Build A Cycle", "date": "Redeemed on 26/10/2020", "points": "100 ⭐️"]
    ]

    // -------------------------------
    // MARK: - EMPTY STATE CARD
    // -------------------------------
    private let emptyCard = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    private let emptyMessage: UILabel = {
        let label = UILabel()
        label.text = "No Tasks Yet"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let emptyAddButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Add New Task", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        b.backgroundColor = UIColor(red: 35/255, green: 129/255, blue: 255/255, alpha: 1)
        b.tintColor = .white
        b.layer.cornerRadius = 24
        b.layer.masksToBounds = true
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return b
    }()


    // ------------------------------------------------------------
    // MARK: - Lifecycle
    // ------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradient()
        setupNavigationBar()
        setupUI()

        updateData(for: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }


    // ------------------------------------------------------------
    // MARK: - Navigation Bar Setup
    // ------------------------------------------------------------
    private func setupNavigationBar() {
        title = "Approval"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.backButtonDisplayMode = .minimal
    }


    // ------------------------------------------------------------
    // MARK: - Gradient
    // ------------------------------------------------------------
    private func setupGradient() {
        backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
                        UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        backgroundGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }


    // ------------------------------------------------------------
    // MARK: - UI Setup
    // ------------------------------------------------------------
    private func setupUI() {

        view.addSubview(nameLabel)
        view.addSubview(segmentControl)
        view.addSubview(tableView)

        nameLabel.text = "Bob"
        nameLabel.font = .systemFont(ofSize: 18)
        nameLabel.textColor = .white

        segmentControl.selectedSegmentIndex = 0
        segmentControl.backgroundColor = UIColor(white: 1, alpha: 0.15)
        segmentControl.selectedSegmentTintColor = .white
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmentControl.layer.cornerRadius = 10
        segmentControl.clipsToBounds = true
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ApprovalCell.self, forCellReuseIdentifier: "ApprovalCell")

        [nameLabel, segmentControl, tableView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            segmentControl.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentControl.heightAnchor.constraint(equalToConstant: 36),

            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // ----------------------------
        // EMPTY STATE CARD SETUP
        // ----------------------------
        emptyCard.layer.cornerRadius = 18
        emptyCard.layer.masksToBounds = true
        emptyCard.isHidden = true

        emptyCard.translatesAutoresizingMaskIntoConstraints = false
        emptyMessage.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(emptyCard)
        emptyCard.contentView.addSubview(emptyMessage)
        emptyCard.contentView.addSubview(emptyAddButton)

        emptyAddButton.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            emptyCard.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 40),
            emptyCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emptyCard.heightAnchor.constraint(equalToConstant: 200),

            emptyMessage.centerXAnchor.constraint(equalTo: emptyCard.centerXAnchor),
            emptyMessage.topAnchor.constraint(equalTo: emptyCard.topAnchor, constant: 26),

            emptyAddButton.topAnchor.constraint(equalTo: emptyMessage.bottomAnchor, constant: 20),
            emptyAddButton.leadingAnchor.constraint(equalTo: emptyCard.leadingAnchor, constant: 20),
            emptyAddButton.trailingAnchor.constraint(equalTo: emptyCard.trailingAnchor, constant: -20)
        ])
    }


    // ------------------------------------------------------------
    // MARK: - Segment Logic
    // ------------------------------------------------------------
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        updateData(for: sender.selectedSegmentIndex)
    }


    // ------------------------------------------------------------
    // MARK: - FIRST TIME USER + MOCK DATA LOGIC
    // ------------------------------------------------------------
    private func updateData(for index: Int) {

        // ------------------------------
        // First-time user check
        // ------------------------------
        let defaults = UserDefaults.standard
        let isFirstTime = defaults.object(forKey: "isFirstTimeUser") == nil
                          ? true
                          : defaults.bool(forKey: "isFirstTimeUser")

        if isFirstTime {
            tableView.isHidden = true
            emptyCard.isHidden = true   // show nothing (just like parent dashboard)
            return
        }

        // ------------------------------
        // Normal approval logic
        // ------------------------------
        switch index {
        case 0:
            currentData = pendingTasks
            emptyMessage.text = "No Pending Tasks"
        case 1:
            currentData = approvedTasks
            emptyMessage.text = "No Approved Tasks"
        case 2:
            currentData = redeemedTasks
            emptyMessage.text = "No Redeemed Tasks"
        default:
            currentData = []
            emptyMessage.text = "No Tasks Available"
        }

        tableView.reloadData()

        if currentData.isEmpty {
            emptyCard.isHidden = false
            tableView.isHidden = true
        } else {
            emptyCard.isHidden = true
            tableView.isHidden = false
        }
    }


    // ------------------------------------------------------------
    // MARK: - Add Task Button
    // ------------------------------------------------------------
    @objc private func addTaskTapped() {
        let newTaskVC = NewTaskViewController()

        if let nav = self.navigationController {
            nav.pushViewController(newTaskVC, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: newTaskVC)
            nav.modalPresentationStyle = .pageSheet
            present(nav, animated: true)
        }
    }


    // ------------------------------------------------------------
    // MARK: - TableView
    // ------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ApprovalCell",
            for: indexPath
        ) as? ApprovalCell else { return UITableViewCell() }

        let data = currentData[indexPath.row]
        let showButtons = (segmentControl.selectedSegmentIndex == 0)

        cell.configure(
            title: data["title"] ?? "",
            subtitle: data["subtitle"] ?? "",
            date: data["date"] ?? "",
            points: data["points"] ?? "",
            showButtons: showButtons
        )

        cell.onApproveTapped = { print("Approved:", data["title"] ?? "") }
        cell.onDeclineTapped = { print("Declined:", data["title"] ?? "") }

        return cell
    }
}

