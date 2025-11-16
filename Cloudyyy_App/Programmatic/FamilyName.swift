//
//  FamilyName.swift
//  Cloudyyy_App
//
//  Created by user@5 on 15/11/25.
//

import UIKit

final class FamilyName: UIViewController {
    
    // MARK: - UI Elements (Top container is identical to Homelogin)
    
    private let topContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        return v
    }()
    
    private let appTitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Cloudyyy"
        l.font = UIFont.systemFont(ofSize: 56, weight: .black)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Organize tasks, Motivate Kids , Track Progress"
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(white: 1.0, alpha: 0.95)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()
    
    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
            b.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        } else {
            b.setTitle("< Back", for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        }
        b.tintColor = .white
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        b.widthAnchor.constraint(equalToConstant: 44).isActive = true
        return b
    }()
    
    // MARK: - Bottom card (dark gradient)
    private let bottomCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 28
        v.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        return v
    }()
    
    // MARK: - Bottom Card Content (New Components)
    
    private let familyNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Family Name"
        l.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        l.textColor = UIColor(red: 92/255, green: 160/255, blue: 1, alpha: 1) // Blue color from image
        l.textAlignment = .center
        return l
    }()

    private let familyNameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor(white: 0.2, alpha: 0.2) // Dark translucent
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(white: 1.0, alpha: 0.1).cgColor
        tf.textColor = .white
        tf.font = UIFont.systemFont(ofSize: 16)
        
        // Attributed placeholder
        let placeholderText = "Happy Home"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(white: 0.7, alpha: 0.7),
            .font: UIFont.systemFont(ofSize: 16)
        ]
        tf.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        // Add padding
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.rightViewMode = .always
        
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tf
    }()

    private let doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Done", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 40/255, green: 125/255, blue: 255/255, alpha: 1) // Blue color from image
        b.layer.cornerRadius = 12
        b.layer.masksToBounds = true
        b.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return b
    }()
    
    // MARK: - Rotation/Centering Fix (Identical to Homelogin)
    private let topSpacer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let bottomSpacer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // MARK: - Landscape Robustness Fix (Identical to Homelogin)
    private let bottomScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    
    // MARK: - Bottom Stack (Updated Content)
    private lazy var bottomStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            topSpacer,
            familyNameLabel,
            spacer(height: 24),
            familyNameTextField,
            spacer(height: 24),
            doneButton,
            bottomSpacer
        ])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .fill
        sv.spacing = 0 // Spacing is handled by spacers
        return sv
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 21/255, green: 130/255, blue: 255/255, alpha: 1)
        
        setupLayout()
        applyGradients()
        
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let topGradient = topContainerGradient {
            topGradient.frame = topContainer.bounds
        }
        if let bottomGradient = bottomCardGradient {
            bottomGradient.frame = bottomCard.bounds
            bottomGradient.cornerRadius = bottomCard.layer.cornerRadius
        }
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        print("Back button tapped")
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func doneTapped() {
        print("Done tapped. Family Name: \(familyNameTextField.text ?? "N/A")")
        let vc = AddChild()
        navigationController?.pushViewController(vc, animated: true)
        // Handle logic for saving family name
    }
    
    // MARK: - Layout helpers
    
    private func spacer(height: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }
    
    private var topContainerGradient: CAGradientLayer?
    private var bottomCardGradient: CAGradientLayer?
    
    // MARK: - Layout Setup (Identical to Homelogin)
    
    private func setupLayout() {
        view.addSubview(topContainer)
        view.addSubview(bottomCard)
        
        topContainer.addSubview(appTitleLabel)
        topContainer.addSubview(subtitleLabel)
        topContainer.addSubview(backButton)
        
        bottomCard.addSubview(bottomScrollView)
        bottomScrollView.addSubview(bottomStack)
        
        let bottomCardHeightConstraint = bottomCard.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        bottomCardHeightConstraint.isActive = true
        
        let stackHeightConstraint = bottomStack.heightAnchor.constraint(equalTo: bottomScrollView.frameLayoutGuide.heightAnchor, constant: -40) // -40 for padding
        stackHeightConstraint.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            // Top Container
            topContainer.topAnchor.constraint(equalTo: view.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Bottom Card
            bottomCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomCard.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -1), // -1 overlap
            
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: topContainer.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: topContainer.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            // Top Content
            appTitleLabel.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            appTitleLabel.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor, constant: -10),
            
            subtitleLabel.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: topContainer.leadingAnchor, constant: 28),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: topContainer.trailingAnchor, constant: -28),
            
            // Bottom Scroll View
            bottomScrollView.topAnchor.constraint(equalTo: bottomCard.topAnchor),
            bottomScrollView.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor),
            bottomScrollView.trailingAnchor.constraint(equalTo: bottomCard.trailingAnchor),
            bottomScrollView.bottomAnchor.constraint(equalTo: bottomCard.bottomAnchor),
            
            // Bottom Stack
            bottomStack.topAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.topAnchor, constant: 20),
            bottomStack.bottomAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            bottomStack.leadingAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.leadingAnchor, constant: 28),
            bottomStack.trailingAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.trailingAnchor, constant: -28),
            bottomStack.widthAnchor.constraint(equalTo: bottomScrollView.frameLayoutGuide.widthAnchor, constant: -56),
            
            stackHeightConstraint,
        ])
        
        // Rotation Fix
        topSpacer.heightAnchor.constraint(equalTo: bottomSpacer.heightAnchor).isActive = true
    }
    
    // MARK: - Gradients (Identical to Homelogin)
    
    private func applyGradients() {
        // Top blue gradient
        let topGradient = CAGradientLayer()
        topGradient.colors = [
            UIColor(red: 21/255, green: 130/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 54/255, green: 114/255, blue: 241/255, alpha: 1).cgColor
        ]
        topGradient.startPoint = CGPoint(x: 0.5, y: 0)
        topGradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        // Bottom gradient (dark)
        let bottomGradient = CAGradientLayer()
        bottomGradient.colors = [
            UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1).cgColor,
            UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1).cgColor
        ]
        bottomGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        bottomGradient.endPoint   = CGPoint(x: 0.5, y: 1.0)
        
        topContainer.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        bottomCard.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        topContainer.layer.insertSublayer(topGradient, at: 0)
        bottomCard.layer.insertSublayer(bottomGradient, at: 0)
        topContainerGradient = topGradient
        bottomCardGradient = bottomGradient
        
        bottomGradient.cornerRadius = bottomCard.layer.cornerRadius
        bottomCard.layer.masksToBounds = true
        
        topGradient.frame = topContainer.bounds
        bottomGradient.frame = bottomCard.bounds
    }
}
