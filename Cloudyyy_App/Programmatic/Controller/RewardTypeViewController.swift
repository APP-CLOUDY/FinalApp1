//
//  RewardTypeViewController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 13/11/25.
//

import UIKit

final class RewardTypeViewController: UIViewController {

    var onSelect: ((String) -> Void)?

    private let gradient = CAGradientLayer()
    private let table = UITableView(frame: .zero, style: .insetGrouped)

    private let items: [(title: String, symbol: String)] = [
        ("Screen Time", "clock"),
        ("Treat", "gift"),
        ("Cartoon Time", "tv"),
        ("Family Time", "house"),
        ("Outdoor Play", "figure.walk")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Reward Type"
        setupNavBar()
        setupGradient()

        table.backgroundColor = .clear
        table.register(RewardTypeCell.self, forCellReuseIdentifier: RewardTypeCell.id)
        table.delegate = self
        table.dataSource = self

        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)

        NSLayoutConstraint.activate([
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
            UIColor(red: 8/255, green: 12/255, blue: 48/255, alpha: 1).cgColor,
            UIColor(red: 12/255, green: 20/255, blue: 75/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }
}

extension RewardTypeViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let c = tableView.dequeueReusableCell(withIdentifier: RewardTypeCell.id, for: indexPath) as! RewardTypeCell
        c.configure(title: items[indexPath.row].title, symbol: items[indexPath.row].symbol)
        return c
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect?(items[indexPath.row].title)
        navigationController?.popViewController(animated: true)
    }
}

final class RewardTypeCell: UITableViewCell {

    static let id = "RewardTypeCell"

    private let icon = UIImageView()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = UIColor.white.withAlphaComponent(0.04)
        layer.cornerRadius = 12
        layer.masksToBounds = true

        icon.tintColor = .white
        icon.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)

        accessoryType = .disclosureIndicator

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, symbol: String) {
        titleLabel.text = title
        icon.image = UIImage(systemName: symbol) ?? UIImage(systemName: "tag")
    }
}
