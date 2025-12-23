//
//  CoinHistoryViewController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 19/12/25.
//

import Foundation
import UIKit

final class CoinHistoryViewController: UIViewController {

    // MARK: - UI

    private let container = UIView()
    private let titleLabel = UILabel()
    private let tableView = UITableView()

    // Mock data for now (replace with backend later)
    var history: [(title: String, points: Int, date: String)] = [
        ("Brushed Teeth", 5, "Today"),
        ("Homework Completed", 10, "Yesterday"),
        ("Good Behavior", 3, "Yesterday"),
        ("Early Wake Up", 5, "2 days ago")
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTable()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 20/255, green: 24/255, blue: 40/255, alpha: 1)
        container.layer.cornerRadius = 24
        container.clipsToBounds = true
        view.addSubview(container)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "⭐ Star History"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        container.addSubview(titleLabel)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(CoinHistoryCell.self, forCellReuseIdentifier: "CoinHistoryCell")
        container.addSubview(tableView)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            container.heightAnchor.constraint(equalToConstant: 420),

            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}
