
//
//  ViewController.swift
//  Cloudyyy_App
//
//  Created by user@5 on 05/11/25.
// hi hello


import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        // Start with logo invisible and slightly smaller
        logoImageView.alpha = 0
        logoImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // Animate fade + scale
        UIView.animate(withDuration: 1.2,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
            self.logoImageView.alpha = 1
            self.logoImageView.transform = .identity // return to normal size
        })
        
        // After 2 seconds → move to Splash
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.goToSplash()
        }
    }
    
    private func goToSplash() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let splashVC = storyboard.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewControllerViewController
        self.navigationController?.pushViewController(splashVC, animated: true)
    }    }
    
