import SwiftUI
import Charts

// MARK: - Data Model
@available(iOS 16.0, *)
struct DashboardChartPoint: Identifiable, Equatable {
    let id = UUID()
    let label: String      // "Mon", "Tue" OR "Week 1", "Week 2"
    let completed: Int
    let assigned: Int
}

// MARK: - Chart View
@available(iOS 16.0, *)
struct DashboardChartView: View {

    let points: [DashboardChartPoint]
    
    // Colors
    private let assignedColor = Color(red: 64/255, green: 156/255, blue: 255/255)
    private let completedColor = Color(red: 160/255, green: 110/255, blue: 255/255)

    // Totals (legend)
    private var totalAssigned: Int {
        points.map(\.assigned).reduce(0, +)
    }

    private var totalCompleted: Int {
        points.map(\.completed).reduce(0, +)
    }

    // ✅ FIXED: Robust Sorting for Days AND Weeks
    private var orderedPoints: [DashboardChartPoint] {
        return points.sorted { a, b in
            // 1. Try to sort by Weekday Index (Mon, Tue...)
            if let indexA = weekdayIndex(a.label), let indexB = weekdayIndex(b.label) {
                return indexA < indexB
            }
            
            // 2. Fallback: Sort by String (Works for "Week 1", "Week 2", etc.)
            return a.label.localizedStandardCompare(b.label) == .orderedAscending
        }
    }

    var body: some View {
        VStack(spacing: 10) {

            // MARK: Legend
            HStack(spacing: 16) {
                Spacer()

                HStack(spacing: 4) {
                    Text("\(totalAssigned)").fontWeight(.bold)
                    Text("Assigned")
                }
                .font(.system(size: 13))
                .foregroundColor(assignedColor)

                HStack(spacing: 4) {
                    Text("\(totalCompleted)").fontWeight(.bold)
                    Text("Completed")
                }
                .font(.system(size: 13))
                .foregroundColor(completedColor)
            }
            .padding(.trailing, 4)

            // MARK: Chart
            if orderedPoints.isEmpty {
                Text("No activity yet")
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.vertical, 40)
            } else {
                Chart(orderedPoints) { point in

                    // Assigned (bottom)
                    BarMark(
                        x: .value("Period", point.label),
                        y: .value("Assigned", point.assigned),
                        width: .fixed(16) // Slightly wider
                    )
                    .foregroundStyle(assignedColor)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                    // Completed (stacked top)
                    BarMark(
                        x: .value("Period", point.label),
                        yStart: .value("Assigned", point.assigned),
                        yEnd: .value("Total", point.assigned + point.completed),
                        width: .fixed(16)
                    )
                    .foregroundStyle(completedColor)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .chartYAxis {
                    AxisMarks(position: .trailing) {
                        AxisGridLine().foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel().foregroundStyle(Color.white.opacity(0.6))
                    }
                }
                .chartXAxis {
                    AxisMarks {
                        AxisValueLabel()
                            .foregroundStyle(Color.gray)
                            .font(.caption)
                    }
                }
                .animation(.easeOut(duration: 0.35), value: orderedPoints)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 4)
        .padding(.horizontal, 12)
        .environment(\.colorScheme, .dark)
    }

    // MARK: - Helper: Returns Index or Nil
    private func weekdayIndex(_ day: String) -> Int? {
        let order = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return order.firstIndex(of: day)
    }
}
