//
//  LoginViewController.swift
//  Cloudyyy_App
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        print("Login button tapped!")

        // Validate input (optional)
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter both email and password.")
            return
        }

        // ✅ Create the main tab bar controller
        let mainTabBar = CustomTabBarController()
        mainTabBar.modalPresentationStyle = .fullScreen
        mainTabBar.modalTransitionStyle = .crossDissolve // smooth fade animation

        // ✅ Present it
        self.present(mainTabBar, animated: true, completion: nil)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
