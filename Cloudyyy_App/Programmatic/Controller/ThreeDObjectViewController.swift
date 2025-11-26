//
//  ThreeDObjectViewController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 13/11/25.
//

import UIKit

final class ThreeDObjectViewController: UIViewController {

    var onSelect: ((String) -> Void)?

    private let gradient = CAGradientLayer()
    private let collectionView: UICollectionView

    private let items: [(name: String, imageName: String)] = [
        ("Bicycle", "bicycle"),
        ("Toy Car", "car"),
        ("Robot", "gearshape"),
        ("Doll House", "house"),
        ("Lego Set", "cube.box.fill"),
        ("Football", "soccerball")
    ]

    init() {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 12
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing

        let side = (UIScreen.main.bounds.width - 32 - (spacing * 2)) / 3
        layout.itemSize = CGSize(width: side, height: side * 1.18)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 24, right: 0)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "3D Object"
        setupNavBar()
        setupGradient()

        collectionView.register(ThreeDCell.self, forCellWithReuseIdentifier: ThreeDCell.reuseId)
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    private func setupNavBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
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
}

// MARK: - CollectionView
extension ThreeDObjectViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: ThreeDCell.reuseId, for: indexPath) as! ThreeDCell
        c.configure(title: items[indexPath.item].name, symbolName: items[indexPath.item].imageName)
        return c
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect?(items[indexPath.item].name)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Cell
private final class ThreeDCell: UICollectionViewCell {

    static let reuseId = "ThreeDCell"

    private let card = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 12
        card.backgroundColor = UIColor.white.withAlphaComponent(0.08)

        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(imageView)
        card.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalTo: card.widthAnchor, multiplier: 0.6),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -4),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, symbolName: String) {
        titleLabel.text = title
        imageView.image = UIImage(systemName: symbolName) ?? UIImage(systemName: "cube.box.fill")
    }
}
