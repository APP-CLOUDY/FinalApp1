import UIKit
import Foundation

/// TEMP VERSION – Supabase code removed so app builds without SDK.
/// Local UserDefaults ONLY. You can re-enable remote sync later.
final class MenuManager {

    static let shared = MenuManager()

    private let defaults = UserDefaults.standard

    // Keys used for storing lists locally
    enum Key: String, CaseIterable {
        case frequency
        case lists
        case assigned
        case rewardTypes
        case claimLimits

        var userDefaultsKey: String { "MenuManager.\(rawValue)" }
    }

    private init() {
        seedDefaultsIfNeeded()
    }

    // ---------------------------------------------------------
    // MARK: - Seed default values
    // ---------------------------------------------------------
    private func seedDefaultsIfNeeded() {
        if values(for: .frequency).isEmpty {
            setDefaults(["Doesn't repeat", "Daily", "Weekly", "Monthly"], for: .frequency)
        }
        if values(for: .assigned).isEmpty {
            setDefaults(["Bob", "Jonesh", "Aisha", "Ramesh"], for: .assigned)
        }
        if values(for: .claimLimits).isEmpty {
            setDefaults(["Once", "Daily", "Weekly", "Monthly", "Unlimited"], for: .claimLimits)
        }
        if values(for: .rewardTypes).isEmpty {
            setDefaults(["Experience", "Toy", "Food", "Custom"], for: .rewardTypes)
        }
        if values(for: .lists).isEmpty {
            setDefaults(["Habits", "Routines", "Studies"], for: .lists)
        }
    }

    // ---------------------------------------------------------
    // MARK: - Local storage
    // ---------------------------------------------------------
    func values(for key: Key) -> [String] {
        defaults.stringArray(forKey: key.userDefaultsKey) ?? []
    }

    private func setDefaults(_ arr: [String], for key: Key) {
        defaults.set(arr, forKey: key.userDefaultsKey)
    }

    /// Add locally (no Supabase)
    func add(_ value: String, to key: Key, completion: ((Bool) -> Void)? = nil) {
        var arr = values(for: key)

        // prevent duplicates ignoring case
        if arr.contains(where: { $0.caseInsensitiveCompare(value) == .orderedSame }) {
            completion?(false)
            return
        }

        arr.insert(value, at: 0)   // add to top
        defaults.set(arr, forKey: key.userDefaultsKey)
        completion?(true)
    }

    // ---------------------------------------------------------
    // MARK: - Build UIMenu with "Add New…"
    // ---------------------------------------------------------
    func menu(
        title: String? = nil,
        for key: Key,
        selectionHandler: @escaping (String) -> Void,
        addNewHandler: @escaping (@escaping (String) -> Void) -> Void
    ) -> UIMenu {

        let items = values(for: key)

        // Build menu items
        var actions: [UIMenuElement] = items.map { v in
            UIAction(title: v) { _ in selectionHandler(v) }
        }

        // Add New section at bottom
        let addAction = UIAction(
            title: "+ Add New…",
            image: UIImage(systemName: "plus")
        ) { _ in
            addNewHandler { newValue in
                self.add(newValue, to: key) { _ in
                    selectionHandler(newValue)
                }
            }
        }

        let addSection = UIMenu(title: "", options: .displayInline, children: [addAction])
        actions.append(addSection)

        return UIMenu(title: title ?? "", children: actions)
    }

    // Refresh menu after adding items
    func updatedMenu(
        title: String? = nil,
        for key: Key,
        selectionHandler: @escaping (String)->Void,
        addNewHandler: @escaping (@escaping (String)->Void)->Void
    ) -> UIMenu {
        menu(
            title: title,
            for: key,
            selectionHandler: selectionHandler,
            addNewHandler: addNewHandler
        )
    }
}

