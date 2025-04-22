import UIKit

@MainActor
public final class PresentationQueue: Sendable {
    /// Initializes a queue for sequential presentation of UIViewControllers.
    /// This initializer swizzles the viewDidDisappear method of UIViewController.
    public init() {
        UIViewController.swizzleViewDidDisappear
    }
    
    struct Item<T: AnyObject & Sendable>: PresentationQueueItem {
        let make: @Sendable @MainActor () -> T
        let presentation: @Sendable (UIViewController, T) async -> Void
    }
    var items: [any PresentationQueueItem] = []
    var presentingObjectID: ObjectIdentifier? = nil
    
    /// Adds a UIViewController to the presentation queue.
    /// - Parameters:
    ///   - make: A closure that creates a UIViewController.
    ///   - presentation: A custom presentation logic closure.
    ///     Defaults to modal presentation.
    public func enqueue<T: UIViewController>(
        _ make: @escaping @Sendable @MainActor () -> T,
        presentation: @escaping @Sendable @MainActor (_ parent: UIViewController, _ object: T) -> Void = { $0.present($1, animated: true) }
    ) {
        let item = Item(make: make, presentation: presentation)
        items.append(item)
    }
    
    /// Adds an asynchronous action to the queue.
    /// - Parameter action: The asynchronous action to execute.
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
    
    /// Returns an async stream of presenters from the queue.
    /// Use this method to sequentially present UIViewControllers that have been added to the queue.
    /// - Returns: An async stream of presenters.
    public func presenters() -> AsyncStream<Presenter> {
        let (stream, continuation) = AsyncStream<Presenter>.makeStream()
        
        func yield(_ item: some PresentationQueueItem) {
            let object = item.make()
            presentingObjectID = ObjectIdentifier(object)
            
            let presentation = Presenter()
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

