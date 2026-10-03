//
//  DarkGlassTabBar.swift
//  Cloudyyy_App
//
//  Custom tab bar matching the app's dark glass card aesthetic.
//  Uses the exact same GlassView styling (subtle white overlay + gradient highlight)
//  instead of iOS 26's default light Liquid Glass material.
//

import UIKit

// MARK: - Delegate

protocol DarkGlassTabBarDelegate: AnyObject {
    func darkGlassTabBar(_ tabBar: DarkGlassTabBar, didSelectIndex index: Int)
}

// MARK: - Tab Item Model

struct DarkGlassTabItem {
    let title: String
    let icon: String
}

// MARK: - Dark Glass Tab Bar

final class DarkGlassTabBar: UIView {

    weak var delegate: DarkGlassTabBarDelegate?
    private(set) var selectedIndex: Int = 0

    // ── Glass layers (matching GlassView.card style exactly) ──
    private let blurView: UIVisualEffectView = {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let glassOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 1, alpha: 0.028) // same as GlassView .card
        v.isUserInteractionEnabled = false
        return v
    }()

    private let highlightLayer: CAGradientLayer = {
        let g = CAGradientLayer()
        g.startPoint = CGPoint(x: 0.5, y: 0)
        g.endPoint   = CGPoint(x: 0.5, y: 1)
        g.colors = [
            UIColor(white: 1, alpha: 0.06).cgColor,   // same as GlassView .card
            UIColor(white: 1, alpha: 0.015).cgColor
        ]
        return g
    }()

    // ── Selected indicator pill (subtle glass) ──
    private let selectionPill: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 1, alpha: 0.08)
        v.layer.cornerRadius = 18
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor(white: 1, alpha: 0.12).cgColor
        return v
    }()

    // ── Tab buttons ──
    private let stackView: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .fillEqually
        s.alignment = .fill
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private var tabButtons: [UIView] = []
    private var items: [DarkGlassTabItem] = []

    // ── Corner radius ──
    private let barCornerRadius: CGFloat = 28

    // MARK: - Init

    init(items: [DarkGlassTabItem]) {
        self.items = items
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        buildUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Build

    private func buildUI() {
        // 1. Dark blur base
        addSubview(blurView)
        blurView.layer.cornerRadius = barCornerRadius
        blurView.clipsToBounds = true
        blurView.layer.borderWidth = 1
        blurView.layer.borderColor = UIColor(white: 1, alpha: 0.055).cgColor // GlassView border

        // 2. Glass overlay inside blur's content view
        blurView.contentView.addSubview(glassOverlay)

        // 3. Highlight gradient inside blur's content view
        blurView.contentView.layer.insertSublayer(highlightLayer, at: 0)

        // 4. Selection pill inside blur (behind buttons)
        blurView.contentView.addSubview(selectionPill)

        // 5. Stack for tab buttons
        blurView.contentView.addSubview(stackView)

        // 6. Create tab buttons
        for (index, item) in items.enumerated() {
            let tab = makeTabView(item: item, index: index)
            stackView.addArrangedSubview(tab)
            tabButtons.append(tab)
        }

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stackView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 6),
            stackView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -6),
        ])
    }

    // MARK: - Tab Button

    private func makeTabView(item: DarkGlassTabItem, index: Int) -> UIView {
        let container = UIView()
        container.tag = index

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: item.icon)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .lightGray
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tag = 100

        let label = UILabel()
        label.text = item.title
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.tag = 200

        container.addSubview(iconView)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 2),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
        container.addGestureRecognizer(tap)

        return container
    }

    // MARK: - Tap Handler

    @objc private func tabTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view else { return }
        let index = tappedView.tag
        selectTab(at: index, animated: true)
        delegate?.darkGlassTabBar(self, didSelectIndex: index)
    }

    // MARK: - Selection

    func selectTab(at index: Int, animated: Bool) {
        guard index >= 0, index < tabButtons.count else { return }
        selectedIndex = index

        // Update icon / label colors
        for (i, tab) in tabButtons.enumerated() {
            let icon = tab.viewWithTag(100) as? UIImageView
            let label = tab.viewWithTag(200) as? UILabel
            let isSelected = (i == index)

            UIView.animate(withDuration: animated ? 0.25 : 0) {
                icon?.tintColor = isSelected ? .white : .lightGray
                label?.textColor = isSelected ? .white : .lightGray
            }
        }

        // Animate pill position
        layoutIfNeeded()
        let target = tabButtons[index]
        let pillFrame = target.convert(target.bounds, to: blurView.contentView).insetBy(dx: 2, dy: 0)

        if animated {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0.5,
                options: .curveEaseInOut
            ) {
                self.selectionPill.frame = pillFrame
                self.selectionPill.alpha = 1
            }
        } else {
            selectionPill.frame = pillFrame
            selectionPill.alpha = 1
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        glassOverlay.frame = blurView.contentView.bounds
        highlightLayer.frame = blurView.contentView.bounds
        highlightLayer.cornerRadius = barCornerRadius

        // Re-position pill without animation on layout
        if tabButtons.indices.contains(selectedIndex) {
            let target = tabButtons[selectedIndex]
            let pillFrame = target.convert(target.bounds, to: blurView.contentView).insetBy(dx: 2, dy: 0)
            selectionPill.frame = pillFrame
        }
    }
}
