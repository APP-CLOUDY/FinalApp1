
//
//  ChildAvatarSelectViewController.swift
//  Cloudyyy_App
//
//  Created by user@5 on 23/01/26.
//

//
//  ChildAvatarSelectViewController.swift
//  Cloudyyy_App
//
//  Created by user@5 on 18/01/26.
//

import UIKit

final class ChildAvatarSelectViewController: UIViewController {

    // MARK: - UI Elements
    private var collectionView: UICollectionView!
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    
    private let activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    // MARK: - Data
    private var avatarFiles: [String] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        setupHeader()
        configureCollectionView()
        setupConstraints()
        
        loadAvatars()
    }

    // MARK: - Backend Logic

    private func loadAvatars() {
            activityIndicator.startAnimating()
            print("🔍 Child Avatar Select: Loading avatars...")
            
            Task {
                do {
                    let files = try await ProfileService.shared.fetchChildAvatarList()
                    
                    // 🚨 ADD THIS DEBUG PRINT
                    print("📦 DEBUG: Found \(files.count) files in bucket.")
                    print("📦 DEBUG: File names: \(files)")

                    await MainActor.run {
                        self.avatarFiles = files
                        self.collectionView.reloadData()
                        self.activityIndicator.stopAnimating()
                    }
                } catch {
                    print("❌ Error loading avatars: \(error)")
                    await MainActor.run { self.activityIndicator.stopAnimating() }
                }
            }
        }
    
    private func saveAvatarAndExit(avatarName: String) {
        view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        Task {
            do {
                // ✅ Service automatically detects this is a Child update
                try await ProfileService.shared.updateAvatar(avatarName: avatarName)
                
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("❌ Error saving child avatar: \(error)")
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                }
            }
        }
    }

    // MARK: - UI Setup
    private func setupBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        // Child Theme Colors (Slightly lighter/fun than Parent)
        gradientLayer.colors = [
            UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0).cgColor,
            UIColor(red: 0.13, green: 0.23, blue: 0.44, alpha: 1.0).cgColor
        ]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        headerView.addSubview(backButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Pick Your Character" // 🧸 Kid-friendly title
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 20)
        headerView.addSubview(titleLabel)
    }

    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        // Reusing the existing AvatarCell
        collectionView.register(AvatarCell.self, forCellWithReuseIdentifier: AvatarCell.reuseID)
        
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
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
extension ChildAvatarSelectViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatarFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCell.reuseID, for: indexPath) as! AvatarCell
        
        let fileName = avatarFiles[indexPath.item]
        
        // ✅ USE NEW URL BUILDER (Gets URL from 'child_avatars' bucket)
        let urlString = ProfileService.shared.getChildAvatarURL(fileName: fileName)
        
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
