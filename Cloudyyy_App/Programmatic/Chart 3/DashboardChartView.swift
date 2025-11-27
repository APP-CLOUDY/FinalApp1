//import SwiftUI
//import Charts
//
//@available(iOS 16.0, *)
//struct DashboardChartView: View {
//    let points: [DashboardChartPoint]
//    
//    // Define colors
//    private let barBlue = Color(red: 70/255, green: 180/255, blue: 255/255)
//    private let barPurple = Color(red: 190/255, green: 120/255, blue: 255/255)
//    
//    var body: some View {
//        Chart(points) { point in
//            // 1. Bottom Bar (Tasks)
//            // We use raw values (point.tasks) here. No manual scaling needed.
//            BarMark(
//                x: .value("Day", point.label),
//                y: .value("Tasks", point.tasks)
//            )
//            .foregroundStyle(barBlue)
//            // Only round the bottom corners of the bottom bar
//            .clipShape(Corners(corner: [.bottomLeft, .bottomRight], radii: 6))
//            
//            // 2. Top Bar (Rewards)
//            // We stack this manually using yStart and yEnd to ensure control
//            BarMark(
//                x: .value("Day", point.label),
//                yStart: .value("Tasks", point.tasks),
//                yEnd: .value("Total", point.tasks + point.rewards)
//            )
//            .foregroundStyle(barPurple)
//            // Only round the top corners of the top bar
//            .clipShape(Corners(corner: [.topLeft, .topRight], radii: 6))
//        }
//        // Hide the Y Axis numbers if you want a cleaner look (optional)
//        .chartYAxis(.hidden)
//        // Add some padding internally so the bars don't touch the edges
//        .padding(.horizontal, 10)
//    }
//}
//
//// Helper for specific corner rounding (Clean visual stacking)
//struct Corners: Shape {
//    var corner: UIRectCorner
//    var radii: CGFloat
//    
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(
//            roundedRect: rect,
//            byRoundingCorners: corner,
//            cornerRadii: CGSize(width: radii, height: radii)
//        )
//        return Path(path.cgPath)
//    }
//}
//
//@available(iOS 16.0, *)
//struct DashboardChartPoint: Identifiable, Equatable {
//    let id = UUID()
//    let label: String
//    let rewards: Int
//    let tasks: Int
//}
