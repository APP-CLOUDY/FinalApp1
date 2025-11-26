import UIKit

// ===========================================================
// MARK: - Base Card
// ===========================================================

class RewardCardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 14
        backgroundColor = UIColor.white.withAlphaComponent(0.06)
        translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) { fatalError() }
}

// ===========================================================
// MARK: - Styled TextField
// ===========================================================

class StyledTextField: RewardCardView {
    private let tf = UITextField()
    var textValue: String { tf.text ?? "" }

    init(placeholder: String) {
        super.init(frame: .zero)
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
        )
        tf.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tf)
        NSLayoutConstraint.activate([
            tf.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tf.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tf.topAnchor.constraint(equalTo: topAnchor),
            tf.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// ===========================================================
// MARK: - Styled TextView
// ===========================================================

class StyledTextView: RewardCardView, UITextViewDelegate {
    private let tv = UITextView()
    private let placeholder: String
    var textValue: String { tv.text ?? "" }

    init(placeholder: String) {
        self.placeholder = placeholder
        super.init(frame: .zero)
        tv.delegate = self
        tv.text = placeholder
        tv.textColor = UIColor.white.withAlphaComponent(0.4)
        tv.font = .systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tv)
        NSLayoutConstraint.activate([
            tv.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            tv.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            tv.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            tv.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
            textView.textColor = .white
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.white.withAlphaComponent(0.4)
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}

// ===========================================================
// MARK: - SelectRow (button-backed, supports UIMenu)
// ===========================================================
class SelectRow: RewardCardView {

    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.down"))
    private let button = UIButton(configuration: .plain())

    var onTap: (() -> Void)?
    var detailText: String? { detailLabel.text }

    init(title: String) {
        super.init(frame: .zero)

        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16)

        detailLabel.text = "Select"
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        detailLabel.font = .systemFont(ofSize: 14)

        chevron.tintColor = UIColor.white.withAlphaComponent(0.5)

        let h = UIStackView(arrangedSubviews: [titleLabel, UIView(), detailLabel, chevron])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 8
        h.translatesAutoresizingMaskIntoConstraints = false
        addSubview(h)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSubview(button)

        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            h.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            h.topAnchor.constraint(equalTo: topAnchor),
            h.bottomAnchor.constraint(equalTo: bottomAnchor),

            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        button.showsMenuAsPrimaryAction = true
    }

    func setMenu(_ menu: UIMenu) {
        button.menu = menu
    }

    func setDetail(_ text: String) {
        detailLabel.text = text
        detailLabel.textColor = .white
    }

    @objc private func buttonTapped() {
        onTap?()
    }

    required init?(coder: NSCoder) { fatalError() }
}

// ===========================================================
// MARK: - PointsRow
// ===========================================================

class PointsRow: RewardCardView {

    private let title = UILabel()
    private let minus = UIButton(type: .system)
    private let plus = UIButton(type: .system)
    private let valueLabel = UILabel()

    var countValue: Int = 0 {
        didSet { valueLabel.text = "\(countValue)" }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        title.text = "Points"
        title.textColor = .white
        title.font = .systemFont(ofSize: 16)

        valueLabel.text = "0"
        valueLabel.textColor = .white
        valueLabel.font = .boldSystemFont(ofSize: 18)

        minus.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        plus.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        minus.tintColor = .white
        plus.tintColor = .white

        minus.addTarget(self, action: #selector(dec), for: .touchUpInside)
        plus.addTarget(self, action: #selector(inc), for: .touchUpInside)

        let h = UIStackView(arrangedSubviews: [title, UIView(), minus, valueLabel, plus])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 10
        h.translatesAutoresizingMaskIntoConstraints = false

        addSubview(h)
        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            h.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            h.topAnchor.constraint(equalTo: topAnchor),
            h.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func inc() { countValue += 1 }
    @objc private func dec() { countValue = max(0, countValue - 1) }

    required init?(coder: NSCoder) { fatalError() }
}

// ===========================================================
// MARK: - UploadBoxCard
// ===========================================================

class UploadBoxCard: RewardCardView {

    private let icon = UIImageView()
    private let label = UILabel()
    private let imageView = UIImageView()
    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        icon.image = UIImage(systemName: "photo.on.rectangle.angled")
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit

        label.text = "Upload your photo here"
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.0
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let v = UIStackView(arrangedSubviews: [icon, label])
        v.axis = .vertical
        v.alignment = .center
        v.spacing = 12
        v.translatesAutoresizingMaskIntoConstraints = false

        addSubview(v)
        addSubview(imageView)

        // tap gesture for opening image picker
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)

        NSLayoutConstraint.activate([
            v.centerXAnchor.constraint(equalTo: centerXAnchor),
            v.centerYAnchor.constraint(equalTo: centerYAnchor),

            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func setImage(_ img: UIImage?) {
        guard let img = img else {
            imageView.image = nil
            imageView.alpha = 0
            return
        }
        imageView.image = img
        imageView.alpha = 1
    }

    @objc private func tapped() { onTap?() }
    required init?(coder: NSCoder) { fatalError() }
}

// ===========================================================
// MARK: - Select3DCard (shows selected 3D object & opens 3D selector)
// ===========================================================

class Select3DCard: RewardCardView {

    private let icon = UIImageView(image: UIImage(systemName: "cube.box.fill"))
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    var selectedValue: String?
    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit

        titleLabel.text = "3D Object"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16)

        detailLabel.text = "Tap to choose"
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        detailLabel.font = .systemFont(ofSize: 14)

        let h = UIStackView(arrangedSubviews: [icon, titleLabel, UIView(), detailLabel])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 12
        h.translatesAutoresizingMaskIntoConstraints = false

        addSubview(h)

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))

        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            h.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            h.topAnchor.constraint(equalTo: topAnchor),
            h.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func setDetail(_ value: String) {
        selectedValue = value
        detailLabel.text = value
        detailLabel.textColor = .white
    }

    @objc private func tapped() { onTap?() }
    required init?(coder: NSCoder) { fatalError() }
}

// ===========================================================
// MARK: - ApprovalToggleRow
// ===========================================================

class ApprovalToggleRow: RewardCardView {

    private let titleLabel = UILabel()
    private let toggle = UISwitch()

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16)

        toggle.onTintColor = .systemGreen

        let h = UIStackView(arrangedSubviews: [titleLabel, UIView(), toggle])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 8
        h.translatesAutoresizingMaskIntoConstraints = false

        addSubview(h)

        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            h.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            h.topAnchor.constraint(equalTo: topAnchor),
            h.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    var isOn: Bool { toggle.isOn }
    required init?(coder: NSCoder) { fatalError() }
}

