import UIKit

@MainActor
public final class PresentationQueue: Sendable {
    public init() {
        UIViewController.swizzleViewDidDisappear
    }
    
    struct Item<T: AnyObject & Sendable>: PresentationQueueItem {
        let make: @Sendable @MainActor () -> T
        let presentation: @Sendable (UIViewController, T) async -> Void
    }
    var items: [any PresentationQueueItem] = []
    var presentingObjectID: ObjectIdentifier? = nil
    
    public func enqueue<T: UIViewController>(
        _ make: @escaping @Sendable @MainActor () -> T,
        presentation: @escaping @Sendable @MainActor (_ parent: UIViewController, _ object: T) -> Void = { $0.present($1, animated: true) }
    ) {
        let item = Item(make: make, presentation: presentation)
        items.append(item)
    }
    
    public func enqueue(
        _ action: @escaping @Sendable () async -> Void
    ) {
        let item = Item<Token>(
            make: { .init() },
            presentation: { _, object in
                await action()
                NotificationCenter.default.postDidDisappear(object)
            }
        )
        items.append(item)
    }
    
    func dequeue() -> (any PresentationQueueItem)? {
        guard !items.isEmpty else { return nil }
        return items.removeFirst()
    }
    
    public func presenters() -> AsyncStream<Presenter> {
        let (stream, continuation) = AsyncStream<Presenter>.makeStream()
        
        func yield(_ item: some PresentationQueueItem) {
            let object = item.make()
            presentingObjectID = ObjectIdentifier(object)
            
            var presentation = Presenter()
            presentation.onPresent = { await item.presentation($0, object) }
            continuation.yield(presentation)
        }
        
        let task = Task {
            if let item = dequeue() {
                yield(item)
            }
            
            for await notification in NotificationCenter.default.viewDidDisappearNotifications() {
                if notification.id == presentingObjectID {
                    if let item = dequeue() {
                        yield(item)
                    }
                }
            }
        }
        continuation.onTermination = { _ in
            task.cancel()
        }
        
        return stream
    }
}

