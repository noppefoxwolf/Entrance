import UIKit

@MainActor
public final class PresentationQueue: Sendable {
    /// Initializes a queue for sequential presentation of UIViewControllers.
    /// This initializer swizzles the viewDidDisappear method of UIViewController.
    public init() {
        UIViewController.swizzleViewDidDisappear
    }
    
    struct Item<T: AnyObject & Sendable>: PresentationQueueItem {
        let make: @MainActor () -> T
        let presentation: @Sendable (UIViewController, T) async -> Void
    }
    var items: [any PresentationQueueItem] = []
    var presentingObjectID: ObjectIdentifier? = nil
    private var continuation: AsyncStream<Presenter>.Continuation?

    /// Dequeues the next item and yields a Presenter if the queue is idle.
    private func yieldNextIfPossible() {
        guard presentingObjectID == nil, let item = dequeue() else { return }
        yield(item)
    }

    /// Builds a Presenter for the given queue item and yields it to the stream.
    private func yield(_ item: some PresentationQueueItem) {
        let object = item.make()
        presentingObjectID = ObjectIdentifier(object)

        let presentation = Presenter()
        presentation.onPresent = { await item.presentation($0, object) }
        continuation?.yield(presentation)
    }
    
    /// Adds a UIViewController to the presentation queue.
    /// - Parameters:
    ///   - make: A closure that creates a UIViewController.
    ///   - presentation: A custom presentation logic closure.
    ///     Defaults to modal presentation.
    public func enqueue<T: UIViewController>(
        _ make: @escaping @MainActor () -> T,
        presentation: @escaping @MainActor (_ parent: UIViewController, _ object: T) -> Void = { $0.present($1, animated: true) }
    ) {
        let item = Item(make: make, presentation: presentation)
        items.append(item)
        yieldNextIfPossible()
    }
    
    /// Adds an asynchronous action to the queue.
    /// - Parameter action: The asynchronous action to execute.
    public func enqueue(
        _ action: @escaping @MainActor @Sendable () async -> Void
    ) {
        let item = Item<Token>(
            make: { .init() },
            presentation: { _, object in
                await action()
                NotificationCenter.default.postDidDisappear(object)
            }
        )
        items.append(item)
        yieldNextIfPossible()
    }
    
    /// Waits until the view controller becomes presentable.
    /// This method pauses execution until any currently presented view controller is dismissed.
    /// - Parameter viewController: The view controller that wants to present another view controller.
    public func waitUntilPresentable(in viewController: UIViewController) async {
        if let vc = viewController.presentedViewController {
            let stream = NotificationCenter.default.viewDidDisappearNotifications()
            for await event in stream {
                let id = ObjectIdentifier(vc)
                if event.id == id {
                    break
                }
            }
        }
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
        self.continuation = continuation
        
        let task = Task { @MainActor in
            yieldNextIfPossible()
            
            let stream = NotificationCenter.default.viewDidDisappearNotifications()
            for await notification in stream {
                if notification.id == presentingObjectID {
                    presentingObjectID = nil
                    yieldNextIfPossible()
                }
            }
        }
        self.continuation?.onTermination = { [weak self] _ in
            task.cancel()
            Task { @MainActor in
                self?.continuation = nil
            }
        }
        
        return stream
    }
}
