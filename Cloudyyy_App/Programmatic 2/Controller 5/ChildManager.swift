////
////  ChildManager.swift
////  Cloudyyy_App
////
////  Centralized ChildManager with mock data for Home / Progress / Schedule / Rewards / Approvals.
////  Replace mock implementations with Supabase API calls when ready.
////
////  NOTE: Uses `day` property on HomeChartItem (you chose option 1).
////
//
//import Foundation
//import UIKit
//
//// ------------------------------
//// MARK: - Child Model
//// ------------------------------
//public struct Kid: Codable, Identifiable, Hashable {
//    public let id: String
//    public let name: String
//}
//
//// ------------------------------
//// MARK: - Home Page Models
//// ------------------------------
//public struct HomeOverview {
//    public let missionsDone: Int
//    public let missionsTotal: Int
//    public let redeemedText: String
//}
//
//public struct HomePendingApproval {
//    public let pendingCount: Int
//}
//
//public struct HomeAllocatedRewards {
//    public let allocatedCount: Int
//}
//
//public struct HomeChartItem {
//    public let day: String        // e.g. "Mon"
//    public let rewards: Int
//    public let tasks: Int
//}
//
//// ------------------------------
//// MARK: - Progress Page Models
//// ------------------------------
//public struct ProgressAchievement {
//    public let title: String
//    public let subtitle: String
//}
//
//public struct ProgressEffort {
//    public let title: String
//    public let progress: Float   // 0..1
//    public let rightText: String // e.g. "1/5"
//}
//
//public struct ProgressReturn {
//    public let progress: CGFloat
//    public let tasksDoneText: String
//    public let todayPoints: String
//    public let totalPoints: String
//    public let achievements: [ProgressAchievement]
//    public let efforts: [ProgressEffort]
//}
//
//// ------------------------------
//// MARK: - Schedule Page Models
//// ------------------------------
//public struct ScheduleTask {
//    public let title: String
//    public let time: String
//    public let category: String
//    public let status: String
//    public let date: String      // "YYYY-MM-DD"
//}
//
//// ------------------------------
//// MARK: - Rewards Page Models
//// ------------------------------
//public struct RewardsSummary {
//    public let activeRewards: Int
//    public let starsThisWeek: Int
//    public let totalStars: Int
//}
//
//public struct RewardCategoryItem {
//    public let title: String
//    public let subtitle: String
//    public let icon: String
//}
//
//// ------------------------------
//// MARK: - Approvals Page Models
//// ------------------------------
//public struct ApprovalRequest {
//    public let title: String
//    public let subtitle: String
//    public let requestedDate: String
//    public let stars: Int
//    public let type: String    // Pending / Approved / Redeemed
//}
//
////struct RewardDetailItem {
////    let id: String
////    let title: String
////    let subtitle: String
////    let points: Int
////    let imageName: String?
////    let isActive: Bool
////    // ✅ Add these
////    let claimLimit: String?
////    let subType: String?
////}
//
//// ------------------------------
//// MARK: - ChildManager (singleton)
//// ------------------------------
//final class ChildManager {
//
//    static let shared = ChildManager()
//    static let kidChangedNotification = Notification.Name("ChildManager.kidChangedNotification")
//
//    // default kids list (replace / fetch from Supabase later)
//    private(set) var kids: [Kid] = [
//        Kid(id: "kid_bob", name: "Bob"),
//        Kid(id: "kid_jonesh", name: "Jonesh"),
//        Kid(id: "kid_aisha", name: "Aisha")
//    ]
//
//    // selected kid (setting will post notification)
//    var selectedKid: Kid? {
//        didSet { notifyKidChange() }
//    }
//
//    private init() {
//        if selectedKid == nil {
//            selectedKid = kids.first
//        }
//    }
//
//    private func notifyKidChange() {
//        NotificationCenter.default.post(name: ChildManager.kidChangedNotification, object: selectedKid)
//    }
//
//    // MARK: - Fetch placeholder (async)
//    func fetchKids(completion: @escaping ([Kid]) -> Void) {
//        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
//            let fetched = self.kids
//            DispatchQueue.main.async {
//                self.kids = fetched
//                completion(fetched)
//            }
//        }
//    }
//
//    // MARK: - Helper
//    func kid(by id: String) -> Kid? {
//        return kids.first(where: { $0.id == id })
//    }
//
//    func selectKid(withId id: String) {
//        if let k = kids.first(where: { $0.id == id }) {
//            selectedKid = k
//        }
//    }
//
//    // ------------------------------------------------------------------
//    // MARK: - HOME data
//    // ------------------------------------------------------------------
//    /// Returns: (overview, pending, allocated, weeklyChart)
//    func homeData(for kidId: String) -> (
//        overview: HomeOverview,
//        pending: HomePendingApproval,
//        allocated: HomeAllocatedRewards,
//        weeklyChart: [HomeChartItem]
//    ) {
//        switch kidId {
//        case "kid_bob":
//            return (
//                HomeOverview(missionsDone: 2, missionsTotal: 7, redeemedText: "Cartoon time"),
//                HomePendingApproval(pendingCount: 6),
//                HomeAllocatedRewards(allocatedCount: 11),
//                [
//                    HomeChartItem(day: "Mon", rewards: 5, tasks: 12),
//                    HomeChartItem(day: "Tue", rewards: 7, tasks: 10),
//                    HomeChartItem(day: "Wed", rewards: 3, tasks: 6),
//                    HomeChartItem(day: "Thu", rewards: 4, tasks: 8),
//                    HomeChartItem(day: "Fri", rewards: 10, tasks: 14),
//                    HomeChartItem(day: "Sat", rewards: 2, tasks: 4),
//                    HomeChartItem(day: "Sun", rewards: 4, tasks: 9)
//                ]
//            )
//
//        case "kid_jonesh":
//            return (
//                HomeOverview(missionsDone: 4, missionsTotal: 8, redeemedText: "Reading Time"),
//                HomePendingApproval(pendingCount: 3),
//                HomeAllocatedRewards(allocatedCount: 5),
//                [
//                    HomeChartItem(day: "Mon", rewards: 3, tasks: 7),
//                    HomeChartItem(day: "Tue", rewards: 9, tasks: 11),
//                    HomeChartItem(day: "Wed", rewards: 5, tasks: 5),
//                    HomeChartItem(day: "Thu", rewards: 2, tasks: 6),
//                    HomeChartItem(day: "Fri", rewards: 6, tasks: 9),
//                    HomeChartItem(day: "Sat", rewards: 4, tasks: 3),
//                    HomeChartItem(day: "Sun", rewards: 3, tasks: 4)
//                ]
//            )
//
//        default: // kid_aisha or others
//            return (
//                HomeOverview(missionsDone: 1, missionsTotal: 5, redeemedText: "Play time"),
//                HomePendingApproval(pendingCount: 1),
//                HomeAllocatedRewards(allocatedCount: 2),
//                [
//                    HomeChartItem(day: "Mon", rewards: 2, tasks: 6),
//                    HomeChartItem(day: "Tue", rewards: 2, tasks: 5),
//                    HomeChartItem(day: "Wed", rewards: 4, tasks: 8),
//                    HomeChartItem(day: "Thu", rewards: 5, tasks: 9),
//                    HomeChartItem(day: "Fri", rewards: 6, tasks: 10),
//                    HomeChartItem(day: "Sat", rewards: 2, tasks: 3),
//                    HomeChartItem(day: "Sun", rewards: 2, tasks: 5)
//                ]
//            )
//        }
//    }
//
//    /// Simple monthly aggregation helper of weekly chart into 4 "weeks"
//    func monthlyChartAggregated(for kidId: String) -> [HomeChartItem] {
//        let weekly = homeData(for: kidId).weeklyChart
//
//        // split into 4 groups (demo only) and sum
//        let groups: [[HomeChartItem]] = [
//            Array(weekly.prefix(2)),                             // days 0..1
//            Array(weekly.dropFirst(2).prefix(2)),                // days 2..3
//            Array(weekly.dropFirst(4).prefix(2)),                // days 4..5
//            Array(weekly.dropFirst(6))                           // day 6
//        ]
//
//        var out: [HomeChartItem] = []
//        for (i, block) in groups.enumerated() {
//            let rewardsSum = block.reduce(0) { $0 + $1.rewards }
//            let tasksSum = block.reduce(0) { $0 + $1.tasks }
//            out.append(HomeChartItem(day: "Week \(i+1)", rewards: rewardsSum, tasks: tasksSum))
//        }
//        return out
//    }
//
//    // ------------------------------------------------------------------
//    // MARK: - PROGRESS data
//    // ------------------------------------------------------------------
//    func dataForKid(_ kidId: String) -> ProgressReturn {
//        switch kidId {
//        case "kid_bob":
//            return ProgressReturn(
//                progress: 0.70,
//                tasksDoneText: "7/10",
//                todayPoints: "310",
//                totalPoints: "900",
//                achievements: [
//                    ProgressAchievement(title: "Math Practice - 20 mins", subtitle: "Today 8:51 AM"),
//                    ProgressAchievement(title: "Drawing", subtitle: "Yesterday")
//                ],
//                efforts: [
//                    ProgressEffort(title: "Habits", progress: 0.5, rightText: "5/10"),
//                    ProgressEffort(title: "Homework", progress: 0.8, rightText: "8/10")
//                ]
//            )
//
//        case "kid_jonesh":
//            return ProgressReturn(
//                progress: 0.40,
//                tasksDoneText: "4/11",
//                todayPoints: "220",
//                totalPoints: "550",
//                achievements: [
//                    ProgressAchievement(title: "Cartoon time - 30 minutes", subtitle: "8:51 AM"),
//                    ProgressAchievement(title: "Chocolate cookie", subtitle: "Thursday")
//                ],
//                efforts: [
//                    ProgressEffort(title: "Habits", progress: 0.2, rightText: "1/5"),
//                    ProgressEffort(title: "Homework", progress: 0.66, rightText: "2/3")
//                ]
//            )
//
//        case "kid_aisha":
//            return ProgressReturn(
//                progress: 0.12,
//                tasksDoneText: "1/8",
//                todayPoints: "40",
//                totalPoints: "150",
//                achievements: [],
//                efforts: [
//                    ProgressEffort(title: "Reading", progress: 0.5, rightText: "5/10")
//                ]
//            )
//
//        default:
//            return ProgressReturn(
//                progress: 0,
//                tasksDoneText: "0/0",
//                todayPoints: "0",
//                totalPoints: "0",
//                achievements: [],
//                efforts: []
//            )
//        }
//    }
//
//    // ------------------------------------------------------------------
//    // MARK: - SCHEDULE
//    // ------------------------------------------------------------------
//    // Replace the existing func schedule(for kidId: String) -> [ScheduleTask] { ... }
//    func schedule(for kidId: String) -> [ScheduleTask] {
//        // generate a few demo dates in current month for better UI testing
//        let cal = Calendar.current
//        let now = Date()
//        let components = cal.dateComponents([.year, .month], from: now)
//        guard let monthStart = cal.date(from: components) else {
//            return []
//        }
//
//        func dateString(day: Int) -> String {
//            guard let d = cal.date(byAdding: .day, value: day - 1, to: monthStart) else { return "" }
//            let df = DateFormatter()
//            df.dateFormat = "yyyy-MM-dd"
//            return df.string(from: d)
//        }
//
//        switch kidId {
//        case "kid_bob":
//            return [
//                ScheduleTask(title: "Do the Homework", time: "06:00 AM", category: "Habits", status: "Not Done", date: dateString(day: 27)),
//                ScheduleTask(title: "Math Practice", time: "07:30 AM", category: "Study", status: "In progress", date: dateString(day: 27)),
//                ScheduleTask(title: "Brush Teeth", time: "09:00 AM", category: "Habits", status: "Completed", date: dateString(day: 9)),
//                ScheduleTask(title: "Piano Practice", time: "03:00 PM", category: "Hobby", status: "Not Done", date: dateString(day: 2)),
//                ScheduleTask(title: "Reading", time: "08:30 PM", category: "Habits", status: "In progress", date: dateString(day: 16)),
//                ScheduleTask(title: "Draw - Art", time: "05:00 PM", category: "Hobby", status: "Completed", date: dateString(day: 27)),
//                ScheduleTask(title: "Help with Chores", time: "04:00 PM", category: "Chores", status: "Not Done", date: dateString(day: 27))
//            ]
//        case "kid_jonesh":
//            return [
//                ScheduleTask(title: "Brush Teeth", time: "07:00 AM", category: "Habits", status: "Completed", date: dateString(day: 10)),
//                ScheduleTask(title: "Practice Piano", time: "05:00 PM", category: "Hobby", status: "In progress", date: dateString(day: 27)),
//                ScheduleTask(title: "Homework Math", time: "06:30 PM", category: "Study", status: "Not Done", date: dateString(day: 16))
//            ]
//        default:
//            return [
//                ScheduleTask(title: "Read a Book", time: "06:30 PM", category: "Habits", status: "Not Done", date: dateString(day: 16))
//            ]
//        }
//    }
//
//
//    // ------------------------------------------------------------------
//    // MARK: - REWARDS
//    // ------------------------------------------------------------------
//    func rewardsSummary(for kidId: String) -> RewardsSummary {
//        switch kidId {
//        case "kid_bob":
//            return RewardsSummary(activeRewards: 22, starsThisWeek: 280, totalStars: 1455)
//        case "kid_jonesh":
//            return RewardsSummary(activeRewards: 9, starsThisWeek: 120, totalStars: 700)
//        default:
//            return RewardsSummary(activeRewards: 3, starsThisWeek: 25, totalStars: 150)
//        }
//    }
//
//    func rewardCategories(for kidId: String) -> [RewardCategoryItem] {
//        return [
//            RewardCategoryItem(title: "Quick Rewards", subtitle: "Small instant treats (e.g., cartoon, snack)", icon: "gift"),
//            RewardCategoryItem(title: "Dream it", subtitle: "Long-term goals (e.g., cycle, art kit)", icon: "sparkles"),
//            RewardCategoryItem(title: "Spring On", subtitle: "Experience-based goal (e.g., zoo trip, picnic)", icon: "leaf")
//        ]
//    }
//    // MARK: - Detailed Reward Items for 3 categories
//    func quickRewards(for kidId: String) -> [RewardDetailItem] {
//        switch kidId {
//        case "kid_bob":
//            return [
//                RewardDetailItem(
//                    id: "qr1",
//                    title: "Cartoon Time",
//                    subtitle: "Watch 20 minutes of cartoons",
//                    points: 40,
//                    imageName: "reward_cartoon",
//                    isActive: true
//                ),
//                RewardDetailItem(
//                    id: "qr2",
//                    title: "Snack Treat",
//                    subtitle: "A small sweet snack",
//                    points: 25,
//                    imageName: "reward_snack",
//                    isActive: false
//                )
//            ]
//
//        case "kid_jonesh":
//            return [
//                RewardDetailItem(id: "qr10",
//                    title: "Small Gift",
//                    subtitle: "A little surprise treat",
//                    points: 50,
//                    imageName: "reward_gift",
//                    isActive: true
//                )
//            ]
//
//        default:
//            return []
//        }
//    }
//
//    func dreamItRewards(for kidId: String) -> [RewardDetailItem] {
//        switch kidId {
//        case "kid_bob":
//            return [
//                RewardDetailItem(
//                    id: "dream1",
//                    title: "New Bicycle",
//                    subtitle: "Long-term goal reward",
//                    points: 1200,
//                    imageName: "reward_cycle",
//                    isActive: true
//                ),
//                RewardDetailItem(
//                    id: "dream2",
//                    title: "Art Kit",
//                    subtitle: "Completed dream reward",
//                    points: 350,
//                    imageName: "reward_artkit",
//                    isActive: false
//                )
//            ]
//
//        case "kid_jonesh":
//            return [
//                RewardDetailItem(
//                    id: "dream10",
//                    title: "Cricket Kit",
//                    subtitle: "Professional cricket set",
//                    points: 900,
//                    imageName: "reward_cricket",
//                    isActive: true
//                )
//            ]
//
//        default:
//            return []
//        }
//    }
//
//    func springOnRewards(for kidId: String) -> [RewardDetailItem] {
//        switch kidId {
//        case "kid_bob":
//            return [
//                RewardDetailItem(
//                    id: "spring1",
//                    title: "Disney Land",
//                    subtitle: "Every puzzle piece reveals a part of the trip",
//                    points: 500,
//                    imageName: "reward_disney",
//                    isActive: true
//                ),
//                RewardDetailItem(
//                    id: "spring2",
//                    title: "Zoo Trip",
//                    subtitle: "Completed experience trip",
//                    points: 200,
//                    imageName: "reward_zoo",
//                    isActive: false
//                )
//            ]
//
//        case "kid_jonesh":
//            return [
//                RewardDetailItem(
//                    id: "spring10",
//                    title: "Wildlife Safari",
//                    subtitle: "Kids' weekend experience",
//                    points: 400,
//                    imageName: "reward_safari",
//                    isActive: true
//                )
//            ]
//
//        default:
//            return []
//        }
//    }
//
//    // ------------------------------------------------------------------
//    // MARK: - APPROVALS
//    // ------------------------------------------------------------------
//    func approvals(for kidId: String) -> [ApprovalRequest] {
//        switch kidId {
//        case "kid_bob":
//            return [
//                ApprovalRequest(title: "Quick Reward", subtitle: "Water Your Plant", requestedDate: "24/10/2020", stars: 100, type: "Pending"),
//                ApprovalRequest(title: "Task", subtitle: "Water Your Plant", requestedDate: "24/10/2020", stars: 100, type: "Approved")
//            ]
//        case "kid_jonesh":
//            return [
//                ApprovalRequest(title: "DREAM IT", subtitle: "Build A Cycle", requestedDate: "24/10/2020", stars: 100, type: "Redeemed")
//            ]
//        default:
//            return []
//        }
//    }
//}
