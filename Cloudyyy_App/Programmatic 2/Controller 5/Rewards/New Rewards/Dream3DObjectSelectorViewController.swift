import UIKit

// MARK: - Model
struct Dream3DObject {
    let objectKey: String
    let uuid: UUID
    let displayName: String
    let previewImage: UIImage
}


// MARK: - View Controller
final class Dream3DObjectSelectorViewController: UIViewController {

    // MARK: - Callback
    var onSelect: ((Dream3DObject) -> Void)?

    // MARK: - Data
    private let objects: [Dream3DObject] = [
        Dream3DObject(
            objectKey: "cycle",
            uuid: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            displayName: "Cycle",
            previewImage: UIImage(named: "cycle") ?? UIImage(systemName: "photo")!
        ),
        Dream3DObject(
            objectKey: "chess_board",
            uuid: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            displayName: "Chess Board",
            previewImage: UIImage(named: "chess") ?? UIImage(systemName: "photo")!
        )
    ]

    
    static func loadImageSafely(named name: String) -> UIImage? {

        // 1️⃣ Asset catalog
        if let img = UIImage(named: name) {
            return img
        }

        // 2️⃣ Bundle PNG
        if let path = Bundle.main.path(forResource: name, ofType: "png") {
            return UIImage(contentsOfFile: path)
        }

        // 3️⃣ Bundle JPG
        if let path = Bundle.main.path(forResource: name, ofType: "jpg") {
            return UIImage(contentsOfFile: path)
        }

        print("❌ Image NOT FOUND:", name)
        return nil
    }

    // MARK: - UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Dream Object"
        l.font = .systemFont(ofSize: 22, weight: .semibold)
        l.textColor = .white
        return l
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupHeader()
        setupCollectionView()
    }

    // MARK: - Background
    private func setupBackground() {
        view.backgroundColor = UIColor(red: 12/255, green: 18/255, blue: 32/255, alpha: 1)
    }

    // MARK: - Header
    private func setupHeader() {
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backButton)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12)
        ])
    }

    // MARK: - Collection View
    private func setupCollectionView() {
        view.addSubview(collectionView)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(Dream3DGridCell.self, forCellWithReuseIdentifier: "Dream3DGridCell")

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Data Source
extension Dream3DObjectSelectorViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        objects.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "Dream3DGridCell",
            for: indexPath
        ) as! Dream3DGridCell

        cell.configure(with: objects[indexPath.item])
        return cell
    }
}

// MARK: - Delegate
extension Dream3DObjectSelectorViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = objects[indexPath.item]
        onSelect?(object)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Layout
extension Dream3DObjectSelectorViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 2
        return CGSize(width: width, height: width + 24)
    }
}

final class Dream3DGridCell: UICollectionViewCell {

    private let containerView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 22
        containerView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.85)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.6),


            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8)
        ])
    }

    func configure(with object: Dream3DObject) {
        imageView.image = object.previewImage
        titleLabel.text = object.displayName
    }
}

