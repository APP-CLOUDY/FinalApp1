//
//  ListsViewController.swift
//  Cloudyyy_App
//

import UIKit

class ListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var lists = ["Habits", "Routines", "Studies", "Exercise", "Extracurricular"]
    
    // 1. Add Gradient Layer Property
    private let gradient = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Lists"
        
        // 2. Setup Gradient (Replaces solid background color)
        setupGradient()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        navigationController?.navigationBar.tintColor = .white // Changed to white to match theme

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
    
    // 3. Important: Update Gradient Frame on Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    // 4. The Gradient Function
    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
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
        
        // Semi-transparent cell background to let gradient show through
        cell.backgroundColor = UIColor(white: 1, alpha: 0.07)
        
        // Selection style
        let selectedBackground = UIView()
        selectedBackground.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedBackground
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedList = lists[indexPath.row]
        NotificationCenter.default.post(name: NSNotification.Name("ListSelected"), object: selectedList)
        dismiss(animated: true)
    }
}
