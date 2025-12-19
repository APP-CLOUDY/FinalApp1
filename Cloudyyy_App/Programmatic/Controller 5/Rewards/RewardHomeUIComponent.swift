//
//  RewardHomeUIComponents.swift
//  Cloudyyy_App
//
//  Created by user@10 on 18/12/25.
//

import Foundation
import UIKit

// -------------------------------------------------
// MARK: - Shared UI Components (Visible to all controllers)
// -------------------------------------------------
final class CombinedTitleNotesView: UIView, UITextViewDelegate {

    private let titleTF: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 15, weight: .regular)
        tf.textColor = .label
        tf.clearButtonMode = .never
        return tf
    }()

    private let notesTV: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 15, weight: .regular)
        tv.textColor = .label
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 12, right: 12)
        tv.textContainer.lineFragmentPadding = 0
        tv.isScrollEnabled = false
        return tv
    }()

    private let placeholderLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = .placeholderText
        lbl.numberOfLines = 0
        return lbl
    }()

    private let container = UIView()
    private let separator = UIView()

    // Internal height constraint for the notes area that we update
    private var notesHeightConstraint: NSLayoutConstraint!
    private let notesMinHeight: CGFloat = 52

    // External API
    var titleText: String {
        get { titleTF.text ?? "" }
        set { titleTF.text = newValue }
    }

    var notesText: String {
        get { notesTV.text == placeholderLabel.text ? "" : notesTV.text }
        set {
            if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                notesTV.text = ""
                placeholderLabel.isHidden = false
                updateNotesHeight(animated: false)
            } else {
                notesTV.text = newValue
                placeholderLabel.isHidden = true
                updateNotesHeight(animated: false)
            }
        }
    }

    init(titlePlaceholder: String = "Title", notesPlaceholder: String = "Description (Optional)") {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        // Container: use white/background card like Reminders screenshot
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true

        // Separator line
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        separator.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        // Placeholder label and textView delegate
        placeholderLabel.text = notesPlaceholder                        // <- set the text
        placeholderLabel.font = .systemFont(ofSize: 15, weight: .regular)
        placeholderLabel.textColor = UIColor.white.withAlphaComponent(0.55)
        placeholderLabel.alpha = 1
        placeholderLabel.isHidden = false

        // ensure typed notes are visible on dark card
        notesTV.textColor = UIColor.white.withAlphaComponent(0.95)
        notesTV.delegate = self

        // make sure placeholder isn't covered by the text view
        container.bringSubviewToFront(placeholderLabel)


        // Title field placeholder attr + styling
        titleTF.font = .systemFont(ofSize: 15, weight: .regular)
        titleTF.textColor = UIColor.white.withAlphaComponent(0.95)

        let titleAttr = NSAttributedString(
            string: titlePlaceholder,
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.55), // brighter placeholder
                .font: UIFont.systemFont(ofSize: 15, weight: .regular)
            ]
        )

        titleTF.attributedPlaceholder = titleAttr

        // Slightly tighter insets for notes to match screenshot
        notesTV.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 12, right: 12)

        // assemble
        addSubview(container)
        container.addSubview(titleTF)
        container.addSubview(separator)
        container.addSubview(notesTV)
        container.addSubview(placeholderLabel)

        // constraints
        notesHeightConstraint = notesTV.heightAnchor.constraint(equalToConstant: notesMinHeight)
        notesHeightConstraint.priority = .required

        NSLayoutConstraint.activate([
            // container pin
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            // title row
            titleTF.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleTF.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            titleTF.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            titleTF.heightAnchor.constraint(equalToConstant: 40),

            // separator: 1 physical pixel
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            separator.topAnchor.constraint(equalTo: titleTF.bottomAnchor, constant: 6),
            separator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),

            // notes area
            notesTV.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            notesTV.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            notesTV.topAnchor.constraint(equalTo: separator.bottomAnchor),
            notesTV.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            // notes height constraint
            notesHeightConstraint,

            // placeholder label inside notes
            placeholderLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            placeholderLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 10),
            placeholderLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])

        // initial states
        placeholderLabel.isHidden = false
        notesTV.text = ""

        // initial sizing after layout
        DispatchQueue.main.async { self.updateNotesHeight(animated: false) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let empty = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        placeholderLabel.isHidden = !empty
        updateNotesHeight(animated: true)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.12) { self.placeholderLabel.alpha = 0 }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        let empty = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        placeholderLabel.isHidden = !empty
        UIView.animate(withDuration: 0.12) { self.placeholderLabel.alpha = empty ? 1 : 0 }
    }

    // Update the notes area height according to content size
    private func updateNotesHeight(animated: Bool) {
        let targetWidth = notesTV.bounds.width > 0 ? notesTV.bounds.width : (container.bounds.width - 28)
        let size = notesTV.sizeThatFits(CGSize(width: targetWidth, height: .greatestFiniteMagnitude))
        let calculatedHeight = max(notesMinHeight, size.height)

        let apply = {
            self.notesHeightConstraint.constant = calculatedHeight
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseInOut]) {
                apply()
                self.superview?.layoutIfNeeded()
            }
        } else {
            apply()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateNotesHeight(animated: false)
    }
    
}



// Section Label
final class SectionLabel: UIView {
    init(text: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false

        addSubview(lbl)

        NSLayoutConstraint.activate([
            lbl.leadingAnchor.constraint(equalTo: leadingAnchor),
            lbl.topAnchor.constraint(equalTo: topAnchor),
            lbl.bottomAnchor.constraint(equalTo: bottomAnchor),
            lbl.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// Large card
final class RewardLargeCard: UIView {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let pointsLabel = UILabel()
    var onTap: (() -> Void)?

    init(item: RewardDetailItem) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 14
        layer.masksToBounds = true
        backgroundColor = UIColor(white: 1, alpha: 0.03)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        if let name = item.imageName, let img = UIImage(named: name) {
            imageView.image = img
        } else {
            imageView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
        }

        imageView.translatesAutoresizingMaskIntoConstraints = false

        let bottom = UIView()
        bottom.backgroundColor = UIColor(white: 0, alpha: 0.3)
        bottom.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        pointsLabel.text = "\(item.points) Points"
        pointsLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        pointsLabel.textColor = .white
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(bottom)
        bottom.addSubview(titleLabel)
        bottom.addSubview(pointsLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottom.topAnchor),

            bottom.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottom.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottom.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottom.heightAnchor.constraint(equalToConstant: 70),

            titleLabel.leadingAnchor.constraint(equalTo: bottom.leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: bottom.topAnchor, constant: 8),

            pointsLabel.leadingAnchor.constraint(equalTo: bottom.leadingAnchor, constant: 12),
            pointsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
    }

    @objc private func didTap() { onTap?() }
    required init?(coder: NSCoder) { fatalError() }
}

// Small card
final class RewardSmallCard: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
    var onTap: (() -> Void)?

    init(item: RewardDetailItem) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 12
        backgroundColor = UIColor(white: 1, alpha: 0.03)
        clipsToBounds = true

        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.text = item.subtitle
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        chevron.tintColor = UIColor.white.withAlphaComponent(0.6)
        chevron.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(chevron)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),

            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 18)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
    }

    @objc private func didTap() { onTap?() }
    required init?(coder: NSCoder) { fatalError() }
}

// Shared Detail
final class RewardDetailViewController: UIViewController {
    private let item: RewardDetailItem

    init(item: RewardDetailItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
        title = item.title
        view.backgroundColor = .systemBackground
    }

    required init?(coder: NSCoder) { fatalError() }
}
