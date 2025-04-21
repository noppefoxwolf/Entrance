import UIKit

@MainActor
public final class PresentationQueue: Sendable {
    public init() {
        UIViewController.swizzleViewDidDisappear
    }
    
    var items: [@Sendable @MainActor () -> UIViewController] = []
    var presentingViewControllerObjectID: ObjectIdentifier?
    
    public func enqueue(_ makeViewController: @Sendable @MainActor @escaping () -> UIViewController) {
        items.append(makeViewController)
    }
    
    func dequeue() -> (UIViewController, ObjectIdentifier)? {
        guard !items.isEmpty else { return nil }
        let makeViewController = items.removeFirst()
        let vc = makeViewController()
        let id = ObjectIdentifier(vc)
        return (vc, id)
    }
    
    public func presentableViewControllers() -> AsyncStream<UIViewController> {
        let (stream, continuation) = AsyncStream<UIViewController>.makeStream()
        
        func yieldNextViewController() {
            guard let (vc, id) = dequeue() else { return }
            presentingViewControllerObjectID = id
            continuation.yield(vc)
        }
        
        let task = Task {
            yieldNextViewController()
            for await notification in NotificationCenter.default.viewDidDisappearNotifications() {
                if notification.id == presentingViewControllerObjectID {
                    yieldNextViewController()
                }
            }
        }
        continuation.onTermination = { _ in
            task.cancel()
        }
        
        return stream
    }
}
