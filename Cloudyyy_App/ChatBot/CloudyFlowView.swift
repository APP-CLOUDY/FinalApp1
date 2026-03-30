import SwiftUI

struct CloudyFlowView: View {
    @StateObject private var vm = CloudyViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.bgGradientStart, .bgGradientEnd]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Button(action: vm.goBack) {
                            Image(systemName: "chevron.left")
                                .font(.title2.bold())
                                .foregroundColor((vm.currentState == .chatWelcome && vm.chatHistory.isEmpty) ? .clear : .white)
                        }
                        .disabled(vm.currentState == .chatWelcome && vm.chatHistory.isEmpty)
                        
                        Text("Cloudyyy")
                            .font(.system(size: 30, weight: .bold)) // Unified size
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20) // Unified leading padding
                    .padding(.top, 16)        // Unified top padding
                    .padding(.bottom, 8)
                    
                    Rectangle().fill(Color.white.opacity(0.15)).frame(height: 0.5)
                }
                
                // Content
                ZStack {
                    if vm.chatHistory.isEmpty {
                        switch vm.currentState {
                        case .chatWelcome:
                            WelcomeView(currentState: $vm.currentState)
                                .transition(.move(edge: .leading))
                        case .missionCluster:
                            MissionClusterView(
                                currentState: $vm.currentState,
                                missions: vm.missions,
                                completedMissionIDs: $vm.completedMissionIDs,
                                dissolvingMissionID: $vm.dissolvingMissionID,
                                isLoading: vm.isLoading
                            )
                        case .missionDetail(let mission):
                            MissionDetailView(
                                currentState: $vm.currentState,
                                mission: mission,
                                completedMissionIDs: $vm.completedMissionIDs,
                                dissolvingMissionID: $vm.dissolvingMissionID
                            )
                        }
                    } else {
                        AIChatScrollView(messages: vm.chatHistory, isThinking: vm.isAIThinking)
                    }
                }
                .animation(.spring(), value: vm.currentState)
                
                Spacer()
                
                // Input Bar
                CloudyInputBar(text: $vm.textInput, isThinking: vm.isAIThinking, onSend: vm.sendMessage)
            }
        }
        .task { await vm.loadMissions() }
        .onTapGesture { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
        .toolbar(.hidden, for: .navigationBar)
    }
}
