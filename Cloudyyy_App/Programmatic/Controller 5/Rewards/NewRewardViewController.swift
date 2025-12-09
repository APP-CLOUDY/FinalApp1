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
    private let titleField = StyledTextField(placeholder: "Title *")
    private let descriptionView = StyledTextView(placeholder: "Description (Optional)")

    private let pointsSpring = PointsRow()
    private let pointsDream = PointsRow()
    private let pointsQuick = PointsRow()

    private let claimLimitRow = SelectRow(title: "Claim Limit")
    private let assignedToRow = SelectRow(title: "Assigned To")
    private let rewardTypeRow = SelectRow(title: "Reward Type")

    private let uploadBox = UploadBoxCard()
    private let select3DBox = Select3DCard()

    private let claimOptions = ["Once", "Daily", "Weekly", "Monthly", "Unlimited"]
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
            // 1. Hide Segment
            segment.isHidden = true
            
            // 2. Set Category manually
            if category == "Spring On" { segment.selectedSegmentIndex = 0 }
            else if category == "Dream it" { segment.selectedSegmentIndex = 1 }
            else { segment.selectedSegmentIndex = 2 } // Quick
            
            // 3. Populate Fields
            titleField.textValue = item.title
            descriptionView.textValue = item.description ?? ""
            existingImageUrl = item.image_url
            
            // ✅ Populate Extra Fields (Claim Limit & Type)
            if let limit = item.claim_limit { claimLimitRow.setDetail(limit) }
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
            else if category == "Dream it" { pointsDream.countValue = item.points }
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
                    
                    self.updateAssignedMenu()
                    self.updateAssignedLabel()
                }
            } catch {
                print("Error fetching data: \(error)")
            }
        }
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
        stack.spacing = 16

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
        titleField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        descriptionView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        pointsSpring.heightAnchor.constraint(equalToConstant: 52).isActive = true
        pointsDream.heightAnchor.constraint(equalToConstant: 52).isActive = true
        pointsQuick.heightAnchor.constraint(equalToConstant: 52).isActive = true
        claimLimitRow.heightAnchor.constraint(equalToConstant: 52).isActive = true
        assignedToRow.heightAnchor.constraint(equalToConstant: 52).isActive = true
        rewardTypeRow.heightAnchor.constraint(equalToConstant: 52).isActive = true
        uploadBox.heightAnchor.constraint(equalToConstant: 160).isActive = true
        select3DBox.heightAnchor.constraint(equalToConstant: 160).isActive = true
    }

    private func buildSections() {
        // Add Delete Button to views
        springViews = [subtitleLabel, titleField, descriptionView, pointsSpring, claimLimitRow, assignedToRow, uploadBox, deleteButton]
        dreamViews = [subtitleLabel, titleField, descriptionView, pointsDream, assignedToRow, select3DBox, deleteButton]
        quickViews = [subtitleLabel, titleField, descriptionView, pointsQuick, claimLimitRow, rewardTypeRow, assignedToRow, deleteButton]
    }

    // MARK: - Menus
    private func setupMenus() {
        claimLimitRow.setMenu(UIMenu(children: claimOptions.map { opt in
            UIAction(title: opt) { [weak self] _ in self?.claimLimitRow.setDetail(opt) }
        }))
        rewardTypeRow.setMenu(UIMenu(children: rewardTypeOptions.map { name in
            UIAction(title: name) { [weak self] _ in self?.rewardTypeRow.setDetail(name) }
        }))
    }
    
    private func updateAssignedMenu() {
        if childrenList.isEmpty {
            assignedToRow.setDetail("No Children Found"); return
        }
        let menuItems = childrenList.map { child in
            UIAction(title: child.name, state: assignedSelections.contains(child.id) ? .on : .off) { [weak self] _ in
                guard let self = self else { return }
                if self.assignedSelections.contains(child.id) { self.assignedSelections.remove(child.id) }
                else { self.assignedSelections.insert(child.id) }
                self.updateAssignedLabel()
                self.updateAssignedMenu()
            }
        }
        assignedToRow.setMenu(UIMenu(title: "Select Children", options: .displayInline, children: menuItems))
    }
    
    private func updateAssignedLabel() {
        if assignedSelections.isEmpty { assignedToRow.setDetail("Select Child"); return }
        let names = childrenList.filter { assignedSelections.contains($0.id) }.map { $0.name }
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
            _Concurrency.Task {
                try? await RewardService.shared.deleteReward(rewardId: item.id)
                await MainActor.run { self.navigationController?.popViewController(animated: true) }
            }
        }))
        present(alert, animated: true)
    }

    // MARK: - Segment Selection
    @objc private func segmentChanged() { applySegment(animated: true) }

    private func applySegment(animated: Bool) {
        for v in stack.arrangedSubviews where v != segment {
            stack.removeArrangedSubview(v); v.removeFromSuperview()
        }

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

        selectedViews.forEach { v in
            v.alpha = 0
            // Hide delete button if in Create mode
            if v == deleteButton, case .create = mode {
                // Do not add delete button
            } else {
                stack.addArrangedSubview(v)
            }
        }

        guard animated else { selectedViews.forEach { $0.alpha = 1 }; return }
        UIView.animate(withDuration: 0.25) { selectedViews.forEach { $0.alpha = 1 } }
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
        
        // 1. Validation
        var missing: [String] = []
        if titleField.textValue.isEmpty { missing.append("Title") }
        if assignedSelections.isEmpty { missing.append("Assigned To") }

        var points = 0
        var categoryName = "Quick Rewards"
        
        switch segment.selectedSegmentIndex {
        case 0: categoryName = "Spring On"; points = pointsSpring.countValue
        case 1: categoryName = "Dream it"; points = pointsDream.countValue
        case 2: categoryName = "Quick Rewards"; points = pointsQuick.countValue
        default: break
        }
        
        if points <= 0 { missing.append("Points") }

        if !missing.isEmpty {
            let alert = UIAlertController(title: "Missing Fields", message: missing.joined(separator: ", "), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // ✅ Capture Extra Fields
        let claimLimit = claimLimitRow.detailText
        let subType = rewardTypeRow.detailText
        
        let doneBtn = customHeaderView.subviews.compactMap { $0 as? UIButton }.last
        doneBtn?.isEnabled = false
        doneBtn?.setTitle("Saving...", for: .normal)

        // 2. Call Service
        _Concurrency.Task {
            do {
                switch mode {
                case .create:
                    _ = try await RewardService.shared.createReward(
                        title: titleField.textValue,
                        description: descriptionView.textValue,
                        points: points,
                        category: categoryName,
                        assignTo: Array(assignedSelections),
                        image: selectedImage,
                        claimLimit: claimLimit,
                        subType: subType // ✅ Passing subType
                    )
                case .edit(let item, _):
                    try await RewardService.shared.updateReward(
                        rewardId: item.id,
                        title: titleField.textValue,
                        description: descriptionView.textValue,
                        points: points,
                        category: categoryName,
                        assignTo: Array(assignedSelections),
                        image: selectedImage,
                        existingImageUrl: existingImageUrl,
                        claimLimit: claimLimit,
                        subType: subType // ✅ Passing subType
                    )
                }
                
                await MainActor.run { self.navigationController?.popViewController(animated: true) }
            } catch {
                await MainActor.run {
                    doneBtn?.isEnabled = true; doneBtn?.setTitle("Done", for: .normal)
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
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
