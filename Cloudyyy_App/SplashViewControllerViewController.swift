//
//  SplashViewControllerViewController.swift
//  Cloudyyy_App
//
//  Created by user@5 on 06/11/25.
//

import UIKit

class SplashViewControllerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func getStartedTapped(_ sender: UIButton) {
        // Button tap animation (optional bounce)
        UIView.animate(withDuration: 0.15,
                       animations: { sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) },
                       completion: { _ in
            UIView.animate(withDuration: 0.15) {
                sender.transform = .identity
            }
        })

        // Load HomeLoginViewController.xib
        let homeLoginVC = HomeLoginViewController(nibName: "HomeLoginViewController", bundle: nil)
        homeLoginVC.modalTransitionStyle = .crossDissolve
        homeLoginVC.modalPresentationStyle = .fullScreen
        present(homeLoginVC, animated: true)
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


