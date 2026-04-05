//
//  NetworkMonitor.swift
//  Cloudyyy_App
//

import Network
import UIKit

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    // UI state
    private var alertWindow: UIWindow?
    private var hasInitialCallback = false
    private var isConnected: Bool = true
    private var pendingWorkItem: DispatchWorkItem?
    
    // Suppression Logic
    private var isManuallyDismissed = false
    
    var isCurrentConnectionSatisfied: Bool {
        return monitor.currentPath.status == .satisfied
    }
    
    private init() {}
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let isConnectedNow = path.status == .satisfied
            
            // Reset suppression if we reconnect
            if isConnectedNow {
                self.isManuallyDismissed = false
            }
            
            // Handle first initialization
            if !self.hasInitialCallback {
                self.hasInitialCallback = true
                self.isConnected = isConnectedNow
                
                // Show immediately if disconnected on launch
                if !isConnectedNow {
                    self.triggerUIUpdate(isConnected: false)
                }
                return
            }
            
            // Only act on state changes
            if self.isConnected != isConnectedNow {
                self.isConnected = isConnectedNow
                self.triggerUIUpdate(isConnected: isConnectedNow)
            }
        }
        monitor.start(queue: queue)
    }
    
    func forceDismiss() {
        isManuallyDismissed = true
        dismissAlert()
    }
    
    private func triggerUIUpdate(isConnected: Bool) {
        // If they manually dismissed, don't show the popup again until isConnected changes from true to false again
        // (already handled by the guard in showAlert anyway, but let's be explicit)
        
        pendingWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if isConnected {
                self.dismissAlert()
            } else {
                if !self.isManuallyDismissed {
                    self.showAlert()
                }
            }
        }
        pendingWorkItem = workItem
        // 0.5s debounce to prevent flickering
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    private func showAlert() {
        // Prevent stacking windows or showing if manually dismissed
        guard alertWindow == nil, !isManuallyDismissed else { return }
        
        // Find foreground active scene reliably
        guard let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }) else { return }
        
        // Setup window
        let newWindow = UIWindow(windowScene: windowScene)
        newWindow.windowLevel = .alert + 1
        newWindow.backgroundColor = .clear
        
        let vc = NetworkAlertViewController()
        newWindow.rootViewController = vc
        
        newWindow.makeKeyAndVisible()
        newWindow.alpha = 0
        UIView.animate(withDuration: 0.3) {
            newWindow.alpha = 1
        }
        
        self.alertWindow = newWindow
    }
    
    private func dismissAlert() {
        guard let window = alertWindow else { return }
        UIView.animate(withDuration: 0.3, animations: {
            window.alpha = 0
        }) { _ in
            window.isHidden = true
            window.resignKey()
            self.alertWindow = nil
        }
    }
}
