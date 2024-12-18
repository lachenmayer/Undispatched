// Copyright (c) 2024 Harry Lachenmayer

import Synchronization

extension Observable {
  public func switchMap<Mapped>(_ f: @escaping @Sendable (Value) -> Observable<Mapped>)
    -> Observable<Mapped>
  {
    Observable<Mapped> { subscriber in
      let innerSubscription = Mutex<Subscription?>(nil)
      let sourceComplete = Mutex(false)

      @Sendable func maybeComplete() {
        let isSourceComplete = sourceComplete.withLock { $0 }
        let innerSubscriptionExists = innerSubscription.withLock { $0 != nil }
        if isSourceComplete, innerSubscriptionExists { subscriber.complete() }
      }

      let subscription = subscribe(
        next: { value in
          innerSubscription.withLock { $0?.unsubscribe() }
          let innerObservable = f(value)
          let newSubscription = innerObservable.subscribe(
            next: subscriber.next,
            error: subscriber.error,
            complete: {
              innerSubscription.withLock { $0 = nil }
              maybeComplete()
            }
          )
          innerSubscription.withLock { $0 = newSubscription }
        },
        error: subscriber.error,
        complete: {
          sourceComplete.withLock { $0 = true }
          maybeComplete()
        }
      )
      return subscription.unsubscribe
    }
  }

  public func switchMap<Mapped>(_ f: @escaping @Sendable (Value) async throws -> Mapped)
    -> Observable<Mapped>
  {
    switchMap { value in Observable<Mapped>.async { try await f(value) } }
  }
}
