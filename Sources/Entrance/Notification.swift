import Foundation
import UIKit

extension Notification.Name {
    static var viewDidDisappear: Notification.Name { Notification.Name("dev.noppe.entrance.viewDidDisappear") }
}

extension NotificationCenter {
    
    func postViewDidDisappear<T: UIViewController>(_ from: T) {
        let id = ObjectIdentifier(from)
        post(name: .viewDidDisappear, object: nil, userInfo: ["id" : id])
    }
    
    func viewDidDisappearNotifications() -> NotificationCenter.ViewDidDisappearNotifications {
        NotificationCenter.ViewDidDisappearNotifications()
    }
}

extension NotificationCenter {
    final public class ViewDidDisappearNotification: Sendable {
        let id: ObjectIdentifier
        
        init(id: ObjectIdentifier) {
            self.id = id
        }
    }
    
    final public class ViewDidDisappearNotifications : AsyncSequence, Sendable {

        /// The type of element produced by this asynchronous sequence.
        public typealias Element = ViewDidDisappearNotification

        @available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
        public struct Iterator : AsyncIteratorProtocol {
            public func next() async -> ViewDidDisappearNotification? {
                let notifications = NotificationCenter.default.notifications(named: .viewDidDisappear)
                let iterator = notifications.makeAsyncIterator()
                let notification = await iterator.next()
                let id = notification?.userInfo?["id"] as? ObjectIdentifier
                guard let id else { return nil }
                return ViewDidDisappearNotification(id: id)
            }

            @available(iOS 15, tvOS 15, watchOS 8, macOS 12, *)
            public typealias Element = ViewDidDisappearNotification
        }
        
        final public func makeAsyncIterator() -> NotificationCenter.ViewDidDisappearNotifications.Iterator {
            NotificationCenter.ViewDidDisappearNotifications.Iterator()
        }
        
        public typealias AsyncIterator = NotificationCenter.ViewDidDisappearNotifications.Iterator
    }
}
