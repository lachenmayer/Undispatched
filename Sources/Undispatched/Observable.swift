// Copyright (c) 2024 Harry Lachenmayer

import Synchronization

public struct Observable<Value: Sendable>: Sendable {
  private let subscribeLogic: SubscribeLogic<Value>

  public init(_ subscribeLogic: @escaping SubscribeLogic<Value>) {
    self.subscribeLogic = subscribeLogic
  }

  public func subscribe(
    next: NextHandler<Value>? = nil,
    error: ErrorHandler? = nil,
    complete: CompleteHandler? = nil
  ) -> Subscription {
    let subscriber = Subscriber(next: next, error: error, complete: complete)
    do {
      let observer = AnyObserver(
        next: subscriber.next,
        error: subscriber.error,
        complete: subscriber.complete
      )
      let teardown = try subscribeLogic(observer)
      subscriber.add(teardown)
    } catch {
      subscriber.error(error)
    }
    return Subscription { subscriber.unsubscribe() }
  }
}
