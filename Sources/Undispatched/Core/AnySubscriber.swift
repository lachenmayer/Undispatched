// Copyright (c) 2024 Harry Lachenmayer

import Synchronization

public final class AnySubscriber: Sendable, Hashable {
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

  static var empty: AnySubscriber { AnySubscriber() }

  public func unsubscribe() {
    _unsubscribe()
  }

  deinit {
    unsubscribe()
  }

  var id: ObjectIdentifier { ObjectIdentifier(self) }

  public static func == (lhs: AnySubscriber, rhs: AnySubscriber) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
