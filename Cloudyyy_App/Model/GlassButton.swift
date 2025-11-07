//
//  GlassButton.swift
//  Cloudyyy_App
//
//  Created by user@5 on 06/11/25.
//

import UIKit

class GlassButton: UIButton {

    // We'll create the blur and gradient as sublayers
    private var blurView: UIVisualEffectView!
    private var gradientLayer: CAGradientLayer!

    // This gets called when the button is loaded from your XIB
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    // This is called when the button is created in code (good to have)
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // awakeFromNib() will be called for XIBs, so no need to call setupView() here
    }

    // This function ensures our blur/gradient layers fill the button
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update frames of sublayers
        blurView.frame = self.bounds
        gradientLayer.frame = self.bounds
    }

    private func setupView() {
        // --- 1. Set up the Button Itself ---
        
        // We must set the button's own background to clear
        self.backgroundColor = .clear
        
        // This is crucial to "clip" the blur view to the button's shape
        self.clipsToBounds = true
        self.layer.cornerRadius = 10 // You can change this
        
        // --- 2. Create the Blur Effect ---
        
        // This is the "frosted glass"
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        
        // Add the blur as the very first layer (at index 0)
        self.insertSubview(blurView, at: 0)
        
        // --- 3. Create the Subtle Gradient (like in your image) ---
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        
        // A very subtle gradient from semi-transparent white to clear
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.2).cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // Add the gradient on top of the blur
        self.layer.insertSublayer(gradientLayer, at: 1)

        // --- 4. Create the "Shine" Border ---
        
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        self.layer.borderWidth = 1.0
    }
}
