// ApprovalViewController.swift
import UIKit

// MARK: - ApprovalViewController
final class ApprovalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - UI Components
    private let header = HomeHeaderView(title: "Approval")
    private let segmentControl = UISegmentedControl(items: ["Pending", "Approved", "Redeemed"])
    private let tableView = UITableView()
    private let backgroundGradient = CAGradientLayer()

    // MARK: - Data
    private var kids: [ChildModel] = []
    private var selectedKid: ChildModel? {
        didSet { updateKidUI() }
    }

    private var currentData: [[String: String]] = []
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
        view.backgroundColor = .clear

        setupGradient()
        setupHeader()
        setupSegment()
        setupTableView()
        setupLayoutConstraints()

        // Header customizations: hide icons, show kids, show header chevron (no overlay)
        header.showNotificationButton(false)
        header.showProfileButton(false)
        header.showPlusButton(false)
        
        header.onChildTapped = { [weak self] in self?.showKidsMenu() }

        // Segment callback
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentControl.selectedSegmentIndex = 0
        updateData(for: 0)

        // Load kids & listen to selection changes
        fetchKidsAndLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleSelectedKidChanged(_:)), name: .selectedKidChanged, object: nil)
        
        header.showBackButton(true)
        header.onBackTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }


        
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }

    // MARK: - Setup UI
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

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 110) // match other screens
        ])
    }

    private func setupSegment() {
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        segmentControl.selectedSegmentTintColor = .white
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.8)], for: .normal)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmentControl.layer.cornerRadius = 10
        segmentControl.layer.masksToBounds = true
        view.addSubview(segmentControl)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ApprovalCell.self, forCellReuseIdentifier: ApprovalCell.reuseId)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
    }

    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            // segment below header (header's height ensures no overlap)
            segmentControl.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentControl.heightAnchor.constraint(equalToConstant: 40),

            // table below segment
            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 14),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Data / API
    private func fetchKidsAndLoad() {
        _Concurrency.Task {
            do {
                let data = try await FamilyService.shared.fetchDashboard()
                await MainActor.run {
                    self.kids = data.children
                    let uiKids = self.kids.map { Kid(id: $0.id.uuidString, name: $0.name) }
                    self.header.setKids(uiKids)

                    // restore saved selection or pick first
                    if let saved = SelectedKidStore.shared.selectedKid,
                       let realKid = self.kids.first(where: { $0.id.uuidString == saved.id }) {
                        self.selectKid(realKid)
                    } else if let first = self.kids.first {
                        self.selectKid(first)
                    } else {
                        self.header.childButton.setTitle("No Kids", for: .normal)
                    }
                }
            } catch {
                print("Error fetching kids: \(error)")
            }
        }
    }

    private func selectKid(_ kid: ChildModel) {
        self.selectedKid = kid
        SelectedKidStore.shared.updateKid(Kid(id: kid.id.uuidString, name: kid.name))
    }

    private func updateKidUI() {
        if let kid = selectedKid {
            header.setSelectedKid(Kid(id: kid.id.uuidString, name: kid.name))
        }
    }

    // MARK: - Actions
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

    // MARK: - Kids Menu
    private func showKidsMenu() {
        guard !kids.isEmpty else { return }
        let uiKids = kids.map { Kid(id: $0.id.uuidString, name: $0.name) }
        let menu = FloatingKidsMenu(kids: uiKids)
        menu.manager = FloatingMenuManager.shared
        menu.onKidSelected = { selectedUiKid in
            SelectedKidStore.shared.updateKid(selectedUiKid)
        }
        menu.show(in: view, anchor: header.childButton)
    }

    @objc private func handleSelectedKidChanged(_ notification: Notification) {
        guard let uiKid = notification.userInfo?["kid"] as? Kid else { return }
        if let realKid = kids.first(where: { $0.id.uuidString == uiKid.id }) {
            selectKid(realKid)
        } else {
            // update header even if this controller doesn't own that kid
            header.setSelectedKid(uiKid)
        }
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ApprovalCell.reuseId, for: indexPath) as? ApprovalCell else {
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

        cell.onApproveTapped = { print("✅ Approved: \(data["title"] ?? "")") }
        cell.onDeclineTapped = { print("❌ Declined: \(data["title"] ?? "")") }

        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// ======================================================
// MARK: - ApprovalCell
// ======================================================
final class ApprovalCell: UITableViewCell {

    static let reuseId = "ApprovalCell"

    // Callbacks
    var onApproveTapped: (() -> Void)?
    var onDeclineTapped: (() -> Void)?

    // UI
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

    required init?(coder: NSCoder) { fatalError("init(coder:)") }

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
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)

        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dateLabel)

        pointsLabel.font = .systemFont(ofSize: 16, weight: .bold)
        pointsLabel.textColor = .systemYellow
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pointsLabel)

        // Buttons
        declineButton.setTitle("Decline", for: .normal)
        declineButton.setTitleColor(.white, for: .normal)
        declineButton.backgroundColor = UIColor(red: 235/255, green: 87/255, blue: 87/255, alpha: 1)
        declineButton.layer.cornerRadius = 8
        declineButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        declineButton.addTarget(self, action: #selector(handleDecline), for: .touchUpInside)

        approveButton.setTitle("Approve", for: .normal)
        approveButton.setTitleColor(.white, for: .normal)
        approveButton.backgroundColor = UIColor(red: 47/255, green: 128/255, blue: 237/255, alpha: 1)
        approveButton.layer.cornerRadius = 8
        approveButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        approveButton.addTarget(self, action: #selector(handleApprove), for: .touchUpInside)

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

            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: pointsLabel.leadingAnchor, constant: -8),

            pointsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            pointsLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),

            buttonStack.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
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

        if points.contains("-") {
            pointsLabel.textColor = UIColor(red: 255/255, green: 107/255, blue: 107/255, alpha: 1)
            iconImageView.image = UIImage(systemName: "gift.fill")
        } else {
            pointsLabel.textColor = .systemYellow
            iconImageView.image = UIImage(systemName: "checkmark.circle.fill")
        }
    }

    @objc private func handleApprove() {
        animateClick(approveButton)
        onApproveTapped?()
    }

    @objc private func handleDecline() {
        animateClick(declineButton)
        onDeclineTapped?()
    }

    private func animateClick(_ view: UIView) {
        UIView.animate(withDuration: 0.08, animations: { view.transform = CGAffineTransform(scaleX: 0.96, y: 0.96) }) { _ in
            UIView.animate(withDuration: 0.08) { view.transform = .identity }
        }
    }
}

