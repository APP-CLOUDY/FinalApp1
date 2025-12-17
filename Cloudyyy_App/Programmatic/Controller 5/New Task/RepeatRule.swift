import Foundation

// MARK: - Backend Payload
struct RepeatRulePayload: Codable, Sendable {
    let type: String
    let interval: Int
    let weekdays: [Int]?
    let day: Int?
    let month: Int?
}

// MARK: - App Enum
enum RepeatRule: Sendable {
    case once
    case daily
    case weekly([Int]?)
    case monthly(Int?)
    case yearly(Int?)
    case custom(CustomRepeatRule)

    var displayText: String {
        switch self {
        case .once: return "Once"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .custom(let rule): return rule.label
        }
    }
}

// MARK: - Custom Rule
struct CustomRepeatRule: Sendable {
    let label: String
    let payload: RepeatRulePayload
}

// MARK: - Payload Mapping (ONE PLACE ONLY)
extension RepeatRule {

    func toPayload() -> RepeatRulePayload? {
        switch self {

        case .once:
            return nil

        case .daily:
            return RepeatRulePayload(
                type: "daily",
                interval: 1,
                weekdays: nil,
                day: nil,
                month: nil
            )

        case .weekly(let days):
            return RepeatRulePayload(
                type: "weekly",
                interval: 1,
                weekdays: days,
                day: nil,
                month: nil
            )

        case .monthly(let day):
            return RepeatRulePayload(
                type: "monthly",
                interval: 1,
                weekdays: nil,
                day: day,
                month: nil
            )

        case .yearly(let month):
            return RepeatRulePayload(
                type: "yearly",
                interval: 1,
                weekdays: nil,
                day: nil,
                month: month
            )

        case .custom(let rule):
            return rule.payload
        }
    }

    static func fromPayload(_ payload: RepeatRulePayload?) -> RepeatRule {
        guard let payload else { return .once }

        switch payload.type {
        case "daily":
            return .daily
        case "weekly":
            return .weekly(payload.weekdays)
        case "monthly":
            return .monthly(payload.day)
        case "yearly":
            return .yearly(payload.month)
        default:
            return .once
        }
    }
}

