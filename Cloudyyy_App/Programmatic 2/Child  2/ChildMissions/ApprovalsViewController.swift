// ApprovalsViewController.swift
// Cloudyyy_App

import UIKit

final class ApprovalsViewController: UIViewController {

    // MARK: - UI Elements
    private let backgroundGradientLayer = CAGradientLayer()
    
    // Header
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        btn.tintColor = .systemBlue
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let headerTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Approvals"
        lbl.font = .systemFont(ofSize: 24, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    // Segmented Control
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
    
    // Data
    private var allItems: [ApprovalRequestItem] = [] // Stores source of truth
    private var items: [ApprovalRequestItem] = []    // Stores visible items

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupLayout()
        
        // Setup Actions
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }

    // MARK: - Setup
    private func setupGradient() {
        backgroundGradientLayer.colors = [
            UIColor(red: 10/255, green: 12/255, blue: 20/255, alpha: 1).cgColor,
            UIColor(red: 25/255, green: 40/255, blue: 70/255, alpha: 1).cgColor
        ]
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }
    
    private func setupLayout() {
        view.addSubview(backButton)
        view.addSubview(headerTitle)
        view.addSubview(segmentControl)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            // Header
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            
            headerTitle.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            headerTitle.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            
            // Segment
            segmentControl.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 20),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentControl.heightAnchor.constraint(equalToConstant: 36),
            
            // List
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
    private func loadData() {
        // Fetch source data
        allItems = KidCoordinator.shared.approvals(for: "kid_bob")
        // Initial filter (Pending)
        updateFilter()
    }
    
    @objc private func segmentChanged() {
        updateFilter()
    }
    
    private func updateFilter() {
        let selectedIndex = segmentControl.selectedSegmentIndex
        let filterType: String
        
        switch selectedIndex {
        case 0: filterType = "Pending"
        case 1: filterType = "Approved"
        case 2: filterType = "Declined"
        default: filterType = "Pending"
        }
        
        // Filter case-insensitively
        items = allItems.filter { $0.type.localizedCaseInsensitiveContains(filterType) }
        renderList()
    }
    
    private func renderList() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if items.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No items found"
            emptyLabel.textColor = .lightGray
            emptyLabel.textAlignment = .center
            stackView.addArrangedSubview(emptyLabel)
            return
        }
        
        for item in items {
            let card = ApprovalCard(item: item)
            card.heightAnchor.constraint(equalToConstant: 70).isActive = true
            stackView.addArrangedSubview(card)
        }
    }
    
    @objc private func handleBack() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Subcomponent: Approval Card
// MARK: - Subcomponent: Approval Card
class ApprovalCard: UIView {
    init(item: ApprovalRequestItem) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(white: 1, alpha: 0.15) // Glassy look
        layer.cornerRadius = 10
        clipsToBounds = true
        
        let normalizedType = item.type.lowercased()
        
        // 1. Determine STRIPE Color (Status indicator)
        let stripeColor: UIColor
        switch normalizedType {
        case "approved":
            stripeColor = .systemGreen
        case "declined":
            stripeColor = .systemRed
        default:
            stripeColor = .systemYellow
        }
        
        // 2. Determine STAR Color
        // User Request: Declined stars should be "regular" (Yellow), not Red.
        let starTint: UIColor
        if normalizedType == "declined" {
            starTint = .systemYellow
        } else {
            // For Approved (Green) and Pending (Yellow), match the stripe
            starTint = stripeColor
        }
        
        // Stripe (Tag)
        let stripe = UIView()
        stripe.backgroundColor = stripeColor
        stripe.translatesAutoresizingMaskIntoConstraints = false
        stripe.layer.cornerRadius = 2
        
        // Title
        let titleLbl = UILabel()
        titleLbl.text = item.title
        titleLbl.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLbl.textColor = .white
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        
        // Star Icon
        let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
        starIcon.tintColor = starTint // Applies the fixed logic
        starIcon.translatesAutoresizingMaskIntoConstraints = false
        
        // Star Label
        let starLabel = UILabel()
        starLabel.text = "\(item.stars)"
        starLabel.font = .systemFont(ofSize: 16, weight: .bold)
        starLabel.textColor = .white
        starLabel.textAlignment = .right
        starLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stripe)
        addSubview(titleLbl)
        addSubview(starIcon)
        addSubview(starLabel)
        
        NSLayoutConstraint.activate([
            stripe.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stripe.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stripe.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            stripe.widthAnchor.constraint(equalToConstant: 5),
            
            titleLbl.leadingAnchor.constraint(equalTo: stripe.trailingAnchor, constant: 12),
            titleLbl.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLbl.trailingAnchor.constraint(lessThanOrEqualTo: starLabel.leadingAnchor, constant: -10),
            
            starIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            starIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            starIcon.widthAnchor.constraint(equalToConstant: 16),
            starIcon.heightAnchor.constraint(equalToConstant: 16),
            
            starLabel.trailingAnchor.constraint(equalTo: starIcon.leadingAnchor, constant: -4),
            starLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}
