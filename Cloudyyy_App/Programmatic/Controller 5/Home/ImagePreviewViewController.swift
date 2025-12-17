//
//  ImagePreviewViewController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 16/12/25.
//

import Foundation
import UIKit

final class ImagePreviewViewController: UIViewController {

    private let imageView = UIImageView()
    private let image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.95)

        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Tap anywhere to dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}

