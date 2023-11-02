#if os(Linux)
// Needed because DispatchQueue isn't Sendable on Linux
@preconcurrency import Foundation
#else
import Foundation
#endif

extension Notification {
  public struct Transformer<A> {
    public let name: Notification.Name

    public let transform: (Notification) -> A

    public init(
      name: Notification.Name,
      transform: @escaping ((Notification) -> A) = {
        (A.self == Void.self ? () : $0.object) as! A  // swiftlint:disable:this force_cast
      }
    ) {
      self.name = name
      self.transform = transform
    }
  }

  /// A Notifiation.Token automatically deregister itself when it's reference count reaches zero.
  public class Token {
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
  public func addObserver<A>(
    for transformer: Notification.Transformer<A>,
    queue: OperationQueue? = .main,
    using block: @escaping (A) -> Void
  ) -> Notification.Token {
    let token = addObserver(forName: transformer.name, object: nil, queue: queue) { note in
      block(transformer.transform(note))
    }
    return Notification.Token(token: token, center: self)
  }

  public func post<A>(_ transformer: Notification.Transformer<A>, value: A) {
    post(name: transformer.name, object: A.self == Void.self ? nil : value)
  }
}
