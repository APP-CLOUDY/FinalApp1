import UIKit

final class AvatarSelectViewController: UIViewController {

    // MARK: - UI Elements
    private var collectionView: UICollectionView!
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private lazy var backButton: UIButton = {
        ParentBackButtonFactory.make(target: self, action: #selector(backTapped))
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    // MARK: - Data (Dynamic from Backend)
    private var avatarFiles: [String] = [] // Empty initially

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        setupHeader()
        configureCollectionView()
        setupConstraints()
        
        // ✅ Load Data from Backend
        loadAvatars()
    }

    // MARK: - Backend Logic
    private func loadAvatars() {
            activityIndicator.startAnimating()
            print("🔍 Starting to load avatars...") // DEBUG 1
            
            _Concurrency.Task {
                do {
                    let files = try await ProfileService.shared.fetchAvatarList()
                    print("✅ Found \(files.count) files: \(files)") // DEBUG 2
                    
                    await MainActor.run {
                        self.avatarFiles = files
                        self.collectionView.reloadData()
                        self.activityIndicator.stopAnimating()
                    }
                } catch {
                    print("❌ ERROR loading avatars: \(error)") // DEBUG 3
                    await MainActor.run {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    
    private func saveAvatarAndExit(avatarName: String) {
        view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        _Concurrency.Task {
            do {
                // Save the filename (e.g. "robot.png") to the users table
                try await ProfileService.shared.updateAvatar(avatarName: avatarName)
                
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                }
            }
        }
    }

    // MARK: - Setup UI (Standard)
    private func setupBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.047, green: 0.047, blue: 0.047, alpha: 1.0).cgColor,
            UIColor(red: 0.125, green: 0.231, blue: 0.435, alpha: 1.0).cgColor
        ]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        headerView.addSubview(backButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Choose Avatar"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 18)
        headerView.addSubview(titleLabel)
    }

    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AvatarCell.self, forCellWithReuseIdentifier: AvatarCell.reuseID)
        
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 44),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Collection View Logic
extension AvatarSelectViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatarFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCell.reuseID, for: indexPath) as! AvatarCell
            
            let fileName = avatarFiles[indexPath.item]
            let urlString = ProfileService.shared.getAvatarURL(fileName: fileName)
            
            // 🔍 DEBUG: Print the URL to the console!
            print("🖼️ Trying to load image from: \(urlString)")
            
            cell.set(url: urlString)
            return cell
        }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fileName = avatarFiles[indexPath.item]
        saveAvatarAndExit(avatarName: fileName)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 60) / 3 // 3 columns
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
}

