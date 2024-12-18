// Copyright (c) 2024 Harry Lachenmayer

public final class Subscription: Sendable, Hashable {

  private let _unsubscribe: @Sendable () -> Void

  static var empty: Subscription { Subscription {} }

  init(_unsubscribe: @escaping @Sendable () -> Void) {
    self._unsubscribe = _unsubscribe
  }

  public func unsubscribe() {
    _unsubscribe()
  }

  deinit {
    _unsubscribe()
  }

  var id: ObjectIdentifier { ObjectIdentifier(self) }

  public static func == (lhs: Subscription, rhs: Subscription) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
