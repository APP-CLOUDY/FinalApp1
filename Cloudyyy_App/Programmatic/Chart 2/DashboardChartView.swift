import SwiftUI
import Charts

@available(iOS 16.0, *)
struct DashboardChartView: View {

    let points: [DashboardChartPoint]
    
    @State private var animateBars = false
    @State private var animateOpacity: CGFloat = 0.0
    @State private var animateScale: CGFloat = 0.96

    private var totalRewards: Int { points.reduce(0) { $0 + $1.rewards } }
    private var totalTasks: Int   { points.reduce(0) { $0 + $1.tasks } }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                Spacer()   // pushes everything to the right

                Text("\(totalRewards) Rewards")
                    .foregroundColor(.blue.opacity(0.9))
                    .font(.system(size: 16, weight: .semibold))

                Text("\(totalTasks) Tasks")
                    .foregroundColor(.purple.opacity(0.9))
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal, 6)

            // MARK: - Chart
            Chart(points) { p in

                // BLUE Rewards
                BarMark(
                    x: .value("Day", p.label),
                    y: .value("Rewards", animateBars ? p.rewards : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.5)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(8)

                // PURPLE Tasks
                BarMark(
                    x: .value("Day", p.label),
                    y: .value("Tasks", animateBars ? p.tasks : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .purple.opacity(0.5)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(8)
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine().foregroundStyle(.white.opacity(0.10))
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.70))
                        .font(.system(size: 10))
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) {
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.95))
                        .font(.system(size: 12, weight: .medium))
                }
            }
            .chartPlotStyle { plot in
                plot.background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.05))
                )
            }
            .frame(height: 185)
            .padding(.horizontal, 4)
            .opacity(animateOpacity)
            .scaleEffect(animateScale)
            .animation(.easeInOut(duration: 0.30), value: animateOpacity)
            .animation(.spring(response: 0.45, dampingFraction: 0.78), value: animateScale)
            .animation(.spring(response: 0.50, dampingFraction: 0.75), value: animateBars)
        }
        .onAppear { animateIn() }
        .onChange(of: points) { _ in animateIn() }
    }

    // MARK: - Weekly ↔ Monthly Smooth Transition
    private func animateIn() {
        animateBars = false
        animateOpacity = 0.0
        animateScale = 0.96

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            animateOpacity = 1.0
            animateScale = 1.0

            withAnimation {
                animateBars = true
            }
        }
    }
}
