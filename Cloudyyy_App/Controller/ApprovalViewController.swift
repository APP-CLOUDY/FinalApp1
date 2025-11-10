//
//  ApprovalViewController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 09/11/25.
//

import UIKit

class ApprovalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var SegmentControl: UISegmentedControl!
    
    private var backgroundGradientLayer: CAGradientLayer?
    private var tableView: UITableView!
    
    // MARK: - Sample Data
    private let pendingTasks = [
        ["title": "Quick Reward", "subtitle": "Water Your Plant", "date": "Requested on 24/10/2020", "points": "100 ⭐️"],
        ["title": "Task", "subtitle": "Clean Your Room", "date": "Requested on 23/10/2020", "points": "80 ⭐️"]
    ]
    
    private let approvedTasks = [
        ["title": "Task", "subtitle": "Finish Homework", "date": "Approved on 22/10/2020", "points": "100 ⭐️"]
    ]
    
    private let redeemedTasks = [
        ["title": "DREAM IT", "subtitle": "Build A Cycle", "date": "Redeemed on 26/10/2020", "points": "100 ⭐️"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ApprovalViewController")
        setupBackgroundGradient()
        setupSegmentControl()
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer?.frame = view.bounds
    }
    
    // MARK: - Setup Segment Control
    private func setupSegmentControl() {
        SegmentControl.backgroundColor = UIColor(white: 1, alpha: 0.15)
        SegmentControl.selectedSegmentTintColor = .white
        
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.9),
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 16)
        ]
        
        SegmentControl.setTitleTextAttributes(normalAttrs, for: .normal)
        SegmentControl.setTitleTextAttributes(selectedAttrs, for: .selected)
        SegmentControl.layer.cornerRadius = 10
        SegmentControl.layer.masksToBounds = true
        
        // Add action
        SegmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    // MARK: - Setup TableView
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ApprovalCell.self, forCellReuseIdentifier: "ApprovalCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: SegmentControl.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func segmentChanged() {
        UIView.transition(with: tableView, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        })
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SegmentControl.selectedSegmentIndex {
        case 0: return pendingTasks.count
        case 1: return approvedTasks.count
        case 2: return redeemedTasks.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalCell", for: indexPath) as? ApprovalCell else {
            return UITableViewCell()
        }
        
        let data: [String: String]
        let showButtons: Bool
        
        switch SegmentControl.selectedSegmentIndex {
        case 0:
            data = pendingTasks[indexPath.row]
            showButtons = true
        case 1:
            data = approvedTasks[indexPath.row]
            showButtons = false
        case 2:
            data = redeemedTasks[indexPath.row]
            showButtons = false
        default:
            data = [:]
            showButtons = false
        }
        
        cell.configure(
            title: data["title"] ?? "",
            subtitle: data["subtitle"] ?? "",
            date: data["date"] ?? "",
            points: data["points"] ?? "",
            showButtons: showButtons
        )
        return cell
    }
    
    // MARK: - Gradient Setup
    private func setupBackgroundGradient() {
        backgroundGradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 10/255, green: 13/255, blue: 41/255, alpha: 1).cgColor,
            UIColor(red: 24/255, green: 30/255, blue: 74/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = view.bounds
        
        view.layer.insertSublayer(gradient, at: 0)
        backgroundGradientLayer = gradient
    }
}
