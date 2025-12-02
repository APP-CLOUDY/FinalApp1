import UIKit

final class NewRewardViewController: UIViewController {

    // ===========================================================
    // MARK: - UI Base Containers
    // ===========================================================

    // 1. Custom Header Container
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
    private let assignedOptions = ["Bob", "Jonesh", "Aisha", "Ramesh"]
    private let rewardTypeOptions = ["Experience", "Toy", "Food", "Custom"]

    private var selectedImage: UIImage? {
        didSet { uploadBox.setImage(selectedImage) }
    }

    // ===========================================================
    // MARK: - Form Sections
    // ===========================================================

    private var springViews: [UIView] = []
    private var dreamViews: [UIView] = []
    private var quickViews: [UIView] = []

    // ===========================================================
    // MARK: - Lifecycle
    // ===========================================================
    
    // Force Full Screen
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
        setupCustomHeader() // <--- New Custom Header
        setupScroll()
        setupStack()

        setupHeights()
        setupMenus()
        setupActions()
        buildSections()
        applySegment(animated: false)

        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    // Hide System Nav Bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    // ===========================================================
    // MARK: - Gradient Background
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
    
    // ===========================================================
    // MARK: - Custom Header (Replaces Navigation Bar)
    // ===========================================================
    
    private func setupCustomHeader() {
        customHeaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customHeaderView)
        
        // 1. Title
        let titleLabel = UILabel()
        titleLabel.text = "New Reward"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 2. Cancel Button
        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 17)
        cancelBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. Done Button
        let doneBtn = UIButton(type: .system)
        doneBtn.setTitle("Done", for: .normal)
        doneBtn.setTitleColor(.systemBlue, for: .normal) // Highlight color
        doneBtn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        doneBtn.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        doneBtn.translatesAutoresizingMaskIntoConstraints = false
        
        customHeaderView.addSubview(titleLabel)
        customHeaderView.addSubview(cancelBtn)
        customHeaderView.addSubview(doneBtn)
        
        NSLayoutConstraint.activate([
            // Header Container (Top Safe Area + 44pt height)
            customHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customHeaderView.heightAnchor.constraint(equalToConstant: 50),
            
            // Center Title
            titleLabel.centerXAnchor.constraint(equalTo: customHeaderView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: customHeaderView.centerYAnchor),
            
            // Left Cancel
            cancelBtn.leadingAnchor.constraint(equalTo: customHeaderView.leadingAnchor, constant: 16),
            cancelBtn.centerYAnchor.constraint(equalTo: customHeaderView.centerYAnchor),
            
            // Right Done
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
            // Pin ScrollView to BOTTOM of Header
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

    // ===========================================================
    // MARK: - Heights
    // ===========================================================

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

    // ===========================================================
    // MARK: - Build Sections
    // ===========================================================

    private func buildSections() {

        springViews = [
            subtitleLabel,
            titleField,
            descriptionView,
            pointsSpring,
            claimLimitRow,
            assignedToRow,
            uploadBox
        ]

        dreamViews = [
            subtitleLabel,
            titleField,
            descriptionView,
            pointsDream,
            assignedToRow,
            select3DBox
        ]

        quickViews = [
            subtitleLabel,
            titleField,
            descriptionView,
            pointsQuick,
            claimLimitRow,
            rewardTypeRow,
            assignedToRow
        ]
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

        assignedToRow.setMenu(
            UIMenu(children: assignedOptions.map { name in
                UIAction(title: name) { [weak self] _ in self?.assignedToRow.setDetail(name) }
            })
        )

        rewardTypeRow.setMenu(
            UIMenu(children: rewardTypeOptions.map { name in
                UIAction(title: name) { [weak self] _ in self?.rewardTypeRow.setDetail(name) }
            })
        )
    }

    // ===========================================================
    // MARK: - Actions
    // ===========================================================

    private func setupActions() {
        uploadBox.onTap = { [weak self] in
            self?.openImagePicker()
        }

        select3DBox.onTap = { [weak self] in
            let vc = ThreeDObjectViewController()
            vc.onSelect = { selected in
                self?.select3DBox.setDetail(selected)
            }
            // Since we hid the nav bar, we must manually present or push carefully
            // If using push, we need the nav bar back for the next screen
            self?.navigationController?.setNavigationBarHidden(false, animated: true)
            self?.navigationController?.pushViewController(vc, animated: true)
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
    // MARK: - Save / Cancel (Navigation)
    // ===========================================================

    @objc private func cancelTapped() {
        // "Go back" logic
        navigationController?.popViewController(animated: true)
    }

    @objc private func doneTapped() {

        var missing: [String] = []

        if titleField.textValue.isEmpty {
            missing.append("Title")
        }

        switch segment.selectedSegmentIndex {
        case 0:
            if pointsSpring.countValue <= 0 { missing.append("Points") }
        case 1:
            if pointsDream.countValue <= 0 { missing.append("Points") }
            if select3DBox.selectedValue == nil { missing.append("3D Object") }
        case 2:
            if pointsQuick.countValue <= 0 { missing.append("Points") }
            if claimLimitRow.detailText == nil { missing.append("Claim Limit") }
            if rewardTypeRow.detailText == nil { missing.append("Reward Type") }
        default: break
        }

        if assignedToRow.detailText == nil {
            missing.append("Assigned To")
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

        print("Saving reward...")
        navigationController?.popViewController(animated: true)
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
