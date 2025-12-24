import UIKit

// MARK: - Custom Cell with Bin Icon
class CustomListCell: UITableViewCell {
    
    var onDelete: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 17, weight: .medium)
        return l
    }()
    
    private lazy var deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        btn.setImage(UIImage(systemName: "trash", withConfiguration: config), for: .normal)
        btn.tintColor = .systemRed.withAlphaComponent(0.8)
        btn.addAction(UIAction(handler: { [weak self] _ in
            self?.onDelete?()
        }), for: .touchUpInside)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(white: 1, alpha: 0.05) // Semi-transparent
        selectionStyle = .none // Handle selection visually manually if needed
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, UIView(), deleteButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            deleteButton.widthAnchor.constraint(equalToConstant: 44),
            deleteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func configure(name: String) {
        titleLabel.text = name
    }
}

// MARK: - View Controller
class CustomListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    var familyId: UUID?
    
    // Callbacks
    var onSelect: ((TaskListModel) -> Void)?
    var onListChange: (() -> Void)?
    
    private var customLists: [TaskListModel] = []
    
    // MARK: - UI
    private let gradient = CAGradientLayer()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .clear // Important for gradient to show
        tv.separatorColor = UIColor(white: 1, alpha: 0.1)
        return tv
    }()
    
    private lazy var addTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Enter new list name...",
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        tf.textColor = .white
        tf.borderStyle = .none
        tf.backgroundColor = UIColor(white: 1, alpha: 0.1)
        tf.layer.cornerRadius = 10
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        tf.leftViewMode = .always
        tf.returnKeyType = .done
        tf.delegate = self
        return tf
    }()
    
    private lazy var addButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Add"
        config.baseBackgroundColor = UIColor(red: 44/255, green: 116/255, blue: 252/255, alpha: 1)
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        
        let btn = UIButton(configuration: config)
        btn.addAction(UIAction(handler: { [weak self] _ in
            self?.addTapped()
        }), for: .touchUpInside)
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom Lists"
        
        // Navigation Bar Appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        
        setupGradient()
        setupUI()
        fetchCustomLists()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = view.bounds
    }
    
    private func setupGradient() {
        gradient.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func setupUI() {
        // Input Stack (Field + Button)
        let inputStack = UIStackView(arrangedSubviews: [addTextField, addButton])
        inputStack.axis = .horizontal
        inputStack.spacing = 10
        inputStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(inputStack)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            inputStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            inputStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputStack.heightAnchor.constraint(equalToConstant: 46),
            
            addButton.widthAnchor.constraint(equalToConstant: 74),
            
            tableView.topAnchor.constraint(equalTo: inputStack.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomListCell.self, forCellReuseIdentifier: "customCell")
    }
    
    // MARK: - Data
    private func fetchCustomLists() {
        guard let familyId else { return }
        
        Task {
            do {
                let allLists = try await TaskService.shared.fetchTaskLists(familyId: familyId)
                // Filter out standard ones so we only show "Custom" ones here
                let standards = ["Routine", "Learning", "Health", "General"]
                
                await MainActor.run {
                    self.customLists = allLists.filter { !standards.contains($0.name) }
                    self.tableView.reloadData()
                }
            } catch {
                print("Error fetching lists:", error)
            }
        }
    }
    
    // MARK: - Actions
    private func addTapped() {
        guard let text = addTextField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty, let familyId else { return }
        
        addTextField.resignFirstResponder()
        addTextField.text = ""
        
        Task {
            do {
                let newList = try await TaskService.shared.createTaskList(name: text, familyId: familyId)
                await MainActor.run {
                    self.customLists.append(newList)
                    self.tableView.reloadData()
                    self.onListChange?() // Notify parent
                }
            } catch {
                print("Error creating list:", error)
            }
        }
    }
    
    private func handleDelete(at indexPath: IndexPath) {
            let list = customLists[indexPath.row]
            
            // Optimistic Update (Remove from UI immediately)
            customLists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            Task {
                do {
                    try await TaskService.shared.deleteTaskList(id: list.id)
                    await MainActor.run { self.onListChange?() }
                } catch {
                    print("Error deleting:", error)
                    
                    // ❌ If failed, put the item back and warn the user
                    await MainActor.run {
                        self.customLists.insert(list, at: indexPath.row)
                        self.tableView.reloadData()
                        
                        let alert = UIAlertController(title: "Delete Failed", message: "Could not delete list. Try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? CustomListCell else {
            return UITableViewCell()
        }
        
        let list = customLists[indexPath.row]
        cell.configure(name: list.name)
        
        // ✅ Handle Bin Icon Tap
        cell.onDelete = { [weak self] in
            self?.confirmDelete(at: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let list = customLists[indexPath.row]
        onSelect?(list)
        navigationController?.popViewController(animated: true)
    }
    
    private func confirmDelete(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete List?", message: "This will delete the list and all tasks inside it.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.handleDelete(at: indexPath)
        }))
        present(alert, animated: true)
    }
}

extension CustomListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addTapped()
        return true
    }
}
