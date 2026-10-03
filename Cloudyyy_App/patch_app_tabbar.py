import re
import sys

file_path = "AppTabBarController.swift"
with open(file_path, 'r') as f:
    content = f.read()

target = """    private func setupDarkGlassBar(for role: UserRole) {
        // 1. Hide the native tab bar (the snowy white one)
        tabBar.isHidden = true"""

replacement = """    private func setupDarkGlassBar(for role: UserRole) {
        // 1. Hide the native tab bar (the snowy white one)
        tabBar.isHidden = true
        
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil
        appearance.shadowColor = .clear
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }"""

content = content.replace(target, replacement)

with open(file_path, 'w') as f:
    f.write(content)
