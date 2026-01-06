//
//  ProgressSemiCircle.swift
//  Cloudyyy_App
//
//  Created by user@10 on 14/12/25.
//

import Foundation
import UIKit

final class ProgressSemiCircleView: UIView {
    private let track = CAShapeLayer()
    private let progress = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        track.fillColor = UIColor.clear.cgColor
        track.strokeColor = UIColor.white.withAlphaComponent(0.1).cgColor
        track.lineWidth = 14
        track.lineCap = .round
        
        progress.fillColor = UIColor.clear.cgColor
        progress.strokeColor = UIColor(red: 64/255, green: 156/255, blue: 255/255, alpha: 1).cgColor
        progress.lineWidth = 14
        progress.lineCap = .round
        progress.strokeEnd = 0
        
        layer.addSublayer(track)
        layer.addSublayer(progress)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.maxY - 10)
        let radius = bounds.width / 2 - 10
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: .pi,
            endAngle: 0,
            clockwise: true
        )
        track.path = path.cgPath
        progress.path = path.cgPath
    }
    
    func setProgress(_ val: CGFloat) {
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = progress.strokeEnd
        anim.toValue = val
        anim.duration = 0.5
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        progress.strokeEnd = val
        progress.add(anim, forKey: "anim")
    }
}
