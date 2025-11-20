// KidCoordinator.swift
// Cloudyyy_App
//
// Centralized KidCoordinator with mock data for Home / Progress / Schedule / Rewards / Approvals.

import Foundation
import UIKit

// ------------------------------
// MARK: - Child & Data Models (Source of Truth)
// ------------------------------

// All data models MUST be defined ONCE here or in their own specific file.
// Since you included them in KidCoordinator, we will define them here.

public struct KidProfile: Codable, Identifiable, Hashable {
    public let id: String
    public let displayName: String
}

public struct HomeDashboardOverview {
    public let completedMissionsCount: Int
    public let totalMissionsCount: Int
    public let redeemedStatusText: String
}

public struct HomePendingItems {
    public let totalPendingItems: Int
}

public struct HomeAssignedRewards {
    public let totalAssignedRewards: Int
}

public struct HomeTimelinePoint {
    public let dayLabel: String
    public let rewardCount: Int
    public let taskCount: Int
}

public struct ProgressMilestone {
    public let headline: String
    public let detail: String
}

public struct ProgressMetric {
    public let metricTitle: String
    public let completionProgress: Float
    public let trailingText: String
}

public struct ProgressSnapshot {
    public let completionRatio: CGFloat
    public let completedTasksDescription: String
    public let pointsForTodayText: String
    public let cumulativePointsText: String
    public let milestones: [ProgressMilestone]
    public let effortMetrics: [ProgressMetric]
}

public struct AgendaEntry {
    public let title: String
    public let time: String
    public let category: String
    public let status: String
    public let date: String      // "YYYY-MM-DD"
}

public struct RewardsHeaderSummary {
    public let activeRewardsCount: Int
    public let weeklyStarsEarned: Int
    public let totalStarsEarned: Int
}

public struct RewardCategorySummaryItem {
    public let title: String
    public let subtitle: String
    public let systemIconName: String
}

struct RewardDetailRow {
    let id: String
    let title: String
    let subtitle: String
    let requiredPoints: Int
    let imageName: String?
    let isCurrentlyActive: Bool
}

public struct ApprovalRequestItem {
    public let title: String
    public let subtitle: String
    public let requestedDate: String
    public let stars: Int
    public let type: String
}

// ------------------------------
// MARK: - KidCoordinator (singleton)
// ------------------------------
final class KidCoordinator {

    static let shared = KidCoordinator()
    static let childDidChangeNotification = Notification.Name("KidCoordinator.childDidChangeNotification")

    private(set) var availableKids: [KidProfile] = [
        KidProfile(id: "kid_bob", displayName: "Bob"),
        KidProfile(id: "kid_jonesh", displayName: "Jonesh"),
        KidProfile(id: "kid_aisha", displayName: "Aisha")
    ]

    var focusedChild: KidProfile? {
        didSet { broadcastChildChange() }
    }

    private init() {
        if focusedChild == nil {
            focusedChild = availableKids.first
        }
    }

    private func broadcastChildChange() {
        NotificationCenter.default.post(name: KidCoordinator.childDidChangeNotification, object: focusedChild)
    }

    // MARK: - Data Fetchers (All your mock data implementations below)
    
    // Re-pasting the critical 'schedule' function for reference, now renamed to use AgendaEntry:
    func schedule(for childIdentifier: String) -> [AgendaEntry] {
        let workingCalendar = Calendar.current
        let currentMoment = Date()
        let currentComponents = workingCalendar.dateComponents([.year, .month], from: currentMoment)
        guard let firstDayOfMonth = workingCalendar.date(from: currentComponents) else { return [] }

        func formattedDateString(forDay day: Int) -> String {
            guard let computedDate = workingCalendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) else { return "" }
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd"
            return format.string(from: computedDate)
        }
        let todayFormattedString = formattedDateString(forDay: workingCalendar.component(.day, from: currentMoment))

        switch childIdentifier {
        case "kid_bob":
            return [
                AgendaEntry(title: "Do the Homework", time: "06:00 AM", category: "Habits", status: "Not Done", date: formattedDateString(forDay: 8)),
                AgendaEntry(title: "Math Practice", time: "07:30 AM", category: "Study", status: "In progress", date: todayFormattedString),
                AgendaEntry(title: "Brush Teeth", time: "09:00 AM", category: "Habits", status: "Completed", date: todayFormattedString),
                AgendaEntry(title: "Piano Practice", time: "03:00 PM", category: "Hobby", status: "Not Done", date: formattedDateString(forDay: 12)),
                AgendaEntry(title: "Reading", time: "08:30 PM", category: "Habits", status: "In progress", date: formattedDateString(forDay: 16)),
                AgendaEntry(title: "Draw - Art", time: "05:00 PM", category: "Hobby", status: "Completed", date: formattedDateString(forDay: 16)),
                AgendaEntry(title: "Help with Chores", time: "04:00 PM", category: "Chores", status: "Not Done", date: formattedDateString(forDay: 20))
            ]
        case "kid_jonesh":
            return [
                AgendaEntry(title: "Brush Teeth", time: "07:00 AM", category: "Habits", status: "Completed", date: todayFormattedString),
                AgendaEntry(title: "Practice Piano", time: "05:00 PM", category: "Hobby", status: "In progress", date: formattedDateString(forDay: 16)),
                AgendaEntry(title: "Homework Math", time: "06:30 PM", category: "Study", status: "Not Done", date: formattedDateString(forDay: 16))
            ]
        default:
            return [
                AgendaEntry(title: "Read a Book", time: "06:30 PM", category: "Habits", status: "Not Done", date: todayFormattedString)
            ]
        }
    }
    
    // ... (End of KidCoordinator implementation) ...
    
    // MARK: - Dummy functions for other screens (Included here for compilation)
    func homeData(for childIdentifier: String) -> (overview: HomeDashboardOverview, pending: HomePendingItems, allocated: HomeAssignedRewards, weeklyChart: [HomeTimelinePoint]) { fatalError() }
    func monthlyChartAggregated(for childIdentifier: String) -> [HomeTimelinePoint] { fatalError() }
    func dataForKid(_ childIdentifier: String) -> ProgressSnapshot { fatalError() }
    func rewardsSummary(for childIdentifier: String) -> RewardsHeaderSummary { fatalError() }
    func rewardCategories(for childIdentifier: String) -> [RewardCategorySummaryItem] { fatalError() }
    func quickRewards(for childIdentifier: String) -> [RewardDetailRow] { fatalError() }
    func dreamItRewards(for childIdentifier: String) -> [RewardDetailRow] { fatalError() }
    func springOnRewards(for childIdentifier: String) -> [RewardDetailRow] { fatalError() }
    func approvals(for childIdentifier: String) -> [ApprovalRequestItem] { fatalError() }

}
