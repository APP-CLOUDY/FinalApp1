import UIKit

final class NewRewardViewController: UIViewController {

    // MARK: - Properties
    // 1. Store real children from Supabase
    private var childrenList: [ChildModel] = []
    // 2. Store selected IDs (UUIDs) for the database
    private var assignedSelections = Set<UUID>()
    // 3. Store selected image
    private var selectedImage: UIImage? {
        didSet { uploadBox.setImage(selectedImage) }
    }

    // ===========================================================
    // MARK: - UI Base Containers
    // ===========================================================

    private let customHeaderView = UIView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()
    private let gradient = CAGradientLayer()

    // Top segment
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

    // ===========================================================
    // MARK: - Reusable UI Components
    // ===========================================================

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

    // ===========================================================
    // MARK: - Form Sections
    // ===========================================================

    private var springViews: [UIView] = []
    private var dreamViews: [UIView] = []
    private var quickViews: [UIView] = []

    // ===========================================================
    // MARK: - Lifecycle
    // ===========================================================
    
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
        applySegment(animated: false)

        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        // FETCH DATA: Load children from DB immediately
        fetchChildren()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    // ===========================================================
    // MARK: - Data Logic (Supabase)
    // ===========================================================
    
    private func fetchChildren() {
        _Concurrency.Task {
            do {
                let data = try await FamilyService.shared.fetchDashboard()
                
                await MainActor.run {
                    self.childrenList = data.children
                    self.updateAssignedMenu()
                }
            } catch {
                print("Error fetching children: \(error)")
            }
        }
    }

    // ===========================================================
    // MARK: - Gradient & Header
    // ===========================================================

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
        titleLabel.text = "New Reward"
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

    // ===========================================================
    // MARK: - Scroll + Stack
    // ===========================================================

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
        springViews = [subtitleLabel, titleField, descriptionView, pointsSpring, claimLimitRow, assignedToRow, uploadBox]
        dreamViews = [subtitleLabel, titleField, descriptionView, pointsDream, assignedToRow, select3DBox]
        quickViews = [subtitleLabel, titleField, descriptionView, pointsQuick, claimLimitRow, rewardTypeRow, assignedToRow]
    }

    // ===========================================================
    // MARK: - Menus
    // ===========================================================

    private func setupMenus() {
        claimLimitRow.setMenu(
            UIMenu(children: claimOptions.map { opt in
                UIAction(title: opt) { [weak self] _ in self?.claimLimitRow.setDetail(opt) }
            })
        )

        rewardTypeRow.setMenu(
            UIMenu(children: rewardTypeOptions.map { name in
                UIAction(title: name) { [weak self] _ in self?.rewardTypeRow.setDetail(name) }
            })
        )
    }
    
    private func updateAssignedMenu() {
        if childrenList.isEmpty {
            assignedToRow.setDetail("No Children Found")
            return
        }
        
        let menuItems = childrenList.map { child in
            UIAction(
                title: child.name,
                state: assignedSelections.contains(child.id) ? .on : .off
            ) { [weak self] _ in
                guard let self = self else { return }
                if self.assignedSelections.contains(child.id) {
                    self.assignedSelections.remove(child.id)
                } else {
                    self.assignedSelections.insert(child.id)
                }
                self.updateAssignedLabel()
                self.updateAssignedMenu()
            }
        }
        
        assignedToRow.setMenu(UIMenu(title: "Select Children", options: .displayInline, children: menuItems))
    }
    
    private func updateAssignedLabel() {
        if assignedSelections.isEmpty {
            assignedToRow.setDetail("Select Child")
            return
        }
        let names = childrenList.filter { assignedSelections.contains($0.id) }.map { $0.name }
        assignedToRow.setDetail(names.joined(separator: ", "))
    }

    // ===========================================================
    // MARK: - Actions
    // ===========================================================

    private func setupActions() {
        uploadBox.onTap = { [weak self] in
            self?.openImagePicker()
        }

        select3DBox.onTap = { [weak self] in
            // Placeholder for 3D picker
        }
    }

    // ===========================================================
    // MARK: - Segment Selection
    // ===========================================================

    @objc private func segmentChanged() { applySegment(animated: true) }

    private func applySegment(animated: Bool) {
        for v in stack.arrangedSubviews where v != segment {
            stack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        let selectedViews: [UIView]
        switch segment.selectedSegmentIndex {
        case 0:
            subtitleLabel.text = "Fun experiences your child can unlock — piece by piece."
            selectedViews = springViews
        case 1:
            subtitleLabel.text = "Big dream rewards your child earns step by step."
            selectedViews = dreamViews
        default:
            subtitleLabel.text = "Quick rewards your child can earn fast."
            selectedViews = quickViews
        }

        selectedViews.forEach { v in
            v.alpha = 0
            stack.addArrangedSubview(v)
        }

        guard animated else {
            selectedViews.forEach { $0.alpha = 1 }
            return
        }

        UIView.animate(withDuration: 0.25) {
            selectedViews.forEach { $0.alpha = 1 }
        }
    }

    // ===========================================================
    // MARK: - Image Picker
    // ===========================================================

    private func openImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true)
    }

    // ===========================================================
    // MARK: - Save / Cancel
    // ===========================================================

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
        
        // Get points based on active segment
        switch segment.selectedSegmentIndex {
        case 0:
            categoryName = "Spring On"
            points = pointsSpring.countValue
            if points <= 0 { missing.append("Points") }
        case 1:
            categoryName = "Dream it"
            points = pointsDream.countValue
            if points <= 0 { missing.append("Points") }
        case 2:
            categoryName = "Quick Rewards"
            points = pointsQuick.countValue
            if points <= 0 { missing.append("Points") }
        default: break
        }

        if !missing.isEmpty {
            let alert = UIAlertController(
                title: "Missing Required Fields",
                message: missing.joined(separator: ", "),
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Get Claim Limit (if present in UI)
        let claimLimit = claimLimitRow.detailText
        
        // Disable UI
        let doneBtn = customHeaderView.subviews.compactMap { $0 as? UIButton }.last
        doneBtn?.isEnabled = false
        doneBtn?.setTitle("Saving...", for: .normal)

        // 2. Call Service
        _Concurrency.Task {
            do {
                let rewardId = try await RewardService.shared.createReward(
                    title: titleField.textValue,
                    description: descriptionView.textValue,
                    points: points,
                    category: categoryName,
                    assignTo: Array(assignedSelections),
                    image: selectedImage, // ✅ Sending Image
                    claimLimit: claimLimit // ✅ Sending Limit
                )
                
                print("Reward Created! ID: \(rewardId)")
                
                await MainActor.run {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("Error: \(error)")
                await MainActor.run {
                    doneBtn?.isEnabled = true
                    doneBtn?.setTitle("Done", for: .normal)
                    
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

// ===========================================================
// MARK: - Image Picker Delegate
// ===========================================================

extension NewRewardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        if let img = info[.originalImage] as? UIImage {
            selectedImage = img
        }
    }
}
