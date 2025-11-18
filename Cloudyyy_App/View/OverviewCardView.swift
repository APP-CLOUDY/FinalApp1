//
//  OverviewCardView.swift
//  Cloudyyy_App
//
//  Created by user@10 on 16/11/25.
//

import Foundation
import UIKit

/// OverviewCardView
/// Glass card with inner shadow, gradient overlay, animated arc and count-up labels.
/// Re-uses your existing `ProgressArcView`.
final class OverviewCardView: UIView {

    // MARK: - Subviews
    private let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let overlayGradient = CAGradientLayer()
    private let innerShadowLayer = CALayer()
    private let container = UIView()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))


    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Today's Overview"
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = UIColor.white.withAlphaComponent(0.75)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let missionsLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let redeemedLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // We'll re-use your ProgressArcView (semi-circle). Must exist in project.
    private let arcView: HomeProgressArcView = {
        let a = HomeProgressArcView()
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()

    // count animation helpers
    private var missionsTargetValue: (done: Int, total: Int) = (0, 0)
    private var countDisplayLink: CADisplayLink?
    private var countStartTime: CFTimeInterval = 0
    private var countDuration: Double = 0.9

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        overlayGradient.frame = bounds
        blur.frame = bounds
        innerShadowLayer.frame = bounds
        applyInnerShadow()
    }

    // MARK: - Setup
    private func setupViews() {
        layer.cornerRadius = 18
        layer.masksToBounds = false

        // Blur background
        addSubview(blur)
        blur.layer.cornerRadius = 18
        blur.layer.masksToBounds = true
        blur.contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false

        // gradient overlay for subtle depth
        overlayGradient.colors = [
            UIColor(white: 1.0, alpha: 0.02).cgColor,
            UIColor(white: 0.0, alpha: 0.02).cgColor
        ]
        overlayGradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        overlayGradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.insertSublayer(overlayGradient, above: blur.layer)

        // inner shadow layer
        innerShadowLayer.backgroundColor = UIColor.clear.cgColor
        layer.addSublayer(innerShadowLayer)

        // content
        container.addSubview(titleLabel)
        container.addSubview(missionsLabel)
        container.addSubview(redeemedLabel)
        container.addSubview(arcView)
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, missionsLabel, redeemedLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(textStack)
        chevron.tintColor = .white.withAlphaComponent(0.35)
        chevron.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chevron)

       

        
        NSLayoutConstraint.activate([
            // container pinned to blur content
            container.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor),
            container.topAnchor.constraint(equalTo: blur.contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor),

            // left column
            textStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            // arc
            arcView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            arcView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            arcView.widthAnchor.constraint(equalToConstant: 110),
            arcView.heightAnchor.constraint(equalToConstant: 110),
            
            chevron.centerYAnchor.constraint(equalTo: arcView.centerYAnchor),
                chevron.leadingAnchor.constraint(equalTo: arcView.trailingAnchor, constant: 10),
                chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

                // FIXED SIZE (ideal for SF Symbols)
                chevron.widthAnchor.constraint(equalToConstant: 18),
                chevron.heightAnchor.constraint(equalToConstant: 18)
        ])

        // accessibility
        isAccessibilityElement = false
        titleLabel.accessibilityTraits = .header
        missionsLabel.accessibilityTraits = .staticText
        redeemedLabel.accessibilityTraits = .staticText
        
        
    }

    // MARK: - Inner shadow
    private func applyInnerShadow() {
        innerShadowLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let radius: CGFloat = 20
        let path = UIBezierPath(roundedRect: innerShadowLayer.bounds.insetBy(dx: -20, dy: -20), cornerRadius: layer.cornerRadius + 20)
        let cutout = UIBezierPath(roundedRect: innerShadowLayer.bounds, cornerRadius: layer.cornerRadius).reversing()
        path.append(cutout)

        let shadowLayer = CAShapeLayer()
        shadowLayer.path = path.cgPath
        shadowLayer.fillRule = .evenOdd
        shadowLayer.fillColor = UIColor.black.withAlphaComponent(0.28).cgColor
        shadowLayer.opacity = 0.28
        innerShadowLayer.addSublayer(shadowLayer)
    }

    // MARK: - Configure / Animate
    /// Provide overview + progress (0..1). The view will animate counts and arc.
    func configure(missionsDone: Int, missionsTotal: Int, redeemedText: String, progress: CGFloat, animated: Bool = true) {
        // set redeemed text immediately
        redeemedLabel.text = "Redeemed \(redeemedText)"

        // prepare count animation
        missionsTargetValue = (missionsDone, missionsTotal)

        // animate arc
        arcView.setProgress(progress, animated: animated)

        // animate the missions label count up: "X / Y Missions"
        startCountAnimation(animated: animated)
    }

    private func startCountAnimation(animated: Bool) {
        countDisplayLink?.invalidate()
        missionsLabel.text = "0/\(missionsTargetValue.total) Missions"

        guard animated else {
            missionsLabel.text = "\(missionsTargetValue.done)/\(missionsTargetValue.total) Missions"
            return
        }

        countStartTime = CACurrentMediaTime()
        countDisplayLink = CADisplayLink(target: self, selector: #selector(handleCountTick))
        countDisplayLink?.add(to: .main, forMode: .common)
    }

    @objc private func handleCountTick() {
        guard let dl = countDisplayLink else { return }
        let elapsed = CACurrentMediaTime() - countStartTime
        if elapsed >= countDuration {
            // done
            missionsLabel.text = "\(missionsTargetValue.done)/\(missionsTargetValue.total) Missions"
            dl.invalidate()
            countDisplayLink = nil
            return
        }

        // easeOut progress
        let t = elapsed / countDuration
        let eased = CGFloat(1 - pow(1 - t, 3)) // easeOut cubic
        let current = Int(round(CGFloat(missionsTargetValue.done) * eased))
        missionsLabel.text = "\(current)/\(missionsTargetValue.total) Missions"
    }

    // expose some small helpers if parent wants to set fonts/colors later
    func setTitleFont(_ font: UIFont) { titleLabel.font = font }
    func setMissionsFont(_ font: UIFont) { missionsLabel.font = font }
    func setRedeemedFont(_ font: UIFont) { redeemedLabel.font = font }
}
