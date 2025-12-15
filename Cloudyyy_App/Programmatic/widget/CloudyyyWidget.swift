//
//  CloudyyyWidget.swift
//  Cloudyyy_App
//
//  Created by user@5 on 14/12/25.
//

import WidgetKit
import SwiftUI

// MARK: - 1. Data Model
// This represents the data passed from your main app to the widget
struct WidgetData: TimelineEntry {
    let date: Date
    let role: UserRole // .parent or .child
    let streakCount: Int
    let dailyProgress: Double // 0.0 to 1.0
    let childName: String
    // For Parent View:
    let childrenStatus: [ChildStatus]
}

struct ChildStatus: Identifiable {
    let id = UUID()
    let name: String
    let streak: Int
    let isDoneToday: Bool
}

enum UserRole {
    case parent
    case child
}

// MARK: - 2. The Main Widget Entry View
struct CloudyyyWidgetEntryView : View {
    var entry: WidgetData

    var body: some View {
        ZStack {
            // Shared Background
            ContainerRelativeShape()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.1, green: 0.12, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            if entry.role == .child {
                ChildStreakView(entry: entry)
            } else {
                ParentDashboardView(entry: entry)
            }
        }
    }
}

// MARK: - 3. Persona A: Child UI (Gamified)
struct ChildStreakView: View {
    var entry: WidgetData
    
    var body: some View {
        VStack(spacing: 8) {
            // Top: Greeting & Mascot
            HStack {
                Text("Hi \(entry.childName)!")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("☁️") // Your Mascot Icon
                    .font(.system(size: 24))
            }
            
            Spacer()
            
            // Center: BIG Streak Counter
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.orange)
                    .shadow(color: .orange.opacity(0.6), radius: 8, x: 0, y: 0)
                
                Text("\(entry.streakCount)")
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text("Day Streak")
                .font(.caption)
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.5))
            
            Spacer()
            
            // Bottom: Daily Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Today's Missions")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Text("\(Int(entry.dailyProgress * 100))%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.green)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.1))
                        Capsule().fill(Color.green)
                            .frame(width: geo.size.width * entry.dailyProgress)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(16)
    }
}

// MARK: - 4. Persona B: Parent UI (Monitoring)
struct ParentDashboardView: View {
    var entry: WidgetData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Family Status")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
            
            VStack(spacing: 10) {
                ForEach(entry.childrenStatus.prefix(3)) { child in
                    HStack {
                        // Status Dot
                        Circle()
                            .fill(child.isDoneToday ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                        
                        Text(child.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Small Streak Indicator
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                                .foregroundColor(child.streak > 0 ? .orange : .gray)
                            Text("\(child.streak)")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }
            Spacer()
        }
        .padding(16)
    }
}

// MARK: - 5. Preview Provider (To see both layouts)
struct CloudyyyWidget_Previews: PreviewProvider {
    static var previews: some View {
        // Preview 1: Child View
        CloudyyyWidgetEntryView(entry: WidgetData(
            date: Date(),
            role: .child,
            streakCount: 12,
            dailyProgress: 0.7,
            childName: "David",
            childrenStatus: []
        ))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        // Preview 2: Parent View
        CloudyyyWidgetEntryView(entry: WidgetData(
            date: Date(),
            role: .parent,
            streakCount: 0,
            dailyProgress: 0,
            childName: "",
            childrenStatus: [
                ChildStatus(name: "David", streak: 12, isDoneToday: true),
                ChildStatus(name: "Sarah", streak: 3, isDoneToday: false)
            ]
        ))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
// MARK: - 6. The Engine (Required to run on Simulator)
struct CloudyyyWidget: Widget {
    let kind: String = "CloudyyyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleProvider()) { entry in
            CloudyyyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Cloudyyy Streak")
        .description("Track your daily chore streak!")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// Simple Provider to feed dummy data to the Simulator
struct SimpleProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetData {
        WidgetData(date: Date(), role: .child, streakCount: 5, dailyProgress: 0.5, childName: "Preview", childrenStatus: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetData) -> Void) {
        let entry = WidgetData(date: Date(), role: .child, streakCount: 5, dailyProgress: 0.5, childName: "Preview", childrenStatus: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetData>) -> Void) {
        // Create a timeline that refreshes every hour
        let entry = WidgetData(
            date: Date(),
            role: .child, // CHANGE THIS to .parent to test Parent View
            streakCount: 12,
            dailyProgress: 0.8,
            childName: "David",
            childrenStatus: [
                ChildStatus(name: "David", streak: 12, isDoneToday: true),
                ChildStatus(name: "Sarah", streak: 3, isDoneToday: false)
            ]
        )
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}
