import UIKit

final class ApprovalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - UI Components
    private let nameLabel = UILabel()
    private let segmentControl = UISegmentedControl(items: ["Pending", "Approved", "Redeemed"])
    private let tableView = UITableView()
    private let backgroundGradientLayer = CAGradientLayer()
    
    // Data Source
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
        view.backgroundColor = .clear
        
        setupGradient()
        setupNavigationBar()
        setupUI()
        
        // Initial Load
        segmentControl.selectedSegmentIndex = 0
        updateData(for: 0)
    }

    // Force Navigation Bar Visible
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }

    // MARK: - Gradient Background
    private func setupGradient() {
        backgroundGradientLayer.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }

    // MARK: - Setup UI
    private func setupUI() {
        nameLabel.text = "Bob"
        nameLabel.font = .systemFont(ofSize: 18, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)

        segmentControl.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        segmentControl.selectedSegmentTintColor = .white
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmentControl.layer.cornerRadius = 10
        segmentControl.clipsToBounds = true
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentControl)

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ApprovalCell.self, forCellReuseIdentifier: "ApprovalCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
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

        cell.onApproveTapped = { print("✅ Approved: \(data["title"] ?? "")") }
        cell.onDeclineTapped = { print("❌ Declined: \(data["title"] ?? "")") }

        return cell
    }
}

// ======================================================
// MARK: - Approval Cell (Dark Navy Theme)
// ======================================================
final class ApprovalCell: UITableViewCell {

    // Callbacks
    var onApproveTapped: (() -> Void)?
    var onDeclineTapped: (() -> Void)?

    // UI Components
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

    // Dynamic Constraints
    private var containerBottomToButtons: NSLayoutConstraint?
    private var containerBottomToDate: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        // 1. Card Container - Dark Navy/Purple Color (#2D3047 approx)
        containerView.backgroundColor = UIColor(red: 45/255, green: 48/255, blue: 71/255, alpha: 1)
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        // 2. Icon Circle
        iconView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        iconView.layer.cornerRadius = 20
        iconView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconView)
        
        iconImageView.image = UIImage(systemName: "star.circle.fill")
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconView.addSubview(iconImageView)

        // 3. Text Labels
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        pointsLabel.font = .systemFont(ofSize: 16, weight: .bold)
        pointsLabel.textColor = .systemYellow
        pointsLabel.textAlignment = .right
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(pointsLabel)

        // 4. Buttons Setup
        setupButtons()

        // 5. Layout Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Icon
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            // Title & Points
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: pointsLabel.leadingAnchor, constant: -8),

            pointsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            pointsLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            // Subtitle
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            // Date
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            
            // Button Stack
            buttonStack.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 34),
            buttonStack.widthAnchor.constraint(equalToConstant: 190) // Fixed width for buttons
        ])
        
        // Dynamic Constraints
        containerBottomToButtons = containerView.bottomAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 16)
        containerBottomToDate = containerView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16)
    }

    private func setupButtons() {
        // Decline - Red
        declineButton.setTitle("Decline", for: .normal)
        declineButton.setTitleColor(.white, for: .normal)
        declineButton.backgroundColor = UIColor(red: 235/255, green: 87/255, blue: 87/255, alpha: 1)
        declineButton.layer.cornerRadius = 8
        declineButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        declineButton.addTarget(self, action: #selector(handleDecline), for: .touchUpInside)

        // Approve - Blue
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
    }

    func configure(title: String, subtitle: String, date: String, points: String, showButtons: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        dateLabel.text = date
        pointsLabel.text = points

        if showButtons {
            buttonStack.isHidden = false
            containerBottomToDate?.isActive = false
            containerBottomToButtons?.isActive = true
        } else {
            buttonStack.isHidden = true
            containerBottomToButtons?.isActive = false
            containerBottomToDate?.isActive = true
        }
        
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
        UIView.animate(withDuration: 0.1, animations: {
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                view.transform = .identity
            }
        }
    }
}
