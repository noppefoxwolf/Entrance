import UIKit
import AVFoundation
import Entrance
import SwiftUI
import UserNotifications

final class ViewController: UIViewController {
    let label: UILabel = UILabel()
    let scheduleButton = UIButton(configuration: .borderedProminent())
    let presentationQueue = PresentationQueue()
    private var notificationObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        label.text = "Hello, World!"
        scheduleButton.configuration?.title = "5秒後にローカル通知を送る"
        
        let stackView = UIStackView(
            arrangedSubviews: [
                label,
                scheduleButton
            ]
        )
        stackView.spacing = 12
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: stackView.safeAreaLayoutGuide.trailingAnchor, constant: 20),
        ])
        
        scheduleButton.addAction(UIAction { [weak self] _ in
            Task {
                try await self?.scheduleLocalNotification()
            }
        }, for: .primaryActionTriggered)
        
        // Demo: queue multiple presentations.
        presentationQueue.enqueue {
            let vc = UIAlertController(title: "Hello", message: "welcome", preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "OK", style: .cancel))
            return vc
        }
        
        presentationQueue.enqueue {
            ChildViewController()
        }
        
        presentationQueue.enqueue({
            ChildViewController()
        }, presentation: { $0.navigationController?.pushViewController($1, animated: true) })
        
        presentationQueue.enqueue {
            await AVCaptureDevice.requestAccess(for: .video)
        }
        
        presentationQueue.enqueue {
            let vc = UIAlertController(title: "Hello", message: "choose", preferredStyle: .actionSheet)
            vc.addAction(UIAlertAction(title: "Option 1", style: .default))
            vc.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            return vc
        }
        
        struct RootView: View {
            @Environment(\.dismiss) var dismiss
            var body: some View {
                Button("dismiss") { dismiss() }
            }
        }
        
        DispatchQueue.main.async { [unowned self] in
            let vc = UIHostingController(rootView: RootView())
            present(vc, animated: true)
        }
        
        Task {
            await presentationQueue.waitUntilPresentable(in: self)
            for await presenter in presentationQueue.presenters() {
                await presenter.present(in: self)
            }
        }
        
        notificationObserver = NotificationCenter.default.addObserver(
            forName: .demoNotificationLaunch,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.navigateToNotificationDestination()
        }
    }
    
    @MainActor deinit {
        if let notificationObserver {
            NotificationCenter.default.removeObserver(notificationObserver)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let appDelegate = AppDelegate.shared, appDelegate.launchedFromNotification {
            appDelegate.launchedFromNotification = false
            navigateToNotificationDestination()
        }
    }
    
    private func navigateToNotificationDestination() {
        // Demo transition: push ChildViewController.
        let destination = ChildViewController()
        navigationController?.pushViewController(destination, animated: true)
    }
    
    private func scheduleLocalNotification() async throws {
        let center = UNUserNotificationCenter.current()
        try await center.requestAuthorization(options: [.alert, .sound])
        let content = UNMutableNotificationContent()
        content.title = "Entrance デモ"
        content.body = "タップで Child 画面へ遷移"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "entrance.demo.local", content: content, trigger: trigger)
        try await center.add(request)
    }
}
