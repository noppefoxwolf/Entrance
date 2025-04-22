import UIKit

@MainActor
protocol PresentationQueueItem: Sendable {
    associatedtype T: AnyObject & Sendable
    var make: @Sendable @MainActor () -> T { get }
    var presentation: @Sendable (UIViewController, T) async -> Void { get }
}
