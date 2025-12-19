import UIKit

final class ApprovalViewController: UIViewController {

    // MARK: - UI
    private let header = HomeHeaderView(title: "Approval")
    private let segmentControl = UISegmentedControl(items: ["Pending", "Approved", "Declined"])
    private let tableView = UITableView()
    private let backgroundGradient = CAGradientLayer()
    
    private var kids: [Kid] = []


    // MARK: - Data Sources
    private var pendingData: [[String: String]] = []
    private var approvedData: [[String: String]] = []
    private var declinedData: [[String: String]] = []

    private var currentData: [[String: String]] {
        switch segmentControl.selectedSegmentIndex {
        case 0: return pendingData
        case 1: return approvedData
        case 2: return declinedData
        default: return []
        }
    }
    
    private func configureHeaderKids() {
        guard let selectedKid = SelectedKidStore.shared.selectedKid else { return }

        header.setKids(kids)
        header.setSelectedKid(selectedKid)
    }

    private func fetchKids() {
        _Concurrency.Task {
            do {
                let dashboardData = try await FamilyService.shared.fetchDashboard()

                let uiKids = dashboardData.children.map {
                    Kid(id: $0.id.uuidString, name: $0.name)
                }

                await MainActor.run {
                    self.kids = uiKids

                    // If no kid selected yet, auto-select first
                    if SelectedKidStore.shared.selectedKid == nil,
                       let first = uiKids.first {
                        SelectedKidStore.shared.updateKid(first)
                    }

                    self.configureHeaderKids()
                }

            } catch {
                print("❌ Failed to load kids for approval:", error)
            }
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupGradient()
        setupHeader()
        setupSegment()
        setupTableView()
        setupConstraints()
        fetchKids()

        segmentControl.selectedSegmentIndex = 0
        loadMockDataIfNeeded()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(selectedKidChanged),
            name: .selectedKidChanged,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }

    @objc private func selectedKidChanged() {
        guard let selectedKid = SelectedKidStore.shared.selectedKid else { return }
        header.setSelectedKid(selectedKid)
        tableView.reloadData()
    }


    // MARK: - Setup
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
        
        header.onChildTapped = { [weak self] in
            guard let self = self, self.kids.count > 1 else { return }

            let menu = FloatingKidsMenu(kids: self.kids)
            menu.manager = FloatingMenuManager.shared

            menu.onKidSelected = { selectedKid in
                SelectedKidStore.shared.updateKid(selectedKid)
            }

            menu.show(in: self.view, anchor: self.header.childButton)
        }


        header.onBackTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    private func setupSegment() {
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        segmentControl.selectedSegmentTintColor = .white
        segmentControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white.withAlphaComponent(0.7)],
            for: .normal
        )
        segmentControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.black],
            for: .selected
        )
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

    // MARK: - Data
    @objc private func segmentChanged() {
        tableView.reloadData()
    }

    private func loadMockDataIfNeeded() {
        guard pendingData.isEmpty else { return }

        pendingData = [
            [
                "id": UUID().uuidString,
                "title": "Task",
                "subtitle": "Clean your room",
                "date": "Requested on 12/12",
                "points": "50 ⭐️",
                "photo_url": "https://picsum.photos/300"
            ],
            [
                "id": UUID().uuidString,
                "title": "Task",
                "subtitle": "Finish homework",
                "date": "Requested on 11/12",
                "points": "30 ⭐️",
                "photo_url": ""
            ]
        ]
    }

    private func approveItem(at indexPath: IndexPath) {
        let item = pendingData.remove(at: indexPath.row)
        approvedData.insert(item, at: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    private func declineItem(at indexPath: IndexPath) {
        let item = pendingData.remove(at: indexPath.row)
        declinedData.insert(item, at: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

        // MARK: - TableView
        
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
                    photoUrl: data["photo_url"],   // 👈 NEW
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
            
        }
        
        //
        // MARK: - ApprovalCell (WITH PHOTO PREVIEW)
        //
final class ApprovalCell: UITableViewCell {
            
            static let reuseId = "ApprovalCell"
            
            var onApproveTapped: (() -> Void)?
            var onDeclineTapped: (() -> Void)?
            
            // MARK: - Views
            
            private let containerView = UIView()
            
            private let iconView = UIView()
            private let iconImageView = UIImageView()
            
            private let titleLabel = UILabel()
            private let subtitleLabel = UILabel()
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
                
                // Container
                containerView.backgroundColor = UIColor(red: 45/255, green: 48/255, blue: 71/255, alpha: 1)
                containerView.layer.cornerRadius = 16
                containerView.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(containerView)
                
                // Icon
                iconView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
                iconView.layer.cornerRadius = 20
                iconView.translatesAutoresizingMaskIntoConstraints = false
                
                iconImageView.image = UIImage(systemName: "checkmark.circle.fill")
                iconImageView.tintColor = .white
                iconImageView.translatesAutoresizingMaskIntoConstraints = false
                
                iconView.addSubview(iconImageView)
                containerView.addSubview(iconView)
                
                // Labels
                titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                titleLabel.textColor = .white
                
                subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
                subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
                
                dateLabel.font = .systemFont(ofSize: 12)
                dateLabel.textColor = UIColor.white.withAlphaComponent(0.5)
                
                childLabel.font = .systemFont(ofSize: 12, weight: .medium)
                childLabel.textColor = UIColor.white.withAlphaComponent(0.6)
                childLabel.isHidden = true
                
                pointsLabel.font = .systemFont(ofSize: 16, weight: .bold)
                pointsLabel.textColor = .systemYellow
                
                [titleLabel, subtitleLabel, dateLabel, childLabel, pointsLabel].forEach {
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    containerView.addSubview($0)
                }
                
                // Proof Image
                proofImageView.layer.cornerRadius = 8
                proofImageView.clipsToBounds = true
                proofImageView.contentMode = .scaleAspectFill
                proofImageView.translatesAutoresizingMaskIntoConstraints = false
                proofImageView.isHidden = true
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(openImage))
                proofImageView.isUserInteractionEnabled = true
                proofImageView.addGestureRecognizer(tap)
                
                // Buttons
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
                buttonStack.addArrangedSubview(declineButton)
                buttonStack.addArrangedSubview(approveButton)
                
                // Bottom row: photo + buttons
                bottomRow.axis = .horizontal
                bottomRow.alignment = .center
                bottomRow.spacing = 12
                bottomRow.translatesAutoresizingMaskIntoConstraints = false
                
                bottomRow.addArrangedSubview(proofImageView)
                bottomRow.addArrangedSubview(UIView()) // spacer
                bottomRow.addArrangedSubview(buttonStack)
                
                containerView.addSubview(bottomRow)
                
                // MARK: - Constraints
                
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
                    
                    dateLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
                    dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                    
                    childLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
                    childLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                    
                    bottomRow.topAnchor.constraint(equalTo: childLabel.bottomAnchor, constant: 12),
                    bottomRow.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                    bottomRow.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                    bottomRow.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
                    
                    proofImageView.widthAnchor.constraint(equalToConstant: 56),
                    proofImageView.heightAnchor.constraint(equalToConstant: 56),
                    buttonStack.widthAnchor.constraint(equalToConstant: 190),
                    buttonStack.heightAnchor.constraint(equalToConstant: 34)
                ])
            }
            
            // MARK: - Configure
            
            func configure(
                title: String,
                subtitle: String,
                date: String,
                points: String,
                photoUrl: String?,
                childName: String? = nil,
                showButtons: Bool
            ) {
                titleLabel.text = title
                subtitleLabel.text = subtitle
                dateLabel.text = date
                pointsLabel.text = points
                buttonStack.isHidden = !showButtons
                
                // Child name
                if let childName, !childName.isEmpty {
                    childLabel.text = "👤 \(childName)"
                    childLabel.isHidden = false
                } else {
                    childLabel.isHidden = true
                }
                
                // Proof image
                if let photoUrl, !photoUrl.isEmpty, let url = URL(string: photoUrl) {
                    proofImageView.isHidden = false
                    loadImage(from: url)
                } else {
                    proofImageView.isHidden = true
                }
            }
            
            // MARK: - Helpers
            
            private func loadImage(from url: URL) {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    guard let data, let image = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        self?.proofImageView.image = image
                    }
                }.resume()
            }
            
    @objc private func openImage() {
        guard let image = proofImageView.image else { return }

        let overlayVC = ImagePreviewViewController(image: image)
        overlayVC.modalPresentationStyle = .overFullScreen
        overlayVC.modalTransitionStyle = .crossDissolve

        // Present from top-most VC safely
        if let topVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?
            .rootViewController {
            topVC.present(overlayVC, animated: true)
        }
    }

            
            @objc private func approveTapped() { onApproveTapped?() }
            @objc private func declineTapped() { onDeclineTapped?() }
    
        }

