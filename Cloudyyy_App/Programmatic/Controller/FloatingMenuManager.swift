import UIKit

final class FloatingMenuManager {

    static let shared = FloatingMenuManager()

    private(set) weak var currentMenu: FloatingKidsMenu?

    private init() {}

    // Called when a new dropdown appears
    func register(menu: FloatingKidsMenu) {
        currentMenu = menu
    }

    // Close dropdown instantly
    func closeMenu() {
        currentMenu?.dismiss(animated: false)
        currentMenu = nil
    }

    // Used by dropdown itself
    func clearMenu() {
        currentMenu = nil
    }

    // ❗ Call this when user switches tab or page
    func pageDidChange() {
        closeMenu()
    }
}
