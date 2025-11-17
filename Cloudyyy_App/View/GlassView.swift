import UIKit

final class GlassView: UIView {

    let blur: UIVisualEffectView
    let contentView = UIView()

    init(cornerRadius: CGFloat = 12) {
        blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        super.init(frame: .zero)

        layer.cornerRadius = cornerRadius
        clipsToBounds = false

        blur.layer.cornerRadius = cornerRadius
        blur.layer.masksToBounds = true

        addSubview(blur)
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.contentView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: blur.contentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

