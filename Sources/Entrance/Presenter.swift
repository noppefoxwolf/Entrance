import UIKit

@MainActor
public final class Presenter: Sendable {
    var onPresent: (UIViewController) async -> Void = { _ in }
    
    public func present(in viewController: UIViewController) async {
        await onPresent(viewController)
    }
}
