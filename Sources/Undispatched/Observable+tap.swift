// Copyright (c) 2024 Harry Lachenmayer

public typealias SubscribeHandler = @Sendable () -> Void

public extension Observable {
  func tap(_ next: @escaping NextHandler<Value>) -> Observable<Value> {
    tap(next: next)
  }

  func tap(
    next onNext: NextHandler<Value>? = nil,
    error onError: ErrorHandler? = nil,
    complete onComplete: CompleteHandler? = nil,
    subscribe onSubscribe: SubscribeHandler? = nil,
    unsubscribe onUnsubscribe: SubscribeHandler? = nil
  ) -> Observable<Value> {
    Observable<Value> { observer in
      onSubscribe?()
      let subscription = self.subscribe(
        next: { value in
          onNext?(value)
          observer.next(value)
        },
        error: { error in
          onError?(error)
          observer.error(error)
        },
        complete: {
          onComplete?()
          observer.complete()
        }
      )
      return {
        onUnsubscribe?()
        subscription.unsubscribe()
      }
    }
  }
}
