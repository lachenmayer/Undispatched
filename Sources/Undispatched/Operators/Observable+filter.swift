// Copyright (c) 2024 Harry Lachenmayer

extension Observable {
  public func filter(_ predicate: @Sendable @escaping (Value) -> Bool) -> Observable<Value> {
    Observable { subscriber in
      return subscribe(
        next: { value in
          if predicate(value) {
            subscriber.next(value)
          }
        },
        error: subscriber.error,
        complete: subscriber.complete
      )
    }
  }
}
