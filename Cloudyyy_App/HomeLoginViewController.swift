import UIKit

class HomeLoginViewController: UIViewController {
    
    @IBOutlet weak var bottomContainer: UIView!
    
    // Create the gradient layer as a class property
    // so we only have to create it one time.
    let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the gradient's colors and direction *once*
        setupGradient()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update the gradient's frame and corner mask
        // every time the view's size changes (like on rotation).
        updateGradientAndCorners()
    }
    
    func setupGradient() {
        // Use the colors from your code
        gradientLayer.colors = [
            UIColor(red: 22/255, green: 42/255, blue: 94/255, alpha: 1.0).cgColor, // Top - #162A5E
            UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1.0).cgColor  // Bottom - #0C0C0C
        ]
        
        // Set direction (vertical)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // Add the layer to the container's layer hierarchy at the bottom
        bottomContainer.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func updateGradientAndCorners() {
        // Always update the gradient's frame to match the container's bounds
        gradientLayer.frame = bottomContainer.bounds
        
        // --- This is the fix for the rounded corners ---
        
        // 1. Define the radius
        let cornerRadius: CGFloat = 30
        
        // 2. Create a new rect that starts *above* the view's frame
        // This pulls the rounding up to overlap the blue view, hiding the gap.
        let rect = CGRect(x: 0, y: -cornerRadius,
                          width: bottomContainer.bounds.width,
                          height: bottomContainer.bounds.height + cornerRadius)

        // 3. Create the path using this new, taller rect
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        
        // 4. Create a shape layer to act as a mask
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        
        // 5. Apply the mask to the container's layer
        bottomContainer.layer.mask = mask
    }

    // MARK: - IBActions

    @IBAction func loginButtonTapped(_ sender: UIButton) {
            print("Log In button tapped!")
            
            // This code will now work
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true)
        }
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        print("Sign Up button tapped!")

        // TODO: Add your navigation code here
        // let signupVC = SignupViewController()
        // signupVC.modalPresentationStyle = .fullScreen
        // self.present(signupVC, animated: true)
    }
    
    @IBAction func joinWithCodeButtonTapped(_ sender: UIButton) {
        print("Join with Code button tapped!")

        // TODO: Add your navigation code here
        // let joinVC = JoinViewController()
        // joinVC.modalPresentationStyle = .fullScreen
        // self.present(joinVC, animated: true)
    }
}
