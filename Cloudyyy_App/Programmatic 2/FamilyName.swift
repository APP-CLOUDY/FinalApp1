//
//  FamilyName.swift
//  Cloudyyy_App
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
    
    // ADDED: Logo Image View
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        // Ensure "app_logo" exists in your Assets catalog
        iv.image = UIImage(named: "app_logo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    // REMOVED: appTitleLabel
    // REMOVED: subtitleLabel
    
    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        b.tintColor = .white
        return b
    }()
    
    // MARK: - Bottom card
    private let bottomCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 32
        v.layer.masksToBounds = true
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()
    
    // MARK: - Bottom Card Content
    
    private let familyNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Family Name"
        l.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        l.textColor = UIColor(red: 92/255, green: 160/255, blue: 1, alpha: 1)
        l.textAlignment = .center // Centered
        return l
    }()

    private let familyNameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor(white: 0.2, alpha: 0.3)
        tf.layer.cornerRadius = 14
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(white: 1.0, alpha: 0.15).cgColor
        tf.textColor = .white
        tf.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        tf.keyboardAppearance = .dark
        
        let placeholderText = "The Super Squad"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(white: 0.5, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 17)
        ]
        tf.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        tf.rightViewMode = .always
        
        tf.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return tf
    }()

    private let nextButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        // Changed to "Next"
        b.setTitle("Next", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 40/255, green: 125/255, blue: 255/255, alpha: 1)
        b.layer.cornerRadius = 14
        b.layer.masksToBounds = true
        b.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        // Disabled styling initially
        b.alpha = 0.5
        b.isEnabled = false
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
        sv.keyboardDismissMode = .interactive
        return sv
    }()
    
    private lazy var bottomStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            topSpacer,
            familyNameLabel,     // Label directly
            spacer(height: 24),  // Clean spacing
            familyNameTextField,
            spacer(height: 24),  // Clean spacing
            nextButton,          // Next button
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
        
        backButton.isHidden = true
        
        // Interaction Logic
        setupKeyboardObservers()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        // Listen for text changes to enable button
        familyNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
    
    @objc private func textFieldDidChange() {
        guard let text = familyNameTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            // Disable
            UIView.animate(withDuration: 0.2) {
                self.nextButton.alpha = 0.5
            }
            nextButton.isEnabled = false
            return
        }
        
        // Enable
        if !nextButton.isEnabled {
            UIView.animate(withDuration: 0.2) {
                self.nextButton.alpha = 1.0
            }
            nextButton.isEnabled = true
        }
    }
    
    @objc private func nextTapped() {
        guard let name = familyNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
        
        nextButton.isEnabled = false
        nextButton.setTitle("Creating...", for: .normal)
        nextButton.alpha = 0.7
        
        _Concurrency.Task {
            do {
                let familyId = try await FamilyService.shared.createFamily(name: name)
                
                await MainActor.run {
                    self.nextButton.isEnabled = true
                    self.nextButton.setTitle("Next", for: .normal)
                    self.nextButton.alpha = 1.0
                    
                    let vc = AddChild()
                    vc.familyId = familyId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } catch {
                await MainActor.run {
                    self.nextButton.isEnabled = true
                    self.nextButton.setTitle("Try Again", for: .normal)
                    self.nextButton.alpha = 1.0
                    print("Error: \(error)")
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
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 20, right: 0)
            bottomScrollView.contentInset = contentInsets
            bottomScrollView.scrollIndicatorInsets = contentInsets
            
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
        
        // UPDATED: Add Logo instead of text labels
        topContainer.addSubview(logoImageView)
        topContainer.addSubview(backButton)
        
        bottomCard.addSubview(bottomScrollView)
        bottomScrollView.addSubview(bottomStack)
        
        // Multiplier 0.60 to push card higher
        let bottomCardHeightConstraint = bottomCard.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.60)
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
            bottomCard.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -32),
            
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: topContainer.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: topContainer.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            // UPDATED: Logo Constraints (Centered in Top Container)
            logoImageView.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: topContainer.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120), // Adjust size as needed
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Bottom Scroll View
            bottomScrollView.topAnchor.constraint(equalTo: bottomCard.topAnchor, constant: 20),
            bottomScrollView.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor),
            bottomScrollView.trailingAnchor.constraint(equalTo: bottomCard.trailingAnchor),
            bottomScrollView.bottomAnchor.constraint(equalTo: bottomCard.bottomAnchor),
            
            // Bottom Stack
            bottomStack.topAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.topAnchor, constant: 10),
            bottomStack.bottomAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            bottomStack.leadingAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.leadingAnchor, constant: 32),
            bottomStack.trailingAnchor.constraint(equalTo: bottomScrollView.contentLayoutGuide.trailingAnchor, constant: -32),
            bottomStack.widthAnchor.constraint(equalTo: bottomScrollView.frameLayoutGuide.widthAnchor, constant: -64),
            
            stackHeightConstraint,
        ])
        
        // Centering logic
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
        // Dark Obsidian to Deep Steel Blue
        bottomGradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
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

