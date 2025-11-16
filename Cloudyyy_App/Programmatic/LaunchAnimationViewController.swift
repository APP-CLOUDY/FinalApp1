import UIKit

final class LaunchAnimationViewController: UIViewController {

    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "cloudyy_logo"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // SAME COLOR AS SCENEDELEGATE BACKGROUND
        view.backgroundColor = UIColor(red: 46/255, green: 142/255, blue: 255/255, alpha: 1)

        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor)
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.goToSplash()
        }
    }

    // 🚀 Zero White Flash Transition
    private func goToSplash() {
        let splash = SplashViewController()
        let newRoot = UINavigationController(rootViewController: splash)
        newRoot.isNavigationBarHidden = true

        // Find the real window
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        guard let window = keyWindow else {
            navigationController?.setViewControllers([splash], animated: false)
            return
        }

        // Background color MUST MATCH splash/launch screen
        window.backgroundColor = UIColor(red: 46/255, green: 142/255, blue: 255/255, alpha: 1)

        UIView.transition(with: window,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: {
            window.rootViewController = newRoot
        })
    }
}
