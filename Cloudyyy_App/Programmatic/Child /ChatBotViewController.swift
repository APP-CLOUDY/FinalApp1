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
    private let inputBar = UIView()
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)

    // MARK: - Constraints
    private var inputBarBottomConstraint: NSLayoutConstraint!
    private var avatarWidthConstraint: NSLayoutConstraint!
    private var avatarHeightConstraint: NSLayoutConstraint!

    private let gradientLayer = CAGradientLayer()
    private var messages: [ChatMessage] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide Nav Bar so it looks like a full screen chat
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupViews()
        setupConstraints()
        setupTable()
        setupKeyboardObservers()
        setupInitialMessages()
        
        // Set initial avatar size based on current orientation
        let isLandscape = view.bounds.width > view.bounds.height
        updateAvatarSize(isLandscape: isLandscape)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = bgView.bounds
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
        // Shrink avatar in landscape to save vertical space
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
        gradientLayer.colors = [
            UIColor(red: 20/255, green: 25/255, blue: 40/255, alpha: 1).cgColor,
            UIColor(red: 30/255, green: 45/255, blue: 85/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        bgView.layer.insertSublayer(gradientLayer, at: 0)

        // 2. Avatar
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFit
        // Ensure you have "cloudyy_logo" in Assets, otherwise use system fallback
        avatarImageView.image = UIImage(named: "cloudyy_logo") ?? UIImage(systemName: "cloud.fill")
        avatarImageView.tintColor = .white
        view.addSubview(avatarImageView)

        // 3. Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        view.addSubview(tableView)

        // 4. Input Bar
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        inputBar.backgroundColor = .clear
        
        // Glass Effect
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 24
        blurView.clipsToBounds = true
        inputBar.addSubview(blurView)
        
        view.addSubview(inputBar)

        // Text Field
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        textField.layer.cornerRadius = 20
        textField.placeholder = "Ask me !"
        
        // Placeholder color
        let placeholderAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.lightGray]
        textField.attributedPlaceholder = NSAttributedString(string: "Ask me!", attributes: placeholderAttributes)
        
        textField.returnKeyType = .send
        textField.delegate = self
        textField.textColor = .white
        
        // Padding for text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        inputBar.addSubview(textField)

        // Send Button
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.layer.cornerRadius = 22 // Half of width (44)
        sendButton.backgroundColor = UIColor(red: 117/255, green: 72/255, blue: 232/255, alpha: 1)
        sendButton.tintColor = .white
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        inputBar.addSubview(sendButton)
        
        // Constraints for Blur (Glass Background)
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: inputBar.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: inputBar.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor)
        ])
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

        // Input Bar Position
        // Pin to Safe Area Bottom. This ensures it sits ON TOP of the Tab Bar.
        inputBarBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        inputBarBottomConstraint.isActive = true

        NSLayoutConstraint.activate([
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputBar.heightAnchor.constraint(equalToConstant: 60) // Reduced height for cleaner look
        ])

        // Table View (Fills space between Avatar and Input Bar)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor, constant: -12)
        ])

        // Input Bar Contents
        NSLayoutConstraint.activate([
            // Send Button
            sendButton.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 44),
            sendButton.heightAnchor.constraint(equalToConstant: 44),

            // Text Field
            textField.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 8),
            textField.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8)
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
            ChatMessage(text: "Hi, Lets Complete all Mission", type: .incoming),
            ChatMessage(text: "I got you some missions for you today.\nWant to see them ??", type: .choice, choices: ["Yes, show me!", "Maybe later"])
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
        textField.resignFirstResponder() // Optional: Hide keyboard on send
        
        tableView.reloadData()
        scrollToBottom(animated: true)

        // Simulated Reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.messages.append(ChatMessage(text: "Nice! I'll show you the missions.", type: .incoming))
            self.tableView.reloadData()
            self.scrollToBottom(animated: true)
        }
    }
    
    // MARK: - UITextFieldDelegate (Handle "Return" key)
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

        // Calculate constraints
        if kbHeight > 0 {
            // Keyboard Visible: Move up by Keyboard Height minus Safe Area Bottom (because constraint is pinned to safe area)
            let safeAreaBottom = view.safeAreaInsets.bottom
            inputBarBottomConstraint.constant = -(kbHeight - safeAreaBottom + 10)
        } else {
            // Keyboard Hidden: Reset to default
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
        
        // IMPORTANT: This requires ChildTabBarController to wrap this VC in a UINavigationController
        if let nav = navigationController {
            nav.pushViewController(detailVC, animated: true)
        } else {
            // Fallback if not in Nav Controller
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
                
                // Proper insertion animation
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
        // Loop through messages to find the Bubble Message
        for (index, msg) in messages.enumerated() {
            if msg.type == .taskBubbles, var tasks = msg.tasks {
                
                if let idx = tasks.firstIndex(where: { $0.title == task.title }) {
                    // Remove the completed task
                    tasks.remove(at: idx)
                    messages[index].tasks = tasks

                    if tasks.isEmpty {
                        // If all tasks done, remove the message row completely
                        messages.remove(at: index)
                        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                        
                        // Add success message
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.messages.append(ChatMessage(text: "Great job! All tasks completed.", type: .incoming))
                            self.tableView.reloadData()
                            self.scrollToBottom(animated: true)
                        }
                        return
                    }

                    // Reload the bubble row to update circles
                    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    break
                }
            }
        }
    }
}
