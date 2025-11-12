//
//  NewRewardViewController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 12/11/25.
//

import UIKit

class NewRewardViewController: UIViewController {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "New Reward"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Spring On", "Dream It", "Quick"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        control.selectedSegmentTintColor = UIColor.systemBlue.withAlphaComponent(0.8)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return control
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Fun experiences your child can unlock — like trips or outings — piece by piece."
        label.textColor = .white.withAlphaComponent(0.8)
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        textField.textColor = .white
        textField.layer.cornerRadius = 10
        textField.setLeftPaddingPoints(12)
        textField.heightAnchor.constraint(equalToConstant: 45).isActive = true
        return textField
    }
    
    private lazy var titleField = createTextField(placeholder: "Title")
    private lazy var descriptionField = createTextField(placeholder: "Description")
    private lazy var pointsField = createTextField(placeholder: "Points")
    private lazy var claimLimitField = createTextField(placeholder: "Claim Limit")
    private lazy var assignedToField = createTextField(placeholder: "Assigned to")
    
    private let uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload your photo here", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        button.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        let icon = UIImage(systemName: "photo.on.rectangle.angled")
        button.setImage(icon, for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        return button
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupLayout()
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [headerLabel, segmentControl, descriptionLabel,
         titleField, descriptionField, pointsField,
         claimLimitField, assignedToField, uploadButton].forEach {
            contentView.addSubview($0)
        }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        [headerLabel, segmentControl, descriptionLabel,
         titleField, descriptionField, pointsField,
         claimLimitField, assignedToField, uploadButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Segmented control
            segmentControl.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            segmentControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            segmentControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            segmentControl.heightAnchor.constraint(equalToConstant: 40),
            
            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: segmentControl.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: segmentControl.trailingAnchor),
            
            // Text fields
            titleField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            titleField.leadingAnchor.constraint(equalTo: segmentControl.leadingAnchor),
            titleField.trailingAnchor.constraint(equalTo: segmentControl.trailingAnchor),
            
            descriptionField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 12),
            descriptionField.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            descriptionField.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            
            pointsField.topAnchor.constraint(equalTo: descriptionField.bottomAnchor, constant: 12),
            pointsField.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            pointsField.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            
            claimLimitField.topAnchor.constraint(equalTo: pointsField.bottomAnchor, constant: 12),
            claimLimitField.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            claimLimitField.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            
            assignedToField.topAnchor.constraint(equalTo: claimLimitField.bottomAnchor, constant: 12),
            assignedToField.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            assignedToField.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            
            uploadButton.topAnchor.constraint(equalTo: assignedToField.bottomAnchor, constant: 20),
            uploadButton.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            uploadButton.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            uploadButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Background
    private func setupGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 8/255, green: 12/255, blue: 48/255, alpha: 1).cgColor,
            UIColor(red: 10/255, green: 20/255, blue: 80/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }
}

// MARK: - Padding Helper
extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
}

