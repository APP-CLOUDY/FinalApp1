import UIKit

final class LaunchAnimationViewController: UIViewController {

    // MARK: - Properties

    // 1. --- RENAMED & UPDATED ---
    private let firstCloudView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "cloudyy_gym"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let secondCloudView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "cloudyy_market"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let thirdCloudView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "cloudyy_paint"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // 2. --- ADDED: Fourth cloud ---
    // 🚨 Update "cloudyy_logo" to your fourth asset name
    private let fourthCloudView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "cloudyy_logo"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 46/255, green: 142/255, blue: 255/255, alpha: 1)

        // 3. --- ADDED: Add all 4 subviews ---
        view.addSubview(firstCloudView)
        view.addSubview(secondCloudView)
        view.addSubview(thirdCloudView)
        view.addSubview(fourthCloudView)

        setupConstraints()
    }

    // 4. --- UPDATED: All clouds in the same position ---
    private func setupConstraints() {
        // Create an array of all cloud views to apply constraints
        let cloudViews = [firstCloudView, secondCloudView, thirdCloudView, fourthCloudView]
        
        // Loop and apply the *same* constraints to all of them
        for cloudView in cloudViews {
            NSLayoutConstraint.activate([
                cloudView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                cloudView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                cloudView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
                cloudView.heightAnchor.constraint(equalTo: cloudView.widthAnchor),
            ])
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLogo()
    }

    // MARK: - Animation

    // 5. --- RE-WRITTEN: "One after other" cross-fade animation ---
    private func animateLogo() {
        // Initial state: Show the first cloud, hide all others
        firstCloudView.alpha = 1
        secondCloudView.alpha = 0
        thirdCloudView.alpha = 0
        fourthCloudView.alpha = 0
        
        let fadeDuration = 0.5 // How long the cross-fade takes
        let holdDuration = 0.8 // How long to show each image
        
        // This creates a chain of animations. Each one starts in
        // the 'completion' block of the one before it.

        // 1. After 'holdDuration', fade from 1 -> 2
        UIView.animate(
            withDuration: fadeDuration,
            delay: holdDuration,
            options: .curveEaseInOut,
            animations: {
                self.firstCloudView.alpha = 0
                self.secondCloudView.alpha = 1
            },
            
            completion: { _ in
                // 2. After 'holdDuration', fade from 2 -> 3
                UIView.animate(
                    withDuration: fadeDuration,
                    delay: holdDuration,
                    options: .curveEaseInOut,
                    animations: {
                        self.secondCloudView.alpha = 0
                        self.thirdCloudView.alpha = 1
                    },
                    completion: { _ in
                        // 3. After 'holdDuration', fade from 3 -> 4
                        UIView.animate(
                            withDuration: fadeDuration,
                            delay: holdDuration,
                            options: .curveEaseInOut,
                            animations: {
                                self.thirdCloudView.alpha = 0
                                self.fourthCloudView.alpha = 1
                            },
                            completion: { _ in
                                // 4. All animations done. Wait 'holdDuration' one last time
                                // then transition to the next screen.
                                DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
                                    self.goToSplash()
                                }
                            }
                        )
                    }
                )
            }
        )
    }

    // 🚀 Zero White Flash Transition (Unchanged)
    private func goToSplash() {
        let splash = SplashViewController()
        let newRoot = UINavigationController(rootViewController: splash)
        newRoot.isNavigationBarHidden = true

        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        guard let window = keyWindow else {
            navigationController?.setViewControllers([splash], animated: false)
            return
        }

        window.backgroundColor = UIColor(red: 46/255, green: 142/255, blue: 255/255, alpha: 1)

        UIView.transition(with: window,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: {
            window.rootViewController = newRoot
        })
    }
}
