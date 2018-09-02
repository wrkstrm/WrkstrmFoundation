//
//  NotificationCenter+Utilities.swift
//  WrkstrmFoundation
//
//  Created by Cristian Monterroza on 9/1/18.
//  Copyright © 2018 Cristian Monterroza. All rights reserved.
//

import Foundation

public struct NotificationTransformer<A> {
    public let name: Notification.Name
    public let transform: (Notification) -> A

    public init(name: Notification.Name,
                transform: @escaping ((Notification) -> A) = { return (A.self == Void.self ? () : $0.object) as! A }) { // swiftlint:disable:this force_cast
        // swiftlint:disable:previous line_length
        self.name = name
        self.transform = transform
    }
}

/// NotifiationTokens automatically deregister themselves when their reference count reaches zero.
public class NotificationToken {
    public let token: NSObjectProtocol
    public let center: NotificationCenter

    public init(token: NSObjectProtocol, center: NotificationCenter) {
        self.token = token
        self.center = center
    }

    deinit {
        center.removeObserver(token)
    }
}

public extension NotificationCenter {

    public func addObserver<A>(for transformer: NotificationTransformer<A>,
                               queue: OperationQueue? = .main,
                               using block: @escaping (A) -> Void) -> NotificationToken {
        let token = addObserver(forName: transformer.name, object: nil, queue: queue) { note in
            block(transformer.transform(note))
        }
        return NotificationToken(token: token, center: self)
    }

    public func post<A>(_ transformer: NotificationTransformer<A>, value: A) {
        post(name: transformer.name, object: A.self == Void.self ? nil : value)
    }
}