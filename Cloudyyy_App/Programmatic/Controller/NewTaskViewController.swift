//
//  NewTaskViewController.swift
//  Cloudyyy_App
//
//  Updated to use white text and native dark styling
//

import UIKit

class NewTaskViewController: UIViewController {

    private var backgroundGradientLayer: CAGradientLayer?
    private var points = 1 { didSet { pointsValueLabel.text = "\(points)" } }

    // MARK: - UI Elements
    private let cancelButton = UIButton(type: .system)
    private let doneButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    private let titleTextField = UITextField()
    private let descriptionTextView = UITextView()

  
    private let priorityButton = UIButton(type: .system)

    private let pointsStack = UIStackView()
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)
    private let pointsValueLabel = UILabel()

  
    private let datePicker = UIDatePicker()

    
    private let frequencyButton = UIButton(type: .system)

  
    private let listsButton = UIButton(type: .system)

   
    private let approvalSwitch = UISwitch()

    private let assignedButton = UIButton(type: .system)

    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    
    private var priorityLabel = UILabel()
    private var frequencyLabel = UILabel()
    private var listsLabel = UILabel()
    private var approvalLabel = UILabel()
    private var assignedLabel = UILabel()
    private var pointsLabel = UILabel()
    private var dateLabel = UILabel()


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupHeader()
        setupUI()
        setupLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer?.frame = view.bounds
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ListSelected"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let selectedList = notification.object as? String {
                self?.listsButton.setTitle(selectedList + " ▸", for: .normal)
            }
        }

    }

    // MARK: - Setup Gradient
    private func setupGradient() {
        backgroundGradientLayer?.removeFromSuperlayer()
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 10/255, green: 13/255, blue: 41/255, alpha: 1).cgColor,
            UIColor(red: 24/255, green: 30/255, blue: 74/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint   = CGPoint(x: 1, y: 1)
        gradient.frame      = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        backgroundGradientLayer = gradient
    }

    // MARK: - Header (Cancel / Title / Done)
    private func setupHeader() {
        // Cancel button (left)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cancelButton.addTarget(self, action: #selector(dismissSheet), for: .touchUpInside)

        // Done button (right)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.systemBlue, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        // Center title
        titleLabel.text = "New Task"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
    }

    // MARK: - Build UI Controls
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        contentView.axis = .vertical
        contentView.spacing = 18
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        setupTextFields()
        setupButtonsAndLabels()
        setupStacks()
    }

    private func setupTextFields() {
        // Title text field
        titleTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.07)
        titleTextField.layer.cornerRadius = 10
        titleTextField.textColor = .white
        titleTextField.font = UIFont.systemFont(ofSize: 16)
        titleTextField.setLeftPaddingPoints(12)
        titleTextField.heightAnchor.constraint(equalToConstant: 48).isActive = true

        // white placeholder with alpha
        let titlePlaceholder = NSAttributedString(
            string: "Title *",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.55),
                .font: UIFont.systemFont(ofSize: 15)
            ])
        titleTextField.attributedPlaceholder = titlePlaceholder

        // Description text view (multiline)
        descriptionTextView.backgroundColor = UIColor(white: 1.0, alpha: 0.07)
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.textColor = UIColor.white.withAlphaComponent(0.9)
        descriptionTextView.font = UIFont.systemFont(ofSize: 15)
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.heightAnchor.constraint(equalToConstant: 96).isActive = true
        descriptionTextView.delegate = self

        // Use a faint placeholder-like text initially
        descriptionTextView.text = "Description"
        descriptionTextView.textColor = UIColor.white.withAlphaComponent(0.55)
    }

    private func setupButtonsAndLabels() {
        func makeSectionLabel(_ text: String) -> UILabel {
            let l = UILabel()
            l.text = text
            l.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            l.textColor = .white
            l.textAlignment = .left
            return l
        }

        priorityLabel = makeSectionLabel("Priority")
        frequencyLabel = makeSectionLabel("Frequency")
        listsLabel = makeSectionLabel("Lists")
        approvalLabel = makeSectionLabel("Approval & Photo proof")
        assignedLabel = makeSectionLabel("Assigned to")
        pointsLabel = makeSectionLabel("Points")
        dateLabel = makeSectionLabel("Date")

        // priorityButton (looks like a field)
        priorityButton.setTitle("None ▾", for: .normal)
        priorityButton.setTitleColor(.white, for: .normal)
        priorityButton.backgroundColor = UIColor(white: 1.0, alpha: 0.07)
        priorityButton.layer.cornerRadius = 10
        priorityButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        priorityButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        priorityButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        priorityButton.addTarget(self, action: #selector(pickPriority), for: .touchUpInside)

        // Frequency button
        frequencyButton.setTitle("Select ▾", for: .normal)
        frequencyButton.setTitleColor(.white, for: .normal)
        frequencyButton.backgroundColor = UIColor(white: 1.0, alpha: 0.07)
        frequencyButton.layer.cornerRadius = 10
        frequencyButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        frequencyButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        frequencyButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        frequencyButton.addTarget(self, action: #selector(pickFrequency), for: .touchUpInside)

        // Lists button
        listsButton.setTitle("Choose ▸", for: .normal)
        listsButton.setTitleColor(.white, for: .normal)
        listsButton.backgroundColor = UIColor(white: 1.0, alpha: 0.07)
        listsButton.layer.cornerRadius = 10
        listsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        listsButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        listsButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        listsButton.addTarget(self, action: #selector(openListsPage), for: .touchUpInside)

        // Assigned button
        assignedButton.setTitle("Select ▾", for: .normal)
        assignedButton.setTitleColor(.white, for: .normal)
        assignedButton.backgroundColor = UIColor(white: 1.0, alpha: 0.07)
        assignedButton.layer.cornerRadius = 10
        assignedButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        // Points stack (minus, value, plus) inside a rounded background
        minusButton.setTitle("-", for: .normal)
        minusButton.setTitleColor(.white, for: .normal)
        minusButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        minusButton.addTarget(self, action: #selector(decrementPoints), for: .touchUpInside)

        plusButton.setTitle("+", for: .normal)
        plusButton.setTitleColor(.white, for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        plusButton.addTarget(self, action: #selector(incrementPoints), for: .touchUpInside)

        pointsValueLabel.text = "\(points)"
        pointsValueLabel.textColor = .white
        pointsValueLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        pointsValueLabel.textAlignment = .center
        pointsValueLabel.widthAnchor.constraint(equalToConstant: 36).isActive = true

        pointsStack.axis = .horizontal
        pointsStack.alignment = .center
        pointsStack.distribution = .equalCentering
        pointsStack.spacing = 16
        pointsStack.addArrangedSubview(minusButton)
        pointsStack.addArrangedSubview(pointsValueLabel)
        pointsStack.addArrangedSubview(plusButton)
        pointsStack.backgroundColor = UIColor(white: 1.0, alpha: 0.07)
        pointsStack.layer.cornerRadius = 10
        pointsStack.heightAnchor.constraint(equalToConstant: 48).isActive = true

        // Date picker styling
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = .white
        datePicker.backgroundColor = UIColor(white: 1.0, alpha: 0.03)
        datePicker.layer.cornerRadius = 10
    }

    // MARK: - Stack building
    // MARK: - Stack building
    private func setupStacks() {
        
        // Title and description
        contentView.addArrangedSubview(titleTextField)
        contentView.addArrangedSubview(descriptionTextView)
        
        func makeRow(left label: UILabel, right view: UIView) -> UIStackView {
            let row = UIStackView(arrangedSubviews: [label, view])
            row.axis = .horizontal
            row.distribution = .equalSpacing
            row.alignment = .center
            row.backgroundColor = UIColor(white: 1.0, alpha: 0.08)
            row.layer.cornerRadius = 12
            row.isLayoutMarginsRelativeArrangement = true
            row.layoutMargins = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
            row.heightAnchor.constraint(equalToConstant: 50).isActive = true
            return row
        }

        // Priority row
        let priorityRow = makeRow(left: priorityLabel, right: priorityButton)
        contentView.addArrangedSubview(priorityRow)

        // Points row (custom HStack for - 1 +)
        let pointsRow = makeRow(left: pointsLabel, right: pointsStack)
        contentView.addArrangedSubview(pointsRow)

        // Date row
        let dateRow = makeRow(left: dateLabel, right: datePicker)
        contentView.addArrangedSubview(dateRow)

        // Frequency row
        let frequencyRow = makeRow(left: frequencyLabel, right: frequencyButton)
        contentView.addArrangedSubview(frequencyRow)

        // Lists row
        let listsRow = makeRow(left: listsLabel, right: listsButton)
        contentView.addArrangedSubview(listsRow)

        // Approval row (label + switch)
        let approvalRow = makeRow(left: approvalLabel, right: approvalSwitch)
        contentView.addArrangedSubview(approvalRow)

        // Assigned to row
        let assignedRow = makeRow(left: assignedLabel, right: assignedButton)
        contentView.addArrangedSubview(assignedRow)
    }


    // MARK: - Layout constraints
    private func setupLayout() {
        let headerStack = UIStackView(arrangedSubviews: [cancelButton, titleLabel, doneButton])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalCentering
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerStack)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            // scroll view
            scrollView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // contentView edges inside scroll
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    // MARK: - Actions
    @objc private func incrementPoints() { if points < 10 { points += 1 } }
    @objc private func decrementPoints() { if points > 1 { points -= 1 } }
    @objc private func doneTapped() {
        // validate minimal fields
        if let t = titleTextField.text, !t.trimmingCharacters(in: .whitespaces).isEmpty {
            print("Task saved: \(t)")
            dismiss(animated: true)
        } else {
            let alert = UIAlertController(title: "Missing Title", message: "Please enter a task title.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    @objc private func dismissSheet() { dismiss(animated: true) }

    @objc private func pickPriority() {
        let alert = UIAlertController(title: "Priority", message: nil, preferredStyle: .actionSheet)
        let priorities: [String] = ["None", "Low", "Medium", "High"]
        
        for option in priorities {
            alert.addAction(UIAlertAction(title: option, style: .default) { [weak self] _ in
                // ✅ Ensure non-optional, clean string
                let cleanTitle = option
                self?.priorityButton.setTitle("\(cleanTitle) ▾", for: .normal)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func pickFrequency() {
        let alert = UIAlertController(title: "Frequency", message: nil, preferredStyle: .actionSheet)
        let frequencies: [String] = ["Doesn't repeat", "Daily", "Weekly", "Monthly"]
        
        for option in frequencies {
            alert.addAction(UIAlertAction(title: option, style: .default) { [weak self] _ in
                let cleanTitle = option
                self?.frequencyButton.setTitle("\(cleanTitle) ▾", for: .normal)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }



    @objc private func openListsPage() {
        let listsVC = ListsViewController()
        // wrap in navigation so Lists has back / Add
        let nav = UINavigationController(rootViewController: listsVC)
        nav.modalPresentationStyle = .fullScreen
        // style nav bar for dark look
        nav.navigationBar.barTintColor = UIColor.clear
        nav.navigationBar.tintColor = .white
        present(nav, animated: true)
    }
}

// MARK: - UITextView placeholder behaviour
extension NewTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.white.withAlphaComponent(0.55) {
            textView.text = ""
            textView.textColor = UIColor.white.withAlphaComponent(0.95)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.white.withAlphaComponent(0.55)
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        // Adjust content inset dynamically for Apple-like top alignment
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 8, right: 8)
    }
}


// MARK: - UITextField padding helper
extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
}
