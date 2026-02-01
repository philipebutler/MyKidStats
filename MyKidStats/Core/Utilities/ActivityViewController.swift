import SwiftUI
import UIKit
import MessageUI

// Helper class to present share sheet from anywhere
class ShareHelper {
    static func share(items: [Any], completion: (() -> Void)? = nil) {
        guard !items.isEmpty else { return }
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.excludedActivityTypes = nil
        
        activityVC.completionWithItemsHandler = { _, _, _, _ in
            completion?()
        }
        
        // Get the key window's root view controller
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                // Find the topmost presented controller
                var topVC = rootVC
                while let presented = topVC.presentedViewController {
                    topVC = presented
                }
                
                // For iPad, set the popover source
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = topVC.view
                    popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                topVC.present(activityVC, animated: true)
            }
        }
    }
}

// Keep ActivityViewController for compatibility with GameSummaryView
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    
    init(activityItems: [Any], applicationActivities: [UIActivity]?) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.excludedActivityTypes = nil
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

// MARK: - Message Compose View Controller

struct MessageComposeView: UIViewControllerRepresentable {
    let messageBody: String
    let onComplete: (Bool) -> Void
    
    static var canSendText: Bool {
        MFMessageComposeViewController.canSendText()
    }
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.body = messageBody
        controller.messageComposeDelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let onComplete: (Bool) -> Void
        
        init(onComplete: @escaping (Bool) -> Void) {
            self.onComplete = onComplete
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true) {
                self.onComplete(result == .sent)
            }
        }
    }
}
