// Copyright (c) 2024 Harry Lachenmayer

import Synchronization

extension Observable<Void> {
  public static func combineLatest<A, B>(_ a: Observable<A>, _ b: Observable<B>) -> Observable<
    (A, B)
  > {
    Observable<(A, B)> { observer in
      let values = Mutex<(a: A?, b: B?)>((a: nil, b: nil))
      let activeSubscriptions = Mutex(2)

      let complete = { @Sendable in
        let shouldComplete = activeSubscriptions.withLock {
          $0 -= 1
          return $0 == 0
        }
        if shouldComplete { observer.complete() }
      }

      let aSubscription = a.subscribe(
        next: { value in
          let combined = values.withLock {
            $0.a = value
            return liftOptional($0)
          }
          if let combined { observer.next(combined) }
        },
        error: observer.error,
        complete: complete
      )

      let bSubscription = b.subscribe(
        next: { value in
          let combined = values.withLock {
            $0.b = value
            return liftOptional($0)
          }
          if let combined { observer.next(combined) }
        },
        error: observer.error,
        complete: complete
      )

      return {
        aSubscription.unsubscribe()
        bSubscription.unsubscribe()
      }
    }
  }

  public static func combineLatest<A, B, C>(
    _ a: Observable<A>,
    _ b: Observable<B>,
    _ c: Observable<C>
  ) -> Observable<
    (
      A,
      B,
      C
    )
  > {
    Observable.combineLatest(Observable.combineLatest(a, b), c)
      .map { l, r in (l.0, l.1, r) }
  }

  public static func combineLatest<A, B, C, D>(
    _ a: Observable<A>,
    _ b: Observable<B>,
    _ c: Observable<C>,
    _ d: Observable<D>
  ) -> Observable<(A, B, C, D)> {
    Observable.combineLatest(Observable.combineLatest(a, b), Observable.combineLatest(c, d))
      .map { l, r in (l.0, l.1, r.0, r.1) }
  }
}

private func liftOptional<A, B>(_ value: (A?, B?)) -> (A, B)? {
  if let a = value.0, let b = value.1 {
    return (a, b)
  } else {
    return nil
  }
}
