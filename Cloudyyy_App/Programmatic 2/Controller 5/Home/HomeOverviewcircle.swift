//
//  HomeOverviewcircle.swift
//  Cloudyyy_App
//
//  Created by user@10 on 16/12/25.
//

import Foundation
import UIKit

final class HomeProgressArcView: UIView {
    
    private let trackLayer = CAShapeLayer()
    private let ringLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    private let glowLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayers()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupLayers() {
        // 1. Track (Gray Background Ring)
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.white.withAlphaComponent(0.1).cgColor
        trackLayer.lineWidth = 12
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        // 2. Ring (The Progress Stroke)
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.lineWidth = 12
        ringLayer.lineCap = .round
        ringLayer.strokeEnd = 0
        ringLayer.strokeColor = UIColor.white.cgColor
        
        // 3. Gradient (Blue to Cyan)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.cyan.cgColor
        ]
        gradientLayer.mask = ringLayer
        layer.addSublayer(gradientLayer)
        
        // 4. Glow (Shadow)
        glowLayer.shadowColor = UIColor.systemBlue.cgColor
        glowLayer.shadowOpacity = 0.4
        glowLayer.shadowRadius = 8
        glowLayer.shadowOffset = .zero
        glowLayer.backgroundColor = UIColor.clear.cgColor
        layer.insertSublayer(glowLayer, below: gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        glowLayer.frame = bounds
        
        // --- FULL CIRCLE MATH ---
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        // Radius is half the width minus padding for the stroke
        let radius = (min(bounds.width, bounds.height) / 2) - 10
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2, // 12 o'clock
            endAngle: 1.5 * CGFloat.pi,  // Full 360 loop
            clockwise: true
        )
        
        trackLayer.path = path.cgPath
        ringLayer.path = path.cgPath
    }
    
    func setProgress(_ value: CGFloat, animated: Bool = true) {
        let clamped = max(0, min(1, value))
        
        if animated {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = ringLayer.strokeEnd
            anim.toValue = clamped
            anim.duration = 0.8
            anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
            ringLayer.strokeEnd = clamped
            ringLayer.add(anim, forKey: "progress")
        } else {
            ringLayer.strokeEnd = clamped
        }
    }
}

