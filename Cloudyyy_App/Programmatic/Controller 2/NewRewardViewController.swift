import UIKit

// MARK: - NewRewardViewController (complete)
class NewRewardViewController: UIViewController {
    
    // MARK: UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()
    private let gradient = CAGradientLayer()
    
    // Segmented control
    private let segment: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Spring On", "Dream It", "Quick"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        sc.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.12)
        sc.layer.cornerRadius = 12
        sc.layer.masksToBounds = true
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.85)], for: .normal)
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
    
    // Inputs / Rows (reusable)
    private let titleField = StyledTextField(placeholder: "Title *")
    private let descriptionView = StyledTextView(placeholder: "Description (Optional)")
    private let pointsRowSpring = PointsRow()
    private let pointsRowDream = PointsRow()
    private let pointsRowQuick = PointsRow()
    private let claimLimitRow = SelectRow(title: "Claim Limit")
    private let assignedRow = SelectRow(title: "Assigned To *")
    private let uploadBox = UploadBox()
    private let rewardTypeRow = SelectRow(title: "Reward Type * ")
    private let select3DBox = Select3DBox()
    
    // Data for pickers
    private let claimOptions = ["Once","Daily", "Weekly", "Monthly", "Unlimited"]
    private let assignedOptions = ["Bob", "Jonesh", "Aisha", "Ramesh"]
    
    // Form arrays
    private var springOnViews: [UIView] = []
    private var dreamItViews: [UIView] = []
    private var quickViews: [UIView] = []
     
    // Stored image
    private var selectedImage: UIImage? {
        didSet {
            uploadBox.setImage(selectedImage)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Reward"
        view.backgroundColor = .black
        
        setupNavigationBar()
        setupGradient()
        setupScrollView()
        setupStack()
        configureRows()
        setupSegmentAction()
        buildFormArrays()
        updateFormForSelectedSegment(animated: false)
        
        
        assignedRow.onTap = { [weak self] in
            let vc = AssignedToViewController()
            vc.onSelection = { selectedKids in
                self?.assignedRow.setDetail(selectedKids.joined(separator: ", "))
            }
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    // MARK: - Navigation bar
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
    }
    
    // MARK: - Gradient
    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 8/255, green: 12/255, blue: 48/255, alpha: 1).cgColor,
            UIColor(red: 12/255, green: 20/255, blue: 75/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    // MARK: - ScrollView & Stack setup
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor) // allow under tab bar
        ])
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor) // CRUCIAL
        ])
    }
    
    private func setupStack() {
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])
        
        // Add always-on segment at top
        segment.heightAnchor.constraint(equalToConstant: 44).isActive = true
        stack.addArrangedSubview(segment)
    }
    
    // MARK: - Configure clickable rows
    private func configureRows() {
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        claimLimitRow.setDetail("Once")

        titleField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        descriptionView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        pointsRowSpring.heightAnchor.constraint(equalToConstant: 52).isActive = true
        pointsRowQuick.heightAnchor.constraint(equalToConstant: 52).isActive = true
        pointsRowDream.heightAnchor.constraint(equalToConstant: 52).isActive = true
        claimLimitRow.heightAnchor.constraint(equalToConstant: 52).isActive = true
        assignedRow.heightAnchor.constraint(equalToConstant: 52).isActive = true
        rewardTypeRow.heightAnchor.constraint(equalToConstant: 52).isActive = true
        uploadBox.heightAnchor.constraint(equalToConstant: 160).isActive = true
        select3DBox.heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        // Add actions
        claimLimitRow.onTap = { [weak self] in self?.presentClaimPicker() }
        assignedRow.onTap = { [weak self] in self?.presentAssignedPicker() }
        rewardTypeRow.onTap = { [weak self] in self?.showRewardTypeList() }
        select3DBox.onTap = { [weak self] in self?.show3DSelection() }
        uploadBox.onTap = { [weak self] in self?.openImagePicker() }
    }
    
    // MARK: - Segment handling
    private func setupSegmentAction() {
        segment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }
    
    private func buildFormArrays() {
        // Spring On:
        springOnViews = [
            subtitleLabel,
            titleField,
            descriptionView,
            pointsRowSpring,
            claimLimitRow,
            assignedRow,
            uploadBox
        ]
        
        // Dream It (no claim limit; has 3D select)
        dreamItViews = [
            subtitleLabel,
            titleField,
            descriptionView,
            pointsRowDream,
            assignedRow,
            select3DBox,
            
        ]
        
        // Quick (shorter)
        quickViews = [
            subtitleLabel,
            titleField,
            descriptionView,
            pointsRowQuick,
            claimLimitRow,
            rewardTypeRow,
            assignedRow
        ]
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        updateFormForSelectedSegment(animated: true)
    }
    
    
    private func updateFormForSelectedSegment(animated: Bool) {
        
        // Remove all views except segmented control
        for v in stack.arrangedSubviews where v != segment {
            stack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        
        // Pick the correct content
        var items: [UIView] = []
        
        switch segment.selectedSegmentIndex {
        case 0:
            subtitleLabel.text = "Fun experiences your child can unlock — like trips or outings. - piece by piece"
            items = springOnViews
            
        case 1:
            subtitleLabel.text = "Big things your child wants to earn — built step by step."
            items = dreamItViews
            
        default:
            subtitleLabel.text = "Small treats or privileges your child can earn quickly."
            items = quickViews
        }
        
        // Add new arranged views
        for v in items {
            v.alpha = 0      // start faded
            stack.addArrangedSubview(v)
        }
        
        view.layoutIfNeeded()
        
        guard animated else {
            for v in items { v.alpha = 1 }
            return
        }
        
        // Soft fade-in animation (super smooth)
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: {
            for v in items { v.alpha = 1 }
        })
        
        
    }
    
    // MARK: - Pickers / Actions
    
    private func presentClaimPicker() {
        let ac = UIAlertController(title: "Claim Limit", message: nil, preferredStyle: .actionSheet)
        claimOptions.forEach { opt in
            ac.addAction(UIAlertAction(title: opt, style: .default, handler: { [weak self] _ in
                self?.claimLimitRow.setDetail(opt)
            }))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func presentAssignedPicker() {
        let ac = UIAlertController(title: "Assign To", message: nil, preferredStyle: .actionSheet)
        assignedOptions.forEach { opt in
            ac.addAction(UIAlertAction(title: opt, style: .default, handler: { [weak self] _ in
                self?.assignedRow.setDetail(opt)
            }))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    // Replace show3DSelection()
    private func show3DSelection() {
        let vc = ThreeDObjectViewController()
        vc.onSelect = { [weak self] objectName in
            self?.select3DBox.setDetail(objectName)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Replace showRewardTypeList()
    private func showRewardTypeList() {
        let vc = RewardTypeViewController()
        vc.onSelect = { [weak self] selection in
            self?.rewardTypeRow.setDetail(selection)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Image Picker
    private func openImagePicker() {
        // UIImagePickerController (photo library)
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true)
    }
    
    // MARK: Buttons
    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func doneTapped() {
        
        let titleText = titleField.textValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let assignedText = assignedRow.detailText ?? ""
        let claimLimitText = claimLimitRow.detailText ?? ""
        let rewardTypeText = rewardTypeRow.detailText ?? ""
        let selected3D = select3DBox.selectedValue ?? ""
        let pointsValueDream = pointsRowDream.countValue
        let pointsValueQuick = pointsRowQuick.countValue
        let pointsValueSpring = pointsRowSpring.countValue
        
        
        var missing: [String] = []
        
        // Required: Title
        if titleText.isEmpty { missing.append("Title") }
        
        // Required: Points
        switch segment.selectedSegmentIndex {

        case 0: // Spring On
            if pointsRowSpring.countValue <= 0 { missing.append("Points") }

        case 1: // Dream It
            if pointsRowDream.countValue <= 0 { missing.append("Points") }

        case 2: // Quick
            if pointsRowQuick.countValue <= 0 { missing.append("Points") }

        default: break
        }

        
        // Required: Assigned To
        if assignedText.isEmpty { missing.append("Assigned To") }
        
        // Segmented-specific requirements
        switch segment.selectedSegmentIndex {
            
        case 0: // Spring On
            // Claim Limit optional (you said default is Once)
            break
            
        case 1: // Dream It
            if selected3D.isEmpty { missing.append("3D Object") }
            
        case 2: // Quick
            if claimLimitText.isEmpty { missing.append("Claim Limit") }
            if rewardTypeText.isEmpty { missing.append("Reward Type") }
            
        default:
            break
        }
        
        // If missing fields → Show alert
        if !missing.isEmpty {
            let message = "Please fill the following fields:\n" + missing.joined(separator: ", ")
            let ac = UIAlertController(title: "Missing Required Fields", message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        
        // All good → proceed to save
        print("Saving reward…")
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension NewRewardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let img = info[.originalImage] as? UIImage {
            selectedImage = img
        }
    }
}

// MARK: - Small reusable UI components

// Card base
class RewardCardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        common()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); common() }
    private func common() {
        backgroundColor = UIColor.white.withAlphaComponent(0.04)
        layer.cornerRadius = 12
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
}

// Styled text field (single line)
class StyledTextField: RewardCardView {
    private let tf = UITextField()
    init(placeholder: String) {
        super.init(frame: .zero)
        tf.placeholder = placeholder
        tf.textColor = .white
        tf.font = .systemFont(ofSize: 16)
        tf.borderStyle = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.45)])
        addSubview(tf)
        NSLayoutConstraint.activate([
            tf.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            tf.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            tf.topAnchor.constraint(equalTo: topAnchor),
            tf.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    var textValue: String { return tf.text ?? "" }
}

// Styled text view with placeholder
class StyledTextView: RewardCardView, UITextViewDelegate {
    private let tv = UITextView()
    private let placeholderLabel = UILabel()
    init(placeholder: String) {
        super.init(frame: .zero)
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.font = .systemFont(ofSize: 15)
        tv.delegate = self
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false

        placeholderLabel.text = placeholder
        placeholderLabel.font = .systemFont(ofSize: 15)
        placeholderLabel.textColor = UIColor.white.withAlphaComponent(0.45)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(tv)
        addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            tv.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            tv.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            tv.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            tv.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            placeholderLabel.leadingAnchor.constraint(equalTo: tv.leadingAnchor, constant: 4),
            placeholderLabel.topAnchor.constraint(equalTo: tv.topAnchor, constant: 6)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    var textValue: String { return tv.text ?? "" }
}

// Points row: label + minus + value + plus
class PointsRow: RewardCardView {
    
    private let label: UILabel = {
        let l = UILabel()
        l.text = "Points *"
        l.textColor = .white
        l.font = .systemFont(ofSize: 16)
        return l
    }()
    
    private let valueLabel: UILabel = {
        let l = UILabel()
        l.text = "20"
        l.textColor = .white
        l.font = .boldSystemFont(ofSize: 16)
        l.textAlignment = .center
        return l
    }()
    
    private let minus = IconButton(systemName: "minus")
    private let plus = IconButton(systemName: "plus")
    
    private(set) var countValue: Int = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let h = UIStackView(arrangedSubviews: [label, UIView(), minus, valueLabel, plus])
        h.axis = .horizontal
        h.spacing = 12
        h.alignment = .center
        h.translatesAutoresizingMaskIntoConstraints = false
        addSubview(h)
        
        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            h.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            h.topAnchor.constraint(equalTo: topAnchor),
            h.bottomAnchor.constraint(equalTo: bottomAnchor),
            minus.widthAnchor.constraint(equalToConstant: 36),
            minus.heightAnchor.constraint(equalToConstant: 36),
            plus.widthAnchor.constraint(equalToConstant: 36),
            plus.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        minus.addTarget(self, action: #selector(dec), for: .touchUpInside)
        plus.addTarget(self, action: #selector(inc), for: .touchUpInside)
        
        valueLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        // 👉 Allow manual number entry by tapping the label
        let tap = UITapGestureRecognizer(target: self, action: #selector(openManualEntry))
        valueLabel.isUserInteractionEnabled = true
        valueLabel.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Increase / Decrease (jump by 5)
    @objc private func inc() {
        countValue += 5
        valueLabel.text = "\(countValue)"
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    @objc private func dec() {
        countValue = max(5, countValue - 5)  // Prevent going below 5
        valueLabel.text = "\(countValue)"
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Manual Entry Alert
    @objc private func openManualEntry() {
        
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController else { return }
        
        let alert = UIAlertController(title: "Enter Points",
                                      message: "Type the number of points you want to set.",
                                      preferredStyle: .alert)
        
        alert.addTextField { tf in
            tf.keyboardType = .numberPad
            tf.placeholder = "Enter points"
            tf.text = "\(self.countValue)"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let text = alert.textFields?.first?.text,
               let val = Int(text),
               val >= 0 {
                self.countValue = val
                self.valueLabel.text = "\(val)"
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }))
        
        root.present(alert, animated: true)
    }
}


class IconButton: UIButton {
    init(systemName: String) {
        super.init(frame: .zero)
        setImage(UIImage(systemName: systemName), for: .normal)
        tintColor = .white
        backgroundColor = UIColor.white.withAlphaComponent(0.08)
        layer.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) { fatalError() }
}

// Select row with chevron and optional detail text
class SelectRow: RewardCardView {
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
    var onTap: (() -> Void)?

    var detailText: String? = nil

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title; titleLabel.textColor = .white; titleLabel.font = .systemFont(ofSize: 16)
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.7); detailLabel.font = .systemFont(ofSize: 14)
        chevron.tintColor = UIColor.white.withAlphaComponent(0.6)
        detailLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let h = UIStackView(arrangedSubviews: [titleLabel, UIView(), detailLabel, chevron])
        h.axis = .horizontal; h.alignment = .center; h.spacing = 8
        h.translatesAutoresizingMaskIntoConstraints = false
        addSubview(h)
        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            h.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            h.topAnchor.constraint(equalTo: topAnchor),
            h.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) { fatalError() }

    @objc private func tapped() { onTap?() }

    func setDetail(_ text: String) {
        detailLabel.text = text
        detailText = text
    }
}

// Upload box (image)
class UploadBox: RewardCardView {
    private let icon = UIImageView(image: UIImage(systemName: "photo.on.rectangle.angled"))
    private let label = UILabel()
    private let imageView = UIImageView()
    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        icon.tintColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        label.text = "Upload your photo here * "; label.textColor = UIColor.white.withAlphaComponent(0.7); label.font = .systemFont(ofSize: 14)

        
        
        
        let v = UIStackView(arrangedSubviews: [icon, label])
        v.axis = .vertical; v.alignment = .center; v.spacing = 8; v.translatesAutoresizingMaskIntoConstraints = false
        addSubview(v)
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            v.centerXAnchor.constraint(equalTo: centerXAnchor),
            v.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 34),
            icon.heightAnchor.constraint(equalToConstant: 34),

            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // imageView hidden until an image is set
        imageView.alpha = 0

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func tapped() { onTap?() }

    func setImage(_ img: UIImage?) {
        guard let img = img else {
            imageView.image = nil; imageView.alpha = 0
            return
        }
        imageView.image = img
        imageView.alpha = 1
    }
}

// Simple 3D selection box (acts like upload box but navigates)
class Select3DBox: RewardCardView {
    private let icon = UIImageView(image: UIImage(systemName: "gift"))
    private let label = UILabel()
    var onTap: (() -> Void)?
    private let detailLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        icon.tintColor = .white
        label.text = "Select the 3D object here * "; label.textColor = UIColor.white.withAlphaComponent(0.8); label.font = .systemFont(ofSize: 14)
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.7); detailLabel.font = .systemFont(ofSize: 13)

        let v = UIStackView(arrangedSubviews: [icon, label, detailLabel])
        v.axis = .vertical; v.alignment = .center; v.spacing = 8; v.translatesAutoresizingMaskIntoConstraints = false

        addSubview(v)
        NSLayoutConstraint.activate([
            v.centerXAnchor.constraint(equalTo: centerXAnchor),
            v.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 34),
            icon.heightAnchor.constraint(equalToConstant: 34)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func tapped() { onTap?() }

    func setDetail(_ text: String) {
        detailLabel.text = text
        selectedValue = text
       
    }
    
    var selectedValue: String? = nil

   

}

// MARK: - Simple selection controller (generic list)
class SimpleSelectionController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let table = UITableView(frame: .zero, style: .insetGrouped)
    private let items: [String]
    private let callback: (String) -> Void
    private let titleText: String

    init(titleText: String, items: [String], callback: @escaping (String) -> Void) {
        self.items = items
        self.callback = callback
        self.titleText = titleText
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = titleText
        view.backgroundColor = UIColor.systemBackground
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)
        NSLayoutConstraint.activate([
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.topAnchor.constraint(equalTo: view.topAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
    }

    @objc private func addTapped() {
        // Placeholder add action
        let ac = UIAlertController(title: "Add", message: "Add new item (demo)", preferredStyle: .alert)
        ac.addTextField { $0.placeholder = "Name" }
        ac.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            // not maintaining list in demo
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    // MARK: Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "cell"
        let c = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        c.textLabel?.text = items[indexPath.row]
        c.accessoryType = .none
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let s = items[indexPath.row]
        callback(s)
        navigationController?.popViewController(animated: true)
        
        
    }
    
    
    
}

