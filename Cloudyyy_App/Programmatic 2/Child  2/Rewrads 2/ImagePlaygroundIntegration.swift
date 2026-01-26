//
//  ImagePlaygroundIntegration.swift
//  Cloudyyy_App
//
//  Created for RewardsHub
//

import SwiftUI
import UIKit

// 1. Safety check: Ensure the framework exists (iOS 18.2+)
#if canImport(ImagePlayground)
import ImagePlayground
#endif

// MARK: - The SwiftUI Wrapper
@available(iOS 18.2, *)
struct ImagePlaygroundLauncher: View {
    // We use a real state here so the sheet can open/close naturally
    @State private var showPlayground = false
    
    // Callbacks to talk back to UIKit
    var onImageGenerated: (URL) -> Void
    var onDismiss: () -> Void
    
    var body: some View {
        // Transparent background container
        Color.clear
            .onAppear {
                // Trigger the sheet as soon as this view appears
                showPlayground = true
            }
            .onChange(of: showPlayground) { _, newValue in
                // If the sheet closes (newValue becomes false), dismiss the whole view controller
                if !newValue {
                    onDismiss()
                }
            }
            // Apple Intelligence Modifier
            #if canImport(ImagePlayground)
            .imagePlaygroundSheet(
                isPresented: $showPlayground,
                concept: "" // Optional: Add default text like "Cartoon cat" here
            ) { url in
                // Success
                print("✨ Image Created at: \(url)")
                onImageGenerated(url)
                // The sheet closes automatically here, triggering the onChange above
            } onCancellation: {
                // Cancelled
                print("Cancelled")
                // The sheet closes automatically here, triggering the onChange above
            }
            #else
            .onAppear {
                print("❌ ImagePlayground framework not found.")
                onDismiss()
            }
            #endif
    }
}

// MARK: - Result Viewer (Preview Popup)
// MARK: - Result Viewer (Preview Popup)
class GeneratedImagePreviewController: UIViewController {
    
    private let imageUrl: URL
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.backgroundColor = .black
        return iv
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 20
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    init(imageUrl: URL) {
        self.imageUrl = imageUrl
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ✅ FIXED LINE: Use withAlphaComponent for UIKit
        view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        
        view.addSubview(imageView)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            closeButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -15),
            closeButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 15),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        closeButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        
        if let data = try? Data(contentsOf: imageUrl) {
            imageView.image = UIImage(data: data)
        }
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}
