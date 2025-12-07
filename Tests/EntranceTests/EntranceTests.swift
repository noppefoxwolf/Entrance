import Testing
@testable import Entrance

#if canImport(UIKit)
import UIKit

/// Dummy host view controller for tests.
private final class HostViewController: UIViewController {}

@MainActor
@Test func yieldsFirstPresenterImmediately() async {
    let queue = PresentationQueue()
    var iterator = queue.presenters().makeAsyncIterator()

    queue.enqueue({ UIViewController() }, presentation: { _, _ in })

    let presenter = await iterator.next()
    #expect(presenter != nil, "First enqueue should yield a presenter without waiting for dismiss.")
}

@MainActor
@Test func advancesToSecondItemAfterDismiss() async {
    let queue = PresentationQueue()
    var iterator = queue.presenters().makeAsyncIterator()

    let firstVC = UIViewController()
    let secondVC = UIViewController()

    queue.enqueue({ firstVC }, presentation: { _, _ in })
    queue.enqueue({ secondVC }, presentation: { _, _ in })

    _ = await iterator.next() // first
    NotificationCenter.default.postDidDisappear(firstVC)

    let secondPresenter = await iterator.next()
    #expect(secondPresenter != nil, "Queue should yield next item after dismissing the first.")
}

@MainActor
@Test func enqueuesAfterIdleAreDelivered() async {
    let queue = PresentationQueue()
    var iterator = queue.presenters().makeAsyncIterator()

    let firstVC = UIViewController()
    queue.enqueue({ firstVC }, presentation: { _, _ in })

    _ = await iterator.next()
    NotificationCenter.default.postDidDisappear(firstVC)

    queue.enqueue({ UIViewController() }, presentation: { _, _ in })

    let secondPresenter = await iterator.next()
    #expect(secondPresenter != nil, "Items enqueued after idle should still be presented.")
}

@MainActor
@Test func asyncActionCompletesAndAllowsNextPresentation() async {
    let queue = PresentationQueue()
    var iterator = queue.presenters().makeAsyncIterator()
    let host = HostViewController()

    var actionExecuted = false
    queue.enqueue {
        actionExecuted = true
    }
    queue.enqueue({ UIViewController() }, presentation: { _, _ in })

    let actionPresenter = await iterator.next()
    #expect(actionPresenter != nil)
    await actionPresenter?.present(in: host)
    #expect(actionExecuted, "Async action should have executed.")

    let nextPresenter = await iterator.next()
    #expect(nextPresenter != nil, "Queue should continue after async action posts disappear.")
}

#else
@Test func skipOnNonUIKitPlatforms() {
    Issue.record("UIKit not available on this platform; UI-based tests skipped.")
}
#endif
