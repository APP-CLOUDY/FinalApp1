import re
import sys

file_path = "Programmatic 2/Child  2/Child Home 2/ChildTabBar.swift"
with open(file_path, 'r') as f:
    content = f.read()

target = """    private func setupDarkGlassBar() {
        tabBar.isHidden = true"""

replacement = """    private func setupDarkGlassBar() {
        tabBar.isHidden = true
        
        // Hide iOS 18 native tab bar artifacts
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
