import SwiftUI
import Charts

@available(iOS 16.0, *)
struct DashboardChartView: View {

    let points: [DashboardChartPoint]
    
    @State private var animateBars = false
    @State private var animateOpacity: CGFloat = 0.0
    @State private var animateScale: CGFloat = 0.96

    // Apple Fitness Style Gradient Colors
    private let appleBlueBottom = Color(red: 60/255, green: 130/255, blue: 255/255)     // Electric Blue
    private let appleBlueTop    = Color(red: 170/255, green: 140/255, blue: 255/255)    // Soft Violet

    private var totalRewards: Int { points.reduce(0) { $0 + $1.rewards } }
    private var totalTasks: Int   { points.reduce(0) { $0 + $1.tasks } }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Header Numbers (Right-Aligned)
            HStack {
                Spacer()
                Text("\(totalRewards) Rewards")
                    .foregroundColor(appleBlueBottom.opacity(0.95))
                    .font(.system(size: 16, weight: .semibold))

                Text("\(totalTasks) Tasks")
                    .foregroundColor(appleBlueTop.opacity(0.95))
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal, 6)

            // MARK: - Chart
            Chart(points) { p in

                // -------------------------------
                // REWARDS (Bold Apple Gradient)
                // -------------------------------
                BarMark(
                    x: .value("Day", p.label),
                    y: .value("Rewards", animateBars ? p.rewards : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            appleBlueBottom.opacity(0.95),
                            appleBlueTop.opacity(0.95)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(8)

                // -------------------------------
                // TASKS (Softer Apple Gradient)
                // -------------------------------
                BarMark(
                    x: .value("Day", p.label),
                    y: .value("Tasks", animateBars ? p.tasks : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            appleBlueBottom.opacity(0.55),
                            appleBlueTop.opacity(0.55)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(8)
            }

            // MARK: - Axis Styling
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.10))
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

            // Chart background rounded style
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

    // MARK: - Animations
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

