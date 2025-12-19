//
//  GlassCardView.swift
//  Cloudyyy_App
//
//  Created by user@5 on 16/12/25.
//

import UIKit

class GlassCardView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGlassStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGlassStyle()
    }
    
    private func setupGlassStyle() {
        self.backgroundColor = UIColor(white: 1, alpha: 0.05)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(white: 1, alpha: 0.1).cgColor
        self.clipsToBounds = true
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
    }
}

