import UIKit

final class AvatarSelectViewController: UIViewController {

    // MARK: - UI Elements
    
    private var collectionView: UICollectionView!
    
    // MARK: - Data
    
    private let avatarNames: [String] = [
        "parent", // Assuming you have an image asset named "parent"
        "child",  // Assuming you have an image asset named "child"
        "avatar-f-1", // Placeholder
        "avatar-m-1", // Placeholder
        "avatar-f-2", // Placeholder
        "avatar-m-2", // Placeholder
        "avatar-f-3", // Placeholder
        "avatar-m-3"  // Placeholder
    ]

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundGradient() // Setup the gradient first
        configureNavBar()
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
            // Invalidate layout for all visible cells to re-layout glass effect
            self?.collectionView.visibleCells.forEach { cell in
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            }
        }, completion: nil)
    }

    // MARK: - Setup
    
    private func setupBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        
        // Colors from your Image 1: #0C0C0C (start) to #203B6F (end)
        gradientLayer.colors = [
            UIColor(red: 0.047, green: 0.047, blue: 0.047, alpha: 1.0).cgColor, // #0C0C0C
            UIColor(red: 0.125, green: 0.231, blue: 0.435, alpha: 1.0).cgColor  // #203B6F
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Top
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // Bottom
        gradientLayer.frame = view.bounds
        
        view.layer.insertSublayer(gradientLayer, at: 0) // Add to the very back
    }

    private func configureNavBar() {
            title = "Avatars"
            
            // Configure appearance for transparent background and white text
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.shadowColor = .clear // Remove the shadow line
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.tintColor = .white // Set tint for all items
            
            // --- ⭐️ HERE IS THE FIX ⭐️ ---
            
            // 1. Define a local UIButton, not a class property
            let backButton: UIButton = {
                let b = UIButton(type: .system)
                b.translatesAutoresizingMaskIntoConstraints = false
                if #available(iOS 13.0, *) {
                    // Use a modern SF Symbol icon
                    let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
                    b.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
                } else {
                    // Fallback for older iOS versions
                    b.setTitle("< Back", for: .normal)
                    b.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                }
                b.tintColor = .white
                // Set explicit size for a good tap target
                b.heightAnchor.constraint(equalToConstant: 44).isActive = true
                b.widthAnchor.constraint(equalToConstant: 44).isActive = true
                return b
            }()
            
            // 1b. (You forgot this!) Add the action to the button
            backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

            // 1c. Wrap the UIButton in a UIBarButtonItem
            let backBarButtonItem = UIBarButtonItem(customView: backButton)

            // 2. Create a negative spacer to pull it to the left
            let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            negativeSpacer.width = -8 // Adjust this value (-8, -12, etc.) to get perfect alignment

            // 3. Set both items. The spacer comes first.
            //    (Use the new 'backBarButtonItem', not 'backButton')
            navigationItem.leftBarButtonItems = [negativeSpacer, backBarButtonItem]
        }

    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear // Crucial: let the gradient show through
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(AvatarCell.self, forCellWithReuseIdentifier: AvatarCell.reuseID)
        
        view.addSubview(collectionView)
    }

    private func setupConstraints() {
        // Pin collection view to the safe area
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Actions
    
    @objc private func backTapped() {
        // Dismiss the view controller if it was presented modally
        dismiss(animated: true, completion: nil)
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
        
        let padding: CGFloat = 20 // Padding from screen edges
        let spacing: CGFloat = 16 // Spacing between items
        
        let safeAreaWidth = collectionView.safeAreaLayoutGuide.layoutFrame.width
        
        // We want 2 columns, so calculate the item width
        let availableWidth = safeAreaWidth - (padding * 2) - spacing
        let itemWidth = availableWidth / 2
        
        // Return a square size for the cells
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    // Set the padding for the entire section
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    // Spacing between rows
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    // Spacing between items in the same row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
