// Copyright (c) 2024 Harry Lachenmayer

import Synchronization

extension Observable {
  public func take(_ count: Int) -> Observable<Value> {
    Observable { observer in
      if count <= 0 {
        let subscription = subscribe()
        observer.complete()
        return subscription.unsubscribe
      }
      let seen = Mutex(0)
      let subscription = subscribe(
        next: { value in
          let shouldComplete = seen.withLock { seen in
            seen += 1
            return seen >= count
          }
          observer.next(value)
          if shouldComplete { observer.complete() }
        },
        error: { error in
          observer.error(error)
        },
        complete: {
          observer.complete()
        })
      return subscription.unsubscribe
    }
  }
}
