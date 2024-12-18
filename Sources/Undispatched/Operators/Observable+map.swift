// Copyright (c) 2024 Harry Lachenmayer

extension Observable {
  public func map<Mapped>(_ f: @Sendable @escaping (Value) throws -> Mapped) -> Observable<Mapped> {
    Observable<Mapped> { observer in
      let subscription = subscribe(
        next: { value in
          do {
            let mapped = try f(value)
            observer.next(mapped)
          } catch {
            observer.error(error)
          }
        },
        error: observer.error,
        complete: observer.complete
      )
      return subscription.unsubscribe
    }
  }
}
