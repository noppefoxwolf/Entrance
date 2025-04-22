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
    final public class ViewDidDisappearNotification: Sendable {
        let id: ObjectIdentifier
        
        init(id: ObjectIdentifier) {
            self.id = id
        }
    }
    
    final public class ViewDidDisappearNotifications : AsyncSequence, Sendable {
        public struct Iterator : AsyncIteratorProtocol {
            public func next() async -> ViewDidDisappearNotification? {
                let notifications = NotificationCenter.default.notifications(named: .didDisappear)
                let iterator = notifications.makeAsyncIterator()
                let notification = await iterator.next()
                let id = notification?.userInfo?["id"] as? ObjectIdentifier
                guard let id else { return nil }
                return ViewDidDisappearNotification(id: id)
            }
        }
        
        final public func makeAsyncIterator() -> Iterator { Iterator() }
    }
}
