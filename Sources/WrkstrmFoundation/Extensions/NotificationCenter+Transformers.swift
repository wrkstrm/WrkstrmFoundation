#if os(Linux)
  // Required due to DispatchQueue's lack of Sendable conformance on Linux.
  @preconcurrency import Foundation
#else
  import Foundation
#endif

extension Notification {
  /// A structure that represents a transformer for notifications, allowing for type-safe handling.
  ///
  /// It includes the notification name and a transformation function that converts a Notification
  /// into a specific type `A`.
  ///
  /// Usage:
  /// ```swift
  /// let myNotificationTransformer = Notification.Transformer<MyType>(name: .myNotification)
  /// ```
  ///
  /// - Parameters:
  ///   - name: The name of the notification.
  ///   - transform: A closure that transforms a `Notification` into type `A`.
  public struct Transformer<A>: Sendable {
    public let name: Notification.Name
    public let transform: @Sendable (Notification) -> A

    public init(
      name: Notification.Name,
      transform: @escaping (@Sendable (Notification) -> A) = {
        (A.self == Void.self ? () : $0.object) as! A  // swiftlint:disable:this force_cast
      },
    ) {
      self.name = name
      self.transform = transform
    }
  }

  /// A token that represents a subscription to a notification.
  ///
  /// Automatically deregisters itself from the notification center upon deinitialization. This
  /// helps manage the lifecycle of notification observers in a more controlled and automatic way.
  ///
  /// - Parameters:
  ///   - token: The observer token returned by the notification center.
  ///   - center: The notification center where the observer is registered.
  public final class Token {
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
}

extension NotificationCenter {
  /// Adds an observer for a given transformer and executes a block when the notification is posted.
  ///
  /// The block receives the transformed notification content as defined in the transformer.
  ///
  /// - Parameters:
  ///   - transformer: A `Notification.Transformer` object defining the notification to observe.
  ///   - queue: The operation queue where the block should be executed. Defaults to the main queue.
  ///   - block: The block to be executed when the notification is received.
  /// - Returns: A `Notification.Token` which controls the lifecycle of the observer.
  @Sendable
  public func addObserver<A>(
    for transformer: Notification.Transformer<A>,
    queue: OperationQueue? = .main,
    using block: @escaping (@Sendable (A) -> Void),
  ) -> Notification.Token {
    let token = addObserver(forName: transformer.name, object: nil, queue: queue) { note in
      let value = transformer.transform(note)
      block(value)
    }
    return Notification.Token(token: token, center: self)
  }

  /// Posts a notification with a given transformer and value.
  ///
  /// - Parameters:
  ///   - transformer: A `Notification.Transformer` object defining the notification to post.
  ///   - value: The value to be posted with the notification.
  public func post<A>(_ transformer: Notification.Transformer<A>, value: A) {
    post(name: transformer.name, object: A.self == Void.self ? nil : value)
  }
}
