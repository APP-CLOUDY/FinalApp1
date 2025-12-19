import UIKit

final class OverviewCardGlassView: UIView {

    // MARK: - Glass
    private let glass = GlassView(style: .card, cornerRadius: 18)

    // MARK: - Content
    private let arcView = HomeProgressArcView()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Today's Overview"
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
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
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor.white.withAlphaComponent(0.6)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let chevron: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = UIColor.white.withAlphaComponent(0.45)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        glass.translatesAutoresizingMaskIntoConstraints = false
        arcView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(glass)

        glass.addSubview(titleLabel)
        glass.addSubview(missionsLabel)
        glass.addSubview(redeemedLabel)
        glass.addSubview(arcView)
        glass.addSubview(chevron)

        NSLayoutConstraint.activate([
            // glass fills card
            glass.topAnchor.constraint(equalTo: topAnchor),
            glass.bottomAnchor.constraint(equalTo: bottomAnchor),
            glass.leadingAnchor.constraint(equalTo: leadingAnchor),
            glass.trailingAnchor.constraint(equalTo: trailingAnchor),

            // text
            titleLabel.topAnchor.constraint(equalTo: glass.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: glass.leadingAnchor, constant: 18),

            missionsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            missionsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            redeemedLabel.topAnchor.constraint(equalTo: missionsLabel.bottomAnchor, constant: 6),
            redeemedLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            // chevron
            chevron.centerYAnchor.constraint(equalTo: glass.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: glass.trailingAnchor, constant: -16),
            chevron.widthAnchor.constraint(equalToConstant: 12),

            // progress arc
            arcView.centerYAnchor.constraint(equalTo: glass.centerYAnchor),
            arcView.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -16),
            arcView.widthAnchor.constraint(equalToConstant: 72),
            arcView.heightAnchor.constraint(equalToConstant: 72)
        ])
    }

    // MARK: - Configure
    func configure(
        missionsDone: Int,
        missionsTotal: Int,
        redeemedText: String,
        progress: CGFloat,
        animated: Bool
    ) {
        missionsLabel.text = "\(missionsDone)/\(missionsTotal) Missions"
        redeemedLabel.text = redeemedText.isEmpty ? "" : "Redeemed \(redeemedText)"
        arcView.setProgress(progress, animated: animated)
    }
}

