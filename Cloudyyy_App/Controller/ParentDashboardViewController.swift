//
//  ParentDashboardViewController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 06/11/25.
//
import UIKit

class ParentDashboardViewController: UIViewController {

   
    @IBOutlet var progressChartView: UIView!

    @IBOutlet var ScrollView: UIScrollView!
    @IBOutlet var ContentView: UIView!
    
    @IBOutlet var WeeklyChart: UISegmentedControl!
    
    
    
        // MARK: - Layers
            private var backgroundGradientLayer: CAGradientLayer?
            private var ringGradientLayer: CAGradientLayer?
            private var progressLayer: CAShapeLayer?

            // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()

        let chartView = WeeklyChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = UIColor.lightGray// light gray
        chartView.layer.cornerRadius = 20
        

        // ✅ Add to the same container as your segmented control
        ContentView.addSubview(chartView)

        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: WeeklyChart.bottomAnchor, constant: 20),
            chartView.leadingAnchor.constraint(equalTo: ContentView.leadingAnchor, constant: 20),
            chartView.trailingAnchor.constraint(equalTo: ContentView.trailingAnchor, constant: -20),
            chartView.heightAnchor.constraint(equalTo: ContentView.heightAnchor, multiplier: 0.35),
            chartView.bottomAnchor.constraint(equalTo: ContentView.bottomAnchor, constant: -20)
        ])
    }



            override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                backgroundGradientLayer?.frame = view.bounds
                setupProgressRing()
            }

            // MARK: - Background Gradient
            private func setupBackgroundGradient() {
                let gradient = CAGradientLayer()
                gradient.colors = [
                    UIColor(red: 10/255, green: 13/255, blue: 41/255, alpha: 1).cgColor,  // deep navy
                    UIColor(red: 24/255, green: 30/255, blue: 74/255, alpha: 1).cgColor   // blue
                ]
                gradient.startPoint = CGPoint(x: 0, y: 0)
                gradient.endPoint = CGPoint(x: 1, y: 1)
                view.layer.insertSublayer(gradient, at: 0)
                backgroundGradientLayer = gradient
            }

            // MARK: - Circular Progress Ring
        private func setupProgressRing() {
            // Remove old layers before redrawing
            progressChartView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

            // Ensure consistent circle dimensions
            let size = min(progressChartView.bounds.width, progressChartView.bounds.height)
            let radius = (size / 2) - 6
            let center = CGPoint(x: progressChartView.bounds.midX, y: progressChartView.bounds.midY)
            
            // Create one shared path (used for both background and progress)
            let circlePath = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: -.pi / 2,
                endAngle: 1.5 * .pi,
                clockwise: true
            )

            // 🩶 Background Circle (base ring)
            let backgroundCircle = CAShapeLayer()
            backgroundCircle.path = circlePath.cgPath
            backgroundCircle.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
            backgroundCircle.fillColor = UIColor.clear.cgColor
            backgroundCircle.lineWidth = 10
            backgroundCircle.lineCap = .round
            progressChartView.layer.addSublayer(backgroundCircle)

            // 💙 Progress Circle (masked to gradient)
            let progressShape = CAShapeLayer()
            progressShape.path = circlePath.cgPath
            progressShape.strokeColor = UIColor.systemBlue.cgColor
            progressShape.fillColor = UIColor.clear.cgColor
            progressShape.lineWidth = 12
            progressShape.lineCap = .round
            progressShape.strokeEnd = 0 // start empty

            // 🎨 Gradient Overlay
            let gradient = CAGradientLayer()
            gradient.frame = progressChartView.bounds
            gradient.colors = [
                UIColor.systemBlue.cgColor,
                UIColor.systemTeal.cgColor
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            gradient.mask = progressShape // mask ensures perfect alignment
            progressChartView.layer.addSublayer(gradient)

            // Save references
            progressLayer = progressShape
            ringGradientLayer = gradient

            // Animate smooth progress
            let progress: CGFloat = 4.0 / 7.0
            animateProgress(to: progress)
        }

            // MARK: - Animation
            private func animateProgress(to progress: CGFloat) {
                guard let progressLayer = progressLayer else { return }

                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = 0
                animation.toValue = progress
                animation.duration = 1.2
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                progressLayer.add(animation, forKey: "progressAnim")

                // Add subtle “pop” animation for a polished effect
                UIView.animate(withDuration: 0.4,
                               delay: 0.2,
                               usingSpringWithDamping: 0.6,
                               initialSpringVelocity: 0.4,
                               options: .curveEaseOut,
                               animations: {
                    self.progressChartView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
                }) { _ in
                    UIView.animate(withDuration: 0.3) {
                        self.progressChartView.transform = .identity
                    }
                }
            }
        
        
      
           
    }
