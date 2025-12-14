import UIKit

// MARK: - ApprovalViewController
final class ApprovalViewController: UIViewController {

    // MARK: UI
    private let header = HomeHeaderView(title: "Approval")
    private let segmentControl = UISegmentedControl(items: ["Pending", "Approved", "Redeemed"])
    private let tableView = UITableView()
    private let backgroundGradient = CAGradientLayer()

    // MARK: Data
    private var currentData: [[String: String]] = []

    private let pendingTasks = [
        ["title": "Quick Reward", "subtitle": "Water Your Plant", "date": "Requested on 24/10/2020", "points": "100 ⭐️"],
        ["title": "Task", "subtitle": "Clean Your Room", "date": "Requested on 23/10/2020", "points": "80 ⭐️"]
    ]

    private let approvedTasks = [
        ["title": "Task", "subtitle": "Finish Homework", "date": "Approved on 22/10/2020", "points": "100 ⭐️"]
    ]

    private let redeemedTasks = [
        ["title": "Dream It", "subtitle": "Build A Cycle", "date": "Redeemed on 26/10/2020", "points": "100 ⭐️"]
    ]

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupGradient()
        setupHeader()
        setupSegment()
        setupTableView()
        setupConstraints()

        segmentControl.selectedSegmentIndex = 0
        updateData(for: 0)
        
        header.onChildTapped = { [weak self] in
            self?.showKidsMenu()
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }
    
    private func showKidsMenu() {

        // 🔑 Always use shared store
        let uiKids = SelectedKidStore.shared.allKids
        guard !uiKids.isEmpty else { return }

        let menu = FloatingKidsMenu(kids: uiKids)
        menu.manager = FloatingMenuManager.shared

        menu.onKidSelected = { [weak self] (selectedKid: Kid) in
            SelectedKidStore.shared.updateKid(selectedKid)
            self?.header.setSelectedKid(selectedKid)
        }

        menu.show(in: view, anchor: header.childButton)
    }

    final class SelectedKidStore {
        static let shared = SelectedKidStore()

        private(set) var allKids: [Kid] = []
        private(set) var selectedKid: Kid?

        func setKids(_ kids: [Kid]) {
            self.allKids = kids
        }

        func updateKid(_ kid: Kid) {
            selectedKid = kid
            NotificationCenter.default.post(
                name: .selectedKidChanged,
                object: nil,
                userInfo: ["kid": kid]
            )
        }
    }



    // MARK: Setup
    private func setupGradient() {
        backgroundGradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        backgroundGradient.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    private func setupHeader() {
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        header.showNotificationButton(false)
        header.showProfileButton(false)
        header.showPlusButton(false)
        header.showBackButton(true)
        header.onBackTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    private func setupSegment() {
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        segmentControl.selectedSegmentTintColor = .white
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.7)], for: .normal)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        view.addSubview(segmentControl)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ApprovalCell.self, forCellReuseIdentifier: ApprovalCell.reuseId)
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 110),

            segmentControl.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentControl.heightAnchor.constraint(equalToConstant: 40),

            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 14),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: Actions
    @objc private func segmentChanged() {
        updateData(for: segmentControl.selectedSegmentIndex)
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
}

// MARK: - UITableView
extension ApprovalViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentData.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: ApprovalCell.reuseId,
            for: indexPath
        ) as! ApprovalCell

        let data = currentData[indexPath.row]
        let isPending = segmentControl.selectedSegmentIndex == 0

        cell.configure(
            title: data["title"] ?? "",
            subtitle: data["subtitle"] ?? "",
            date: data["date"] ?? "",
            points: data["points"] ?? "",
            showButtons: isPending
        )

        cell.onApproveTapped = { [weak self] in
            self?.approveItem(at: indexPath)
        }

        cell.onDeclineTapped = { [weak self] in
            self?.declineItem(at: indexPath)
        }

        return cell
    }

    // MARK: Swipe Actions
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        guard segmentControl.selectedSegmentIndex == 0 else { return nil }

        let approve = UIContextualAction(style: .normal, title: "Approve") { [weak self] _, _, done in
            self?.approveItem(at: indexPath)
            done(true)
        }

        approve.backgroundColor = UIColor(red: 47/255, green: 128/255, blue: 237/255, alpha: 1)
        approve.image = UIImage(systemName: "checkmark.circle.fill")

        return UISwipeActionsConfiguration(actions: [approve])
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        guard segmentControl.selectedSegmentIndex == 0 else { return nil }

        let decline = UIContextualAction(style: .destructive, title: "Decline") { [weak self] _, _, done in
            self?.declineItem(at: indexPath)
            done(true)
        }

        decline.image = UIImage(systemName: "xmark.circle.fill")

        return UISwipeActionsConfiguration(actions: [decline])
    }

    // MARK: Logic
    private func approveItem(at indexPath: IndexPath) {
        let item = currentData.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        print("✅ Approved:", item)
    }

    private func declineItem(at indexPath: IndexPath) {
        let item = currentData.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        print("❌ Declined:", item)
    }
}


final class ApprovalCell: UITableViewCell {

    static let reuseId = "ApprovalCell"

    var onApproveTapped: (() -> Void)?
    var onDeclineTapped: (() -> Void)?

    private let containerView = UIView()
    private let iconView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let dateLabel = UILabel()
    private let pointsLabel = UILabel()
    private let buttonStack = UIStackView()
    private let approveButton = UIButton(type: .system)
    private let declineButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        containerView.backgroundColor = UIColor(red: 45/255, green: 48/255, blue: 71/255, alpha: 1)
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        iconView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        iconView.layer.cornerRadius = 20
        iconView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconView)

        iconImageView.image = UIImage(systemName: "checkmark.circle.fill")
        iconImageView.tintColor = .white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconView.addSubview(iconImageView)

        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.5)

        pointsLabel.font = .systemFont(ofSize: 16, weight: .bold)
        pointsLabel.textColor = .systemYellow

        [titleLabel, subtitleLabel, dateLabel, pointsLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }

        declineButton.setTitle("Decline", for: .normal)
        declineButton.backgroundColor = UIColor(red: 235/255, green: 87/255, blue: 87/255, alpha: 1)
        declineButton.layer.cornerRadius = 8
        declineButton.setTitleColor(.white, for: .normal)
        declineButton.addTarget(self, action: #selector(declineTapped), for: .touchUpInside)

        approveButton.setTitle("Approve", for: .normal)
        approveButton.backgroundColor = UIColor(red: 47/255, green: 128/255, blue: 237/255, alpha: 1)
        approveButton.layer.cornerRadius = 8
        approveButton.setTitleColor(.white, for: .normal)
        approveButton.addTarget(self, action: #selector(approveTapped), for: .touchUpInside)

        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.addArrangedSubview(declineButton)
        buttonStack.addArrangedSubview(approveButton)
        containerView.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),

            pointsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            pointsLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            buttonStack.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            buttonStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 34),
            buttonStack.widthAnchor.constraint(equalToConstant: 190)
        ])
    }

    func configure(title: String, subtitle: String, date: String, points: String, showButtons: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        dateLabel.text = date
        pointsLabel.text = points
        buttonStack.isHidden = !showButtons
        buttonStack.alpha = showButtons ? 1 : 0
    }

    @objc private func approveTapped() {
        onApproveTapped?()
    }

    @objc private func declineTapped() {
        onDeclineTapped?()
    }
}

