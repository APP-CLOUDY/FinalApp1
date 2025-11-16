//
//  SplashViewControllerViewController.swift
//  Cloudyyy_App
//

import UIKit

class SplashViewControllerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func getStartedTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15,
                       animations: { sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) },
                       completion: { _ in
            UIView.animate(withDuration: 0.15) {
                sender.transform = .identity
            }
        })

//        let homeLoginVC = HomeLoginViewController(nibName: "HomeLoginViewController", bundle: nil)
//        self.navigationController?.pushViewController(homeLoginVC, animated: true)
    }
}
