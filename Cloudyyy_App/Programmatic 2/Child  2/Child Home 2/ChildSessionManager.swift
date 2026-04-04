import Foundation

final class ChildSessionManager {
    static let shared = ChildSessionManager()
    
    private init() {}
    
    var currentChildName: String? = nil
    
    func updateCurrentChildName(_ name: String?) {
        self.currentChildName = name
    }
    
    func clear() {
        self.currentChildName = nil
    }
}
