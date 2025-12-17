import SwiftUI
import Charts

// MARK: - Data Model
@available(iOS 16.0, *)
struct DashboardChartPoint: Identifiable, Equatable {
    let id = UUID()
    let label: String      // Mon, Tue, Wed...
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

    // ✅ Ensure correct weekday order
    private var orderedPoints: [DashboardChartPoint] {
        points.sorted {
            weekdayIndex($0.label) < weekdayIndex($1.label)
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
                        x: .value("Day", point.label),
                        y: .value("Assigned", point.assigned),
                        width: .fixed(12)
                    )
                    .foregroundStyle(assignedColor)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 6)
                    )

                    // Completed (stacked top)
                    BarMark(
                        x: .value("Day", point.label),
                        yStart: .value("Assigned", point.assigned),
                        yEnd: .value("Total", point.assigned + point.completed),
                        width: .fixed(12)
                    )
                    .foregroundStyle(completedColor)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 6)
                    )
                }
                .chartYAxis {
                    AxisMarks(position: .trailing) {
                        AxisGridLine()
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel()
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                }
                .chartXAxis {
                    AxisMarks {
                        AxisGridLine()
                            .foregroundStyle(Color.white.opacity(0.1))
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

    // MARK: - Helpers
    private func weekdayIndex(_ day: String) -> Int {
        let order = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return order.firstIndex(of: day) ?? 0
    }
}

