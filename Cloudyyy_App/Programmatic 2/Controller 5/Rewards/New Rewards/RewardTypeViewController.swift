import UIKit

final class RewardTypeViewController: UIViewController {

    var onSelect: ((String) -> Void)?

    private let gradient = CAGradientLayer()
    private let header = HomeHeaderView(title: "Reward Type")

    private var selectedIndex: Int?

    private let items: [(title: String, key: String, imageName: String)] = [
        ("Gadget Time", "gadget_time", "reward_screen_time"),
        ("TV Time", "tv_time", "reward_cartoon"),

        ("Snacks", "snacks", "reward_treat"),
        ("Icecream", "icecream", "reward_icecream"),
        ("Chocolate", "chocolate", "reward_chocolate"),
        ("Takeaway", "takeaway", "reward_outside_food"),

        ("Toys", "toys", "reward_toys"),
        ("Outdoor Play", "outdoor_play", "reward_outdoor"),

        ("Surprise", "surprise", "reward_surprise")
    ]


    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(RewardGridCell.self,
                    forCellWithReuseIdentifier: RewardGridCell.id)
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupGradient()
        setupHeader()
        setupCollection()
        styleHeaderTitle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func styleHeaderTitle() {
        if let label = findLabel(in: header) {
            label.font = .systemFont(ofSize: 20, weight: .medium)
            label.textColor = UIColor.white.withAlphaComponent(0.85)
        }
    }

    private func findLabel(in view: UIView) -> UILabel? {
        for v in view.subviews {
            if let l = v as? UILabel { return l }
            if let found = findLabel(in: v) { return found }
        }
        return nil
    }

    private func setupHeader() {
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false

        header.showBackButton(true)
        header.showNotificationButton(false)
        header.showProfileButton(false)
        header.showPlusButton(false)

        header.onBackTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    private func setupCollection() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: -16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
}

// MARK: - Collection
extension RewardTypeViewController: UICollectionViewDelegate,
                                   UICollectionViewDataSource,
                                   UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RewardGridCell.id,
            for: indexPath
        ) as! RewardGridCell

        let item = items[indexPath.item]
        
        cell.configure(
            title: item.title,
            imageName: item.imageName,
            isSelected: indexPath.item == selectedIndex
        )


        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        selectedIndex = indexPath.item
        collectionView.reloadData()

        // ✅ SEND BACKEND KEY (NOT TITLE)
        onSelect?(items[indexPath.item].key)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.navigationController?.popViewController(animated: true)
        }
    }


    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.bounds.width - 24) / 2
        return CGSize(width: width, height: width - 10)

    }
}

final class RewardGridCell: UICollectionViewCell {

    static let id = "RewardGridCell"

    private let card = RewardCardView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let tick = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Card tuning (slightly clearer than default)
        card.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        card.layer.cornerRadius = 22
        card.translatesAutoresizingMaskIntoConstraints = false

        // Subtle border to separate from bg
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor

        // Image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.95)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Tick
        tick.tintColor = .systemGreen
        tick.translatesAutoresizingMaskIntoConstraints = false
        tick.isHidden = true

        contentView.addSubview(card)
        card.addSubview(imageView)
        card.addSubview(titleLabel)
        card.addSubview(tick)

        NSLayoutConstraint.activate([
            // Card
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // Bigger image
            imageView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 90),
            imageView.heightAnchor.constraint(equalToConstant: 90),

            // Title
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            // Tick
            tick.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            tick.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            tick.widthAnchor.constraint(equalToConstant: 22),
            tick.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    func configure(title: String,
                   imageName: String,
                   isSelected: Bool) {

        titleLabel.text = title
        imageView.image = UIImage(named: imageName)
        tick.isHidden = !isSelected
    }

    required init?(coder: NSCoder) { fatalError() }
}
