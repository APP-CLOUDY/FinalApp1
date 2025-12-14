//
//  CustomListViewController.swift
//  Cloudyyy_App
//
//  Created by user@10 on 14/12/25.
//

import UIKit

final class CustomListViewController: UIViewController {

    // MARK: - Callback
    var onSave: ((String) -> Void)?

    // MARK: - Gradient
    private let gradient = CAGradientLayer()

    // MARK: - UI
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "List name"
        tf.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        tf.textColor = .white
        tf.font = .systemFont(ofSize: 16, weight: .medium)
        tf.layer.cornerRadius = 12
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 52).isActive = true
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf.leftViewMode = .always
        tf.autocapitalizationType = .words
        return tf
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        title = "New List"

        setupGradient()
        setupNavigationBar()
        setupLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }

    // MARK: - Setup
    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
    }

    private func setupLayout() {
        view.addSubview(textField)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
    }

    // MARK: - Actions
    @objc private func saveTapped() {
        let name = textField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !name.isEmpty else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            return
        }

        onSave?(name)
        navigationController?.popViewController(animated: true)
    }
}

