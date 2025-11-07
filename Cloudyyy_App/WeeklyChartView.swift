import UIKit

class WeeklyChartView: UIView {

    // MARK: - Data
    private let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let rewards: [CGFloat] = [12, 10, 8, 7, 14, 6, 9]
    private let tasks: [CGFloat] = [20, 17, 15, 13, 18, 10, 12]

    private let rewardsColor = UIColor.systemBlue
    private let tasksColor = UIColor.systemPurple.withAlphaComponent(0.8)

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // light gray card style background
        backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        layer.cornerRadius = 20
        layer.masksToBounds = true        // clip bars to rounded corner
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
        isOpaque = true                   // prevents white halo blending
    }

    // MARK: - Draw
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let maxBarHeight = rect.height * 0.6
        let barWidth: CGFloat = rect.width / CGFloat(dayLabels.count * 2)

        for (index, day) in dayLabels.enumerated() {
            let x = CGFloat(index) * barWidth * 2 + barWidth / 2
            let scale = maxBarHeight / 20   // normalize

            let rewardHeight = rewards[index] * scale
            let taskHeight = tasks[index] * scale

            // blue bar (rewards)
            let rewardRect = CGRect(
                x: x,
                y: rect.height - rewardHeight - 20,
                width: barWidth,
                height: rewardHeight
            )
            drawRoundedBar(in: rewardRect, color: rewardsColor, context: context)

            // purple overlay (tasks)
            let taskRect = CGRect(
                x: x,
                y: rect.height - taskHeight - 20,
                width: barWidth,
                height: taskHeight
            )
            drawRoundedBar(in: taskRect, color: tasksColor, context: context)

            // label
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            let labelRect = CGRect(x: x - barWidth/2, y: rect.height - 18, width: barWidth * 2, height: 16)
            day.draw(in: labelRect, withAttributes: attrs)
        }
    }

    private func drawRoundedBar(in rect: CGRect, color: UIColor, context: CGContext) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 6)
        context.setFillColor(color.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
    }
}
