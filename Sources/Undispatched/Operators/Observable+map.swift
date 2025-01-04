// Copyright (c) 2024 Harry Lachenmayer

extension Observable {
  public func map<Mapped>(_ f: @Sendable @escaping (Value) throws -> Mapped) -> Observable<Mapped> {
    Observable<Mapped> { subscriber in
      return subscribe(
        next: { value in
          do {
            let mapped = try f(value)
            subscriber.next(mapped)
          } catch {
            subscriber.error(error)
          }
        },
        error: subscriber.error,
        complete: subscriber.complete
      )
    }
  }
}
