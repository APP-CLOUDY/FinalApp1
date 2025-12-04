import SwiftUI
import Charts

// MARK: - 1. The Data Model
@available(iOS 16.0, *)
struct DashboardChartPoint: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let rewards: Int
    let tasks: Int
}

// MARK: - 2. The Chart View
@available(iOS 16.0, *)
struct DashboardChartViews: View {
    let points: [DashboardChartPoint]
    
    // --- Colors matching the Screenshot ---
    // Bright Blue for the bottom bar (Tasks)
    private let taskBlue = Color(red: 64/255, green: 156/255, blue: 255/255)
    // Lavender Purple for the top bar (Rewards)
    private let rewardPurple = Color(red: 160/255, green: 110/255, blue: 255/255)
    
    // Calculate totals for the header
    var totalTasks: Int { points.map(\.tasks).reduce(0, +) }
    var totalRewards: Int { points.map(\.rewards).reduce(0, +) }
    
    var body: some View {
        VStack(spacing: 10) {
            
            // 1. Header Legend (Top Right)
            HStack(spacing: 16) {
                Spacer()
                
                // Rewards Legend (Matches Top Bar Color)
                HStack(spacing: 4) {
                    Text("\(totalRewards)")
                        .fontWeight(.bold)
                    Text("rewards")
                }
                .font(.system(size: 13))
                .foregroundColor(rewardPurple) // Purple text
                
                // Tasks Legend (Matches Bottom Bar Color)
                HStack(spacing: 4) {
                    Text("\(totalTasks)")
                        .fontWeight(.bold)
                    Text("Tasks")
                }
                .font(.system(size: 13))
                .foregroundColor(taskBlue) // Blue text
            }
            .padding(.trailing, 4) // Align with chart right edge
            
            // 2. The Chart
            Chart(points) { point in
                
                // Bottom Bar: Tasks
                BarMark(
                    x: .value("Day", point.label),
                    y: .value("Tasks", point.tasks),
                    width: .fixed(12) // Narrow bars
                )
                .foregroundStyle(taskBlue)
                .clipShape(Corners(corner: [.bottomLeft, .bottomRight], radii: 6))
                
                // Top Bar: Rewards (Stacked)
                BarMark(
                    x: .value("Day", point.label),
                    yStart: .value("Tasks", point.tasks),
                    yEnd: .value("Total", point.tasks + point.rewards),
                    width: .fixed(12) // Narrow bars
                )
                .foregroundStyle(rewardPurple)
                .clipShape(Corners(corner: [.topLeft, .topRight], radii: 6))
            }
            // 3. Axis Styling
            .chartYAxis {
                // Y-Axis on Right Side (.trailing)
                AxisMarks(position: .trailing, values: .automatic) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color.white.opacity(0.1)) // Faint horizontal grid
                    AxisValueLabel()
                        .foregroundStyle(Color.white.opacity(0.6)) // Light gray numbers
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    // Vertical separators
                    AxisGridLine()
                        .foregroundStyle(Color.white.opacity(0.1))
                    AxisValueLabel()
                        .foregroundStyle(Color.gray) // Day names (Mon, Tue)
                        .font(.caption)
                }
            }
        }
        // Padding inside the "Glass" container
        .padding(.top, 12)
        .padding(.bottom, 4)
        .padding(.horizontal, 12)
    }
}

// MARK: - 3. Helper for Custom Rounded Corners
struct Corners: Shape {
    var corner: UIRectCorner
    var radii: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corner,
            cornerRadii: CGSize(width: radii, height: radii)
        )
        return Path(path.cgPath)
    }
}
