//
//  HomeProgressArcView.swift
//  Cloudyyy_App
//

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

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Build Layers
    private func setupLayers() {
        // ----- BASE GRAY TRACK -----
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.white.withAlphaComponent(0.10).cgColor
        trackLayer.lineWidth = 18
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)

        // ----- ACTIVE RING (stroke only) -----
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.lineWidth = 18
        ringLayer.lineCap = .round
        ringLayer.strokeEnd = 0
        ringLayer.strokeColor = UIColor.white.cgColor // real color is from gradient mask
        
        // Gradient for Fitness-style color
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemTeal.cgColor,
            UIColor.systemPurple.cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.mask = ringLayer
        layer.addSublayer(gradientLayer)

        // ----- GLOW LAYER -----
        glowLayer.shadowColor = UIColor.systemBlue.cgColor
        glowLayer.shadowOpacity = 0.7
        glowLayer.shadowRadius = 12
        glowLayer.shadowOffset = .zero
        layer.insertSublayer(glowLayer, above: gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
        glowLayer.frame = bounds

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width/2 - 14, bounds.height/2 - 14)

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,   // full circle
            clockwise: true
        )

        trackLayer.path = path.cgPath
        ringLayer.path = path.cgPath
    }

    // MARK: - Set Progress
    func setProgress(_ value: CGFloat, animated: Bool = true) {
        let clamped = max(0, min(1, value))

        if animated {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = ringLayer.strokeEnd
            anim.toValue = clamped
            anim.duration = 0.9
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            ringLayer.strokeEnd = clamped
            ringLayer.add(anim, forKey: "progress")

            // Pulse like Apple Fitness when updated
            addPulseAnimation()
        } else {
            ringLayer.strokeEnd = clamped
        }
    }

    // MARK: - Pulse Animation
    private func addPulseAnimation() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.05
        pulse.duration = 0.25
        pulse.autoreverses = true
        pulse.timingFunction = CAMediaTimingFunction(name: .easeOut)
        layer.add(pulse, forKey: "pulse")
    }
}

