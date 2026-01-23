import SwiftUI

// ⚠️ NOTE: 'struct Mission' has been REMOVED.
// It now uses the 'class Mission' defined in CloudyModels.swift

// MARK: - 1. Welcome View
struct WelcomeView: View {
    @Binding var currentState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Image("cloudyy_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .shadow(color: .white.opacity(0.15), radius: 15)
                    .padding(.top, 40)
               
                ChatBubbleContainer {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                            .font(.system(size: 18))
                        Text("Hi, Lets Complete all Mission")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.black.opacity(0.7))
                    }
                }
               
                ChatBubbleContainer {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.purple)
                                .font(.system(size: 18))
                            Text("I got you some missions for you today.\nWant to see them ??")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.black.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(4)
                        }
                       
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.spring()) { currentState = .missionCluster }
                            }) {
                                Text("Yes, show me!")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.darkButtonNavy)
                                    .cornerRadius(14)
                            }
                            
                            Button(action: {}) {
                                Text("Maybe later")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.darkButtonNavy.opacity(0.6))
                                    .cornerRadius(14)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
}

// MARK: - 2. Cluster View
struct MissionClusterView: View {
    @Binding var currentState: AppState
    let missions: [Mission]
    @Binding var completedMissionIDs: Set<UUID>
    @Binding var dissolvingMissionID: UUID?
    let isLoading: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
               
                ChatBubbleContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "sparkles").foregroundColor(.purple)
                            Text("Here are your tasks for today!")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.black.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 20)
               
                Text("Tap a bubble to start")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.top, 15)
               
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(1.5)
                        Spacer()
                    }
                    .padding(.top, 50)
                } else if missions.isEmpty {
                    Text("No missions found for today!\nRelax & Enjoy ☁️")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                } else {
                    // Floating Bubbles Area
                    ZStack {
                        Image("cloudBasket")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 170)
                            .offset(x: -80, y: -120)
                            .opacity(0.5)
                       
                        ForEach(missions) { mission in
                            if !completedMissionIDs.contains(mission.id) {
                                if mission.id == dissolvingMissionID {
                                    DissolvingBubble(mission: mission) {
                                        completedMissionIDs.insert(mission.id)
                                        dissolvingMissionID = nil
                                    }
                                    .offset(x: mission.x, y: mission.y)
                                } else {
                                    FloatingMissionItem(mission: mission)
                                        .onTapGesture {
                                            withAnimation(.easeOut) { currentState = .missionDetail(mission) }
                                        }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 500)
                }
            }
            .padding(.top, 20)
        }
    }
}

// MARK: - 3. Detail View
struct MissionDetailView: View {
    @Binding var currentState: AppState
    let mission: Mission
    @Binding var completedMissionIDs: Set<UUID>
    @Binding var dissolvingMissionID: UUID?
    
    // Logic States
    @State private var showCamera = false
    @State private var showSourceSelection = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var capturedImage: UIImage?
    @State private var isUploading = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                   
                    // Chat Bubble
                    ChatBubbleContainer {
                        HStack {
                            Image(systemName: "sparkles").foregroundColor(.purple)
                            Text(mission.requiresPhoto ? "I need a photo proof for this one!" : "Great Choice , Lets do it !")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.black.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 20)
                   
                   
                    // ... (Chat Bubble code above remains the same)

                                        Text("Mission")
                                            .font(.title3.bold())
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 24)
                                            .padding(.bottom, -15)
                                        
                                        // MARK: - 🔥 UPDATED GLASSY MISSION CARD
                                        HStack(alignment: .top, spacing: 16) {
                                            
                                            // 1. Left Accent Bar (Pill Shape)
                                            Capsule()
                                                .fill(mission.color) // Uses the mission's dynamic color
                                                .frame(width: 5)
                                                .padding(.vertical, 4) // Slight inset from top/bottom
                                            
                                            // 2. Center Content (Title & Details)
                                            VStack(alignment: .leading, spacing: 6) {
                                                // Title
                                                Text(mission.title.replacingOccurrences(of: "\n", with: " "))
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .lineLimit(2)
                                                
                                                // Points & Time Row
                                                HStack(spacing: 6) {
                                                    // Note: If your Mission class has a 'points' property, use: "\(mission.points)"
                                                    Text("40 Points")
                                                        .fontWeight(.medium)
                                                    
                                                    Text("•")
                                                    
                                                    Text("Due \(mission.time)")
                                                }
                                                .font(.system(size: 14))
                                                .foregroundColor(.white.opacity(0.6)) // Light grey for metadata
                                                
                                                // Folder / Category Row
                                                HStack(spacing: 6) {
                                                    Image(systemName: "folder")
                                                    Text("General") // You can swap this with mission.category if available
                                                }
                                                .font(.system(size: 13))
                                                .foregroundColor(.white.opacity(0.5))
                                            }
                                            
                                            Spacer()
                                            
                                            // 3. Right Icon (Hourglass)
                                            Image(systemName: "hourglass")
                                                .font(.system(size: 22))
                                                .foregroundColor(mission.color) // Matches the accent bar
                                                .padding(.top, 4)
                                        }
                                        .padding(16) // Padding inside the card
                                        .background(
                                            // ✨ The Glassy Dark Background
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.black.opacity(0.3)) // Dark semi-transparent background
                                        )
                                        .overlay(
                                            // ✨ Subtle White Border for "Glass" edge
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                        .padding(.horizontal, 20) // Padding from screen edges

                                        // ... (Photo Preview code below remains the same)
                   
                    // Photo Preview (Shows image if taken)
                    if let img = capturedImage {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 180)
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity)
                           
                            Button(action: { capturedImage = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .background(Circle().fill(Color.white))
                                    .font(.title2)
                            }
                            .padding(8)
                        }
                        .padding(.horizontal, 20)
                    }
                   
                    // Decoration & Submit Button Area
                    ZStack(alignment: .bottomTrailing) {
                        // The Cloud Umbrella Image
                        Image("cloudUmbrella")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 170)
                            .padding(.trailing, 20)
                       
                        // Speech Bubble decoration
                        ZStack(alignment: .bottomTrailing) {
                            Text("Let me know, When\nyou are done!")
                                .font(.system(size: 14, weight: .bold))
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 18)
                                .background(Color.white)
                                .cornerRadius(20)
                           
                            Image(systemName: "arrowtriangle.down.fill")
                                .resizable()
                                .frame(width: 18, height: 12)
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(-30))
                                .offset(x: -15, y: 8)
                        }
                        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
                        .offset(x: -95, y: -100)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                   
                    // Buttons
                    HStack(spacing: 16) {
                        // Done/Submit Button
                        Button(action: handleDoneTap) {
                            HStack {
                                if isUploading {
                                    ProgressView().tint(.white)
                                    Text(" Uploading...")
                                } else {
                                    if mission.requiresPhoto && capturedImage == nil {
                                        Text("Add Photo 🖼️")
                                    } else if capturedImage != nil {
                                        Text("Submit")
                                    } else {
                                        Text("Done!")
                                    }
                                }
                            }
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.darkButtonNavy)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.buttonStroke, lineWidth: 1))
                            .cornerRadius(16)
                        }
                        .disabled(isUploading)
                       
                        Button(action: { withAnimation { currentState = .missionCluster } }) {
                            Text("Back")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.darkButtonNavy)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.buttonStroke, lineWidth: 1))
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .padding(.top, 20)
            }
            .blur(radius: isUploading ? 2 : 0)
        }
        // 1. The Menu (Camera or Library)
        .confirmationDialog("Choose Photo Source", isPresented: $showSourceSelection, titleVisibility: .visible) {
            Button("Camera") {
                self.sourceType = .camera
                self.showCamera = true
            }
            Button("Photo Library") {
                self.sourceType = .photoLibrary
                self.showCamera = true
            }
            Button("Cancel", role: .cancel) {}
        }
        // 2. The Actual Picker
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(selectedImage: $capturedImage, sourceType: sourceType)
                .ignoresSafeArea()
        }
    }
    
    func handleDoneTap() {
        // If photo required but not taken, Ask for Photo
        if mission.requiresPhoto && capturedImage == nil {
            showSourceSelection = true // 👈 Trigger the menu
            return
        }
        // Otherwise, submit
        startSubmissionProcess()
    }
    
    func startSubmissionProcess() {
        isUploading = true
        Task {
            do {
                var finalPhotoUrl: String? = nil
               
                if let img = capturedImage, let childId = ChildSessionManager.shared.currentChildId {
                    finalPhotoUrl = try await ChildHomeService.shared.uploadProof(image: img, childId: childId)
                }
               
                // ✅ CORRECTED: Use 'approvalRequired' (camelCase from Class)
                try await ChildHomeService.shared.submitTask(
                    taskId: mission.id,
                    photoUrl: finalPhotoUrl,
                    approvalRequired: mission.approvalRequired
                )
               
                await navigateBackToHome()
            } catch {
                print("Error submitting: \(error)")
                await navigateBackToHome()
            }
        }
    }
    
    @MainActor
    func navigateBackToHome() {
        isUploading = false
        completedMissionIDs.insert(mission.id)
        dissolvingMissionID = mission.id
        withAnimation {
            currentState = .missionCluster
        }
        NotificationCenter.default.post(name: .taskDidComplete, object: nil)
    }
}
