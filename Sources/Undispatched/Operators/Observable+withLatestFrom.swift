//
//  Observable+withLatestFrom.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 18/12/2024.
//

import Synchronization

extension Observable {
  public func withLatestFrom<Latest>(_ latest: Observable<Latest>) -> Observable<(Value, Latest)> {
    Observable<(Value, Latest)> { observer in
      let latestValue = Mutex<Latest?>(nil)
      let latestSubscription = latest.subscribe(
        next: { value in
          latestValue.withLock { $0 = value }
        },
        error: observer.error,
        complete: observer.complete
      )

      let valueSubscription = subscribe(
        next: { value in
          let latest = latestValue.withLock { $0 }
          if let latest {
            observer.next((value, latest))
          }
        },
        error: observer.error,
        complete: observer.complete
      )

      return {
        latestSubscription.unsubscribe()
        valueSubscription.unsubscribe()
      }
    }
  }
}
