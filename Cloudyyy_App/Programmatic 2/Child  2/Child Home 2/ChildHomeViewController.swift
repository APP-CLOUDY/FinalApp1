import UIKit
import SwiftUI

// MARK: - Physics Helper Class
// This tracks the velocity and view for each bubble in UIKit
final class PhysicsBubble {
    let view: UIView
    var velocity: CGPoint
    let radius: CGFloat
    
    init(view: UIView, velocity: CGPoint, radius: CGFloat) {
        self.view = view
        self.velocity = velocity
        self.radius = radius
    }
}

final class ChildHomeViewController: UIViewController {

    // MARK: - UI Elements
    // 🔥 Added reference to the height constraint for dynamic resizing
    private var bubbleContainerHeightConstraint: NSLayoutConstraint?
    
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
    
    // MARK: - Physics & Data State
    private var currentTasks: [ScheduleTaskModelChild] = []
    private var physicsBubbles: [PhysicsBubble] = []
    private var displayLink: CADisplayLink?
    
    // 🎨 Neon Palette (Matching CloudyTheme.swift)
    private let bubbleColors: [UIColor] = [
        UIColor(red: 1.0, green: 0.6, blue: 0.7, alpha: 1.0), // Neon Pink
        UIColor(red: 0.4, green: 0.65, blue: 1.0, alpha: 1.0), // Neon Blue
        UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0), // Neon Green
        UIColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 1.0)  // Neon Yellow
    ]

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
        startPhysicsEngine() // Start the loop
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPhysicsEngine() // Stop loop to save battery
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        scrollView.contentSize = contentView.bounds.size
    }
    
    // MARK: - Physics Engine (The "Roaming" Logic)
    private func startPhysicsEngine() {
        stopPhysicsEngine()
        displayLink = CADisplayLink(target: self, selector: #selector(updatePhysics))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopPhysicsEngine() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updatePhysics() {
        let containerW = bubbleContainerView.bounds.width
        let containerH = bubbleContainerView.bounds.height
        
        // 1. Move Bubbles & Check Walls
        for i in 0..<physicsBubbles.count {
            let b1 = physicsBubbles[i]
            var center = b1.view.center
            
            // Apply Velocity
            center.x += b1.velocity.x
            center.y += b1.velocity.y
            
            // Wall Bouncing (Keep inside container)
            if center.x < b1.radius {
                center.x = b1.radius
                b1.velocity.x *= -1
            } else if center.x > containerW - b1.radius {
                center.x = containerW - b1.radius
                b1.velocity.x *= -1
            }
            
            if center.y < b1.radius {
                center.y = b1.radius
                b1.velocity.y *= -1
            } else if center.y > containerH - b1.radius {
                center.y = containerH - b1.radius
                b1.velocity.y *= -1
            }
            
            b1.view.center = center
            
            // 2. Collision Logic (Bubble vs Bubble)
            for j in (i + 1)..<physicsBubbles.count {
                let b2 = physicsBubbles[j]
                let center2 = b2.view.center
                
                let dx = center2.x - center.x
                let dy = center2.y - center.y
                let distance = sqrt(dx*dx + dy*dy)
                let minDistance = b1.radius + b2.radius
                
                if distance < minDistance {
                    let angle = atan2(dy, dx)
                    let force: CGFloat = 0.5 // Bounce factor
                    
                    let fx = cos(angle) * force
                    let fy = sin(angle) * force
                    
                    b1.velocity.x -= fx
                    b1.velocity.y -= fy
                    b2.velocity.x += fx
                    b2.velocity.y += fy
                    
                    // Separate them so they don't get stuck
                    let overlap = minDistance - distance
                    let separationX = cos(angle) * overlap * 0.5
                    let separationY = sin(angle) * overlap * 0.5
                    
                    b1.view.center.x -= separationX
                    b1.view.center.y -= separationY
                    b2.view.center.x += separationX
                    b2.view.center.y += separationY
                }
            }
        }
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
        // Clear existing views and physics objects
        bubbleContainerView.subviews.forEach { $0.removeFromSuperview() }
        physicsBubbles.removeAll()
        
        let activeTasks = tasks.filter {
            $0.submission_status != "approved" && $0.submission_status != "pending"
        }
        
        self.currentTasks = activeTasks

        if activeTasks.isEmpty {
            // Reset to default height if empty
            self.bubbleContainerHeightConstraint?.constant = 400
            showEmptyState()
            return
        }
        
        // 1. UNLIMITED TASKS (Removed the .prefix(10) limit)
        let displayTasks = activeTasks
        
        // 2. 🔥 DYNAMIC HEIGHT CALCULATION
        // Base height 450. We add ~80px per bubble to ensure they have vertical room to float.
        let baseHeight: CGFloat = 450
        let requiredHeight = max(baseHeight, CGFloat(displayTasks.count) * 80)
        
        // 3. APPLY HEIGHT UPDATE
        self.bubbleContainerHeightConstraint?.constant = requiredHeight
        self.view.layoutIfNeeded() // Force layout update so physics bounds are correct
        
        let containerW = view.bounds.width
        let containerH = requiredHeight // Use new dynamic height
        
        for (index, task) in displayTasks.enumerated() {
            
            // 🔥 4. DYNAMIC SIZE LOGIC BASED ON POINTS
            // 20 points = 90 size, 30 points = 100 size.
            // Clamped between 80 (min) and 150 (max) to prevent tiny or huge bubbles.
            let pointsValue = CGFloat(task.points)
            let bubbleSize = min(150, max(80, 70 + pointsValue))
            let radius = bubbleSize / 2
            
            // Random Position (safe from edges using the specific radius of this bubble)
            let minX = radius
            let maxX = max(radius, containerW - radius)
            let minY = radius
            let maxY = max(radius, containerH - radius)
            
            let safeX = CGFloat.random(in: minX...maxX)
            let safeY = CGFloat.random(in: minY...maxY)
            
            let frame = CGRect(x: safeX - radius, y: safeY - radius, width: bubbleSize, height: bubbleSize)
            
            // Random Velocity
            let vx = CGFloat.random(in: -0.8...0.8)
            let vy = CGFloat.random(in: -0.8...0.8)
            
            // Create View
            let bubble = createBubbleView(for: task, frame: frame, index: index)
            bubbleContainerView.addSubview(bubble)
            
            // Add to Physics System
            let node = PhysicsBubble(view: bubble, velocity: CGPoint(x: vx, y: vy), radius: radius)
            physicsBubbles.append(node)
        }
        
        // 🔥 5. Update ScrollView Content Size
        // This ensures the user can scroll down to see the new extended area
        scrollView.contentSize = contentView.bounds.size
    }

    private func createBubbleView(for task: ScheduleTaskModelChild, frame: CGRect, index: Int) -> UIView {
        let bubble = UIView(frame: frame)
        
        // 🔥 RANDOM COLOR SELECTION
        let themeColor = bubbleColors.randomElement() ?? bubbleColors[0]
        
        // 1. Simple Glassy Background
        bubble.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        // 2. Thin Neon Border
        bubble.layer.borderColor = themeColor.withAlphaComponent(0.6).cgColor
        bubble.layer.borderWidth = 1.0
        bubble.layer.cornerRadius = frame.width / 2
        
        // 3. Soft Glow
        bubble.layer.shadowColor = themeColor.cgColor
        bubble.layer.shadowOpacity = 0.2
        bubble.layer.shadowOffset = .zero
        bubble.layer.shadowRadius = 8
        
        // TEXT
        let titleLabel = UILabel()
        titleLabel.text = task.title ?? "Task"
        titleLabel.textColor = themeColor
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        let subLabel = UILabel()
        // Show Points
        subLabel.text = "\(task.points) ⭐️"
        subLabel.textColor = UIColor.white.withAlphaComponent(0.6)
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
        
        // Tap Gesture
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

    // MARK: - Setup Gradient, UI, Layout
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
        
        bubbleInstructionLabel.text = ""
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
        // 🔥 Create the height constraint separately so we can store it
        let heightConstraint = bubbleContainerView.heightAnchor.constraint(equalToConstant: 450)
        self.bubbleContainerHeightConstraint = heightConstraint
        
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

            // ... inside setupLayout ...

                        quoteBubble.bottomAnchor.constraint(equalTo: mascotImageView.topAnchor, constant: 70), // Vertical overlap
                        
                        // 1. Move RIGHT: Increase this number to overlap more into the cloud
                        // (e.g., 60 means the bubble goes 60pts past the start of the mascot)
                        quoteBubble.trailingAnchor.constraint(equalTo: mascotImageView.leadingAnchor, constant: 60),
                        
                        // 2. FIXED SIZE: Keep these so it doesn't stretch
                        quoteBubble.widthAnchor.constraint(equalToConstant: 180),
                        quoteBubble.heightAnchor.constraint(equalToConstant: 75),
                        
                        // ❌ DELETE OR COMMENT OUT THIS LINE 👇
                        // quoteBubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),m
            quoteLabel.centerYAnchor.constraint(equalTo: quoteBubble.centerYAnchor),
            quoteLabel.leadingAnchor.constraint(equalTo: quoteBubble.leadingAnchor, constant: 16),
            quoteLabel.trailingAnchor.constraint(equalTo: quoteBubble.trailingAnchor, constant: -16),

            bubbleInstructionLabel.topAnchor.constraint(equalTo: mascotImageView.bottomAnchor, constant: 30),
            bubbleInstructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            bubbleContainerView.topAnchor.constraint(equalTo: bubbleInstructionLabel.bottomAnchor, constant: -100),
            bubbleContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bubbleContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // 🔥 Active the stored constraint
            heightConstraint,

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

    // 🔥 4. BUBBLE TAP + ANIMATION
    @objc private func bubbleTapped(_ sender: UITapGestureRecognizer) {
        guard let bubble = sender.view else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            bubble.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                bubble.transform = .identity
            } completion: { [weak self] _ in
                guard let self = self else { return }
                
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
        let approvalNeeded = task.approval_required ?? false
        
        // We set up the Mission object but color is not crucial here as it will re-randomize in Detail View
        let mission = Mission(
            id: task.id,
            title: task.title ?? "Unknown",
            time: task.frequency ?? "Today",
            requiresPhoto: approvalNeeded,
            approvalRequired: approvalNeeded,
            color: .blue,
            size: 100,
            x: 0,
            y: 0
        )
        
        let detailContainer = MissionDetailContainer(mission: mission) {
            self.navigationController?.popViewController(animated: true)
            self.fetchAndDisplayData()
        }
        
        let host = UIHostingController(rootView: detailContainer)
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
struct MissionDetailContainer: View {
    let mission: Mission
    var onDismiss: () -> Void
    
    @State private var currentState: AppState
    @State private var completedMissionIDs: Set<UUID> = []
    @State private var dissolvingMissionID: UUID? = nil
    
    init(mission: Mission, onDismiss: @escaping () -> Void) {
        self.mission = mission
        self.onDismiss = onDismiss
        _currentState = State(initialValue: .missionDetail(mission))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.bgGradientStart, .bgGradientEnd]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            MissionDetailView(
                currentState: $currentState,
                mission: mission,
                completedMissionIDs: $completedMissionIDs,
                dissolvingMissionID: $dissolvingMissionID
            )
        }
        .onChange(of: currentState) { newState in
            if case .missionCluster = newState {
                onDismiss()
            }
        }
    }
}
