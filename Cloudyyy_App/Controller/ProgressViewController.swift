import UIKit

class ProgressViewController: UIViewController {
    
    @IBOutlet var HeaderView: UIView!
    @IBOutlet var ScrollView: UIScrollView!
    @IBOutlet var ContentView: UIView!
    
    private var backgroundGradientLayer: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer?.frame = view.bounds
    }
    
    // MARK: - Gradient
    private func setupBackgroundGradient() {
        backgroundGradientLayer?.removeFromSuperlayer()
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 10/255, green: 13/255, blue: 41/255, alpha: 1).cgColor,
            UIColor(red: 24/255, green: 30/255, blue: 74/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        backgroundGradientLayer = gradient
        view.bringSubviewToFront(HeaderView)
        
}
    }

