import UIKit

// Simple manager to ensure only one menu is open at a time
final class FloatingMenuManager {
    static let shared = FloatingMenuManager()
    
    private weak var activeMenu: UIView?
    
    func register(menu: UIView) {
        activeMenu = menu
    }
    
    func closeMenu() {
        if let menu = activeMenu as? FloatingKidsMenu {
            menu.dismiss(animated: true)
        } else {
            activeMenu?.removeFromSuperview()
        }
        activeMenu = nil
    }
    
    func clearMenu() {
        activeMenu = nil
    }
}
