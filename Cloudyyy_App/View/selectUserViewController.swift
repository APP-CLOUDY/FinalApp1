import UIKit

class selectUserViewController: UIViewController {

    // MARK: - IBOutlets

    // Parent Button Outlets
    @IBOutlet weak var parentCircleView: UIView!
    @IBOutlet weak var parentIconImageView: UIImageView!
    
    // Child Button Outlets
    @IBOutlet weak var childCircleView: UIView!
    @IBOutlet weak var childIconImageView: UIImageView!
    
    // Main Illustration Outlet (if image is set programmatically)
    @IBOutlet weak var familyIllustrationImageView: UIImageView!
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Apply initial setup (images and colors)
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 2. Apply the circular corner radius after Auto Layout has finished
        applyCircularDesign()
    }
    
    // MARK: - Setup Functions
    
    private func setupViews() {
        // Load the main illustration image
//        familyIllustrationImageView.image = UIImage(named: "family_illustration")
        
        // Set the icon images and background colors for the buttons
//        parentIconImageView.image = UIImage(named: "parent_icon")
//        parentCircleView.backgroundColor = UIColor.white
        
//        childIconImageView.image = UIImage(named: "child_icon")
//        childCircleView.backgroundColor = UIColor.white
    }
    
    private func applyCircularDesign() {
        let circleDimension: CGFloat = 120.0
        let cornerRadius: CGFloat = circleDimension / 2.0 // 60.0 points

        // Apply to Parent button container
        parentCircleView.layer.cornerRadius = cornerRadius
        parentCircleView.clipsToBounds = true
        
        // Apply to Child button container
        childCircleView.layer.cornerRadius = cornerRadius
        childCircleView.clipsToBounds = true
    }

    // MARK: - IBActions 🚀 (Functional Logic)

    /**
     * Connect this action to the UIButton or UITapGestureRecognizer covering the Parent option.
     */
    @IBAction func parentSelectionTapped(_ sender: Any) {
        print("Parent selected: Proceeding to Parent flow.")
        // Add navigation logic here, e.g.,
        // self.performSegue(withIdentifier: "ShowParentLogin", sender: self)
    }
    
    /**
     * Connect this action to the UIButton or UITapGestureRecognizer covering the Child option.
     */
    @IBAction func childSelectionTapped(_ sender: Any) {
        print("Child selected: Proceeding to Child flow.")
        // Add navigation logic here, e.g.,
        // self.performSegue(withIdentifier: "ShowChildSignup", sender: self)
    }
}
