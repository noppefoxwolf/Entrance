import UIKit
import ObjectiveC.runtime

extension UIViewController {
    static let swizzleViewDidDisappear: Void = {
        let originalSelector = #selector(UIViewController.viewDidDisappear(_:))
        let swizzledSelector = #selector(UIViewController.swizzled_viewDidDisappear(_:))

        let originalMethod = class_getInstanceMethod(
            UIViewController.self,
            originalSelector
        )
        let swizzledMethod = class_getInstanceMethod(
            UIViewController.self,
            swizzledSelector
        )
        guard let originalMethod, let swizzledMethod else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc func swizzled_viewDidDisappear(_ animated: Bool) {
        // Call the original implementation
        self.swizzled_viewDidDisappear(animated)
        
        customDidDisappear()
    }

    func customDidDisappear() {
        NotificationCenter.default.postViewDidDisappear(self)
    }
}
