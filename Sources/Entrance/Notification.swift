import Foundation
import UIKit

extension Notification.Name {
    static var didDisappear: Notification.Name { Notification.Name(#function) }
}

extension NotificationCenter {
    
    func postDidDisappear<T: AnyObject>(_ from: T) {
        let id = ObjectIdentifier(from)
        post(name: .didDisappear, object: nil, userInfo: ["id" : id])
    }
    
    func viewDidDisappearNotifications() -> NotificationCenter.ViewDidDisappearNotifications {
        NotificationCenter.ViewDidDisappearNotifications()
    }
}

extension NotificationCenter {
    /// A class representing a UIViewController disappearance notification.
    final public class ViewDidDisappearNotification: Sendable {
        /// The identifier of the object that disappeared.
        let id: ObjectIdentifier
        
        init(id: ObjectIdentifier) {
            self.id = id
        }
    }
    
    /// A class for handling UIViewController disappearance notifications as an asynchronous sequence.
    final public class ViewDidDisappearNotifications : AsyncSequence, Sendable {
        /// An iterator for sequentially retrieving UIViewController disappearance notifications.
        public struct Iterator : AsyncIteratorProtocol {
            /// Asynchronously retrieves the next UIViewController disappearance notification.
            /// - Returns: The next disappearance notification, or nil if none can be retrieved.
            public func next() async -> ViewDidDisappearNotification? {
                if Task.isCancelled {
                    return nil
                }
                let notifications = NotificationCenter.default.notifications(named: .didDisappear)
                let iterator = notifications.makeAsyncIterator()
                let notification = await iterator.next()
                let id = notification?.userInfo?["id"] as? ObjectIdentifier
                guard let id else { return nil }
                return ViewDidDisappearNotification(id: id)
            }
        }
        
        /// Creates an asynchronous iterator for retrieving UIViewController disappearance notifications.
        /// - Returns: An asynchronous iterator.
        final public func makeAsyncIterator() -> Iterator { Iterator() }
    }
}
