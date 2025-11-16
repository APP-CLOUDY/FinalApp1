import UIKit

protocol TaskDetailViewControllerDelegate: AnyObject {
    func taskDetailViewController(_ controller: TaskDetailViewController, didCompleteTask task: Task)
}

final class TaskDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let task: Task
    weak var delegate: TaskDetailViewControllerDelegate?
    
    // UI Elements
    private let titleLabel = UILabel()
    private let missionLabel = UILabel()
    private let missionContainer = UIView()
    private let missionName = UILabel()
    private let missionTimeLabel = UILabel()
    private let cloudImage = UIImageView()
    private let chatBubble = UILabel()
    private let doneButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)
    private let inputField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    // MARK: - Init
    init(task: Task) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupTopBar()
        setupMissionSection()
        setupCloudAndChat()
        setupButtons()
        setupInputBar()
    }
}

// MARK: - Setup UI
extension TaskDetailViewController {
    
    private func setupBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 20/255, green: 25/255, blue: 40/255, alpha: 1).cgColor,
            UIColor(red: 30/255, green: 45/255, blue: 85/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func setupTopBar() {
        title = "Cloudyy"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
    }
    
    private func setupMissionSection() {
        missionLabel.text = "Mission"
        missionLabel.textColor = .white
        missionLabel.font = .boldSystemFont(ofSize: 20)
        missionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(missionLabel)
        
        missionContainer.backgroundColor = UIColor(white: 1.0, alpha: 0.08)
        missionContainer.layer.cornerRadius = 12
        missionContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(missionContainer)
        
        let yellowBar = UIView()
        yellowBar.backgroundColor = .systemYellow
        yellowBar.layer.cornerRadius = 2
        yellowBar.translatesAutoresizingMaskIntoConstraints = false
        missionContainer.addSubview(yellowBar)
        
        missionName.text = task.title
        missionName.textColor = .white
        missionName.font = .boldSystemFont(ofSize: 17)
        missionName.translatesAutoresizingMaskIntoConstraints = false
        missionContainer.addSubview(missionName)
        
        missionTimeLabel.text = task.time
        missionTimeLabel.textColor = .white
        missionTimeLabel.font = .systemFont(ofSize: 15)
        missionTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        missionContainer.addSubview(missionTimeLabel)
        
        NSLayoutConstraint.activate([
            missionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            missionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            missionContainer.topAnchor.constraint(equalTo: missionLabel.bottomAnchor, constant: 12),
            missionContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            missionContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            missionContainer.heightAnchor.constraint(equalToConstant: 70),
            
            yellowBar.leadingAnchor.constraint(equalTo: missionContainer.leadingAnchor, constant: 8),
            yellowBar.centerYAnchor.constraint(equalTo: missionContainer.centerYAnchor),
            yellowBar.widthAnchor.constraint(equalToConstant: 5),
            yellowBar.heightAnchor.constraint(equalTo: missionContainer.heightAnchor, multiplier: 0.7),
            
            missionName.topAnchor.constraint(equalTo: missionContainer.topAnchor, constant: 10),
            missionName.leadingAnchor.constraint(equalTo: yellowBar.trailingAnchor, constant: 12),
            
            missionTimeLabel.topAnchor.constraint(equalTo: missionName.bottomAnchor, constant: 6),
            missionTimeLabel.leadingAnchor.constraint(equalTo: yellowBar.trailingAnchor, constant: 12)
        ])
    }
    
    private func setupCloudAndChat() {
        chatBubble.text = "Let me know when you are done!"
        chatBubble.font = .systemFont(ofSize: 15, weight: .medium)
        chatBubble.textAlignment = .center
        chatBubble.textColor = .black
        chatBubble.numberOfLines = 2
        chatBubble.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        chatBubble.layer.cornerRadius = 16
        chatBubble.clipsToBounds = true
        chatBubble.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatBubble)
        
        cloudImage.image = UIImage(named: "imgCloudMain")
        cloudImage.contentMode = .scaleAspectFit
        cloudImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cloudImage)
        
        NSLayoutConstraint.activate([
            chatBubble.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chatBubble.topAnchor.constraint(equalTo: missionContainer.bottomAnchor, constant: 40),
            chatBubble.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            chatBubble.heightAnchor.constraint(equalToConstant: 60),
            
            cloudImage.topAnchor.constraint(equalTo: chatBubble.bottomAnchor, constant: 20),
            cloudImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cloudImage.widthAnchor.constraint(equalToConstant: 160),
            cloudImage.heightAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    private func setupButtons() {
        doneButton.setTitle("Done!", for: .normal)
        doneButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        doneButton.layer.cornerRadius = 14
        doneButton.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        doneButton.layer.borderWidth = 1
        doneButton.tintColor = .white
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        
        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        backButton.layer.cornerRadius = 14
        backButton.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        backButton.layer.borderWidth = 1
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [doneButton, backButton])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: cloudImage.bottomAnchor, constant: 30),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: 300),
            stack.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func setupInputBar() {
        inputField.placeholder = "Ask me !"
        inputField.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        inputField.textColor = .white
        inputField.layer.cornerRadius = 14
        inputField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputField)
        
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = .white
        sendButton.backgroundColor = UIColor.systemPurple
        sendButton.layer.cornerRadius = 28
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            inputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -12),
            inputField.heightAnchor.constraint(equalToConstant: 56),
            
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sendButton.centerYAnchor.constraint(equalTo: inputField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 56),
            sendButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Actions
    @objc private func doneTapped() {
        delegate?.taskDetailViewController(self, didCompleteTask: task)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
