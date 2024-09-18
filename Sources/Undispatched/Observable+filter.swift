// Copyright (c) 2024 Harry Lachenmayer

public extension Observable {
  func filter(_ predicate: @Sendable @escaping (Value) -> Bool) -> Observable<Value> {
    Observable { observer in
      let subscription = subscribe(
        next: { value in
          if predicate(value) {
            observer.next(value)
          }
        },
        error: observer.error,
        complete: observer.complete
      )
      return subscription.unsubscribe
    }
  }
}
