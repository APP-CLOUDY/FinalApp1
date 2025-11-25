import UIKit

final class AvatarSelectViewController: UIViewController {

    // MARK: - UI Elements
    
    private var collectionView: UICollectionView!
    
    // Custom Header Elements (replaces native Navigation Bar)
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    
    // MARK: - Data
    
    private let avatarNames: [String] = [
        "parent",
        "child",
        "avatar-f-1",
        "avatar-m-1",
        "avatar-f-2",
        "avatar-m-2",
        "avatar-f-3",
        "avatar-m-3"
    ]

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundGradient()
        setupHeader()            // Changed from configureNavBar
        configureCollectionView()
        setupConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure gradient frame updates with view bounds on rotation/layout changes
        if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            gradientLayer.frame = view.bounds
        }
    }
    
    // This ensures the layout updates correctly *during* rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    // MARK: - Setup
    
    private func setupBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        
        // Colors: #0C0C0C (start) to #203B6F (end)
        gradientLayer.colors = [
            UIColor(red: 0.047, green: 0.047, blue: 0.047, alpha: 1.0).cgColor,
            UIColor(red: 0.125, green: 0.231, blue: 0.435, alpha: 1.0).cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Top
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // Bottom
        gradientLayer.frame = view.bounds
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupHeader() {
        // 1. Configure Header Container
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .clear
        view.addSubview(headerView)
        
        // 2. Configure Back Button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        // Increase touch area
        backButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        headerView.addSubview(backButton)
        
        // 3. Configure Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Avatars"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
    }

    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Assuming AvatarCell is defined elsewhere
        collectionView.register(AvatarCell.self, forCellWithReuseIdentifier: AvatarCell.reuseID)
        
        view.addSubview(collectionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // --- Header Constraints ---
            // Pin header to the Safe Area Top
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 44), // Standard Nav Bar height
            
            // Back Button (Leading)
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8), // constant 8 + inset 10 = visually 18
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Title (Centered)
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // --- Collection View Constraints ---
            // Pin top to bottom of Header
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions
    
    @objc private func backTapped() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension AvatarSelectViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatarNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AvatarCell.reuseID,
            for: indexPath
        ) as! AvatarCell
        
        let imageName = avatarNames[indexPath.item]
        cell.set(imageName: imageName)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AvatarSelectViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat = 20
        let spacing: CGFloat = 16
        let safeWidth = collectionView.safeAreaLayoutGuide.layoutFrame.width
        
        // Smart Column Calculation:
        // Use 2 columns for Portrait (regular width)
        // Use 4 columns for Landscape (wide width) to prevent "giant" cells
        let columns: CGFloat = safeWidth > 600 ? 4 : 2
        
        let totalSpacing = (padding * 2) + (spacing * (columns - 1))
        let itemWidth = (safeWidth - totalSpacing) / columns
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
