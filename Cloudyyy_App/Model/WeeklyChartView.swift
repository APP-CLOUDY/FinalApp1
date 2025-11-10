import UIKit

class WeeklyChartView: UIView {

    private var hasDrawn = false
    private var isWeekly = true
    private var contentLayer = CALayer()

    // MARK: - Data
    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let weeklyRewards: [CGFloat] = [12, 10, 8, 7, 14, 6, 9]
    private let weeklyTasks: [CGFloat] = [20, 17, 15, 13, 18, 10, 12]
    private let monthlyRewards: [CGFloat] = (1...30).map { _ in CGFloat.random(in: 6...14) }
    private let monthlyTasks: [CGFloat] = (1...30).map { _ in CGFloat.random(in: 10...20) }

    // MARK: - Colors
    private let blue = UIColor.systemBlue
    private let violet = UIColor.systemPurple
    private let gridColor = UIColor.black.withAlphaComponent(0.08)
    private let textColor = UIColor.black.withAlphaComponent(0.85)
    private let chartBackground = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        if !hasDrawn {
            setupBackground()
            drawChart()
            hasDrawn = true
        }
    }

    func updateMode(isWeekly: Bool) {
        self.isWeekly = isWeekly
        drawChart()
    }

    // MARK: - Chart Drawing
    private func drawChart() {
        contentLayer.removeFromSuperlayer()
        contentLayer = CALayer()
        contentLayer.frame = bounds
        layer.addSublayer(contentLayer)

        let rewards = isWeekly ? weeklyRewards : monthlyRewards
        let tasks = isWeekly ? weeklyTasks : monthlyTasks
        let labels = isWeekly ? weekDays : (1...30).map { "\($0)" }

        let barCount = rewards.count
        let leftPadding: CGFloat = 35
        let rightPadding: CGFloat = 20
        let bottomPadding: CGFloat = 35
        let topPadding: CGFloat = 25

        let chartWidth = bounds.width - leftPadding - rightPadding
        let chartHeight = (bounds.height - topPadding - bottomPadding) * 0.85 // slightly shorter bars
        let spacing = chartWidth / CGFloat(barCount)
        let barWidth = spacing * 0.35
        let originY = bounds.height - bottomPadding
        let maxValue = max((rewards + tasks).max() ?? 1, 20)

        // 🩶 Grid Lines
        let gridLayer = CAShapeLayer()
        let gridPath = UIBezierPath()
        let stepCount = 4
        for i in 0...stepCount {
            let y = originY - (CGFloat(i) / CGFloat(stepCount)) * chartHeight
            gridPath.move(to: CGPoint(x: leftPadding, y: y))
            gridPath.addLine(to: CGPoint(x: bounds.width - rightPadding, y: y))

            // Y-axis labels
            let label = CATextLayer()
            label.string = "\(Int((CGFloat(i) / CGFloat(stepCount)) * maxValue))"
            label.fontSize = 11
            label.alignmentMode = .right
            label.foregroundColor = textColor.cgColor
            label.contentsScale = UIScreen.main.scale
            label.frame = CGRect(x: bounds.width - rightPadding - 25, y: y - 7, width: 25, height: 14)
            contentLayer.addSublayer(label)
        }
        gridLayer.path = gridPath.cgPath
        gridLayer.strokeColor = gridColor.cgColor
        gridLayer.lineWidth = 1
        contentLayer.addSublayer(gridLayer)

        // 📊 Bars
        for i in 0..<barCount {
            let totalHeight = (tasks[i] + rewards[i]) / maxValue * chartHeight
            let heightScale: CGFloat = 0.9 // ensures bars stay below top grid line
            let adjustedChartHeight = chartHeight * heightScale

            let taskHeight = (tasks[i] / maxValue) * adjustedChartHeight
            let rewardHeight = (rewards[i] / maxValue) * adjustedChartHeight
            let x = leftPadding + CGFloat(i) * spacing

            // Blue base (tasks)
            let taskRect = CGRect(x: x, y: originY - taskHeight, width: barWidth, height: taskHeight)
            let taskPath = UIBezierPath(roundedRect: taskRect, cornerRadius: barWidth / 2)
            let taskLayer = CAShapeLayer()
            taskLayer.path = taskPath.cgPath
            taskLayer.fillColor = blue.cgColor
            contentLayer.addSublayer(taskLayer)

            // Violet overlay (rewards)
            let rewardRect = CGRect(x: x, y: originY - taskHeight - rewardHeight, width: barWidth, height: rewardHeight)
            let rewardPath = UIBezierPath(roundedRect: rewardRect, cornerRadius: barWidth / 2)
            let rewardLayer = CAShapeLayer()
            rewardLayer.path = rewardPath.cgPath
            rewardLayer.fillColor = violet.cgColor
            contentLayer.addSublayer(rewardLayer)

            // Bottom labels
            if isWeekly || i % 3 == 0 {
                let textLayer = CATextLayer()
                textLayer.string = labels[i]
                textLayer.fontSize = 11
                textLayer.alignmentMode = .center
                textLayer.foregroundColor = textColor.cgColor
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.frame = CGRect(x: x - barWidth / 2, y: originY + 4, width: spacing, height: 14)
                contentLayer.addSublayer(textLayer)
            }
        }

        addLegend()
    }

    // MARK: - Legend
    private func addLegend() {
        let legendY: CGFloat = 6

        let blueDot = CALayer()
        blueDot.backgroundColor = blue.cgColor
        blueDot.cornerRadius = 4
        blueDot.frame = CGRect(x: bounds.width - 130, y: legendY, width: 8, height: 8)
        contentLayer.addSublayer(blueDot)

        let violetDot = CALayer()
        violetDot.backgroundColor = violet.cgColor
        violetDot.cornerRadius = 4
        violetDot.frame = CGRect(x: bounds.width - 70, y: legendY, width: 8, height: 8)
        contentLayer.addSublayer(violetDot)

        let blueText = CATextLayer()
        blueText.string = "Tasks"
        blueText.fontSize = 12
        blueText.foregroundColor = blue.cgColor
        blueText.contentsScale = UIScreen.main.scale
        blueText.frame = CGRect(x: bounds.width - 120, y: legendY - 3, width: 45, height: 14)
        contentLayer.addSublayer(blueText)

        let violetText = CATextLayer()
        violetText.string = "Rewards"
        violetText.fontSize = 12
        violetText.foregroundColor = violet.cgColor
        violetText.contentsScale = UIScreen.main.scale
        violetText.frame = CGRect(x: bounds.width - 60, y: legendY - 3, width: 60, height: 14)
        contentLayer.addSublayer(violetText)
    }

    // MARK: - Background Setup
    private func setupBackground() {
        backgroundColor = chartBackground
        layer.cornerRadius = 18
        layer.masksToBounds = true
    }
}
