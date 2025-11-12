//
//  SignupViewController.swift
//  Cloudyyy_App
//
//  Created by user@5 on 07/11/25.
//

import UIKit
import Supabase

// MARK: - User Model (matches Supabase table)
struct UserModel: Encodable {
    let id: UUID
    let first_name: String
    let email: String
    let role: String
    let date_of_birth: String
}

class SignupViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var roleSegment: UISegmentedControl!
    @IBOutlet weak var dobPicker: UIDatePicker!
    @IBOutlet weak var signupButton: UIButton!
    
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        applyGradient()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = topContainer.bounds
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        signupButton.layer.cornerRadius = 10
        signupButton.clipsToBounds = true
        roleSegment.selectedSegmentIndex = 0
    }
    
    private func applyGradient() {
        topContainer.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1).cgColor,
            UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = topContainer.bounds
        gradient.cornerRadius = topContainer.layer.cornerRadius
        topContainer.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
    
    // MARK: - Actions
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        registerUser()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Supabase Signup Logic
    private func registerUser() {
        guard let name = nameField.text, !name.isEmpty,
              let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            self.showAlert(message: "Please fill all fields.")
            return
        }

        let selectedRoleIndex = roleSegment.selectedSegmentIndex
        let role = roleSegment.titleForSegment(at: selectedRoleIndex) ?? "Parent"
        let dateOfBirth = dobPicker.date

        Task {
            do {
                // Step 1: Create user in Supabase Auth
                let response = try await SupabaseManager.shared.client.auth.signUp(
                    email: email,
                    password: password
                )

                let user = response.user  // ✅ Non-optional in new SDK

                // Step 2: Insert into 'users' table
                let userData = UserModel(
                    id: user.id,
                    first_name: name,
                    email: email,
                    role: role,
                    date_of_birth: ISO8601DateFormatter().string(from: dateOfBirth)
                )

                let insertResponse = try await SupabaseManager.shared.client
                    .from("users")
                    .insert([userData])
                    .execute()

                print("✅ Inserted data into Supabase:", insertResponse)

                // Step 3: Verify insert (optional)
                let result = try await SupabaseManager.shared.client
                    .from("users")
                    .select()
                    .eq("email", value: email)
                    .single()

                print("✅ Verified in database:", result)

                // ✅ Use `self.` inside Task for clarity
                self.showAlert(message: "🎉 Signup successful! Welcome, \(name).")

            } catch {
                self.showAlert(message: "❌ Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Helper Alert
    private func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Signup", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
