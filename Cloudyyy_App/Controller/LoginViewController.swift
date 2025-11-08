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
        let dashboardVC = ParentDashboardViewController(nibName: "ParentDashboardViewController", bundle: nil)
        self.navigationController?.pushViewController(dashboardVC, animated: true)
    }
}
