//
//  Observable+withLatestFrom.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 18/12/2024.
//

import Synchronization

extension Observable {
  public func withLatestFrom<Latest>(_ latest: Observable<Latest>) -> Observable<(Value, Latest)> {
    Observable<(Value, Latest)> { subscriber in
      let latestValue = Mutex<Latest?>(nil)
      let latestSubscription = latest.subscribe(
        next: { value in
          latestValue.withLock { $0 = value }
        },
        error: subscriber.error,
        complete: subscriber.complete
      )

      let valueSubscription = subscribe(
        next: { value in
          let latest = latestValue.withLock { $0 }
          if let latest {
            subscriber.next((value, latest))
          }
        },
        error: subscriber.error,
        complete: subscriber.complete
      )

      return {
        latestSubscription.unsubscribe()
        valueSubscription.unsubscribe()
      }
    }
  }
}
