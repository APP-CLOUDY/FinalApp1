import UIKit
import SwiftUI // 🔥 1. IMPORT SWIFTUI

final class ChildHomeViewController: UIViewController {

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let gradientLayer = CAGradientLayer()

    // Header Elements
    private let greetingLabel = UILabel()
    private let subGreetingLabel = UILabel()
    private let bellButton = UIButton(type: .system)
    private let profileButton = UIButton(type: .system)

    // Mascot & Quote
    private let quoteBubble = UIView()
    private let quoteLabel = UILabel()
    private let mascotImageView = UIImageView()

    // Bubble Interaction Area
    private let bubbleInstructionLabel = UILabel()
    private let bubbleContainerView = UIView()
    private let bottomPaddingView = UIView()
    
    // 🔥 2. DATA STORAGE
    // We need to store tasks here so "bubbleTapped" knows which task was clicked
    private var currentTasks: [ScheduleTaskModelChild] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupUI()
        setupLayout()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startMascotFloatingAnimation()
        fetchAndDisplayData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        scrollView.contentSize = contentView.bounds.size
    }
    
    // MARK: - Data Logic
    private func fetchAndDisplayData() {
        if let name = ChildSessionManager.shared.currentChildName {
            greetingLabel.text = "Hello \(name)."
        }
        
        Task {
            do {
                let tasks = try await ChildHomeService.shared.fetchSchedule(date: Date())
                await MainActor.run {
                    self.updateDynamicBubblesUI(tasks: tasks)
                }
            } catch {
                print("Error loading schedule: \(error)")
            }
        }
    }
    
    // MARK: - Bubble UI Logic
    private func updateDynamicBubblesUI(tasks: [ScheduleTaskModelChild]) {
        bubbleContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        // 🔥 FIX: Hide "pending" tasks too so the bubble disappears immediately
        let activeTasks = tasks.filter {
            $0.submission_status != "approved" && $0.submission_status != "pending"
        }
        
        // 🔥 3. STORE DATA FOR LATER
        self.currentTasks = activeTasks

        if activeTasks.isEmpty {
            showEmptyState()
            return
        }
        
        // (Logic remains same, just ensuring we use activeTasks safely)
        let displayTasks = activeTasks.prefix(5)
        var occupiedFrames: [CGRect] = []
        let bubbleSize: CGFloat = 100
        let containerW = view.bounds.width
        let containerH: CGFloat = 450
        
        for (index, task) in displayTasks.enumerated() {
            var finalFrame = CGRect.zero
            var isPositionValid = false
            var attempts = 0
            
            while !isPositionValid && attempts < 50 {
                let randomX = CGFloat.random(in: 10...(containerW - bubbleSize - 10))
                let randomY = CGFloat.random(in: 10...(containerH - bubbleSize - 10))
                let proposedFrame = CGRect(x: randomX, y: randomY, width: bubbleSize, height: bubbleSize)
                
                let intersects = occupiedFrames.contains { existingFrame in
                    return proposedFrame.intersects(existingFrame.insetBy(dx: -10, dy: -10))
                }
                
                if !intersects {
                    finalFrame = proposedFrame
                    isPositionValid = true
                }
                attempts += 1
            }
            
            if !isPositionValid {
                finalFrame = CGRect(x: CGFloat(index * 20) + 20, y: CGFloat(index * 50) + 20, width: bubbleSize, height: bubbleSize)
            }
            
            occupiedFrames.append(finalFrame)
            
            // Note: passing 'index' as tag is crucial here
            let bubble = createBubbleView(for: task, frame: finalFrame, index: index)
            bubbleContainerView.addSubview(bubble)
            
            startBubbleFloatAnimation(view: bubble, delay: Double(index) * 0.4)
        }
    }

    private func createBubbleView(for task: ScheduleTaskModelChild, frame: CGRect, index: Int) -> UIView {
            let bubble = UIView(frame: frame)
            
            let categoryName = task.list_name ?? "General"
            let themeColor = getColorForCategory(categoryName)
            
            // 🎨 1. GLASSY BACKGROUND (Semi-transparent black)
            bubble.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            
            // 🎨 2. THIN BORDER (Subtle Stroke)
            bubble.layer.borderColor = themeColor.withAlphaComponent(0.6).cgColor
            bubble.layer.borderWidth = 1.0 // Thinner than before (was 2.0)
            bubble.layer.cornerRadius = frame.width / 2
            
            // 🎨 3. SOFT GLOW (Reduced Shadow)
            bubble.layer.shadowColor = themeColor.cgColor
            bubble.layer.shadowOpacity = 0.2 // Much softer than before (was 0.6)
            bubble.layer.shadowOffset = .zero
            bubble.layer.shadowRadius = 8
            
            // TEXT CONTENT
            let titleLabel = UILabel()
            titleLabel.text = task.title ?? "Task"
            titleLabel.textColor = themeColor
            titleLabel.font = .systemFont(ofSize: 14, weight: .semibold) // Slightly larger, readable
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 2
            
            let subLabel = UILabel()
            // 🔥 CHANGE: Show Frequency (e.g. "Daily") instead of Category ("LEARNING")
            subLabel.text = (task.frequency ?? "Once").capitalized
            subLabel.textColor = UIColor.white.withAlphaComponent(0.6) // Faded white text
            subLabel.font = .systemFont(ofSize: 11, weight: .regular)
            subLabel.textAlignment = .center
            
            let textStack = UIStackView(arrangedSubviews: [titleLabel, subLabel])
            textStack.axis = .vertical
            textStack.spacing = 2
            textStack.alignment = .center
            textStack.translatesAutoresizingMaskIntoConstraints = false
            
            bubble.addSubview(textStack)
            
            NSLayoutConstraint.activate([
                textStack.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
                textStack.centerYAnchor.constraint(equalTo: bubble.centerYAnchor),
                textStack.widthAnchor.constraint(equalTo: bubble.widthAnchor, constant: -10)
            ])
            
            // Interaction
            let tap = UITapGestureRecognizer(target: self, action: #selector(bubbleTapped(_:)))
            bubble.addGestureRecognizer(tap)
            bubble.isUserInteractionEnabled = true
            bubble.tag = index
            
            return bubble
        }
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "All caught up! 🎉"
        emptyLabel.textColor = .white.withAlphaComponent(0.7)
        emptyLabel.font = .boldSystemFont(ofSize: 20)
        emptyLabel.textAlignment = .center
        emptyLabel.frame = bubbleContainerView.bounds
        emptyLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bubbleContainerView.addSubview(emptyLabel)
    }

    // MARK: - Helper: Colors
    private func getColorForCategory(_ name: String) -> UIColor {
        let lower = name.lowercased()
        if lower.contains("test") || lower.contains("daily") {
            return UIColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)
        }
        if lower.contains("math") || lower.contains("study") {
            return UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0)
        }
        if lower.contains("clean") || lower.contains("chore") {
            return UIColor(red: 0.2, green: 1.0, blue: 0.5, alpha: 1.0)
        }
        return UIColor(red: 0.8, green: 0.4, blue: 1.0, alpha: 1.0)
    }

    // MARK: - Setup Gradient, UI, Layout, Animations
    // (These functions remain exactly as you wrote them)
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 15/255, green: 18/255, blue: 24/255, alpha: 1).cgColor,
            UIColor(red: 36/255, green: 55/255, blue: 99/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupUI() {
        greetingLabel.text = "Hello Child."
        greetingLabel.font = UIFont.boldSystemFont(ofSize: 32)
        greetingLabel.textColor = .white

        subGreetingLabel.text = "We hope you have a Great day !!"
        subGreetingLabel.font = UIFont.systemFont(ofSize: 16)
        subGreetingLabel.textColor = UIColor(white: 0.9, alpha: 1)

        bellButton.setImage(UIImage(systemName: "bell"), for: .normal)
        bellButton.tintColor = .white
        
        profileButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
        profileButton.tintColor = .white

        quoteBubble.backgroundColor = UIColor(red: 240/255, green: 228/255, blue: 241/255, alpha: 1)
        quoteBubble.layer.cornerRadius = 20
        quoteBubble.layer.masksToBounds = true
        
        quoteLabel.text = "Let’s Finish our Missions today !!"
        quoteLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        quoteLabel.textColor = .black
        quoteLabel.numberOfLines = 0
        quoteLabel.textAlignment = .center
        quoteBubble.addSubview(quoteLabel)

        mascotImageView.image = UIImage(named: "cloudyy_logo") ?? UIImage(systemName: "cloud.rain.fill")
        mascotImageView.contentMode = .scaleAspectFit
        mascotImageView.isUserInteractionEnabled = true
        
        bubbleInstructionLabel.text = "Tap a bubble to start"
        bubbleInstructionLabel.font = UIFont.boldSystemFont(ofSize: 18)
        bubbleInstructionLabel.textColor = .white
        
        bubbleContainerView.backgroundColor = .clear

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [greetingLabel, subGreetingLabel, bellButton, profileButton,
         quoteBubble, mascotImageView,
         bubbleInstructionLabel, bubbleContainerView,
         bottomPaddingView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            greetingLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            subGreetingLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 6),
            subGreetingLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),

            profileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            profileButton.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 30),
            profileButton.heightAnchor.constraint(equalToConstant: 30),

            bellButton.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -16),
            bellButton.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor),
            bellButton.widthAnchor.constraint(equalToConstant: 30),
            bellButton.heightAnchor.constraint(equalToConstant: 30),

            mascotImageView.topAnchor.constraint(equalTo: subGreetingLabel.bottomAnchor, constant: 65),
            mascotImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10),
            mascotImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.55),
            mascotImageView.heightAnchor.constraint(equalTo: mascotImageView.widthAnchor),

            quoteBubble.bottomAnchor.constraint(equalTo: mascotImageView.topAnchor, constant: 40),
            quoteBubble.trailingAnchor.constraint(equalTo: mascotImageView.leadingAnchor, constant: 20),
            quoteBubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            quoteBubble.widthAnchor.constraint(equalToConstant: 180),
            quoteBubble.heightAnchor.constraint(equalToConstant: 75),
            
            quoteLabel.centerYAnchor.constraint(equalTo: quoteBubble.centerYAnchor),
            quoteLabel.leadingAnchor.constraint(equalTo: quoteBubble.leadingAnchor, constant: 16),
            quoteLabel.trailingAnchor.constraint(equalTo: quoteBubble.trailingAnchor, constant: -16),

            bubbleInstructionLabel.topAnchor.constraint(equalTo: mascotImageView.bottomAnchor, constant: 30),
            bubbleInstructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            bubbleContainerView.topAnchor.constraint(equalTo: bubbleInstructionLabel.bottomAnchor, constant: 10),
            bubbleContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bubbleContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bubbleContainerView.heightAnchor.constraint(equalToConstant: 450),

            bottomPaddingView.topAnchor.constraint(equalTo: bubbleContainerView.bottomAnchor, constant: 20),
            bottomPaddingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomPaddingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomPaddingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomPaddingView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func startMascotFloatingAnimation() {
        let floatAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        floatAnimation.fromValue = 0
        floatAnimation.toValue = -12
        floatAnimation.duration = 2.5
        floatAnimation.autoreverses = true
        floatAnimation.repeatCount = .infinity
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        mascotImageView.layer.add(floatAnimation, forKey: "floating")
    }
    
    private func startBubbleFloatAnimation(view: UIView, delay: Double) {
        let upDown = CABasicAnimation(keyPath: "transform.translation.y")
        upDown.fromValue = -5
        upDown.toValue = 5
        upDown.duration = Double.random(in: 2.0...3.5)
        upDown.autoreverses = true
        upDown.repeatCount = .infinity
        upDown.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        upDown.beginTime = CACurrentMediaTime() + delay
        view.layer.add(upDown, forKey: "bubbleFloat")
    }
    
    // MARK: - Actions
    private func setupActions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(mascotTapped))
        mascotImageView.addGestureRecognizer(tap)
        
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        bellButton.addTarget(self, action: #selector(bellButtonTapped), for: .touchUpInside)
    }

    @objc private func mascotTapped() {
        self.tabBarController?.selectedIndex = 3
    }

    // 🔥 4. UPDATED TAP ACTION TO NAVIGATE TO SWIFTUI
    @objc private func bubbleTapped(_ sender: UITapGestureRecognizer) {
        guard let bubble = sender.view else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            bubble.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                bubble.transform = .identity
            } completion: { [weak self] _ in
                guard let self = self else { return }
                
                // 1. Get the Task Model
                let index = bubble.tag
                if index < self.currentTasks.count {
                    let task = self.currentTasks[index]
                    self.navigateToMissionDetail(for: task)
                }
            }
        }
    }
    
    // 🔥 5. NAVIGATION FUNCTION
    private func navigateToMissionDetail(for task: ScheduleTaskModelChild) {
        // 1. Convert Backend Task -> UI Mission Class
        let approvalNeeded = task.approval_required ?? false
        
        let mission = Mission(
            id: task.id,
            title: task.title ?? "Unknown",
            time: task.frequency ?? "Today",
            requiresPhoto: approvalNeeded,
            approvalRequired: approvalNeeded,
            color: Color(getColorForCategory(task.list_name ?? "")),
            size: 100, // Static for Detail View
            x: 0,
            y: 0
        )
        
        // 2. Wrap the SwiftUI View
        // We pass a closure 'onDismiss' so the SwiftUI view can tell UIKit to go back
        let detailContainer = MissionDetailContainer(mission: mission) {
            // This runs when SwiftUI says "Back" or "Done"
            self.navigationController?.popViewController(animated: true)
            // Optional: Refresh data to remove completed task
            self.fetchAndDisplayData()
        }
        
        // 3. Create Host and Push
        let host = UIHostingController(rootView: detailContainer)
        // Ensure nav bar stays hidden or styled as preferred
        self.navigationController?.pushViewController(host, animated: true)
    }

    @objc private func profileButtonTapped() {
        print("Navigating to Profile")
    }
    
    @objc private func bellButtonTapped() {
        print("Navigating to Notifications")
    }
}

// 🔥 6. SWIFTUI BRIDGE VIEW
// This wraps your existing MissionDetailView to make it work easily inside UIKit
struct MissionDetailContainer: View {
    let mission: Mission
    var onDismiss: () -> Void // Callback to UIKit
    
    // We create dummy state to satisfy MissionDetailView's bindings
    @State private var currentState: AppState = .missionDetail(Mission(id: UUID(), title: "", time: "", requiresPhoto: false, approvalRequired: false, color: .blue, size: 0, x: 0, y: 0))
    @State private var completedMissionIDs: Set<UUID> = []
    @State private var dissolvingMissionID: UUID? = nil
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [.bgGradientStart, .bgGradientEnd]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Your Existing View
            // We pass the mission we created from UIKit
            MissionDetailView(
                currentState: $currentState,
                mission: mission,
                completedMissionIDs: $completedMissionIDs,
                dissolvingMissionID: $dissolvingMissionID
            )
        }
        // Watch for state changes. If currentState changes from .missionDetail -> .missionCluster (which happens when you click "Back"), we dismiss UIKit.
        .onChange(of: currentState) { newState in
            if case .missionCluster = newState {
                onDismiss()
            }
        }
    }
}
