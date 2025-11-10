import UIKit

final class BottomCapsuleNavView: UIView {

    struct Item {
        let title: String
        let icon: UIImage?
    }

    // callback when item tapped
    var didSelectIndex: ((Int) -> Void)?

    private var buttons: [UIButton] = []
    private let stack = UIStackView()
    private let capsule = UIView()

    private(set) var selectedIndex: Int = 0

    init(items: [Item]) {
        super.init(frame: .zero)
        setup(items: items)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setup(items: [Item]) {
        backgroundColor = .clear

        // capsule background
        capsule.translatesAutoresizingMaskIntoConstraints = false
        capsule.backgroundColor = UIColor(white: 1, alpha: 0.06) // subtle translucent
        capsule.layer.cornerRadius = 35
        capsule.layer.masksToBounds = false
        capsule.layer.shadowColor = UIColor.black.cgColor
        capsule.layer.shadowOpacity = 0.25
        capsule.layer.shadowRadius = 10
        capsule.layer.shadowOffset = CGSize(width: 0, height: 6)

        addSubview(capsule)

        // stack for items
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        capsule.addSubview(stack)

        // create buttons
        // create buttons
        buttons = items.enumerated().map { (idx, item) in
            let btn = UIButton(type: .system)
            btn.translatesAutoresizingMaskIntoConstraints = false

            // Symbol config (adjust size slightly)
            let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
            if let icon = item.icon {
                btn.setImage(icon.withConfiguration(configuration), for: .normal)
            }

            btn.setTitle(item.title, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            btn.tintColor = UIColor(white: 1, alpha: 0.6)
            btn.setTitleColor(UIColor(white: 1, alpha: 0.6), for: .normal)
            btn.contentHorizontalAlignment = .center
            btn.contentVerticalAlignment = .center
            

            // Adjust image & title spacing
            btn.imageEdgeInsets = UIEdgeInsets(top: -6, left: 0, bottom: 6, right: 0)
            btn.titleEdgeInsets = UIEdgeInsets(top: 30, left: -30, bottom: 0, right: 0)

            btn.tag = idx
            btn.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)

            return btn
        }

        

        // add buttons to stack
        buttons.forEach { stack.addArrangedSubview($0) }

        // layout
        NSLayoutConstraint.activate([
            capsule.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            capsule.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            capsule.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            capsule.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),

            stack.leadingAnchor.constraint(equalTo: capsule.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: capsule.trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: capsule.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: capsule.bottomAnchor, constant: -8)
        ])

        // initial selection
        setSelected(index: 0, animated: false)
    }

    @objc private func itemTapped(_ sender: UIButton) {
        setSelected(index: sender.tag, animated: true)
        didSelectIndex?(sender.tag)
    }

    func setSelected(index: Int, animated: Bool) {
        guard index >= 0, index < buttons.count else { return }
        selectedIndex = index

        for (i, btn) in buttons.enumerated() {
            let isSelected = (i == index)
            let tint: UIColor = isSelected ? UIColor.white : UIColor(white: 1, alpha: 0.6)
            btn.tintColor = tint
            btn.setTitleColor(tint, for: .normal)

            // small selected background for the icon
            if isSelected {
                // add a round background view behind icon
                addSelectedBackground(to: btn)
            } else {
                removeSelectedBackground(from: btn)
            }
        }
    }

    private func addSelectedBackground(to button: UIButton) {
        // check if already has
        if button.viewWithTag(999) != nil { return }

        let bg = UIView()
        bg.tag = 999
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.backgroundColor = UIColor.systemBlue
        bg.layer.cornerRadius = 18
        bg.isUserInteractionEnabled = false
        bg.alpha = 0
        button.insertSubview(bg, at: 0)

        NSLayoutConstraint.activate([
            bg.centerXAnchor.constraint(equalTo: button.imageView!.centerXAnchor),
            bg.centerYAnchor.constraint(equalTo: button.imageView!.centerYAnchor),
            bg.widthAnchor.constraint(equalToConstant: 36),
            bg.heightAnchor.constraint(equalToConstant: 36)
        ])

        UIView.animate(withDuration: 0.22) {
            bg.alpha = 1
            button.tintColor = .white
            button.setTitleColor(.white, for: .normal)
        }
    }

    private func removeSelectedBackground(from button: UIButton) {
        if let bg = button.viewWithTag(999) {
            UIView.animate(withDuration: 0.18, animations: {
                bg.alpha = 0
            }, completion: { _ in
                bg.removeFromSuperview()
            })
        }
    }
}
