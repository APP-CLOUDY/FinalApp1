import Foundation

final class SelectedKidStore {
    static let shared = SelectedKidStore()
    private init() {}

    // UI model (Kid)
    private(set) var selectedKid: Kid? {
        didSet {
            // 1) If nil or same id — nothing to do.
            guard let kid = selectedKid else { return }

            // 2) Post async to avoid re-entrancy during notification delivery.
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .selectedKidChanged,
                    object: nil,
                    userInfo: ["kid": kid]
                )
            }
        }
    }

    // Use this to update the selected kid from anywhere.
    // Prevents re-setting the same kid and re-triggering notifications.
    func updateKid(_ uiKid: Kid) {
        // Prevent duplicate updates (compare by id)
        if let current = selectedKid, current.id == uiKid.id {
            return
        }
        self.selectedKid = uiKid
    }
}

extension Notification.Name {
    static let selectedKidChanged = Notification.Name("selectedKidChanged")
}

