// Copyright (c) 2024 Harry Lachenmayer

public final class Subscription: Sendable {
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
}
