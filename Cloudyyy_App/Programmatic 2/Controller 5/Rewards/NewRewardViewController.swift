import UIKit

// ✅ Define Modes
enum RewardFormMode {
    case create
    case edit(RewardItemModel, category: String) // Need basic info + category context
}

final class NewRewardViewController: UIViewController {
    
    // MARK: - Properties
    var mode: RewardFormMode = .create
    
    private var childrenList: [ChildModel] = []
    private var assignedSelections = Set<UUID>()
    private var selectedImage: UIImage? {
        didSet { uploadBox.setImage(selectedImage) }
    }
    private var existingImageUrl: String? // To keep track if we don't upload a new one
    
    private var selectedClaimLimit: String?
    
    private let approvalRow = ApprovalToggleRow(title: "Approval")


    // MARK: - UI Base Containers
    private let customHeaderView = UIView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()
    private let gradient = CAGradientLayer()

    // Top segment (Hidden in Edit Mode)
    private let segment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Spring On", "Dream It", "Quick"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        sc.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.12)
        sc.layer.cornerRadius = 12
        sc.layer.masksToBounds = true
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.7)], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return sc
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white.withAlphaComponent(0.75)
        l.font = .systemFont(ofSize: 13)
        l.numberOfLines = 0
        return l
    }()
    
    // UI Components
    private let springInput = CombinedTitleNotesView()
    private let dreamInput = CombinedTitleNotesView()
    private let quickInput = CombinedTitleNotesView()
    
    private let pointsSpring = PointsRow()
    private let pointsDream = PointsRow()
    private let pointsQuick = PointsRow()
    
    private let claimLimitRow = SelectRow(title: "Claim Limit")
    private let assignedToRow = SelectRow(title: "Assigned To")
    private let rewardTypeRow = SelectRow(title: "Reward Type")
    
    private let uploadBox = UploadBoxCard()
    private let select3DBox = Select3DCard()
    
    private let claimOptions: [(title: String, isCustom: Bool)] = [
        ("Once", false),
        ("Daily", false),
        ("Weekdays", false),
        ("Weekends", false),
        ("Weekly", false),
        ("Monthly", false),
        ("Every 3 Months", false),
        ("Yearly", false),
        ("Custom", true)
    ]
    
    private let rewardTypeOptions = ["Experience", "Toy", "Food", "Custom"]
    
    // ✅ Delete Button
    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Delete Reward", for: .normal)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return btn
    }()
    
    // Form Sections
    private var springViews: [UIView] = []
    private var dreamViews: [UIView] = []
    private var quickViews: [UIView] = []
    
    // MARK: - Lifecycle
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupGradient()
        setupCustomHeader()
        setupScroll()
        setupStack()
        
        setupHeights()
        setupMenus()
        setupActions()
        
        buildSections()
        
        // Mode Handling
        configureForMode()
        
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        // Fetch Children (and assignments if editing)
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ✅ Force Hide System Navigation Bar so only our Custom Header shows
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    // MARK: - Mode Logic
    private func configureForMode() {
        switch mode {
        case .create:
            deleteButton.isHidden = true
            // Default
            applySegment(animated: false)
            
        case .edit(let item, let category):
            // 1. Hide Segment (Locked Category)
            segment.isHidden = true
            
            if let approval = item.approval_required {
                approvalRow.setOn(approval)
            }

            
            // 2. Set Category manually
            if category == "Spring On" { segment.selectedSegmentIndex = 0 }
            else if category == "Dream It" { segment.selectedSegmentIndex = 1 }
            else { segment.selectedSegmentIndex = 2 } // Quick
            
            // 3. Populate Fields
            // 3. Populate Fields into the correct input block
            switch category {
            case "Spring On":
                springInput.titleText = item.title
                springInput.notesText = item.description ?? ""
                
            case "Dream It":
                dreamInput.titleText = item.title
                dreamInput.notesText = item.description ?? ""
                
            default: // Quick
                quickInput.titleText = item.title
                quickInput.notesText = item.description ?? ""
            }
            
            existingImageUrl = item.image_url
            
            // ✅ Populate Extra Fields (Claim Limit & Type)
            if let limit = item.claim_limit {
                selectedClaimLimit = limit
                claimLimitRow.setDetail(limit)
            }

            if let type = item.reward_sub_type { rewardTypeRow.setDetail(type) }
            
            // Load existing image if available
            if let urlStr = item.image_url, let url = URL(string: urlStr) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                        DispatchQueue.main.async { self.selectedImage = img }
                    }
                }
            }
            
            // Set points based on category view
            if category == "Spring On" { pointsSpring.countValue = item.points }
            else if category == "Dream It" { pointsDream.countValue = item.points }
            else { pointsQuick.countValue = item.points }
            
            deleteButton.isHidden = false
            applySegment(animated: false)
        }
    }
    
    // MARK: - Data Logic
    private func fetchData() {
        _Concurrency.Task {
            do {
                // 1. Fetch Children
                let dashboardData = try await FamilyService.shared.fetchDashboard()
                
                // 2. If Editing, fetch Assignments
                var existingAssignments: [UUID] = []
                if case .edit(let item, _) = mode {
                    existingAssignments = try await RewardService.shared.fetchAssignments(for: item.id)
                }
                
                await MainActor.run {
                    self.childrenList = dashboardData.children

                    if case .edit = mode {
                        self.assignedSelections = Set(existingAssignments)
                    }

                    self.handleAssignedToVisibility()

                    // ✅ ADD THESE (CRITICAL)
                    self.buildSections()
                    self.applySegment(animated: false)
                }

            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }
    
    private func handleAssignedToVisibility() {

        let count = childrenList.count

        if count == 0 {
            assignedToRow.isHidden = true
            return
        }

        if count == 1 {
            let onlyChild = childrenList.first!
            assignedSelections = [onlyChild.id]
            assignedToRow.isHidden = true
            return
        }

        // ✅ MULTIPLE CHILDREN
        assignedToRow.isHidden = false

        updateAssignedMenu()     // ✅ MUST
        updateAssignedLabel()    // ✅ MUST
    }

    // MARK: - Gradient & Header
    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func setupCustomHeader() {
        customHeaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customHeaderView)
        
        let titleLabel = UILabel()
        // Update Title based on Mode
        if case .edit = mode { titleLabel.text = "Edit Reward" }
        else { titleLabel.text = "New Reward" }
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 17)
        cancelBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        
        let doneBtn = UIButton(type: .system)
        doneBtn.setTitle("Done", for: .normal)
        doneBtn.setTitleColor(.systemBlue, for: .normal)
        doneBtn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        doneBtn.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        doneBtn.translatesAutoresizingMaskIntoConstraints = false
        
        customHeaderView.addSubview(titleLabel)
        customHeaderView.addSubview(cancelBtn)
        customHeaderView.addSubview(doneBtn)
        
        NSLayoutConstraint.activate([
            customHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customHeaderView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.centerXAnchor.constraint(equalTo: customHeaderView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: customHeaderView.centerYAnchor),
            
            cancelBtn.leadingAnchor.constraint(equalTo: customHeaderView.leadingAnchor, constant: 16),
            cancelBtn.centerYAnchor.constraint(equalTo: customHeaderView.centerYAnchor),
            
            doneBtn.trailingAnchor.constraint(equalTo: customHeaderView.trailingAnchor, constant: -16),
            doneBtn.centerYAnchor.constraint(equalTo: customHeaderView.centerYAnchor)
        ])
    }
    
    // MARK: - Scroll + Stack
    private func setupScroll() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        // ✅ Ensure scroll interaction works well with keyboard
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: customHeaderView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func setupStack() {
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])
        
        segment.heightAnchor.constraint(equalToConstant: 44).isActive = true
        stack.addArrangedSubview(segment)
    }
    
    private func setupHeights() {
        // Combined Title + Notes block — start with a comfortable minimum but allow growth
        springInput.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
        dreamInput.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
        quickInput.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
        
        pointsSpring.heightAnchor.constraint(equalToConstant: 56).isActive = true
        pointsDream.heightAnchor.constraint(equalToConstant: 56).isActive = true
        pointsQuick.heightAnchor.constraint(equalToConstant: 56).isActive = true
        claimLimitRow.heightAnchor.constraint(equalToConstant: 56).isActive = true
        assignedToRow.heightAnchor.constraint(equalToConstant: 56).isActive = true
        rewardTypeRow.heightAnchor.constraint(equalToConstant: 56).isActive = true
        approvalRow.heightAnchor.constraint(equalToConstant: 56).isActive = true

        
        uploadBox.heightAnchor.constraint(equalToConstant: 160).isActive = true
        select3DBox.heightAnchor.constraint(equalToConstant: 160).isActive = true
    }
    
    private func buildSections() {
        
        let assignedBlock: [UIView] = assignedToRow.isHidden ? [] : [assignedToRow]
        
        springViews = [subtitleLabel, springInput, pointsSpring] + assignedBlock + [uploadBox]
        
        dreamViews  = [subtitleLabel, dreamInput, pointsDream] + assignedBlock + [select3DBox]
        
        quickViews  = [subtitleLabel, quickInput, pointsQuick, approvalRow , claimLimitRow, rewardTypeRow]
        + assignedBlock
        
    }
    // MARK: - Menus
        private func setupMenus() {
            
            claimLimitRow.setMenu(
                UIMenu(children: [
                    
                    UIAction(title: "Once") { [weak self] _ in
                        self?.claimLimitRow.setDetail("Once")
                        self?.selectedClaimLimit = "Once"
                    },
                    
                    UIAction(title: "Daily") { [weak self] _ in
                        self?.selectedClaimLimit = "Daily"
                        self?.claimLimitRow.setDetail("Daily")
                    },

                    
                    UIAction(title: "Weekdays") { [weak self] _ in
                        self?.claimLimitRow.setDetail("Weekdays")
                        self?.selectedClaimLimit = "Weekdays"
                    },
                    
                    UIAction(title: "Weekends") { [weak self] _ in
                        self?.claimLimitRow.setDetail("Weekends")
                        self?.selectedClaimLimit = "Weekends"
                    },
                    
                    UIAction(title: "Weekly") { [weak self] _ in
                        self?.selectedClaimLimit = "Weekly"
                        self?.claimLimitRow.setDetail("Weekly")
                    },

                    
                    UIAction(title: "Monthly") { [weak self] _ in
                        self?.claimLimitRow.setDetail("Monthly")
                        self?.selectedClaimLimit = "Monthly"
                    },
                    
                    UIAction(title: "Yearly") { [weak self] _ in
                        self?.claimLimitRow.setDetail("Yearly")
                        self?.selectedClaimLimit = "Yearly"
                    }

                ])
            )
            rewardTypeRow.setMenu(
                UIMenu(
                    title: "Reward Type",
                    children: rewardTypeOptions.map { option in
                        UIAction(title: option) { [weak self] _ in
                            self?.rewardTypeRow.setDetail(option)
                        }
                    }
                )
            )
        }
        

    
    private func updateAssignedMenu() {
        if childrenList.isEmpty { return }

        var items: [UIMenuElement] = []

        // 1️⃣ Add ALL option
        if childrenList.count > 1 {
            let allSelected = assignedSelections.count == childrenList.count

            let allAction = UIAction(
                title: allSelected ? "Deselect" : "All",
                state: allSelected ? .on : .off
            ) { [weak self] _ in
                guard let self = self else { return }

                if allSelected {
                    self.assignedSelections.removeAll()
                } else {
                    self.assignedSelections = Set(self.childrenList.map { $0.id })
                }

                self.updateAssignedLabel()
                self.updateAssignedMenu()
            }

            items.append(allAction)
        }

        // 2️⃣ Add individual children
        for child in childrenList {
            let selected = assignedSelections.contains(child.id)

            let action = UIAction(title: child.name, state: selected ? .on : .off) { [weak self] _ in
                guard let self = self else { return }

                if selected {
                    self.assignedSelections.remove(child.id)
                } else {
                    self.assignedSelections.insert(child.id)
                }

                self.updateAssignedLabel()
                self.updateAssignedMenu()
            }

            items.append(action)
        }

        assignedToRow.setMenu(
            UIMenu(title: "Select Children", options: .displayInline, children: items)
        )
    }

    private func updateAssignedLabel() {
        // If only one child, label is hidden so keep detail empty
        if childrenList.count == 1 {
            assignedToRow.setDetail("")
            return
        }

        if assignedSelections.isEmpty {
            assignedToRow.setDetail("Select")
            return
        }

        let names = childrenList
            .filter { assignedSelections.contains($0.id) }
            .map { $0.name }

        assignedToRow.setDetail(names.joined(separator: ", "))
    }

    
    // MARK: - Actions
    private func setupActions() {
        uploadBox.onTap = { [weak self] in self?.openImagePicker() }
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    @objc private func deleteTapped() {
        guard case .edit(let item, _) = mode else { return }
        
        let alert = UIAlertController(title: "Delete Reward?", message: "This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            
            // Disable button to prevent double taps
            self.deleteButton.isEnabled = false
            self.deleteButton.setTitle("Deleting...", for: .normal)
            
            _Concurrency.Task {
                do {
                    // ✅ Pass the image URL to the service for cleanup
                    try await RewardService.shared.deleteReward(rewardId: item.id, imageUrl: item.image_url)
                    
                    await MainActor.run {
                        self.navigationController?.popViewController(animated: true)
                    }
                } catch {
                    print("Delete failed: \(error)")
                    await MainActor.run {
                        self.deleteButton.isEnabled = true
                        self.deleteButton.setTitle("Delete Reward", for: .normal)
                    }
                }
            }
        }))
        present(alert, animated: true)
    }
    
    // MARK: - Segment Selection
    @objc private func segmentChanged() { applySegment(animated: true) }
    
    private func applySegment(animated: Bool) {

        // Remove all arranged subviews except the segment control
        for v in stack.arrangedSubviews where v != segment {
            stack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        // Decide which views to show
        let selectedViews: [UIView]
        switch segment.selectedSegmentIndex {
        case 0:
            subtitleLabel.text = "Fun experiences your child can unlock."
            selectedViews = springViews
        case 1:
            subtitleLabel.text = "Big dream rewards step by step."
            selectedViews = dreamViews
        default:
            subtitleLabel.text = "Quick rewards your child can earn fast."
            selectedViews = quickViews
        }

        // Add the views with fade-in animation
        selectedViews.forEach { v in
            v.alpha = 0
            stack.addArrangedSubview(v)
        }

        // Add delete button ONLY in Edit mode
        if case .edit = mode {
            deleteButton.alpha = 0
            stack.addArrangedSubview(deleteButton)
        }

        let viewsToAnimate = stack.arrangedSubviews

        guard animated else {
            viewsToAnimate.forEach { $0.alpha = 1 }
            return
        }

        UIView.animate(withDuration: 0.25) {
            viewsToAnimate.forEach { $0.alpha = 1 }
            self.view.layoutIfNeeded()
        }
    }

    // Helper
    private var modeIsEdit: Bool {
        if case .edit = mode { return true }
        return false
    }

    
    // MARK: - Image Picker
    private func openImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true)
    }
    
    // MARK: - Save / Cancel
    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
        
        // -----------------------------------------
        // 1️⃣ Determine which Title/Description to use
        // -----------------------------------------
        var title = ""
        var notes = ""
        
        switch segment.selectedSegmentIndex {
        case 0:
            title = springInput.titleText
            notes = springInput.notesText
        case 1:
            title = dreamInput.titleText
            notes = dreamInput.notesText
        case 2:
            title = quickInput.titleText
            notes = quickInput.notesText
        default:
            break
        }
        
        // -----------------------------------------
        // 2️⃣ Validation
        // -----------------------------------------
        var missing: [String] = []
        if title.isEmpty { missing.append("Title") }
        if childrenList.count > 1 && assignedSelections.isEmpty {
            missing.append("Assigned To")
        }
        
        var points = 0
        var categoryName = "Quick Rewards"
        
        switch segment.selectedSegmentIndex {
        case 0:
            categoryName = "Spring On"
            points = pointsSpring.countValue
        case 1:
            categoryName = "Dream It"
            points = pointsDream.countValue
        case 2:
            categoryName = "Quick Rewards"
            points = pointsQuick.countValue
        default:
            break
        }
        
        if points <= 0 { missing.append("Points") }
        
        if !missing.isEmpty {
            let alert = UIAlertController(
                title: "Missing Fields",
                message: missing.joined(separator: ", "),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        
        // -----------------------------------------
        // 3️⃣ Extra Fields
        // -----------------------------------------
        let claimLimit: String? =
            categoryName == "Quick Rewards"
            ? selectedClaimLimit
            : nil

        let subType = rewardTypeRow.detailText
        
        let approvalRequired =
            categoryName == "Quick Rewards"
            ? approvalRow.isOn
            : nil

        
        let doneBtn = customHeaderView.subviews.compactMap { $0 as? UIButton }.last
        doneBtn?.isEnabled = false
        doneBtn?.setTitle("Saving...", for: .normal)
        
        // ✅ SAFETY: auto-assign all children if none selected
        if childrenList.count > 1 && assignedSelections.isEmpty {
            assignedSelections = Set(childrenList.map { $0.id })
        }

        
        // -----------------------------------------
        // 4️⃣ Network Call (Create or Edit)
        // -----------------------------------------
        _Concurrency.Task {
            do {
                switch mode {
                case .create:
                    _ = try await RewardService.shared.createReward(
                        title: title,
                        description: notes,
                        points: points,
                        category: categoryName,
                        assignTo: Array(assignedSelections),
                        image: selectedImage,
                        claimLimit: claimLimit,
                        subType: subType,
                        approvalRequired:    approvalRequired
                    )
                    
                case .edit(let item, _):
                    try await RewardService.shared.updateReward(
                        rewardId: item.id,
                        title: title,
                        description: notes,
                        points: points,
                        category: categoryName,
                        assignTo: Array(assignedSelections),
                        image: selectedImage,
                        existingImageUrl: existingImageUrl,
                        claimLimit: claimLimit,
                        subType: subType,
                        approvalRequired:    approvalRequired
                    )
                }
                
                await MainActor.run {
                    self.navigationController?.popViewController(animated: true)
                }
                
            } catch {
                await MainActor.run {
                    doneBtn?.isEnabled = true
                    doneBtn?.setTitle("Done", for: .normal)
                    
                    let alert = UIAlertController(
                        title: "Error",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
extension NewRewardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { picker.dismiss(animated: true) }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let img = info[.originalImage] as? UIImage { selectedImage = img }
    }
}
