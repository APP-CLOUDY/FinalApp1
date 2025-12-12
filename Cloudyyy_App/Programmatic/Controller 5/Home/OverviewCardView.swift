import UIKit

/// A liquid-glass style card similar to Apple marketing cards.
/// No sheen, no extra container — all UI sits directly inside the UIVisualEffectView.contentView.
final class OverviewCardGlassView: UIView {

    // MARK: - Blur + glass layers (no container)
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: currentBlurStyle())
        let v = UIVisualEffectView(effect: effect)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = cornerRadius
        v.layer.masksToBounds = true
        return v
    }()

    // subtle tint gradient INSIDE the blur
    private let tintGradient = CAGradientLayer()

    // faint frosted border (top-left bright, bottom-right darker)
    private let borderHighlight = CAGradientLayer()

    // inner shadow (static) using shape layer
    private let innerShadowLayer = CAShapeLayer()

    // small soft outer shadow on the whole view (not on blur layer)
    private let outerShadowRadius: CGFloat = 12

    // adjustable constants
    private let cornerRadius: CGFloat = 18

    // MARK: - Content (your existing subviews — these will be added directly to blurView.contentView)
    private let arcView = HomeProgressArcView()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Today's Overview"
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.78)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let missionsLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let redeemedLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.6)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let chevron: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = UIColor.white.withAlphaComponent(0.32)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraints()
        setupGlassLayers()
        applyOuterShadow()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup hierarchy (no container)
    private func setupViewHierarchy() {
        addSubview(blurView)

        // Add your elements directly into blurView.contentView:
        blurView.contentView.addSubview(titleLabel)
        blurView.contentView.addSubview(missionsLabel)
        blurView.contentView.addSubview(redeemedLabel)
        blurView.contentView.addSubview(arcView)
        blurView.contentView.addSubview(chevron)

        arcView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // blur fills whole view
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // left text column (pinned to contentView so blur's rounded corners are respected)
            titleLabel.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 20),

            missionsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            missionsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            redeemedLabel.topAnchor.constraint(equalTo: missionsLabel.bottomAnchor, constant: 6),
            redeemedLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            // chevron far right
            chevron.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -16),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 20),

            // arc on the right
            arcView.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor),
            arcView.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -20),
            arcView.widthAnchor.constraint(equalToConstant: 80),
            arcView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    // MARK: - Glass layers & visuals
    private func setupGlassLayers() {
        // tint gradient (very low alpha to give subtle color)
        tintGradient.colors = tintGradientColors()
        tintGradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        tintGradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        tintGradient.cornerRadius = cornerRadius

        // border highlight — a tiny gradient that serves as the frosted edge
        borderHighlight.colors = [
            UIColor(white: 1.0, alpha: 0.12).cgColor, // top-left highlight
            UIColor(white: 1.0, alpha: 0.04).cgColor // fade
        ]
        borderHighlight.startPoint = CGPoint(x: 0, y: 0)
        borderHighlight.endPoint = CGPoint(x: 1, y: 1)
        borderHighlight.cornerRadius = cornerRadius

        // inner shadow (simulate a subtle darkening near bottom edges)
        innerShadowLayer.fillRule = .evenOdd
        innerShadowLayer.shadowColor = UIColor.black.cgColor
        innerShadowLayer.shadowOffset = CGSize(width: 0, height: 10)
        innerShadowLayer.shadowOpacity = 0.16
        innerShadowLayer.shadowRadius = 14

        // add layers inside blurView.layer so they are clipped by blur's corner radius
        blurView.layer.insertSublayer(tintGradient, at: 0)            // bottom-most inside blur
        blurView.layer.insertSublayer(borderHighlight, above: tintGradient)
        blurView.layer.addSublayer(innerShadowLayer)                 // sits above tint but below content

        // subtle border line using the blurView's borderColor (tonal)
        blurView.layer.borderWidth = 0.3
        blurView.layer.borderColor = UIColor(white: 1.0, alpha: 0.06).cgColor
    }

    private func applyOuterShadow() {
        // outer shadow from the view's layer (not the blur layer) — lifts the card
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = outerShadowRadius
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.masksToBounds = false
    }

    // MARK: - Layout updates
    override func layoutSubviews() {
        super.layoutSubviews()

        // make sublayers follow the blur bounds (note: blurView may equal our bounds)
        tintGradient.frame = blurView.bounds
        borderHighlight.frame = blurView.bounds

        // inner shadow: create a path that is the outside rect, subtract the inner rounded rect
        let bounds = blurView.bounds
        let radius = blurView.layer.cornerRadius
        let outerPath = UIBezierPath(roundedRect: bounds.insetBy(dx: -20, dy: -20), cornerRadius: radius + 20)
        let innerRect = bounds.insetBy(dx: 1, dy: 1)
        let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: radius)
        outerPath.append(innerPath)
        outerPath.usesEvenOddFillRule = true
        innerShadowLayer.path = outerPath.cgPath
        innerShadowLayer.fillRule = .evenOdd
        innerShadowLayer.frame = blurView.bounds

        // keep the view's shadow path for better performance
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    // MARK: - Helpers (adaptive colors)
    private func currentBlurStyle() -> UIBlurEffect.Style {
        if traitCollection.userInterfaceStyle == .dark {
            // systemThinMaterialDark or systemUltraThinMaterialDark look great in dark mode
            return .systemUltraThinMaterialDark
        } else {
            // in light mode prefer a slightly lighter material so tinted gradient comes through
            return .systemThinMaterial
        }
    }

    private func tintGradientColors() -> [CGColor] {
        if traitCollection.userInterfaceStyle == .dark {
            // cool blue-violet tint (very low alpha)
            return [
                UIColor(red: 0.06, green: 0.08, blue: 0.18, alpha: 0.12).cgColor,
                UIColor(red: 0.10, green: 0.06, blue: 0.15, alpha: 0.06).cgColor
            ]
        } else {
            // light subtle warm/cool mix for light mode
            return [
                UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.06).cgColor,
                UIColor(red: 0.88, green: 0.95, blue: 1.0, alpha: 0.03).cgColor
            ]
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // adapt blur material and tint colors when interface style changes
        blurView.effect = UIBlurEffect(style: currentBlurStyle())
        tintGradient.colors = tintGradientColors()
    }

    // MARK: - Public configure (keeps your original signature)
    func configure(missionsDone: Int, missionsTotal: Int, redeemedText: String, progress: CGFloat, animated: Bool) {
        missionsLabel.text = "\(missionsDone)/\(missionsTotal) Missions"
        missionsLabel.isHidden = false
        redeemedLabel.text = redeemedText.isEmpty ? "No rewards yet" : "Redeemed \(redeemedText)"
        arcView.setProgress(progress, animated: animated)
    }
}

