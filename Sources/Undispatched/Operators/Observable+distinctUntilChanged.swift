//
//  Observable+distinctUntilChanged.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 18/12/2024.
//

import Synchronization

extension Observable {
  public func distinctUntilChanged() -> Observable<Value> where Value: Equatable {
    Observable { observer in
      let previousValue = Mutex<Value?>(nil)
      let subscription = subscribe(
        next: { value in
          let shouldEmit = previousValue.withLock { previousValue in
            if previousValue != value {
              previousValue = value
              return true
            }
            return false
          }
          if shouldEmit { observer.next(value) }
        },
        error: observer.error,
        complete: observer.complete
      )
      return subscription.unsubscribe
    }
  }
}
