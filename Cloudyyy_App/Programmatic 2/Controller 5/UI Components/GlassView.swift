//
//  GlassView.swift
//  Cloudyyy_App
//
//  Created by user@10 on 14/12/25.
//

import Foundation
import UIKit

// MARK: - Glass Style

enum GlassStyle {
    case card        // big cards (stats, profile)
    case row         // list rows (menus, categories)
}

// MARK: - Acrylic Glass View

final class GlassView: UIView {

    private let style: GlassStyle
    private let highlightLayer = CAGradientLayer()

    init(style: GlassStyle, cornerRadius: CGFloat) {
        self.style = style
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        isUserInteractionEnabled = false   // ⭐ IMPORTANT ⭐

        setupBase(cornerRadius: cornerRadius)
        setupHighlight(cornerRadius: cornerRadius)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupBase(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true

        switch style {
        case .card:
            backgroundColor = UIColor(white: 1, alpha: 0.028)
            layer.borderColor = UIColor(white: 1, alpha: 0.055).cgColor

        case .row:
            backgroundColor = UIColor(white: 1, alpha: 0.035)
            layer.borderColor = UIColor(white: 1, alpha: 0.065).cgColor
        }

        layer.borderWidth = 1
    }

    private func setupHighlight(cornerRadius: CGFloat) {
        highlightLayer.startPoint = CGPoint(x: 0.5, y: 0)
        highlightLayer.endPoint = CGPoint(x: 0.5, y: 1)

        switch style {
        case .card:
            highlightLayer.colors = [
                UIColor(white: 1, alpha: 0.06).cgColor,
                UIColor(white: 1, alpha: 0.015).cgColor
            ]

        case .row:
            highlightLayer.colors = [
                UIColor(white: 1, alpha: 0.045).cgColor,
                UIColor(white: 1, alpha: 0.012).cgColor
            ]
        }

        highlightLayer.cornerRadius = cornerRadius
        layer.insertSublayer(highlightLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        highlightLayer.frame = bounds
    }
}
