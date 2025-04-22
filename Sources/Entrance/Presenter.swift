import UIKit

@MainActor
public final class Presenter: Sendable {
    var onPresent: (UIViewController) async -> Void = { _ in }
    
    /// Presents content in the specified UIViewController.
    /// - Parameter viewController: The parent UIViewController to present content in.
    public func present(in viewController: UIViewController) async {
        await onPresent(viewController)
    }
}
