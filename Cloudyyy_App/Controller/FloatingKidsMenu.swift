import UIKit

final class FloatingKidsMenu: UIView {

    // MARK: - Manager Reference (needed to auto-close)
    weak var manager: FloatingMenuManager?

    // MARK: - Callback
    var onKidSelected: ((Kid) -> Void)?

    // MARK: - UI
    private let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
    private let stack = UIStackView()
    private var kids: [Kid] = []

    // MARK: - Init
    init(kids: [Kid]) {
        self.kids = kids
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Setup
    private func setup() {

        // Tap outside dismiss enabled
        backgroundColor = UIColor.black.withAlphaComponent(0.001)

        // Blur container
        blur.layer.cornerRadius = 18
        blur.layer.masksToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blur)

        // Button stack
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        blur.contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: blur.contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor, constant: -12)
        ])

        // Add kid options
        kids.forEach { kid in
            let btn = UIButton(type: .system)
            btn.setTitle(kid.name, for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            btn.contentHorizontalAlignment = .leading
            btn.heightAnchor.constraint(equalToConstant: 42).isActive = true

            btn.addAction(UIAction(handler: { [weak self] _ in
                guard let self else { return }
                self.onKidSelected?(kid)
                self.dismiss(animated: true)
            }), for: .touchUpInside)

            stack.addArrangedSubview(btn)
        }

        // Tap outside to dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissTap))
        addGestureRecognizer(tap)
    }

    // MARK: - Show
    func show(in parent: UIView, anchor: UIView) {

        // Close any existing dropdown FIRST
        manager?.closeMenu()

        manager?.register(menu: self)


        parent.addSubview(self)
        parent.bringSubviewToFront(self)

        translatesAutoresizingMaskIntoConstraints = false

        // Fill entire parent (so taps outside dismiss)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            topAnchor.constraint(equalTo: parent.topAnchor),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])
        layoutIfNeeded()

        // Menu size
        let menuWidth: CGFloat = 180
        let menuHeight: CGFloat = CGFloat(kids.count * 46 + 24)

        let anchorFrame = anchor.convert(anchor.bounds, to: parent)
        let safeTop = parent.safeAreaInsets.top
        let safeBottom = parent.safeAreaInsets.bottom

        let spaceAbove = anchorFrame.minY - safeTop
        let spaceBelow = parent.bounds.height - anchorFrame.maxY - safeBottom

        let shouldShowAbove = spaceBelow < menuHeight && spaceAbove > menuHeight

        blur.translatesAutoresizingMaskIntoConstraints = false

        if shouldShowAbove {
            NSLayoutConstraint.activate([
                blur.widthAnchor.constraint(equalToConstant: menuWidth),
                blur.heightAnchor.constraint(equalToConstant: menuHeight),
                blur.leadingAnchor.constraint(equalTo: anchor.leadingAnchor),
                blur.bottomAnchor.constraint(equalTo: anchor.topAnchor, constant: -8)
            ])
        } else {
            NSLayoutConstraint.activate([
                blur.widthAnchor.constraint(equalToConstant: menuWidth),
                blur.heightAnchor.constraint(equalToConstant: menuHeight),
                blur.leadingAnchor.constraint(equalTo: anchor.leadingAnchor),
                blur.topAnchor.constraint(equalTo: anchor.bottomAnchor, constant: 8)
            ])
        }

        // Animate dropdown
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.85, y: 0.85)

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.78,
            initialSpringVelocity: 0.4,
            options: .curveEaseOut
        ) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    // MARK: - Dismiss Handlers
    @objc private func dismissTap() { dismiss(animated: true) }

    func dismiss(animated: Bool) {
        let finish = {
            self.removeFromSuperview()
            self.manager?.clearMenu()
        }

        guard animated else { finish(); return }

        UIView.animate(
            withDuration: 0.18,
            animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            },
            completion: { _ in finish() }
        )
    }
}

