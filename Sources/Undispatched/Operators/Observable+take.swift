// Copyright (c) 2024 Harry Lachenmayer

import Synchronization

extension Observable {
  public func take(_ count: Int) -> Observable<Value> {
    Observable { subscriber in
      if count <= 0 {
        let subscription = subscribe()
        subscriber.complete()
        return subscription
      }
      let seen = Mutex(0)
      return subscribe(
        next: { value in
          let shouldComplete = seen.withLock { seen in
            seen += 1
            return seen >= count
          }
          subscriber.next(value)
          if shouldComplete { subscriber.complete() }
        },
        error: { error in
          subscriber.error(error)
        },
        complete: {
          subscriber.complete()
        })
    }
  }
}
