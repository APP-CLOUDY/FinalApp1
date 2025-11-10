//
//  LoginViewController.swift
//  Cloudyyy_App
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var topContainer: UIView!
    private var gradientLayer: CAGradientLayer?
    override func viewDidLoad() {
            super.viewDidLoad()
            applyGradient()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            // Always update the gradient frame when layout changes
            gradientLayer?.frame = topContainer.bounds
        }

        private func applyGradient() {
            // Remove old gradients if any
            topContainer.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1).cgColor,  // #0C0C0C
                UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1).cgColor   // #203B6F
            ]
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint   = CGPoint(x: 0.5, y: 1.0)
            gradient.frame = topContainer.bounds
            gradient.cornerRadius = topContainer.layer.cornerRadius

            topContainer.layer.insertSublayer(gradient, at: 0)
            gradientLayer = gradient
        }
    
    

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        print("Login button tapped!")
        let dashboardVC = ParentDashboardViewController(nibName: "ParentDashboardViewController", bundle: nil)
        self.navigationController?.pushViewController(dashboardVC, animated: true)
    }
    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
            print("Forgot Password button tapped!")
            
            // Assuming your ForgotPasswordViewController also has a .xib file
            // like your ParentDashboardViewController
            let forgotVC = forgotPasswordViewController(nibName: "forgotPasswordViewController", bundle: nil)
            
            // Push the new view controller onto the stack
            self.navigationController?.pushViewController(forgotVC, animated: true)
        }
    @IBAction func backButtonTapped(_ sender: UIButton) {
        print("✅ Back button tapped")
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
