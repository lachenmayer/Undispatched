//
//  Observable+mergeMap.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 18/12/2024.
//

import Synchronization

extension Observable {
  public func mergeMap<Mapped>(_ f: @escaping @Sendable (Value) -> Observable<Mapped>)
    -> Observable<Mapped>
  {
    Observable<Mapped> { subscriber in
      let nextSubscriptionId = Mutex(0)
      let activeSubscriptions = Mutex([Int: Subscription]())
      let sourceComplete = Mutex(false)

      @Sendable func maybeComplete() {
        let isSourceComplete = sourceComplete.withLock { $0 }
        let noActives = activeSubscriptions.withLock { $0.isEmpty }
        if isSourceComplete, noActives { subscriber.complete() }
      }

      let subscription = subscribe(
        next: { value in
          let innerObservable = f(value)
          let subscriptionId = nextSubscriptionId.withLock { id in
            let currentId = id
            id += 1
            return currentId
          }
          let innerSubscription = innerObservable.subscribe(
            next: subscriber.next,
            error: subscriber.error,
            complete: {
              let _ = activeSubscriptions.withLock { actives in
                actives.removeValue(forKey: subscriptionId)
                return true
              }
              maybeComplete()
            }
          )
          if !innerSubscription.isCompleted {
            activeSubscriptions.withLock { $0[subscriptionId] = innerSubscription }
          }
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

  public func mergeMap<Mapped>(_ f: @escaping @Sendable (Value) async throws -> Mapped)
    -> Observable<Mapped>
  {
    mergeMap { value in Observable<Mapped>.async { try await f(value) } }
  }
}
