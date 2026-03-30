//
//  KidsApprovalsViewController.swift
//  Cloudyyy_App
//
//  Created by user on 06/01/26.
//

import UIKit

final class KidsApprovalsViewController: UIViewController {

    // MARK: - UI Elements
    private let backgroundGradientLayer = CAGradientLayer()
    private lazy var backButton: UIButton = {
        ChildBackButtonFactory.make(target: self, action: #selector(backTapped))
    }()
    
    private let headerTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Activity Status"
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Pending", "Approved", "Declined"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.backgroundColor = UIColor(white: 1, alpha: 0.1)
        sc.selectedSegmentTintColor = .white
        sc.setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.black, .font: UIFont.boldSystemFont(ofSize: 13)], for: .selected)
        return sc
    }()
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let refreshControl = UIRefreshControl()
    
    // --- Data ---
    private var allActivityItems: [ChildActivityItem] = [] // Raw Data from Service
    private var displayItems: [ChildActivityItem] = []     // Filtered Data

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupNavigationBar()
        setupLayout()
        
        // Actions
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Setup
    private func setupGradient() {
        backgroundGradientLayer.colors = [
            UIColor(red: 10/255, green: 12/255, blue: 20/255, alpha: 1).cgColor,
            UIColor(red: 25/255, green: 40/255, blue: 70/255, alpha: 1).cgColor
        ]
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    private func setupLayout() {
        view.addSubview(backButton)
        view.addSubview(headerTitle)
        view.addSubview(segmentControl)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12 // Tighter spacing
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),

            headerTitle.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            headerTitle.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            
            segmentControl.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 20),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentControl.heightAnchor.constraint(equalToConstant: 36),
            
            scrollView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Data Logic
    
    @objc private func loadData() {
        Task {
            // 1. Get the Child ID safely from UserDefaults
            guard let childIdString = UserDefaults.standard.string(forKey: "selectedChildId"),
                  let childId = UUID(uuidString: childIdString) else {
                print("❌ DEBUG: No Child ID found in UserDefaults")
                await MainActor.run {
                    self.showErrorState(message: "No Child Selected")
                    self.refreshControl.endRefreshing()
                }
                return
            }
            
            print("✅ DEBUG: Fetching activity for Child ID: \(childId)")
            
            do {
                // 2. Fetch Real Data from Supabase using the ID
                let activities = try await ChildActivityService.shared.fetchAllActivity(for: childId)
                
                await MainActor.run {
                    self.allActivityItems = activities
                    self.updateFilter()
                    self.refreshControl.endRefreshing()
                }
            } catch {
                print("Error loading child activity: \(error)")
                await MainActor.run {
                    self.showErrorState(message: "Failed to load activity")
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    private func showErrorState(message: String) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let emptyLabel = UILabel()
        emptyLabel.text = message
        emptyLabel.textColor = .systemRed
        emptyLabel.textAlignment = .center
        stackView.addArrangedSubview(emptyLabel)
    }
    
    @objc private func segmentChanged() {
        updateFilter()
    }
    
    private func updateFilter() {
        let filterStatus: String
        switch segmentControl.selectedSegmentIndex {
        case 0: filterStatus = "pending"
        case 1: filterStatus = "approved"
        case 2: filterStatus = "declined" // Handles 'declined' and 'rejected'
        default: filterStatus = "pending"
        }
        
        // Filter raw data
        displayItems = allActivityItems.filter { item in
            if filterStatus == "declined" {
                return item.status == "declined" || item.status == "rejected"
            }
            return item.status == filterStatus
        }
        
        renderList()
    }
    
    private func renderList() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if displayItems.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No items found"
            emptyLabel.textColor = .lightGray
            emptyLabel.textAlignment = .center
            emptyLabel.font = .systemFont(ofSize: 16, weight: .medium)
            stackView.addArrangedSubview(emptyLabel)
            return
        }
        
        for item in displayItems {
            // Map ChildActivityItem to UI Card
            let card = ApprovalCard(
                title: item.title,
                points: item.points,
                status: item.status, // "approved", "pending"
                type: item.type // .task or .reward
            )
            card.heightAnchor.constraint(equalToConstant: 76).isActive = true
            stackView.addArrangedSubview(card)
        }
    }
}

// MARK: - Subcomponent: Approval Card
class ApprovalCard: UIView {
    
    init(title: String, points: Int, status: String, type: ChildActivityItem.ItemType) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        // Glassy Background
        backgroundColor = UIColor(white: 1, alpha: 0.08)
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 1, alpha: 0.1).cgColor
        clipsToBounds = true
        
        // Color Logic
        let statusColor: UIColor
        let statusIconName: String
        
        switch status.lowercased() {
        case "approved":
            statusColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1) // Green
            statusIconName = "checkmark.circle.fill"
        case "declined", "rejected":
            statusColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1) // Red
            statusIconName = "xmark.circle.fill"
        default: // Pending
            statusColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1) // Yellow
            statusIconName = "hourglass"
        }
        
        // --- UI Components ---
        
        // Left Color Stripe
        let stripe = UIView()
        stripe.backgroundColor = statusColor
        stripe.translatesAutoresizingMaskIntoConstraints = false
        stripe.layer.cornerRadius = 2
        
        // Icon Container
        let iconContainer = UIView()
        iconContainer.backgroundColor = statusColor.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 12
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: statusIconName))
        iconView.tintColor = statusColor
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(iconView)
        
        // Title
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLbl.textColor = .white
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        
        // Subtitle (Type)
        let subtitleLbl = UILabel()
        subtitleLbl.text = type == .task ? "TASK" : "REWARD"
        subtitleLbl.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLbl.textColor = UIColor.white.withAlphaComponent(0.6)
        subtitleLbl.translatesAutoresizingMaskIntoConstraints = false
        
        // Points
        let pointsLabel = UILabel()
        pointsLabel.text = "\(points)"
        pointsLabel.font = .systemFont(ofSize: 18, weight: .bold)
        pointsLabel.textColor = .systemYellow
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
        starIcon.tintColor = .systemYellow
        starIcon.translatesAutoresizingMaskIntoConstraints = false
        
        // --- Adding Views ---
        addSubview(stripe)
        addSubview(iconContainer)
        addSubview(titleLbl)
        addSubview(subtitleLbl)
        addSubview(pointsLabel)
        addSubview(starIcon)
        
        // --- Constraints ---
        NSLayoutConstraint.activate([
            // Stripe
            stripe.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stripe.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            stripe.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            stripe.widthAnchor.constraint(equalToConstant: 6),
            
            // Icon
            iconContainer.leadingAnchor.constraint(equalTo: stripe.trailingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            // Text
            titleLbl.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLbl.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLbl.trailingAnchor.constraint(lessThanOrEqualTo: pointsLabel.leadingAnchor, constant: -10),
            
            subtitleLbl.leadingAnchor.constraint(equalTo: titleLbl.leadingAnchor),
            subtitleLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 4),
            
            // Points (Right side)
            starIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            starIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            starIcon.widthAnchor.constraint(equalToConstant: 18),
            starIcon.heightAnchor.constraint(equalToConstant: 18),
            
            pointsLabel.trailingAnchor.constraint(equalTo: starIcon.leadingAnchor, constant: -4),
            pointsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
