//
//  NewRewardViewController.swift
//  Cloudyyy_App
//

import UIKit

final class NewRewardViewController: UIViewController {

    // ===========================================================
    // MARK: - UI Base Containers
    // ===========================================================
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
    private let select3DBox = Select3DCard()     // IMPORTANT

    private let claimOptions = ["Once", "Daily", "Weekly", "Monthly", "Unlimited"]
    private let assignedOptions = ["Bob", "Jonesh", "Aisha", "Ramesh"]
    private let rewardTypeOptions = ["Experience", "Toy", "Food", "Custom"]

    private var selectedImage: UIImage? {
        didSet { uploadBox.setImage(selectedImage) }
    }

    func userAddedFirstTask() {
        UserDefaults.standard.set(false, forKey: "isFirstTimeUser")
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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "New Reward"

        setupNavigationBar()
        setupGradient()
        setupScroll()
        setupStack()

        setupHeights()
        setupMenus()
        setupActions()
        buildSections()
        applySegment(animated: false)

        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    // ===========================================================
    // MARK: - Navigation Bar
    // ===========================================================
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
    }

    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
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
    // MARK: - Scroll + Stack
    // ===========================================================
    private func setupScroll() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
            select3DBox          // IMPORTANT
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
    // MARK: - Menus (Floating Menu)
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
    // MARK: - Save
    // ===========================================================
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

        // -------------------------
        // Create and save reward
        // -------------------------
        guard let kid = ChildManager.shared.selectedKid else {
            navigationController?.popViewController(animated: true)
            return
        }

        // pick points based on selected segment
        let points =
            segment.selectedSegmentIndex == 0 ? pointsSpring.countValue :
            segment.selectedSegmentIndex == 1 ? pointsDream.countValue :
            pointsQuick.countValue

        let id = UUID().uuidString
        let title = titleField.textValue
        let subtitle = descriptionView.textValue

        let type =
            segment.selectedSegmentIndex == 0 ? "spring" :
            segment.selectedSegmentIndex == 1 ? "dream" : "quick"

        var newReward = RewardDetailItem(
            id: id,
            title: title,
            subtitle: subtitle,
            points: points,
            imageName: nil,
            isActive: true,
            type: type
        )

        // set imageName if upload selected (optional)
        if let img = selectedImage {
            // you may want to save the image to disk and store the filename
            // for demo, we keep imageName nil
            newReward.imageName = nil
        }

        // add to manager
        ChildManager.shared.addReward(newReward, for: kid.id)

        // mark user as not first-time
        UserDefaults.standard.set(false, forKey: "isFirstTimeUser")

        print("Saving reward... -> added to ChildManager")
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

