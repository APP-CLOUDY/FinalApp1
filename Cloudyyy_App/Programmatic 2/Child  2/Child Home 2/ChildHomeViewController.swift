import UIKit
import SwiftUI
import CoreMotion

// MARK: - Physics Helper Class
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
    private var bubbleContainerHeightConstraint: NSLayoutConstraint?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let gradientLayer = CAGradientLayer()

    // Header Elements
    private let greetingLabel = UILabel()
    private let subGreetingLabel = UILabel()
    
    // ✨ Profile Button (Normal Icon Style)
    private let profileButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let icon = UIImage(systemName: "person.circle.fill", withConfiguration: config)
        btn.setImage(icon, for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // ✨ Magic Motion Toggle (Glassy Style)
    private let gravityButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let icon = UIImage(systemName: "wind", withConfiguration: config)
        btn.setImage(icon, for: .normal)
        btn.tintColor = .white
        
        // Glassy Background for the Tool
        btn.layer.cornerRadius = 20
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return btn
    }()

    // Mascot & Quote
    private let quoteBubble = UIView()
    private let quoteLabel = UILabel()
    private let mascotImageView = UIImageView()

    // Bubble Interaction Area
    private let bubbleInstructionLabel = UILabel()
    private let bubbleContainerView = UIView()
    private let bottomPaddingView = UIView()
    
    // MARK: - Physics & Motion State
    private var currentTasks: [ScheduleTaskModelChild] = []
    private var physicsBubbles: [PhysicsBubble] = []
    private var displayLink: CADisplayLink?
    
    private let motionManager = CMMotionManager()
    private var isGravityEnabled: Bool = false
    private let impactGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    // 🎨 Neon Palette
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
        
        impactGenerator.prepare()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startMascotFloatingAnimation()
        fetchAndDisplayData()
        startPhysicsEngine()
        
        if isGravityEnabled {
            startMotionUpdates()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPhysicsEngine()
        stopMotionUpdates()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        scrollView.contentSize = contentView.bounds.size
    }
    
    // MARK: - Motion Logic
    private func startMotionUpdates() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0
        motionManager.startAccelerometerUpdates()
    }
    
    private func stopMotionUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
    
    @objc private func toggleGravity() {
        isGravityEnabled.toggle()
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if isGravityEnabled {
            // ON: Start reading sensors
            startMotionUpdates()
            UIView.animate(withDuration: 0.3) {
                self.gravityButton.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.3) // Gold glow
                self.gravityButton.tintColor = .systemYellow
                self.gravityButton.layer.borderColor = UIColor.systemYellow.cgColor
                self.gravityButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        } else {
            // OFF: Stop sensors & Restore Float
            stopMotionUpdates()
            restoreFloatingState() // Push bubbles so they don't get stuck
            
            UIView.animate(withDuration: 0.3) {
                self.gravityButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
                self.gravityButton.tintColor = .white
                self.gravityButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
                self.gravityButton.transform = .identity
            }
        }
    }
    
    // Gives bubbles a random nudge so they float when gravity is off
    private func restoreFloatingState() {
        for bubble in physicsBubbles {
            // Push them hard so they start moving fast
            bubble.velocity.x = CGFloat.random(in: -2.0...2.0)
            bubble.velocity.y = CGFloat.random(in: -2.0...2.0)
        }
    }
    
    // MARK: - Physics Engine
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
        
        var gravityX: CGFloat = 0
        var gravityY: CGFloat = 0
        
        // 1. Calculate Forces
        if isGravityEnabled, let data = motionManager.accelerometerData {
            gravityX = CGFloat(data.acceleration.x) * 2.5
            gravityY = CGFloat(-data.acceleration.y) * 2.5
        }
        
        for i in 0..<physicsBubbles.count {
            let b1 = physicsBubbles[i]
            var center = b1.view.center
            
            if isGravityEnabled {
                // 🔥 MODE 1: Gravity ON (Tilt Control)
                b1.velocity.x += gravityX
                b1.velocity.y += gravityY
                
                // Friction (Damping) - Stops bubbles if phone is flat
                b1.velocity.x *= 0.94
                b1.velocity.y *= 0.94
            } else {
                // 🔥 MODE 2: Gravity OFF (Automatic Roaming - FAST)
                let maxSpeed: CGFloat = 3.0
                b1.velocity.x = max(-maxSpeed, min(maxSpeed, b1.velocity.x))
                b1.velocity.y = max(-maxSpeed, min(maxSpeed, b1.velocity.y))
                
                // If they slow down too much, give them a bigger kick
                if abs(b1.velocity.x) < 0.2 { b1.velocity.x = CGFloat.random(in: -1.0...1.0) }
                if abs(b1.velocity.y) < 0.2 { b1.velocity.y = CGFloat.random(in: -1.0...1.0) }
            }
            
            // Move
            center.x += b1.velocity.x
            center.y += b1.velocity.y
            
            // 3. Wall Bouncing
            let bounce: CGFloat = isGravityEnabled ? -0.6 : -1.0
            var hitWall = false
            
            if center.x < b1.radius {
                center.x = b1.radius
                b1.velocity.x *= bounce
                hitWall = true
            } else if center.x > containerW - b1.radius {
                center.x = containerW - b1.radius
                b1.velocity.x *= bounce
                hitWall = true
            }
            
            if center.y < b1.radius {
                center.y = b1.radius
                b1.velocity.y *= bounce
                hitWall = true
            } else if center.y > containerH - b1.radius {
                center.y = containerH - b1.radius
                b1.velocity.y *= bounce
                hitWall = true
            }
            
            // ✨ REDUCED HAPTICS: Wall Hit
            if hitWall && isGravityEnabled && (abs(b1.velocity.x) > 3 || abs(b1.velocity.y) > 3) {
                impactGenerator.impactOccurred(intensity: 0.25)
            }
            
            b1.view.center = center
            
            // 4. Collision Detection (Bubble vs Bubble)
            for j in (i + 1)..<physicsBubbles.count {
                let b2 = physicsBubbles[j]
                let center2 = b2.view.center
                
                let dx = center2.x - center.x
                let dy = center2.y - center.y
                let distance = sqrt(dx*dx + dy*dy)
                let minDistance = b1.radius + b2.radius
                
                if distance < minDistance {
                    let angle = atan2(dy, dx)
                    let force: CGFloat = 0.5
                    
                    let fx = cos(angle) * force
                    let fy = sin(angle) * force
                    
                    b1.velocity.x -= fx
                    b1.velocity.y -= fy
                    b2.velocity.x += fx
                    b2.velocity.y += fy
                    
                    let overlap = minDistance - distance
                    let separation = overlap + 1.0
                    let separationX = cos(angle) * separation * 0.5
                    let separationY = sin(angle) * separation * 0.5
                    
                    b1.view.center.x -= separationX
                    b1.view.center.y -= separationY
                    b2.view.center.x += separationX
                    b2.view.center.y += separationY
                    
                    // ✨ REDUCED HAPTICS: Bubble Collision
                    if isGravityEnabled && (abs(b1.velocity.x) > 2 || abs(b2.velocity.x) > 2) {
                        impactGenerator.impactOccurred(intensity: 0.15)
                    }
                }
            }
        }
    }
    
    // MARK: - Data Loading
    private func fetchAndDisplayData() {
        if let name = SessionManager.shared.childName {
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
    
    private func updateDynamicBubblesUI(tasks: [ScheduleTaskModelChild]) {
        bubbleContainerView.subviews.forEach { $0.removeFromSuperview() }
        physicsBubbles.removeAll()
        
        let activeTasks = tasks.filter {
            let status = $0.submission_status?.lowercased()
            return status != "approved" && status != "pending"
        }
        
        self.currentTasks = activeTasks

        if activeTasks.isEmpty {
            self.bubbleContainerHeightConstraint?.constant = 400
            showEmptyState()
            return
        }
        
        let baseHeight: CGFloat = 450
        let requiredHeight = max(baseHeight, CGFloat(activeTasks.count) * 85)
        
        self.bubbleContainerHeightConstraint?.constant = requiredHeight
        self.view.layoutIfNeeded()
        
        let containerW = bubbleContainerView.bounds.width
        let containerH = requiredHeight
        
        for (index, task) in activeTasks.enumerated() {
            let pointsValue = CGFloat(task.points)
            let bubbleSize = min(150, max(80, 70 + pointsValue))
            let radius = bubbleSize / 2
            
            let minX = radius
            let maxX = max(radius, containerW - radius)
            let minY = radius
            let maxY = max(radius, containerH - radius)
            
            let safeX = CGFloat.random(in: minX...maxX)
            let safeY = CGFloat.random(in: minY...maxY)
            let frame = CGRect(x: safeX - radius, y: safeY - radius, width: bubbleSize, height: bubbleSize)
            
            let vx = CGFloat.random(in: -0.8...0.8)
            let vy = CGFloat.random(in: -0.8...0.8)
            
            let bubble = createBubbleView(for: task, frame: frame, index: index)
            bubbleContainerView.addSubview(bubble)
            
            let node = PhysicsBubble(view: bubble, velocity: CGPoint(x: vx, y: vy), radius: radius)
            physicsBubbles.append(node)
        }
        
        scrollView.contentSize = contentView.bounds.size
    }

    private func createBubbleView(for task: ScheduleTaskModelChild, frame: CGRect, index: Int) -> UIView {
        let bubble = UIView(frame: frame)
        let themeColor = bubbleColors.randomElement() ?? bubbleColors[0]
        let redoAccentColor = UIColor(red: 1.0, green: 0.62, blue: 0.28, alpha: 1.0)
        let isRedoTask = {
            let status = task.submission_status?.lowercased()
            return status == "declined" || status == "rejected" || status == "redo"
        }()
        
        bubble.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        bubble.layer.borderColor = themeColor.withAlphaComponent(0.6).cgColor
        bubble.layer.borderWidth = 1.5
        bubble.layer.cornerRadius = frame.width / 2
        
        bubble.layer.shadowColor = themeColor.cgColor
        bubble.layer.shadowOpacity = 0.3
        bubble.layer.shadowOffset = .zero
        bubble.layer.shadowRadius = 10
        
        let titleLabel = UILabel()
        titleLabel.text = task.title ?? "Task"
        titleLabel.textColor = themeColor
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        let infoStack = UIStackView()
        infoStack.axis = .vertical
        infoStack.spacing = isRedoTask ? 6 : 4
        infoStack.alignment = .center

        if isRedoTask {
            let redoBadge = UILabel()
            redoBadge.text = "REDO"
            redoBadge.textColor = redoAccentColor
            redoBadge.font = .systemFont(ofSize: 11, weight: .heavy)
            redoBadge.textAlignment = .center
            redoBadge.backgroundColor = redoAccentColor.withAlphaComponent(0.18)
            redoBadge.layer.cornerRadius = 10
            redoBadge.layer.borderWidth = 1
            redoBadge.layer.borderColor = redoAccentColor.withAlphaComponent(0.45).cgColor
            redoBadge.clipsToBounds = true
            redoBadge.translatesAutoresizingMaskIntoConstraints = false

            let pointsLabel = UILabel()
            pointsLabel.text = "\(task.points) ⭐️"
            pointsLabel.textColor = UIColor.white.withAlphaComponent(0.9)
            pointsLabel.font = .systemFont(ofSize: 12, weight: .semibold)
            pointsLabel.textAlignment = .center

            infoStack.addArrangedSubview(redoBadge)
            infoStack.addArrangedSubview(pointsLabel)

            NSLayoutConstraint.activate([
                redoBadge.heightAnchor.constraint(equalToConstant: 20),
                redoBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 48)
            ])
        } else {
            let pointsLabel = UILabel()
            pointsLabel.text = "\(task.points) ⭐️"
            pointsLabel.textColor = UIColor.white.withAlphaComponent(0.8)
            pointsLabel.font = .systemFont(ofSize: 12, weight: .medium)
            pointsLabel.textAlignment = .center
            infoStack.addArrangedSubview(pointsLabel)
        }

        let textStack = UIStackView(arrangedSubviews: [titleLabel, infoStack])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .center
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        bubble.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            textStack.centerXAnchor.constraint(equalTo: bubble.centerXAnchor),
            textStack.centerYAnchor.constraint(equalTo: bubble.centerYAnchor),
            textStack.widthAnchor.constraint(equalTo: bubble.widthAnchor, constant: -12)
        ])
        
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

    // MARK: - Setup UI & Layout
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
        
        // ✨ Add buttons to layout
        [greetingLabel, subGreetingLabel, gravityButton, profileButton,
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

            // Profile Button (Right) - Normal Icon Style
            profileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            profileButton.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 44),
            profileButton.heightAnchor.constraint(equalToConstant: 44),

            // Gravity Button (Left of Profile) - Glassy Style
            gravityButton.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -16),
            gravityButton.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor),
            gravityButton.widthAnchor.constraint(equalToConstant: 40),
            gravityButton.heightAnchor.constraint(equalToConstant: 40),

            mascotImageView.topAnchor.constraint(equalTo: subGreetingLabel.bottomAnchor, constant: 65),
            mascotImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10),
            mascotImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.55),
            mascotImageView.heightAnchor.constraint(equalTo: mascotImageView.widthAnchor),

            quoteBubble.bottomAnchor.constraint(equalTo: mascotImageView.topAnchor, constant: 70),
            quoteBubble.trailingAnchor.constraint(equalTo: mascotImageView.leadingAnchor, constant: 60),
            quoteBubble.widthAnchor.constraint(equalToConstant: 180),
            quoteBubble.heightAnchor.constraint(equalToConstant: 75),
            
            quoteLabel.centerYAnchor.constraint(equalTo: quoteBubble.centerYAnchor),
            quoteLabel.leadingAnchor.constraint(equalTo: quoteBubble.leadingAnchor, constant: 16),
            quoteLabel.trailingAnchor.constraint(equalTo: quoteBubble.trailingAnchor, constant: -16),

            bubbleInstructionLabel.topAnchor.constraint(equalTo: mascotImageView.bottomAnchor, constant: 30),
            bubbleInstructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            bubbleContainerView.topAnchor.constraint(equalTo: bubbleInstructionLabel.bottomAnchor, constant: -100),
            bubbleContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bubbleContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
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
        gravityButton.addTarget(self, action: #selector(toggleGravity), for: .touchUpInside)
    }

    @objc private func mascotTapped() {
        self.tabBarController?.selectedIndex = 3
    }

    @objc private func bubbleTapped(_ sender: UITapGestureRecognizer) {
        guard let bubble = sender.view else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            bubble.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
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
    
    private func navigateToMissionDetail(for task: ScheduleTaskModelChild) {
        let approvalNeeded = task.approval_required ?? false
        
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
        let profileVC = ProfileViewController()
        profileVC.hidesBottomBarWhenPushed = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}

// MARK: - SwiftUI Bridge (For Mission Detail)
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
