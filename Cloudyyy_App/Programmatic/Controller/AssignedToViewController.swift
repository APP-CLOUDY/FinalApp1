//
//  AssignedToViewController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 13/11/25.
//

import UIKit

final class AssignedToViewController: UIViewController {

    // Callback to send selected children back
    var onSelection: (([String]) -> Void)?

    private let gradient = CAGradientLayer()
    private let table = UITableView(frame: .zero, style: .insetGrouped)

    // Replace with your real children list from database
    private var childNames = [
        "Aarav",
        "Meera",
        "Jonah",
        "Sara"
    ]

    private var selectedChildNames: Set<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Assigned To"
        setupNavBar()
        setupGradient()

        table.register(AssignedChildCell.self, forCellReuseIdentifier: AssignedChildCell.id)
        table.delegate = self
        table.dataSource = self
        table.allowsMultipleSelection = true
        table.backgroundColor = .clear
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )

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

    @objc private func saveTapped() {
        onSelection?(Array(selectedChildNames))
        navigationController?.popViewController(animated: true)
    }
}

extension AssignedToViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = table.dequeueReusableCell(withIdentifier: AssignedChildCell.id, for: indexPath) as! AssignedChildCell
        let name = childNames[indexPath.row]

        let isSelected = selectedChildNames.contains(name)
        cell.configure(name: name, selected: isSelected)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = childNames[indexPath.row]
        selectedChildNames.insert(name)

        let cell = tableView.cellForRow(at: indexPath) as? AssignedChildCell
        cell?.setSelectedState(true)

        // Haptic feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let name = childNames[indexPath.row]
        selectedChildNames.remove(name)

        let cell = tableView.cellForRow(at: indexPath) as? AssignedChildCell
        cell?.setSelectedState(false)
    }
}


// MARK: - Cell
final class AssignedChildCell: UITableViewCell {

    static let id = "AssignedChildCell"

    private let avatar = UIImageView()
    private let nameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = UIColor.white.withAlphaComponent(0.05)
        layer.cornerRadius = 12
        layer.masksToBounds = true

        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.image = UIImage(systemName: "person.circle.fill")
        avatar.tintColor = .white
        avatar.contentMode = .scaleAspectFit

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 16)

        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)

        accessoryType = .none

        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 36),
            avatar.heightAnchor.constraint(equalToConstant: 36),

            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(name: String, selected: Bool) {
        nameLabel.text = name
        accessoryType = selected ? .checkmark : .none
    }

    func setSelectedState(_ selected: Bool) {
        UIView.animate(withDuration: 0.15) {
            self.accessoryType = selected ? .checkmark : .none
        }
    }
}
