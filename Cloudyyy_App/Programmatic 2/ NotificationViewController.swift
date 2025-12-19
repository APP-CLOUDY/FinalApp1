//
//  NotificationViewController.swift
//  Cloudyyy_App
//
//  Created by you on YYYY/MM/DD.
//

import UIKit

struct AppNotification {
    let category: String
    let message: String
    let timeAgo: String      // e.g. "34 minutes ago"
    var isUnread: Bool
    let symbolName: String
}

final class NotificationViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)

    private var gradientLayer: CAGradientLayer?

    private var notifications: [AppNotification] = [
        AppNotification(category: "Mission Assigned", message: "Complete Homework", timeAgo: "34 minutes ago", isUnread: true, symbolName: "book.circle"),
        AppNotification(category: "Mission Assigned", message: "Clean the room", timeAgo: "15 minutes ago", isUnread: true, symbolName: "bell"),
        AppNotification(category: "Mission Assigned", message: "Go Jogging", timeAgo: "52 minutes ago", isUnread: false, symbolName: "figure.walk"),
        AppNotification(category: "Rewards", message: "30 Points Added", timeAgo: "35 minutes ago", isUnread: false, symbolName: "gift"),
        AppNotification(category: "Rewards", message: "100 Points Spent", timeAgo: "24 minutes ago", isUnread: false, symbolName: "star")
    ]

    private lazy var originalNotifications = notifications

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        applyGradient()
        setupViews()
        configureNavigationBar()
        configureTableView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }

    // MARK: - Setup

    private func setupViews() {
        view.backgroundColor = .systemBackground

        // header (white)
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = "Notifications"
        headerLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        headerLabel.textColor = .white
        headerLabel.textAlignment = .center

        view.addSubview(headerLabel)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerLabel.heightAnchor.constraint(equalToConstant: 36),

            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureNavigationBar() {

        // Back button
        let back = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(didTapBack))
        back.tintColor = .white
        navigationItem.leftBarButtonItem = back

        // ---- IMPROVED SORT BUTTON ----

        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 16
        blurView.clipsToBounds = true

        let sortButton = UIButton(type: .system)
        sortButton.setTitle("Sort ▾", for: .normal)
        sortButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        sortButton.setTitleColor(.white, for: .normal)
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        sortButton.addTarget(self, action: #selector(didTapSort(_:)), for: .touchUpInside)

        blurView.contentView.addSubview(sortButton)

        NSLayoutConstraint.activate([
            sortButton.leadingAnchor.constraint(equalTo: blurView.leadingAnchor, constant: 12),
            sortButton.trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -12),
            sortButton.topAnchor.constraint(equalTo: blurView.topAnchor, constant: 6),
            sortButton.bottomAnchor.constraint(equalTo: blurView.bottomAnchor, constant: -6)
        ])

        let barItem = UIBarButtonItem(customView: blurView)
        navigationItem.rightBarButtonItem = barItem
    }
    
    @objc private func didTapBack() {
        // pop if in a navigation stack, otherwise dismiss
        if let nav = navigationController {
            if nav.viewControllers.first != self {
                nav.popViewController(animated: true)
                return
            }
        }
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Gradient Background

    private func applyGradient() {
        // Remove old gradients if any
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 12/255, green: 12/255, blue: 12/255, alpha: 1).cgColor,  // #0C0C0C
            UIColor(red: 32/255, green: 59/255, blue: 111/255, alpha: 1).cgColor   // #203B6F
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }

    // MARK: - Table

    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 92
        tableView.rowHeight = UITableView.automaticDimension

        // add extra padding at bottom
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
    }

    // MARK: - Sort Action

    @objc private func didTapSort(_ sender: UIButton) {
        let sheet = UIAlertController(title: "Sort notifications", message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "Newest first", style: .default, handler: { [weak self] _ in
            self?.sortNewestFirst()
        }))
        sheet.addAction(UIAlertAction(title: "Oldest first", style: .default, handler: { [weak self] _ in
            self?.sortOldestFirst()
        }))
        sheet.addAction(UIAlertAction(title: "Unread first", style: .default, handler: { [weak self] _ in
            self?.sortUnreadFirst()
        }))
        sheet.addAction(UIAlertAction(title: "Reset", style: .default, handler: { [weak self] _ in
            self?.resetOrder()
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if let pop = sheet.popoverPresentationController {
            pop.sourceView = sender
            pop.sourceRect = sender.bounds
        }

        present(sheet, animated: true)
    }

    private func sortNewestFirst() {
        notifications.sort { minutes(from: $0.timeAgo) < minutes(from: $1.timeAgo) }
        reloadTableAnimated()
    }

    private func sortOldestFirst() {
        notifications.sort { minutes(from: $0.timeAgo) > minutes(from: $1.timeAgo) }
        reloadTableAnimated()
    }

    private func sortUnreadFirst() {
        notifications.sort {
            if $0.isUnread == $1.isUnread {
                return minutes(from: $0.timeAgo) < minutes(from: $1.timeAgo)
            }
            return $0.isUnread && !$1.isUnread
        }
        reloadTableAnimated()
    }

    private func resetOrder() {
        notifications = originalNotifications
        reloadTableAnimated()
    }

    private func reloadTableAnimated() {
        UIView.transition(with: tableView, duration: 0.28, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: {
            self.tableView.reloadData()
        }, completion: nil)
    }

    // helper to parse "xx minutes ago" into integer minutes
    private func minutes(from timeAgo: String) -> Int {
        // naive parse: take first integer found; fallback large value on failure
        let parts = timeAgo.split(separator: " ")
        if let first = parts.first, let v = Int(first) { return v }
        return 99999
    }
}

// MARK: - UITableViewDataSource

extension NotificationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.reuseIdentifier, for: indexPath) as? NotificationCell else {
            return UITableViewCell()
        }

        let n = notifications[indexPath.row]
        cell.configure(with: n)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotificationViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // mark as read when tapped
        if notifications[indexPath.row].isUnread {
            notifications[indexPath.row].isUnread = false
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // add spacing at the bottom of the table (optional)
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 12 }
}
