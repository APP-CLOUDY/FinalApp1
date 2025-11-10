//
//  ListsViewController.swift
//  Cloudyyy_App
//

import UIKit

class ListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var lists = ["Habits", "Routines", "Studies", "Exercise", "Extracurricular"]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Lists"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        navigationController?.navigationBar.tintColor = .systemBlue
        view.backgroundColor = UIColor(red: 10/255, green: 13/255, blue: 41/255, alpha: 1)

        // Navigation buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(dismissPage)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addList)
        )

        setupTable()
    }

    private func setupTable() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    @objc private func dismissPage() {
        dismiss(animated: true)
    }

    @objc private func addList() {
        let alert = UIAlertController(title: "New List", message: "Enter a name for your list", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "List name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                self?.lists.append(text)
                self?.tableView.reloadData()
            }
        })
        present(alert, animated: true)
    }

    // MARK: TableView Data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        lists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = lists[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.backgroundColor = UIColor(white: 1, alpha: 0.07)
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedList = lists[indexPath.row]
        NotificationCenter.default.post(name: NSNotification.Name("ListSelected"), object: selectedList)
        dismiss(animated: true)
    }
}
