import UIKit


final class ChatBotViewController: UIViewController, TaskBubbleCellDelegate, UITextFieldDelegate {
    func taskBubbleCell(_ cell: TaskBubbleCell, didSelectTask task: Task) {
        let detailVC = TaskDetailViewController(task: task)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
    

    // MARK: Views
    private let bgView = UIView()
    private let avatarImageView = UIImageView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let inputBar = UIView()
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)

    private var inputBarBottomConstraint: NSLayoutConstraint!
    private let gradientLayer = CAGradientLayer()
    private var messages: [ChatMessage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupTable()
        setupKeyboardObservers()
        setupInitialMessages()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = bgView.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Setup
    private func setupViews() {
        view.backgroundColor = .black

        // background gradient
        bgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgView)
        gradientLayer.colors = [
            UIColor(red: 20/255, green: 25/255, blue: 40/255, alpha: 1).cgColor,
            UIColor(red: 30/255, green: 45/255, blue: 85/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        bgView.layer.insertSublayer(gradientLayer, at: 0)

        // back chevron
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backToChildHome), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)

        // avatar
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.image = UIImage(named: "cloudyy_logo")
        view.addSubview(avatarImageView)
        

        // table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        view.addSubview(tableView)

        // input bar
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        inputBar.backgroundColor = .clear
        view.addSubview(inputBar)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(white: 0.97, alpha: 1)
        textField.layer.cornerRadius = 14
        textField.placeholder = "Ask me !"
        textField.returnKeyType = .send
        textField.delegate = self
        inputBar.addSubview(textField)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.layer.cornerRadius = 28
        sendButton.backgroundColor = UIColor(red: 117/255, green: 72/255, blue: 232/255, alpha: 1)
        sendButton.tintColor = .white
        let plane = UIImage(systemName: "paperplane.fill")
        sendButton.setImage(plane, for: .normal)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        inputBar.addSubview(sendButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: view.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        NSLayoutConstraint.activate([
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 150),
            avatarImageView.heightAnchor.constraint(equalToConstant: 150)
        ])

        inputBarBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        inputBarBottomConstraint.isActive = true

        NSLayoutConstraint.activate([
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBar.heightAnchor.constraint(equalToConstant: 84)
        ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor, constant: -12)
        ])

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 16),
            textField.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 56),

            sendButton.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 56),
            sendButton.heightAnchor.constraint(equalToConstant: 56),

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
    }

    private func setupInitialMessages() {
        messages = [
            ChatMessage(text: "Hi, Lets Complete all Mission", type: .incoming),
            ChatMessage(text: "I got you some missions for you today.\nWant to see them ??", type: .choice, choices: ["Yes, show me!", "Maybe later"])
        ]
        tableView.reloadData()
        scrollToBottom(animated: false)
    }

    // MARK: Actions
    @objc private func backToChildHome() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func sendTapped() {
        guard let t = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return }
        let msg = ChatMessage(text: t, type: .outgoing)
        messages.append(msg)
        textField.text = ""
        tableView.reloadData()
        scrollToBottom(animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.messages.append(ChatMessage(text: "Nice! I'll show you the missions.", type: .incoming))
            self.tableView.reloadData()
            self.scrollToBottom(animated: true)
        }
    }

    // MARK: Keyboard
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let frameEnd = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        let screenH = UIScreen.main.bounds.height
        let kbHeight: CGFloat = frameEnd.origin.y >= screenH ? 0 : frameEnd.height

        UIView.animate(withDuration: duration) {
            self.inputBarBottomConstraint.constant = -kbHeight + self.view.safeAreaInsets.bottom
            self.view.layoutIfNeeded()
            self.scrollToBottom(animated: false)
        }
    }

    private func scrollToBottom(animated: Bool) {
        DispatchQueue.main.async {
            let c = self.messages.count
            guard c > 0 else { return }
            let idx = IndexPath(row: c - 1, section: 0)
            self.tableView.scrollToRow(at: idx, at: .bottom, animated: animated)
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ChatBotViewController: UITableViewDataSource, UITableViewDelegate, ChoiceMessageCellDelegate {
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
                cell.delegate = self   // 👈 Correct — allows ChatBotViewController to handle taps
            }
            return cell
        }
    }

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


                // ✅ Create the new bubble message
                let bubbleMsg = ChatMessage(text: nil, type: .taskBubbles, choices: nil, tasks: tasks)

                // ✅ Append it
                self.messages.append(bubbleMsg)

                // ✅ Debug print to console — check if message exists
                print("DEBUG → messages count:", self.messages.count)
                print("DEBUG → last message type:", self.messages.last?.type ?? .incoming)

                // ✅ Reload and force layout update
                self.tableView.reloadData()
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                self.tableView.layoutIfNeeded()
                self.scrollToBottom(animated: true)
            }
        }

    }
}

// MARK: - UITextFieldDelegate
extension ChatBotViewController: TaskDetailViewControllerDelegate {
    func taskDetailViewController(_ controller: TaskDetailViewController, didCompleteTask task: Task) {
        for (index, msg) in messages.enumerated() {
            if msg.type == .taskBubbles, var tasks = msg.tasks {
                if let idx = tasks.firstIndex(where: { $0.title == task.title }) {
                    tasks.remove(at: idx)
                    messages[index].tasks = tasks
                    
                    if tasks.isEmpty {
                        messages.remove(at: index)
                        tableView.reloadData()
                        print("✅ All tasks completed!")
                        return
                    }
                    
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    tableView.endUpdates()
                    break
                }
            }
        }
    }
}
