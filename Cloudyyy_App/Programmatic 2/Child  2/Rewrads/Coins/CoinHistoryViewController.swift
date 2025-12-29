//
//  CoinHistoryViewController.swift
//  Cloudyyy_App
//

import UIKit

final class CoinHistoryViewController: UIViewController {

    // MARK: - UI
    private let container = UIView()
    private let tableView = UITableView()

    // ⭐ Summary Card
    private let summaryCard = UIView()
    private let summaryTitle = UILabel()
    private let summaryValue = UILabel()

    // MARK: - Data (TEMP – backend later)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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

        // ⭐ Summary Card
        summaryCard.translatesAutoresizingMaskIntoConstraints = false
        summaryCard.backgroundColor = UIColor(
            red: 30/255,
            green: 35/255,
            blue: 60/255,
            alpha: 1
        )
        summaryCard.layer.cornerRadius = 18
        summaryCard.layer.shadowColor = UIColor.black.cgColor
        summaryCard.layer.shadowOpacity = 0.3
        summaryCard.layer.shadowRadius = 8
        summaryCard.layer.shadowOffset = CGSize(width: 0, height: 6)
        container.addSubview(summaryCard)

        summaryTitle.translatesAutoresizingMaskIntoConstraints = false
        summaryTitle.text = "Stars Earned"
        summaryTitle.font = .systemFont(ofSize: 14, weight: .medium)
        summaryTitle.textColor = UIColor.white.withAlphaComponent(0.7)

        summaryValue.translatesAutoresizingMaskIntoConstraints = false
        summaryValue.text = "\(history.reduce(0) { $0 + $1.points }) ⭐"
        summaryValue.font = .systemFont(ofSize: 28, weight: .bold)
        summaryValue.textColor = UIColor(
            red: 255/255,
            green: 204/255,
            blue: 92/255,
            alpha: 1
        )

        summaryCard.addSubview(summaryTitle)
        summaryCard.addSubview(summaryValue)

        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
        tableView.register(CoinHistoryCell.self, forCellReuseIdentifier: "CoinHistoryCell")
        container.addSubview(tableView)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Summary Card
            summaryCard.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 16),
            summaryCard.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            summaryCard.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            summaryCard.heightAnchor.constraint(equalToConstant: 90),

            summaryTitle.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 16),
            summaryTitle.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),

            summaryValue.topAnchor.constraint(equalTo: summaryTitle.bottomAnchor, constant: 8),
            summaryValue.leadingAnchor.constraint(equalTo: summaryTitle.leadingAnchor),

            // Table
            tableView.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 16),
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

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {

        cell.transform = CGAffineTransform(translationX: 0, y: 20)
        cell.alpha = 0

        UIView.animate(
            withDuration: 0.4,
            delay: Double(indexPath.row) * 0.05,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut],
            animations: {
                cell.transform = .identity
                cell.alpha = 1
            }
        )
    }
}

