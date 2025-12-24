//
//  CoinHistoryViewController.swift
//  Cloudyyy_App
//

import UIKit

final class CoinHistoryViewController: UIViewController {

    // MARK: - UI
    private let container = UIView()
    private let tableView = UITableView()

    // MARK: - Data (TEMP – replace with backend later)
    var history: [(title: String, points: Int, date: String)] = [
        ("Brushed Teeth", 5, "Today"),
        ("Homework Completed", 10, "Yesterday"),
        ("Good Behavior", 3, "Yesterday"),
        ("Early Wake Up", 5, "2 days ago")
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(
            red: 15/255,
            green: 18/255,
            blue: 24/255,
            alpha: 1
        )

        setupNavigationBar()
        setupUI()
        setupTable()
    }

    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        navigationItem.title = "Star History"

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(
            red: 15/255,
            green: 18/255,
            blue: 24/255,
            alpha: 1
        )

        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 22, weight: .bold)
        ]

        // 🔥 REMOVE THAT LINE COMPLETELY
        appearance.shadowColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Container
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(
            red: 20/255,
            green: 24/255,
            blue: 40/255,
            alpha: 1
        )
        view.addSubview(container)

        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CoinHistoryCell.self, forCellReuseIdentifier: "CoinHistoryCell")
        container.addSubview(tableView)

        NSLayoutConstraint.activate([
            // Container fills screen
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),


            // Table
            tableView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    // MARK: - Table Setup
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }


}

// MARK: - UITableViewDataSource & Delegate
extension CoinHistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        history.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CoinHistoryCell",
            for: indexPath
        ) as? CoinHistoryCell else {
            return UITableViewCell()
        }

        let item = history[indexPath.row]
        cell.configure(
            title: item.title,
            points: item.points,
            date: item.date
        )

        return cell
    }
}

