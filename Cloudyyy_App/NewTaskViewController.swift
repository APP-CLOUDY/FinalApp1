//
//  NewTaskViewController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 07/11/25.
//

import UIKit

class NewTaskViewController: UIViewController {

        private var backgroundGradientLayer: CAGradientLayer?

        override func viewDidLoad() {
            super.viewDidLoad()
            setupBackgroundGradient()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            // Ensure the gradient resizes properly when layout updates
            backgroundGradientLayer?.frame = view.bounds
        }

        // MARK: - Gradient Setup
        private func setupBackgroundGradient() {
            // Remove existing gradient (avoid duplicates when layout refreshes)
            backgroundGradientLayer?.removeFromSuperlayer()

            // Create and configure gradient
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor(red: 10/255, green: 13/255, blue: 41/255, alpha: 1).cgColor,  // Deep navy
                UIColor(red: 24/255, green: 30/255, blue: 74/255, alpha: 1).cgColor   // Lighter navy
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            gradient.frame = view.bounds

            // Insert at bottom of the view’s layer stack
            view.layer.insertSublayer(gradient, at: 0)

            backgroundGradientLayer = gradient
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

