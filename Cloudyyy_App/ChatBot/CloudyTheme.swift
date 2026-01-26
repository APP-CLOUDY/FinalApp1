import SwiftUI

// MARK: - Notification Extension
extension Notification.Name {
    static let taskDidComplete = Notification.Name("taskDidComplete")
}

// MARK: - Color Theme
extension Color {
    static let bgGradientStart = Color(red: 15/255, green: 18/255, blue: 24/255)
    static let bgGradientEnd = Color(red: 36/255, green: 55/255, blue: 99/255)
    static let chatLightBg = Color(red: 0.82, green: 0.84, blue: 0.88)
    static let missionCardBg = Color(red: 0.22, green: 0.24, blue: 0.32)
    static let darkButtonNavy = Color(red: 0.11, green: 0.20, blue: 0.35)
    static let buttonStroke = Color(red: 0.3, green: 0.4, blue: 0.6)
    static let accentPurple = Color(red: 0.45, green: 0.35, blue: 0.95)
    
    // Bubble Neon Colors
    static let neonPink = Color(red: 1.0, green: 0.6, blue: 0.7)
    static let neonBlue = Color(red: 0.4, green: 0.65, blue: 1.0)
    static let neonGreen = Color(red: 0.4, green: 0.8, blue: 0.6)
    static let neonYellow = Color(red: 1.0, green: 0.9, blue: 0.4)
}

// MARK: - View Extensions
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Shapes
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
