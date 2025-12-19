//
//  OnboardingContentViewController.swift
//  Cloudyyy_App
//
//  Created by user@5 on 25/11/25.
//

import UIKit

// This class represents a single page in the slider
final class OnboardingContentViewController: UIViewController {
    
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    
    // Data to display
    private let imageName: String
    private let text: String
    
    init(imageName: String, text: String) {
        self.imageName = imageName
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // --- Image Setup ---
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        // Note: Using systemName for demo. Replace with UIImage(named: imageName) for your assets
        if let customImage = UIImage(named: imageName) {
             imageView.image = customImage
        } else {
            // Fallback to SF Symbols if you don't have the assets yet
            imageView.image = UIImage(systemName: imageName)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
        view.addSubview(imageView)
        
        // --- Label Setup ---
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = text
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0 // Allow multiple lines
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        view.addSubview(descriptionLabel)
        
        // --- Constraints ---
        NSLayoutConstraint.activate([
            // Image takes up the top portion
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.65), // Image takes 65% height
            
            // Label takes the space below image
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
    }
}
