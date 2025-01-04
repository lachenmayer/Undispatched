// Copyright (c) 2024 Harry Lachenmayer

import Synchronization

/// A subscription represents the lifetime of an observable.
///
/// You never manually instantiate a subscription, it is returned by calling ``Observable/subscribe(next:error:complete:)``.
///
/// Observables only emit values (and perform side effects) as long as a reference to their
/// corresponding subscription exists.
///
/// When a subscription is deinitialized, the observable is unsubscribed, and its cleanup logic
/// is executed. This ensures that underlying resources are correctly cleaned up, eg. tasks are
/// cancelled or connections are closed.
public final class Subscription: Sendable, Hashable {
  private let _isCompleted: @Sendable () -> Bool
  private let _unsubscribe: @Sendable () -> Void

  public var isCompleted: Bool { _isCompleted() }

  init<Value: Sendable>(subscriber: Subscriber<Value>) {
    self._isCompleted = { subscriber.isCompleted }
    self._unsubscribe = subscriber.unsubscribe
  }

  private init() {
    self._isCompleted = { true }
    self._unsubscribe = {}
  }

  static var empty: Subscription { Subscription() }

  public func unsubscribe() {
    _unsubscribe()
  }

  deinit {
    unsubscribe()
  }

  var id: ObjectIdentifier { ObjectIdentifier(self) }

  public static func == (lhs: Subscription, rhs: Subscription) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
