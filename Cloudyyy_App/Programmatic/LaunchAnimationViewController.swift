//
//  LaunchAnimationViewController.swift
//  Cloudyyy_App
//
//  Created by user@5 on 15/11/25.
//

import UIKit

final class LaunchAnimationViewController: UIViewController {

    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "yourLogo"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white  // same color as LaunchScreen

        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 180),
            logoImageView.widthAnchor.constraint(equalToConstant: 180)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLogo()
    }

    private func animateLogo() {
        logoImageView.alpha = 0
        logoImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        UIView.animate(
            withDuration: 1.2,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut,
            animations: {
                self.logoImageView.alpha = 1
                self.logoImageView.transform = .identity
            }
        )

        // Move to Splash after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.goToSplash()
        }
    }

    private func goToSplash() {
        let vc = SplashViewController()
        navigationController?.setViewControllers([vc], animated: true)
    }
}
