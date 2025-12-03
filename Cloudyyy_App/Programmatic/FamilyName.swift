//
//  FamilyName.swift
//  Cloudyyy_App
//
//  Created by user@5 on 15/11/25.
//

import UIKit

final class FamilyName: UIViewController {
    
    // MARK: - UI Elements
    
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
    
    // NOTE: I kept this defined but hidden in viewDidLoad since users shouldn't go back to Signup
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
    
    // MARK: - Bottom card
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
    
    // MARK: - Bottom Card Content
    
    private let familyNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Family Name"
        l.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        l.textColor = UIColor(red: 92/255, green: 160/255, blue: 1, alpha: 1)
        l.textAlignment = .center
        return l
    }()

    private let familyNameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor(white: 0.2, alpha: 0.2)
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(white: 1.0, alpha: 0.1).cgColor
        tf.textColor = .white
        tf.font = UIFont.systemFont(ofSize: 16)
        
        let placeholderText = "Happy Home"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(white: 0.7, alpha: 0.7),
            .font: UIFont.systemFont(ofSize: 16)
        ]
        tf.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
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
        b.backgroundColor = UIColor(red: 40/255, green: 125/255, blue: 255/255, alpha: 1)
        b.layer.cornerRadius = 12
        b.layer.masksToBounds = true
        b.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return b
    }()
    
    // MARK: - Spacers & ScrollView
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
    
    private let bottomScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.keyboardDismissMode = .interactive
        return sv
    }()
    
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
        sv.spacing = 0
        return sv
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 21/255, green: 130/255, blue: 255/255, alpha: 1)
        
        setupLayout()
        applyGradients()
        
        // Hide back button to prevent going back to Signup
        backButton.isHidden = true
        
        // Keyboard & Tap Handling
        setupKeyboardObservers()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    @objc private func doneTapped() {
            guard let name = familyNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
                print("Name is empty")
                return
            }
            
            doneButton.isEnabled = false
            doneButton.setTitle("Creating...", for: .normal)
            doneButton.alpha = 0.7
            
            // FIX: Use '_Concurrency.Task' to avoid conflict with your 'Task' model
            _Concurrency.Task {
                do {
                    let familyId = try await FamilyService.shared.createFamily(name: name)
                    print("Family Created Successfully. ID: \(familyId)")
                    
                    await MainActor.run {
                        self.doneButton.isEnabled = true
                        self.doneButton.setTitle("Done", for: .normal)
                        self.doneButton.alpha = 1.0
                        
                        let vc = AddChild()
                        // vc.familyId = familyId // Pass ID if needed
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } catch {
                    print("Error creating family: \(error)")
                    await MainActor.run {
                        self.doneButton.isEnabled = true
                        self.doneButton.setTitle("Try Again", for: .normal)
                        self.doneButton.alpha = 1.0
                    }
                }
            }
        }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // Add extra padding at bottom so button is visible
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 20, right: 0)
            bottomScrollView.contentInset = contentInsets
            bottomScrollView.scrollIndicatorInsets = contentInsets
            
            // Scroll to ensure the Done button is visible
            let bottomOffset = CGPoint(x: 0, y: bottomScrollView.contentSize.height - bottomScrollView.bounds.size.height + keyboardSize.height + 20)
            if bottomOffset.y > 0 {
                bottomScrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        bottomScrollView.contentInset = .zero
        bottomScrollView.scrollIndicatorInsets = .zero
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
    
    // MARK: - Layout Setup
    
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
        
        let stackHeightConstraint = bottomStack.heightAnchor.constraint(equalTo: bottomScrollView.frameLayoutGuide.heightAnchor, constant: -40)
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
            bottomCard.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -1),
            
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
    
    private func applyGradients() {
        let topGradient = CAGradientLayer()
        topGradient.colors = [
            UIColor(red: 21/255, green: 130/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 54/255, green: 114/255, blue: 241/255, alpha: 1).cgColor
        ]
        topGradient.startPoint = CGPoint(x: 0.5, y: 0)
        topGradient.endPoint = CGPoint(x: 0.5, y: 1)
        
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
