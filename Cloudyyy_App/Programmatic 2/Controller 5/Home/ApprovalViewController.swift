import UIKit

// MARK: - Filter Enum
enum DateFilter {
    case all
    case today
    case past
}

final class ApprovalViewController: UIViewController {

    // MARK: - UI Components
    private let header = HomeHeaderView(title: "Approval")
    
    // Filter Button (Native iOS Menu)
    private let filterButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        btn.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let segmentControl = UISegmentedControl(items: ["Pending", "Approved", "Declined"])
    private let tableView = UITableView()
    private let backgroundGradient = CAGradientLayer()
    
    // MARK: - Data Properties
    private var kids: [Kid] = []
    private var currentFilter: DateFilter = .all

    // Data Sources
    private var pendingData: [[String: String]] = []
    private var approvedData: [[String: String]] = []
    private var declinedData: [[String: String]] = []

    // Filtered Data Accessor
    private var currentData: [[String: String]] {
        let sourceData: [[String: String]]
        
        switch segmentControl.selectedSegmentIndex {
        case 0: sourceData = pendingData
        case 1: sourceData = approvedData
        case 2: sourceData = declinedData
        default: sourceData = []
        }
        
        // Apply Date Filter
        if currentFilter == .all { return sourceData }
        
        return sourceData.filter { item in
            guard let rawDate = item["raw_date"] else { return false }
            if self.isDateInToday(rawDate) {
                return currentFilter == .today
            } else {
                return currentFilter == .past
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupGradient()
        setupHeader()
        setupControls()
        setupTableView()
        setupConstraints()
        setupFilterMenu()
        
        fetchKids()

        segmentControl.selectedSegmentIndex = 0
        // Initial Fetch relies on kid selection logic in fetchKids
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(selectedKidChanged),
            name: .selectedKidChanged,
            object: nil
        )
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }

    @objc private func selectedKidChanged() {
        guard let selectedKid = SelectedKidStore.shared.selectedKid else { return }
        header.setSelectedKid(selectedKid)
        fetchApprovalData()
    }

    // MARK: - UI Setup
    
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
        
        header.onChildTapped = { [weak self] in
            guard let self = self, self.kids.count > 1 else { return }
            let menu = FloatingKidsMenu(kids: self.kids)
            menu.manager = FloatingMenuManager.shared
            menu.onKidSelected = { selectedKid in
                SelectedKidStore.shared.updateKid(selectedKid)
            }
            menu.show(in: self.view, anchor: self.header.childButton)
        }
    }

    private func setupControls() {
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        segmentControl.selectedSegmentTintColor = .white
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.7)], for: .normal)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        view.addSubview(segmentControl)
        view.addSubview(filterButton)
    }
    
    private func setupFilterMenu() {
        let allAction = UIAction(title: "All Time", state: .on) { [weak self] _ in self?.updateFilter(.all) }
        let todayAction = UIAction(title: "Today", image: UIImage(systemName: "calendar")) { [weak self] _ in self?.updateFilter(.today) }
        let pastAction = UIAction(title: "Past", image: UIImage(systemName: "clock.arrow.circlepath")) { [weak self] _ in self?.updateFilter(.past) }
        
        let menu = UIMenu(title: "Filter by Date", children: [allAction, todayAction, pastAction])
        filterButton.menu = menu
        filterButton.showsMenuAsPrimaryAction = true
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ApprovalCell.self, forCellReuseIdentifier: ApprovalCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 110),

            // Filter Button (Right)
            filterButton.centerYAnchor.constraint(equalTo: segmentControl.centerYAnchor),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterButton.widthAnchor.constraint(equalToConstant: 40),
            filterButton.heightAnchor.constraint(equalToConstant: 40),

            // Segment Control (Fills space to left of button)
            segmentControl.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentControl.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -12),
            segmentControl.heightAnchor.constraint(equalToConstant: 40),

            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 14),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Logic & Actions
    
    private func updateFilter(_ filter: DateFilter) {
        currentFilter = filter
        
        // Update Menu Checkmarks
        if let menu = filterButton.menu {
            let updatedChildren = menu.children.map { action -> UIMenuElement in
                guard let action = action as? UIAction else { return action }
                var newAction = action
                if (filter == .all && action.title == "All Time") ||
                   (filter == .today && action.title == "Today") ||
                   (filter == .past && action.title == "Past") {
                    newAction.state = .on
                } else {
                    newAction.state = .off
                }
                return newAction
            }
            filterButton.menu = filterButton.menu?.replacingChildren(updatedChildren)
        }
        
        // Update Icon State
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let iconName = filter == .all ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill"
        filterButton.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
        
        tableView.reloadData()
    }
    
    @objc private func segmentChanged() {
        fetchApprovalData()
    }

    private func approveItem(at indexPath: IndexPath) {
        let item = currentData[indexPath.row]
        
        // Find and remove from main source
        if let index = pendingData.firstIndex(where: { $0["id"] == item["id"] }) {
            pendingData.remove(at: index)
        }
        
        var approvedItem = item
        approvedItem["date"] = "Approved just now"
        // Update raw_date so it stays in "Today" filter
        approvedItem["raw_date"] = ISO8601DateFormatter().string(from: Date())
        approvedData.insert(approvedItem, at: 0)
        
        tableView.reloadData()
        
        Task {
            try? await ApprovalService.shared.approve(item: item)
        }
    }

    private func declineItem(at indexPath: IndexPath) {
        let item = currentData[indexPath.row]
        
        if let index = pendingData.firstIndex(where: { $0["id"] == item["id"] }) {
            pendingData.remove(at: index)
        }
        
        var declinedItem = item
        declinedItem["date"] = "Declined just now"
        declinedItem["raw_date"] = ISO8601DateFormatter().string(from: Date())
        declinedData.insert(declinedItem, at: 0)
        
        tableView.reloadData()
        
        Task {
            try? await ApprovalService.shared.decline(item: item)
        }
    }
    
    private func fetchKids() {
        Task {
            do {
                let dashboardData = try await FamilyService.shared.fetchDashboard()
                let uiKids = dashboardData.children.map { Kid(id: $0.id.uuidString, name: $0.name) }
                await MainActor.run {
                    self.kids = uiKids
                    if SelectedKidStore.shared.selectedKid == nil, let first = uiKids.first {
                        SelectedKidStore.shared.updateKid(first)
                    }
                    self.configureHeaderKids()
                    // Initial Data Fetch happens after kids are loaded
                    self.fetchApprovalData()
                }
            } catch { print("❌ Failed to load kids:", error) }
        }
    }
    
    private func configureHeaderKids() {
        guard let selectedKid = SelectedKidStore.shared.selectedKid else { return }
        header.setKids(kids)
        header.setSelectedKid(selectedKid)
    }
    
    private func fetchApprovalData() {
        guard let selectedKid = SelectedKidStore.shared.selectedKid,
              let childId = UUID(uuidString: selectedKid.id) else { return }

        Task {
            do {
                // Fetch data for the current segment
                switch segmentControl.selectedSegmentIndex {
                case 0: pendingData = try await ApprovalService.shared.fetchPending(childId: childId)
                case 1: approvedData = try await ApprovalService.shared.fetchApproved(childId: childId)
                case 2: declinedData = try await ApprovalService.shared.fetchRedeemed(childId: childId)
                default: break
                }
                
                await MainActor.run { tableView.reloadData() }
            } catch { print("❌ Error fetching data:", error) }
        }
    }
    
    // Helper: Check if date is today
    private func isDateInToday(_ dateString: String) -> Bool {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var date: Date? = isoFormatter.date(from: dateString)
        if date == nil {
            let simpleFormatter = DateFormatter()
            simpleFormatter.dateFormat = "yyyy-MM-dd"
            date = simpleFormatter.date(from: String(dateString.prefix(10)))
        }
        
        guard let validDate = date else { return false }
        return Calendar.current.isDateInToday(validDate)
    }
}

// MARK: - TableView Delegate
extension ApprovalViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = currentData.count
        if count == 0 {
            tableView.setEmptyMessage("No items found")
        } else {
            tableView.restore()
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ApprovalCell.reuseId, for: indexPath) as! ApprovalCell
        let data = currentData[indexPath.row]
        let isPending = segmentControl.selectedSegmentIndex == 0
        
        cell.configure(
            title: data["title"] ?? "",
            subtitle: data["subtitle"] ?? "",
            date: data["date"] ?? "",
            points: data["points"] ?? "",
            photoUrl: data["photo_url"],
            showButtons: isPending
        )
        
        cell.onApproveTapped = { [weak self] in self?.approveItem(at: indexPath) }
        cell.onDeclineTapped = { [weak self] in self?.declineItem(at: indexPath) }
        
        return cell
    }
}

// MARK: - Table View Helper
extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
    func restore() {
        self.backgroundView = nil
    }
}

// MARK: - ApprovalCell (Dashboard Glass Style & Task Name First)
final class ApprovalCell: UITableViewCell {
    
    static let reuseId = "ApprovalCell"
    
    var onApproveTapped: (() -> Void)?
    var onDeclineTapped: (() -> Void)?
    
    // MARK: - Views
    
    // 1. DASHBOARD STYLE GLASS CONTAINER
    // This uses the exact styling from your Dashboard Card (UltraThinMaterialDark + 0.05 White)
    private let glassContainer: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        
        // Very subtle white tint (0.05) to match Dashboard cards
        view.contentView.backgroundColor = UIColor(white: 1, alpha: 0.05)
        
        // Subtle Border
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 1, alpha: 0.1).cgColor
        
        return view
    }()
    
    private let iconView = UIView()
    private let iconImageView = UIImageView()
    
    // Task Name (First, Bold, Big)
    private let mainTaskNameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    // Type Label (Small, Uppercase)
    private let typeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.6) // Slightly dimmer
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel = UILabel()
    private let pointsLabel = UILabel()
    private let childLabel = UILabel()
    
    private let proofImageView = UIImageView()
    
    private let approveButton = UIButton(type: .system)
    private let declineButton = UIButton(type: .system)
    
    private let buttonStack = UIStackView()
    private let bottomRow = UIStackView()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Add Glass Container
        contentView.addSubview(glassContainer)
        let content = glassContainer.contentView
        
        // Icon (Light background circle)
        iconView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        iconView.layer.cornerRadius = 20
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.image = UIImage(systemName: "checkmark.seal.fill")
        iconImageView.tintColor = .white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iconView.addSubview(iconImageView)
        content.addSubview(iconView)
        
        // Labels
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        
        childLabel.font = .systemFont(ofSize: 12, weight: .bold)
        childLabel.textColor = UIColor(red: 100/255, green: 200/255, blue: 255/255, alpha: 1) // Cyan/Blue accent
        childLabel.isHidden = true
        
        pointsLabel.font = .systemFont(ofSize: 18, weight: .bold)
        pointsLabel.textColor = .systemYellow
        
        [mainTaskNameLabel, typeLabel, dateLabel, childLabel, pointsLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview($0)
        }
        
        // Proof Image styling
        proofImageView.layer.cornerRadius = 12
        proofImageView.clipsToBounds = true
        proofImageView.contentMode = .scaleAspectFill
        proofImageView.translatesAutoresizingMaskIntoConstraints = false
        proofImageView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        proofImageView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openImage))
        proofImageView.isUserInteractionEnabled = true
        proofImageView.addGestureRecognizer(tap)
        
        // Buttons
        declineButton.setTitle("Decline", for: .normal)
        declineButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
        declineButton.layer.borderWidth = 1
        declineButton.layer.borderColor = UIColor.systemRed.cgColor
        declineButton.layer.cornerRadius = 12
        declineButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        declineButton.setTitleColor(.systemRed, for: .normal)
        declineButton.addTarget(self, action: #selector(declineTapped), for: .touchUpInside)
        
        approveButton.setTitle("Approve", for: .normal)
        approveButton.backgroundColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 0.9) // Brand Green
        approveButton.layer.cornerRadius = 12
        approveButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        approveButton.setTitleColor(.white, for: .normal)
        approveButton.addTarget(self, action: #selector(approveTapped), for: .touchUpInside)
        
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.addArrangedSubview(declineButton)
        buttonStack.addArrangedSubview(approveButton)
        
        // Bottom Row Layout
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.spacing = 12
        bottomRow.translatesAutoresizingMaskIntoConstraints = false
        
        bottomRow.addArrangedSubview(proofImageView)
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        bottomRow.addArrangedSubview(spacer)
        bottomRow.addArrangedSubview(buttonStack)
        
        content.addSubview(bottomRow)
        
        // MARK: - Constraints
        
        NSLayoutConstraint.activate([
            // Glass Card Padding
            glassContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            glassContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            glassContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            glassContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Icon
            iconView.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
            iconView.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Points (Top Right)
            pointsLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 20),
            pointsLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),

            // Main Title (Task Name) - Aligned Top with Icon
            mainTaskNameLabel.topAnchor.constraint(equalTo: iconView.topAnchor, constant: -2),
            mainTaskNameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            mainTaskNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: pointsLabel.leadingAnchor, constant: -12),
            
            // Type Label (TASK/REWARD) - Below Title
            typeLabel.topAnchor.constraint(equalTo: mainTaskNameLabel.bottomAnchor, constant: 4),
            typeLabel.leadingAnchor.constraint(equalTo: mainTaskNameLabel.leadingAnchor),
            typeLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
            
            // Date
            dateLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: mainTaskNameLabel.leadingAnchor),
            
            // Child Name
            childLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            childLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 12),
            
            // Bottom Row (Image & Buttons)
            bottomRow.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            bottomRow.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            bottomRow.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
            bottomRow.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -20),
            
            proofImageView.widthAnchor.constraint(equalToConstant: 60),
            proofImageView.heightAnchor.constraint(equalToConstant: 60),
            
            buttonStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            buttonStack.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Configure
    
    func configure(
        title: String,     // "Task" or "Reward"
        subtitle: String,  // Task Name (e.g., "Walk Dog")
        date: String,
        points: String,
        photoUrl: String?,
        childName: String? = nil,
        showButtons: Bool
    ) {
        // HIERARCHY: Task Name (Big) -> Type (Small)
        mainTaskNameLabel.text = subtitle
        typeLabel.text = title.uppercased()
        
        dateLabel.text = date
        pointsLabel.text = points
        buttonStack.isHidden = !showButtons
        
        if let childName, !childName.isEmpty {
            childLabel.text = "👤 \(childName)"
            childLabel.isHidden = false
        } else {
            childLabel.isHidden = true
        }
        
        if let photoUrl, !photoUrl.isEmpty, let url = URL(string: photoUrl) {
            proofImageView.isHidden = false
            loadImage(from: url)
        } else {
            proofImageView.isHidden = true
        }
    }
    
    // MARK: - Helpers
    
    private func loadImage(from url: URL) {
        proofImageView.image = nil
        proofImageView.backgroundColor = UIColor.white.withAlphaComponent(0.1) // Placeholder
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.proofImageView.image = image
                self?.proofImageView.backgroundColor = .clear
            }
        }.resume()
    }
    
    @objc private func openImage() {
        guard let image = proofImageView.image else { return }

        let overlayVC = ImagePreviewViewController(image: image)
        overlayVC.modalPresentationStyle = .overCurrentContext
        overlayVC.modalTransitionStyle = .crossDissolve

        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?
            .rootViewController {
            
            var currentVC = topVC
            while let presentedVC = currentVC.presentedViewController {
                currentVC = presentedVC
            }
            currentVC.present(overlayVC, animated: true)
        }
    }
    
    @objc private func approveTapped() { onApproveTapped?() }
    @objc private func declineTapped() { onDeclineTapped?() }
}
