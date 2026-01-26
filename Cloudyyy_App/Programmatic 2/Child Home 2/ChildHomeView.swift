//import SwiftUI
//
//struct ChildHomeView: View {
//    // We reuse your existing ViewModel which handles Physics & Data
//    @StateObject private var vm = CloudyViewModel()
//    
//    // Animation state for the center mascot
//    @State private var mascotBreathing = false
//    
//    var body: some View {
//        ZStack {
//            // 1. Background Gradient (Matches your Theme)
//            LinearGradient(
//                gradient: Gradient(colors: [.bgGradientStart, .bgGradientEnd]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
//            
//            // 2. Main Content
//            VStack(spacing: 0) {
//                
//                // A. Header Section
//                headerSection
//                    .padding(.horizontal, 20)
//                    .padding(.top, 10)
//                
//                Spacer()
//                
//                // B. The "Solar System" (Mascot + Bubbles)
//                // We use a ZStack to layer bubbles over/around the mascot
//                ZStack {
//                    // 1. The Central Mascot (The Sun)
//                    Image("cloudyy_logo") // Make sure this asset exists
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 160, height: 160)
//                        .scaleEffect(mascotBreathing ? 1.05 : 1.0)
//                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: mascotBreathing)
//                        .onAppear { mascotBreathing = true }
//                        // Add a glow effect behind mascot
//                        .background(
//                            Circle()
//                                .fill(Color.purple.opacity(0.3))
//                                .frame(width: 200, height: 200)
//                                .blur(radius: 20)
//                        )
//                    
//                    // 2. The Orbiting Bubbles (The Planets)
//                    // We only show bubbles if we are in 'cluster' mode
//                    if case .missionCluster = vm.currentState {
//                        ForEach(vm.missions) { mission in
//                            if !vm.completedMissionIDs.contains(mission.id) {
//                                FloatingMissionItem(mission: mission)
//                                    .onTapGesture {
//                                        withAnimation(.spring()) {
//                                            vm.currentState = .missionDetail(mission)
//                                        }
//                                    }
//                            }
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity)
//                .frame(height: 450) // Defined area for physics bounds
//                .contentShape(Rectangle()) // Ensures touch areas work
//                
//                Spacer()
//                
//                // C. Bottom Insight Card (Replacing the old middle card)
//                insightCard
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 20)
//            }
//            .blur(radius: vm.currentState == .missionCluster ? 0 : 10) // Blur home when details open
//            
//            // 3. Detail Overlay
//            // When a bubble is tapped, this overlay appears
//            if case .missionDetail(let mission) = vm.currentState {
//                MissionDetailOverlay(vm: vm, mission: mission)
//                    .transition(.move(edge: .bottom))
//                    .zIndex(2)
//            }
//        }
//        .onAppear {
//            // Force the state to Cluster to start Physics
//            vm.currentState = .missionCluster
//            // Load data from Supabase
//            Task { await vm.loadMissions() }
//        }
//    }
//    
//    // MARK: - Subviews
//    
//    private var headerSection: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Hello Rob.") // Replace "Rob" with dynamic name if available
//                    .font(.system(size: 32, weight: .bold))
//                    .foregroundColor(.white)
//                
//                Text("Tap a bubble to start!")
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(.white.opacity(0.7))
//            }
//            
//            Spacer()
//            
//            // Icons
//            HStack(spacing: 16) {
//                Button(action: {}) {
//                    Image(systemName: "bell.fill")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                }
//                
//                Button(action: {}) {
//                    Image(systemName: "person.circle.fill")
//                        .font(.largeTitle)
//                        .foregroundColor(.white)
//                }
//            }
//        }
//    }
//    
//    private var insightCard: some View {
//        HStack(spacing: 15) {
//            // Icon Container
//            ZStack {
//                Circle()
//                    .fill(Color.blue.opacity(0.2))
//                    .frame(width: 50, height: 50)
//                
//                Image(systemName: "guitars.fill") // Or "cloudyy_guitar"
//                    .foregroundColor(.blue)
//                    .font(.system(size: 24))
//            }
//            
//            // Text
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Your cleanup yesterday created 15 mins of calm for Mom.")
//                    .font(.system(size: 14))
//                    .foregroundColor(.black.opacity(0.8))
//                    .fixedSize(horizontal: false, vertical: true)
//                
//                Text("That's your power!")
//                    .font(.system(size: 14, weight: .bold))
//                    .foregroundColor(.black)
//            }
//            
//            Spacer()
//        }
//        .padding(16)
//        .background(Color.white.opacity(0.95))
//        .cornerRadius(20)
//        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
//    }
//}
//
//// MARK: - Detail Overlay Wrapper
//// This wraps your existing MissionDetailView to make it look like a popup
//struct MissionDetailOverlay: View {
//    @ObservedObject var vm: CloudyViewModel
//    let mission: Mission
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.4).ignoresSafeArea()
//                .onTapGesture {
//                    withAnimation { vm.currentState = .missionCluster }
//                }
//            
//            // We reuse the existing logic but constrain the frame
//            MissionDetailView(
//                currentState: $vm.currentState,
//                mission: mission,
//                completedMissionIDs: $vm.completedMissionIDs,
//                dissolvingMissionID: $vm.dissolvingMissionID
//            )
//            .background(Color.bgGradientEnd)
//            .cornerRadius(24)
//            .padding(.top, 60)
//            .ignoresSafeArea(edges: .bottom)
//        }
//    }
//}
//
//struct ChildHomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChildHomeView()
//    }
//}
