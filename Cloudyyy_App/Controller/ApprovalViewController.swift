import UIKit

class ApprovalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let nameLabel = UILabel()
    private let segmentControl = UISegmentedControl(items: ["Pending", "Approved", "Redeemed"])
    private let tableView = UITableView()
    private var backgroundGradientLayer: CAGradientLayer!
    private var currentData: [[String: String]] = []

    // Sample Data
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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupNavigationBar()
        setupUI()
        updateData(for: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }

    // MARK: - Navigation Bar Setup
    private func setupNavigationBar() {
        title = "Approval"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.backButtonDisplayMode = .minimal
    }

    // MARK: - Gradient Background
    private func setupGradient() {
        backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.colors = [
            UIColor(red: 10/255, green: 13/255, blue: 41/255, alpha: 1).cgColor,
            UIColor(red: 24/255, green: 30/255, blue: 74/255, alpha: 1).cgColor
        ]
        backgroundGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        backgroundGradientLayer.frame = view.bounds
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(nameLabel)
        view.addSubview(segmentControl)
        view.addSubview(tableView)

        nameLabel.text = "Bob"
        nameLabel.font = UIFont.systemFont(ofSize: 18)
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.register(ApprovalCell.self, forCellReuseIdentifier: "ApprovalCell")

        // Enable Auto Layout
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
    }

    // MARK: - Segment Logic
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        updateData(for: sender.selectedSegmentIndex)
    }

    private func updateData(for index: Int) {
        switch index {
        case 0: currentData = pendingTasks
        case 1: currentData = approvedTasks
        case 2: currentData = redeemedTasks
        default: currentData = []
        }
        tableView.reloadData()
    }

    // MARK: - Table DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalCell", for: indexPath) as? ApprovalCell else {
            return UITableViewCell()
        }

        let data = currentData[indexPath.row]
        let showButtons = (segmentControl.selectedSegmentIndex == 0)
        cell.configure(
            title: data["title"] ?? "",
            subtitle: data["subtitle"] ?? "",
            date: data["date"] ?? "",
            points: data["points"] ?? "",
            showButtons: showButtons
        )

        // Handle button actions
        cell.onApproveTapped = {
            print("✅ Approved: \(data["title"] ?? "")")
        }

        cell.onDeclineTapped = {
            print("❌ Declined: \(data["title"] ?? "")")
        }

        return cell
    }
}
