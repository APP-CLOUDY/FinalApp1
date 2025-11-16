//
//  FamilySignup.swift
//  Cloudyyy_App
//
//  Created by user@5 on 16/11/25.
//

import UIKit

// --- Custom Gradient View ---
// This view replicates the subtle gradient seen in the cards
class GradientCardView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    // Gradient colors from the image
    private let startColor = UIColor(red: 50/255, green: 60/255, blue: 85/255, alpha: 1.0)
    private let endColor = UIColor(red: 40/255, green: 50/255, blue: 75/255, alpha: 1.0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0) // Top-left
        gradientLayer.endPoint = CGPoint(x: 1, y: 1) // Bottom-right
        layer.insertSublayer(gradientLayer, at: 0)
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update the gradient layer's frame when the view's bounds change
        gradientLayer.frame = bounds
    }
    
    // Helper to set corner radius
    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
    }
}
// --- End Custom View ---


class FamilyViewController: UIViewController {

    private let darkBlueBackground = UIColor(red: 20/255, green: 25/255, blue: 40/255, alpha: 1.0)

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search"
        sb.backgroundImage = UIImage()
        
        let micButton = UIButton(type: .system)
        micButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        micButton.tintColor = .systemGray
        
        sb.searchTextField.rightView = micButton
        sb.searchTextField.rightViewMode = .always
        sb.searchTextField.leftView?.tintColor = .systemGray
        // Use the flat color for the search bar as gradients are complex here
        sb.searchTextField.backgroundColor = UIColor(red: 40/255, green: 50/255, blue: 75/255, alpha: 1.0)
        sb.searchTextField.textColor = .white
        sb.searchTextField.layer.cornerRadius = 18
        sb.searchTextField.layer.masksToBounds = true
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    private let familyNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Family Name"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Use GradientCardView for the container
    private let familyNameContainer: GradientCardView = {
        let view = GradientCardView()
        view.setCornerRadius(10)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let familyNameTextField: UITextField = {
        let tf = UITextField()
        tf.text = "Happy Home"
        tf.textColor = .white
        tf.borderStyle = .none
        tf.backgroundColor = .clear // Important: make background clear
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let editIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "pencil")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let parentsLabel: UILabel = {
        let label = UILabel()
        label.text = "Parents"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let childrenLabel: UILabel = {
        let label = UILabel()
        label.text = "Children"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // Use a custom button with gradient
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.8), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 14
        button.clipsToBounds = true // Important for gradient
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Add gradient layer to the button
        let gradientLayer = CAGradientLayer()
        let startColor = UIColor(red: 50/255, green: 60/255, blue: 85/255, alpha: 1.0)
        let endColor = UIColor(red: 40/255, green: 50/255, blue: 75/255, alpha: 1.0)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        // Use a name to find this layer later in viewDidLayoutSubviews
        gradientLayer.name = "buttonGradient"
        
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        return button
    }()
    
    // We need this to resize the button's gradient when the view lays out
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = nextButton.layer.sublayers?.first(where: { $0.name == "buttonGradient" }) as? CAGradientLayer {
            gradientLayer.frame = nextButton.bounds
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = darkBlueBackground
        setupNavigation()
        setupUI()
    }

    private func setupNavigation() {
        title = "Family"
        
        // Add the back button manually
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handleBack)
        )
        // Set the arrow color
        navigationController?.navigationBar.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = darkBlueBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    // Action for the manual back button
    @objc private func handleBack() {
        print("Back button tapped")
        // If you were pushed to this view, you would use:
        // navigationController?.popViewController(animated: true)
    }

    // Updated to use GradientCardView
    private func createMemberCard(avatarImage: UIImage, name: String, subtitle1: String, subtitle2: String?) -> UIView {
        let card = GradientCardView() // Use the custom gradient view
        card.setCornerRadius(16)
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let avatarView = UIImageView(image: avatarImage)
        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.cornerRadius = 30
        avatarView.clipsToBounds = true
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        let subtitle1Label = UILabel()
        subtitle1Label.text = subtitle1
        subtitle1Label.textColor = .systemGray
        subtitle1Label.font = .systemFont(ofSize: 14)
        
        let textStackView = UIStackView(arrangedSubviews: [nameLabel, subtitle1Label])
        textStackView.axis = .vertical
        textStackView.spacing = 4
        
        if let subtitle2 = subtitle2 {
            let subtitle2Label = UILabel()
            subtitle2Label.text = subtitle2
            subtitle2Label.textColor = .systemGray
            subtitle2Label.font = .systemFont(ofSize: 14)
            textStackView.addArrangedSubview(subtitle2Label)
        }
        
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(avatarView)
        card.addSubview(textStackView)
        
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 60),
            avatarView.heightAnchor.constraint(equalToConstant: 60),
            
            textStackView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            textStackView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            card.heightAnchor.constraint(equalToConstant: 92)
        ])
        
        return card
    }

    private func setupUI() {
        view.addSubview(searchBar)
        
        view.addSubview(familyNameLabel)
        view.addSubview(familyNameContainer)
        familyNameContainer.addSubview(familyNameTextField)
        familyNameContainer.addSubview(editIcon)
        
        view.addSubview(parentsLabel)
        let parentCard = createMemberCard(
            avatarImage: UIImage(named: "mom_avatar") ?? UIImage(systemName: "person.fill")!,
            name: "Ridu Mom",
            subtitle1: "Mom",
            subtitle2: nil
        )
        view.addSubview(parentCard)
        
        view.addSubview(childrenLabel)
        let childCard = createMemberCard(
            avatarImage: UIImage(named: "child_avatar") ?? UIImage(systemName: "person.fill")!,
            name: "Ananya varshini",
            subtitle1: "Anu",
            subtitle2: "Code: 33501"
        )
        view.addSubview(childCard)
        
        view.addSubview(addButton)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            familyNameLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            familyNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            familyNameContainer.topAnchor.constraint(equalTo: familyNameLabel.bottomAnchor, constant: 12),
            familyNameContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            familyNameContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            familyNameContainer.heightAnchor.constraint(equalToConstant: 50),
            
            editIcon.centerYAnchor.constraint(equalTo: familyNameContainer.centerYAnchor),
            editIcon.trailingAnchor.constraint(equalTo: familyNameContainer.trailingAnchor, constant: -16),
            editIcon.widthAnchor.constraint(equalToConstant: 20),
            editIcon.heightAnchor.constraint(equalToConstant: 20),
            
            familyNameTextField.centerYAnchor.constraint(equalTo: familyNameContainer.centerYAnchor),
            familyNameTextField.leadingAnchor.constraint(equalTo: familyNameContainer.leadingAnchor, constant: 16),
            familyNameTextField.trailingAnchor.constraint(equalTo: editIcon.leadingAnchor, constant: -8),
            
            parentsLabel.topAnchor.constraint(equalTo: familyNameContainer.bottomAnchor, constant: 30),
            parentsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            parentCard.topAnchor.constraint(equalTo: parentsLabel.bottomAnchor, constant: 12),
            parentCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            parentCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            childrenLabel.topAnchor.constraint(equalTo: parentCard.bottomAnchor, constant: 30),
            childrenLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            childCard.topAnchor.constraint(equalTo: childrenLabel.bottomAnchor, constant: 12),
            childCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            childCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            
            addButton.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
