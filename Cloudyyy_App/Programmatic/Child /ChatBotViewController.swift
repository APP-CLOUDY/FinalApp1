import UIKit

final class ChatBotViewController: UIViewController,
    TaskBubbleCellDelegate,
    UITextFieldDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    ChoiceMessageCellDelegate,
    TaskDetailViewControllerDelegate {

    // MARK: - Views
    private let bgView = UIView()
    private let avatarImageView = UIImageView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    // Input Components
    // inputBar is now just a transparent container holding the two separate elements in place
    private let inputBar = UIView()
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)

    // MARK: - Layers & Visuals
    private let bgGradientLayer = CAGradientLayer()
    private let buttonGradientLayer = CAGradientLayer()

    // MARK: - Constraints
    private var inputBarBottomConstraint: NSLayoutConstraint!
    private var avatarWidthConstraint: NSLayoutConstraint!
    private var avatarHeightConstraint: NSLayoutConstraint!

    private var messages: [ChatMessage] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupViews()
        setupConstraints()
        setupTable()
        setupKeyboardObservers()
        setupInitialMessages()
        
        let isLandscape = view.bounds.width > view.bounds.height
        updateAvatarSize(isLandscape: isLandscape)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 1. Update Background Gradient
        bgGradientLayer.frame = bgView.bounds
        
        // 2. Update Button Gradient
        buttonGradientLayer.frame = sendButton.bounds
        buttonGradientLayer.cornerRadius = sendButton.layer.cornerRadius
        
        // 3. Update Shadow Path
        sendButton.layer.shadowPath = UIBezierPath(roundedRect: sendButton.bounds, cornerRadius: sendButton.layer.cornerRadius).cgPath
        
        // 4. CRITICAL FIX: Ensure icon is on top of the gradient layer
        if let imageView = sendButton.imageView {
            sendButton.bringSubviewToFront(imageView)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Rotation / Landscape Handling
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let isLandscape = size.width > size.height
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updateAvatarSize(isLandscape: isLandscape)
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func updateAvatarSize(isLandscape: Bool) {
        let size: CGFloat = isLandscape ? 80 : 150
        avatarWidthConstraint?.constant = size
        avatarHeightConstraint?.constant = size
    }

    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .black

        // 1. Background Gradient
        bgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgView)
        bgGradientLayer.colors = [
            UIColor(red: 20/255, green: 25/255, blue: 40/255, alpha: 1).cgColor,
            UIColor(red: 30/255, green: 45/255, blue: 85/255, alpha: 1).cgColor
        ]
        bgGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        bgView.layer.insertSublayer(bgGradientLayer, at: 0)

        // 2. Avatar
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.image = UIImage(named: "cloudyy_logo") ?? UIImage(systemName: "cloud.fill")
        avatarImageView.tintColor = .white
        view.addSubview(avatarImageView)

        // 3. Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        view.addSubview(tableView)

        // 4. Input Bar Container (Transparent holder)
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        inputBar.backgroundColor = .clear
        view.addSubview(inputBar)

        // 4a. Text Field (The Capsule)
        textField.translatesAutoresizingMaskIntoConstraints = false
        // Dark semi-transparent background for the field itself
        textField.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 30/255, alpha: 0.5)
        // Full rounded corners (half of height 44)
        textField.layer.cornerRadius = 22
        textField.clipsToBounds = true
        
        // Subtle border for definition
        textField.layer.borderColor = UIColor(white: 1.0, alpha: 0.1).cgColor
        textField.layer.borderWidth = 1.0
        
        // Typography
        let placeholderText = "Ask me anything..."
        let placeholderColor = UIColor.lightGray.withAlphaComponent(0.7)
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [.foregroundColor: placeholderColor])
        
        textField.returnKeyType = .send
        textField.delegate = self
        textField.textColor = .white
        
        // Padding inside the text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
        
        inputBar.addSubview(textField)

        // 4b. Send Button (The Adjacent Circle)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        // Full rounded corners (half of height 44)
        sendButton.layer.cornerRadius = 22
        
        // Gradient
        buttonGradientLayer.colors = [
            UIColor(red: 117/255, green: 72/255, blue: 232/255, alpha: 1).cgColor,
            UIColor(red: 90/255, green: 50/255, blue: 200/255, alpha: 1).cgColor
        ]
        buttonGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        buttonGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        sendButton.layer.insertSublayer(buttonGradientLayer, at: 0)
        
        // Shadow / Glow
        sendButton.layer.shadowColor = UIColor(red: 117/255, green: 72/255, blue: 232/255, alpha: 1).cgColor
        sendButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        sendButton.layer.shadowOpacity = 0.4
        sendButton.layer.shadowRadius = 6
        
        // Icon Setup
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold, scale: .medium)
        // Using a slightly different paperplane icon that looks better in a circle
        let iconImage = UIImage(systemName: "paperplane.fill", withConfiguration: iconConfig)
        sendButton.setImage(iconImage, for: .normal)
        sendButton.tintColor = .white
        // Slightly offset the icon to visually center it in the circle
        sendButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 0)
        
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        
        inputBar.addSubview(sendButton)
    }

    private func setupConstraints() {
        // BG View
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: view.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Avatar
        avatarWidthConstraint = avatarImageView.widthAnchor.constraint(equalToConstant: 150)
        avatarHeightConstraint = avatarImageView.heightAnchor.constraint(equalToConstant: 150)
        
        NSLayoutConstraint.activate([
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            avatarWidthConstraint,
            avatarHeightConstraint
        ])

        // Input Bar Position (The container holding both parts)
        inputBarBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        inputBarBottomConstraint.isActive = true

        NSLayoutConstraint.activate([
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputBar.heightAnchor.constraint(equalToConstant: 44) // Height matches the elements inside
        ])

        // Table View
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor, constant: -12)
        ])

        // Input Bar Contents Constraints
        NSLayoutConstraint.activate([
            // Send Button (Right Side)
            sendButton.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor),
            sendButton.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 44),
            sendButton.heightAnchor.constraint(equalToConstant: 44),

            // Text Field (Left Side, stretching to meet the button with a gap)
            textField.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor),
            textField.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44),
            // 12 point gap between field and button
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -12)
        ])
    }

    private func setupTable() {
        tableView.register(IncomingMessageCell.self, forCellReuseIdentifier: IncomingMessageCell.reuseId)
        tableView.register(OutgoingMessageCell.self, forCellReuseIdentifier: OutgoingMessageCell.reuseId)
        tableView.register(ChoiceMessageCell.self, forCellReuseIdentifier: ChoiceMessageCell.reuseId)
        tableView.register(TaskBubbleCell.self, forCellReuseIdentifier: TaskBubbleCell.reuseId)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .interactive
    }

    private func setupInitialMessages() {
        messages = [
            ChatMessage(text: "Hi, Let's complete all missions!", type: .incoming),
            ChatMessage(text: "I got some missions for you today.\nWant to see them?", type: .choice, choices: ["Yes, show me!", "Maybe later"])
        ]
        tableView.reloadData()
        scrollToBottom(animated: false)
    }

    // MARK: - Actions
    @objc private func sendTapped() {
        guard let t = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return }
        
        let msg = ChatMessage(text: t, type: .outgoing)
        messages.append(msg)
        textField.text = ""
        textField.resignFirstResponder()
        
        tableView.reloadData()
        scrollToBottom(animated: true)

        // Simulated Reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.messages.append(ChatMessage(text: "Nice! I'll show you the missions.", type: .incoming))
            self.tableView.reloadData()
            self.scrollToBottom(animated: true)
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped()
        return true
    }

    // MARK: - Keyboard handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let info = notification.userInfo else { return }

        let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let frameEnd = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        let screenH = UIScreen.main.bounds.height
        let kbHeight = frameEnd.origin.y >= screenH ? 0 : frameEnd.height

        if kbHeight > 0 {
            let safeAreaBottom = view.safeAreaInsets.bottom
            inputBarBottomConstraint.constant = -(kbHeight - safeAreaBottom + 10)
        } else {
            inputBarBottomConstraint.constant = -10
        }

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
            self.scrollToBottom(animated: false)
        }
    }

    private func scrollToBottom(animated: Bool) {
        DispatchQueue.main.async {
            let c = self.messages.count
            guard c > 0 else { return }
            let idx = IndexPath(row: c - 1, section: 0)
            if self.tableView.numberOfRows(inSection: 0) > idx.row {
                self.tableView.scrollToRow(at: idx, at: .bottom, animated: animated)
            }
        }
    }

    // MARK: - TaskBubbleCellDelegate
    func taskBubbleCell(_ cell: TaskBubbleCell, didSelectTask task: Task) {
        let detailVC = TaskDetailViewController(task: task)
        detailVC.delegate = self
        
        if let nav = navigationController {
            nav.pushViewController(detailVC, animated: true)
        } else {
            present(detailVC, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource & Delegate / ChoiceMessageCellDelegate
extension ChatBotViewController {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messages.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.row]
        switch msg.type {
        case .incoming:
            let cell = tableView.dequeueReusableCell(withIdentifier: IncomingMessageCell.reuseId, for: indexPath) as! IncomingMessageCell
            cell.configure(with: msg)
            return cell
        case .outgoing:
            let cell = tableView.dequeueReusableCell(withIdentifier: OutgoingMessageCell.reuseId, for: indexPath) as! OutgoingMessageCell
            cell.configure(with: msg)
            return cell
        case .choice:
            let cell = tableView.dequeueReusableCell(withIdentifier: ChoiceMessageCell.reuseId, for: indexPath) as! ChoiceMessageCell
            cell.configure(with: msg)
            cell.delegate = self
            return cell
        case .taskBubbles:
            let cell = tableView.dequeueReusableCell(withIdentifier: TaskBubbleCell.reuseId, for: indexPath) as! TaskBubbleCell
            if let tasks = msg.tasks {
                cell.configure(tasks: tasks)
                cell.delegate = self
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // ChoiceMessageCellDelegate
    func choiceMessageCell(_ cell: ChoiceMessageCell, didSelectChoice title: String) {
        let userMessage = ChatMessage(text: title, type: .outgoing)
        messages.append(userMessage)
        tableView.reloadData()
        scrollToBottom(animated: true)

        if title.lowercased().contains("yes") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                let tasks: [Task] = [
                    Task(title: "News", time: "6:00 pm", sizeFactor: 1.2, color: .systemRed),
                    Task(title: "Brush", time: "5:30 am", sizeFactor: 0.9, color: .systemGreen),
                    Task(title: "Play", time: "6:30 pm", sizeFactor: 1.3, color: .systemPink),
                    Task(title: "Do Dishes", time: "10:30 pm", sizeFactor: 1.0, color: .systemGreen),
                    Task(title: "Mop", time: "6:30 pm", sizeFactor: 0.8, color: .systemBlue),
                    Task(title: "Home work", time: "6:30 pm", sizeFactor: 0.9, color: .systemBlue),
                    Task(title: "Water Your Plants", time: "8:30 pm", sizeFactor: 1.8, color: .systemRed)
                ]

                let bubbleMsg = ChatMessage(text: nil, type: .taskBubbles, choices: nil, tasks: tasks)
                self.messages.append(bubbleMsg)
                
                let newIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.insertRows(at: [newIndexPath], with: .fade)
                self.scrollToBottom(animated: true)
            }
        }
    }
}

// MARK: - TaskDetailViewControllerDelegate
extension ChatBotViewController {
    func taskDetailViewController(_ controller: TaskDetailViewController, didCompleteTask task: Task) {
        for (index, msg) in messages.enumerated() {
            if msg.type == .taskBubbles, var tasks = msg.tasks {
                
                if let idx = tasks.firstIndex(where: { $0.title == task.title }) {
                    tasks.remove(at: idx)
                    messages[index].tasks = tasks

                    if tasks.isEmpty {
                        messages.remove(at: index)
                        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.messages.append(ChatMessage(text: "Great job! All tasks completed.", type: .incoming))
                            self.tableView.reloadData()
                            self.scrollToBottom(animated: true)
                        }
                        return
                    }

                    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    break
                }
            }
        }
    }
}
