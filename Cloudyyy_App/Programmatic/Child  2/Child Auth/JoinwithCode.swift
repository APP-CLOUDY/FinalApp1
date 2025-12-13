//
//  JoinWithCode.swift
//  Cloudyyy_App
//

import UIKit

final class JoinWithCode: PremiumBaseViewController, UITextFieldDelegate {

    // MARK: - Properties
    private let codeLength = 6
    private var codeFields: [UITextField] = []

    // MARK: - UI Components
    
    // Stack to hold the 6 boxes
    private let codeStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.distribution = .fillEqually
        s.spacing = 8
        return s
    }()

    private let joinButton: PremiumLoginButton = {
        let b = PremiumLoginButton(frame: .zero)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Join Family", for: .normal)
        return b
    }()
    
    // --- INSTRUCTION LABEL (Now styled for dark background) ---
    private let instructionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Find the code in Parent Dashboard > Profile > Family Members after adding a child."
        l.font = .systemFont(ofSize: 13, weight: .regular)
        // Changed to White/Light Gray since it is now outside the white card
        l.textColor = UIColor(white: 1.0, alpha: 0.8)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerTitleLabel.text = "Join with Code"
        headerSubtitleLabel.text = "Enter the 6-digit code provided by your parent."
        
        setupContent()
        setupCodeFields()
        setupActions()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.codeFields.first?.becomeFirstResponder()
        }
    }
    
    // MARK: - Layout
    private func setupContent() {
        // Card Content
        cardView.addSubview(codeStack)
        cardView.addSubview(joinButton)
        
        // Background Content (Label moves here)
        view.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            // 1. Code Stack (Inside Card)
            codeStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 40),
            codeStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            codeStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            codeStack.heightAnchor.constraint(equalToConstant: 56),
            
            // 2. Join Button (Inside Card)
            joinButton.topAnchor.constraint(equalTo: codeStack.bottomAnchor, constant: 32),
            joinButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            joinButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            joinButton.heightAnchor.constraint(equalToConstant: 56),
            
            // 3. Card Bottom Constraint
            // The card ends 30pts below the button
            cardView.bottomAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 30),
            
            // 4. Instruction Label (Outside Card)
            // Sits below the cardView
            instructionLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 24),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    // MARK: - 6-Digit Field Setup
    private func setupCodeFields() {
        for index in 0..<codeLength {
            let tf = UITextField()
            
            tf.backgroundColor = .white
            tf.layer.borderWidth = 1.0
            tf.layer.borderColor = UIColor.systemGray4.cgColor
            tf.layer.cornerRadius = 12
            
            tf.textAlignment = .center
            tf.font = .systemFont(ofSize: 22, weight: .bold)
            tf.textColor = .black
            tf.keyboardType = .numberPad
            tf.tintColor = .systemBlue
            
            tf.tag = index
            tf.delegate = self
            tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
            
            codeStack.addArrangedSubview(tf)
            codeFields.append(tf)
        }
    }
    
    private func setupActions() {
        joinButton.addTarget(self, action: #selector(didTapJoin), for: .touchUpInside)
    }

    // MARK: - Logic & Networking
    
    @objc private func didTapJoin() {
        view.endEditing(true)
        
        let code = codeFields.compactMap { $0.text }.joined()
        
        guard code.count == codeLength, code.allSatisfy({ $0.isWholeNumber }) else {
            showAlert(title: "Invalid Code", message: "Please enter the full \(codeLength)-digit numeric code.")
            return
        }
        
        joinButton.isEnabled = false
        joinButton.alpha = 0.7
        
        _Concurrency.Task {
            do {
                let success = try await AuthService.shared.loginChild(code: code)
                
                await MainActor.run {
                    self.joinButton.isEnabled = true
                    self.joinButton.alpha = 1.0
                    
                    if success {
                        self.navigateToChildHome()
                    } else {
                        self.shakeCard()
                        self.showAlert(title: "Invalid Code", message: "That code didn't work. Please try again.")
                        self.clearFields()
                    }
                }
            } catch {
                await MainActor.run {
                    self.joinButton.isEnabled = true
                    self.joinButton.alpha = 1.0
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func navigateToChildHome() {
        let vc = ChildTabBarController()
        
        if let window = view.window {
            window.rootViewController = vc
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        } else {
            navigationController?.setViewControllers([vc], animated: true)
        }
    }
    
    // MARK: - Auto-Advance Logic
    @objc private func textDidChange(_ textField: UITextField) {
        let text = textField.text
        
        if text?.count == 1 {
            let nextTag = textField.tag + 1
            if nextTag < codeLength {
                codeFields[nextTag].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        } else if let text = text, text.count > 1 {
            let digits = text.filter { $0.isWholeNumber }
            for (offset, char) in digits.enumerated() {
                let index = textField.tag + offset
                if index < codeLength {
                    codeFields[index].text = String(char)
                }
            }
            let lastIndex = min(textField.tag + digits.count, codeLength - 1)
            codeFields[lastIndex].becomeFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            if textField.text?.isEmpty == true {
                let prevTag = textField.tag - 1
                if prevTag >= 0 {
                    codeFields[prevTag].becomeFirstResponder()
                }
            }
        }
        return true
    }
    
    // MARK: - Helpers
    private func clearFields() {
        codeFields.forEach { $0.text = "" }
        codeFields.first?.becomeFirstResponder()
    }
    
    private func shakeCard() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        cardView.layer.add(animation, forKey: "shake")
    }
    
    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
