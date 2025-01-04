// Copyright (c) 2024 Harry Lachenmayer

import Synchronization

public struct Observable<Value: Sendable>: Sendable, ObservableProtocol {
  private let subscribeLogic: SubscribeLogic<Value>

  public init(_ subscribeLogic: @escaping SubscribeLogic<Value>) {
    self.subscribeLogic = subscribeLogic
  }

  public init(
    _ subscription: @escaping @Sendable (Subscriber<Value>) throws -> Subscription
  ) {
    self.subscribeLogic = { subscriber in
      let subscription = try subscription(subscriber)
      return subscription.unsubscribe
    }
  }

  public init(
    _ subscription: @escaping @Sendable (Subscriber<Value>) throws -> Void
  ) {
    self.subscribeLogic = { subscriber in
      try subscription(subscriber)
      return {}
    }
  }

  public func subscribe(
    next: NextHandler<Value>? = nil,
    error: ErrorHandler? = nil,
    complete: CompleteHandler? = nil
  ) -> Subscription {
    let subscriber = Subscriber(next: next, error: error, complete: complete)
    do {
      let teardown = try subscribeLogic(subscriber)
      subscriber.add(teardown)
    } catch {
      subscriber.error(error)
    }
    return Subscription(subscriber: subscriber)
  }
}
