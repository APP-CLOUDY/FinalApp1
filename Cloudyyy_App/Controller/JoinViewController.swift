//
//  JoinViewController.swift
//  Cloudyyy_App
//
//  Created by user@5 on 08/11/25.
//

import UIKit

class JoinViewController: UIViewController {
    
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
    @IBAction func backButtonTapped(_ sender: UIButton) {
        print("✅ Back button tapped")
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func joinButtonTapped(_ sender: UIButton) {
            print("Join with Code button tapped!")

            // ✅ Navigate to ChildHomeViewController (XIB)
            let childHomeVC = childHome(nibName: "childHome", bundle: nil)
            self.navigationController?.pushViewController(childHomeVC, animated: true)
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
