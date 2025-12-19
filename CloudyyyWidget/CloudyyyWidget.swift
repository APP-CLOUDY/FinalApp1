import WidgetKit
import SwiftUI

// MARK: - 1. Data Model
struct ChoreEntry: TimelineEntry {
    let date: Date
    let choresDone: Int
    let totalChores: Int
    let streakDays: Int
    
    var progress: CGFloat {
        totalChores > 0 ? CGFloat(choresDone) / CGFloat(totalChores) : 0
    }
    
    var motivationText: String {
        if progress >= 1.0 { return "Legendary!" }
        if progress >= 0.5 { return "Keep going!" }
        return "You rock!"
    }
}

// MARK: - 2. The View (UI)
struct CloudyyyWidgetEntryView : View {
    var entry: Provider.Entry

    // Colors from your image
    let darkBackground = Color(hex: "0C0C0C")
    let deepBlue = Color(hex: "203B6F")
    
    // UI Accent Colors
    let cloudBlue = Color(red: 0.11, green: 0.61, blue: 0.96)
    let glassWhite = Color.white.opacity(0.15)

    var body: some View {
        HStack(spacing: 16) {
            
            // Left Side: Mascot Section
            VStack(spacing: 8) {
                ZStack {
                    // Glass Circle Base
                    Circle()
                        .fill(glassWhite)
                        .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Image("cloud")
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                }
                .frame(width: 70, height: 70)
                
                Text(entry.motivationText)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity)
            
            // Right Side: Stats
            VStack(alignment: .leading, spacing: 12) {
                
                // Streak Badge
                HStack(spacing: 6) {
                    ZStack {
                        Circle().fill(.orange.opacity(0.2)).frame(width: 28, height: 28)
                        Image(systemName: "flame.fill")
                            .foregroundStyle(LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom))
                            .font(.system(size: 14))
                    }
                    
                    VStack(alignment: .leading, spacing: -2) {
                        Text("\(entry.streakDays) DAY")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.orange)
                        Text("STREAK")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                // Progress Section
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .bottom) {
                        Text("Daily Goal")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(entry.choresDone)")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(cloudBlue)
                        Text("/ \(entry.totalChores)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    // Glassy Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                            
                            Capsule()
                                .fill(LinearGradient(colors: [cloudBlue.opacity(0.7), cloudBlue], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * entry.progress)
                            
                            // Glass Shine on Bar
                            Capsule()
                                .fill(.white.opacity(0.2))
                                .frame(width: max(0, (geo.size.width * entry.progress) - 8), height: 4)
                                .offset(x: 4, y: -3)
                        }
                    }
                    .frame(height: 12)
                }
            }
            .padding(.trailing, 4)
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        // APPLYING THE GRADIENT FROM YOUR IMAGE
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [darkBackground, deepBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - 3. Provider & Config (Standard)
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ChoreEntry {
        ChoreEntry(date: Date(), choresDone: 3, totalChores: 5, streakDays: 12)
    }
    func getSnapshot(in context: Context, completion: @escaping (ChoreEntry) -> ()) {
        completion(ChoreEntry(date: Date(), choresDone: 3, totalChores: 5, streakDays: 12))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ChoreEntry>) -> ()) {
        let entry = ChoreEntry(date: Date(), choresDone: 2, totalChores: 5, streakDays: 4)
        completion(Timeline(entries: [entry], policy: .atEnd))
    }
}

@main
struct CloudyyyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CloudyyyWidget", provider: Provider()) { entry in
            CloudyyyWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    CloudyyyWidget()
} timeline: {
    ChoreEntry(date: Date(), choresDone: 3, totalChores: 5, streakDays: 14)
}
