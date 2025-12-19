//
//  GradientView.swift
//  Cloudyyy_App
//
//  Created by user@5 on 08/11/25.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1) // #0C0C0C
    @IBInspectable var endColor: UIColor = UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1) // #203B6F
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }

    // 👇 This makes the gradient ignore touch events
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
