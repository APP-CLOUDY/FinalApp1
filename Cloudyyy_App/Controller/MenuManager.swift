import UIKit
import Foundation
#if canImport(Supabase)

// Optional: only compile Supabase code if SDK is added
import Supabase
#endif

/// Central manager for building UIMenu lists that include an "Add New..." action.
/// Stores items in UserDefaults per key; optionally persists to Supabase if configured.
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

    // Optional Supabase client wrapper (nil if not configured)
    #if canImport(Supabase)
    private var supabaseClient: SupabaseClient?
    #endif

    private init() {
        // Optionally initialize Supabase if keys are present in Info.plist
        #if canImport(Supabase)
        if let url = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
           let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String,
           !url.isEmpty, !key.isEmpty {
            supabaseClient = SupabaseClient(supabaseURL: URL(string: url)!, supabaseKey: key)
        }
        #endif

        // Seed some sensible defaults if not present
        seedDefaultsIfNeeded()
    }

    private func seedDefaultsIfNeeded() {
        if values(for: .frequency).isEmpty {
            let defaults = ["Doesn't repeat", "Daily", "Weekly", "Monthly"]
            setDefaults(defaults, for: .frequency)
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

    // MARK: - Local storage helpers

    func values(for key: Key) -> [String] {
        return defaults.stringArray(forKey: key.userDefaultsKey) ?? []
    }

    private func setDefaults(_ arr: [String], for key: Key) {
        defaults.set(arr, forKey: key.userDefaultsKey)
    }

    /// Adds a new value locally (front of list) if not duplicate (case-insensitive).
    /// Also attempts to persist to Supabase if configured.
    func add(_ value: String, to key: Key, completion: ((Bool) -> Void)? = nil) {
        var arr = values(for: key)
        // prevent duplicates (case-insensitive)
        if arr.contains(where: { $0.caseInsensitiveCompare(value) == .orderedSame }) {
            completion?(false)
            return
        }
        arr.insert(value, at: 0)
        defaults.set(arr, forKey: key.userDefaultsKey)

        // Optional remote persist
        #if canImport(Supabase)
        if let client = supabaseClient {
            // Example: write to a generic table named "menu_items" with columns: key, value
            let payload: [String: Any] = ["menu_key": key.rawValue, "value": value]
            Task {
                do {
                    _ = try await client.database.from("menu_items").insert(values: payload).execute()
                    completion?(true)
                } catch {
                    // remote failed — we still return true because local succeeded
                    print("Supabase insert failed:", error)
                    completion?(true)
                }
            }
            return
        }
        #endif

        completion?(true)
    }

    // MARK: - Menu builder

    /// Build a UIMenu for the given key, with selection and add-new callbacks.
    /// - parameter title: optional menu title
    /// - parameter key: which list to read
    /// - parameter selectionHandler: called when user picks existing item
    /// - parameter addNewHandler: called when user taps Add New… (we expect VC to show an alert)
    func menu(
        title: String? = nil,
        for key: Key,
        selectionHandler: @escaping (String) -> Void,
        addNewHandler: @escaping (@escaping (String) -> Void) -> Void
    ) -> UIMenu {

        let items = values(for: key)
        var actions: [UIMenuElement] = items.map { v in
            UIAction(title: v, handler: { _ in selectionHandler(v) })
        }

        // Separator and Add New action
        let add = UIAction(title: "+ Add New…", image: UIImage(systemName: "plus")) { _ in
            // ask caller to show add UI; caller will call the provided callback when user submits text
            addNewHandler { newValue in
                // Add locally and call selection
                self.add(newValue, to: key) { _ in
                    // update menu is left to caller (they can call setMenu again using this manager)
                    selectionHandler(newValue)
                }
            }
        }

        actions.append(UIMenu(title: "", options: .displayInline, children: [add]))

        let menu = UIMenu(title: title ?? "", children: actions)
        return menu
    }

    // Convenience: return an updated UIMenu for key (useful after adding)
    func updatedMenu(title: String? = nil, for key: Key, selectionHandler: @escaping (String)->Void, addNewHandler: @escaping (@escaping (String)->Void)->Void) -> UIMenu {
        return menu(title: title, for: key, selectionHandler: selectionHandler, addNewHandler: addNewHandler)
    }
}

