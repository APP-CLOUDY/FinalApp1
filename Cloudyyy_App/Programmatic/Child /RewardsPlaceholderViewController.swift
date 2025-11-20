import UIKit

class RewardsPlaceholderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        let lbl = UILabel()
        lbl.text = "Rewards"
        lbl.textColor = .white
        lbl.font = .boldSystemFont(ofSize: 22)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lbl)
        
        NSLayoutConstraint.activate([
            lbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lbl.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
