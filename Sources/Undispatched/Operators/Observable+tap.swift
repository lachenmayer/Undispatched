// Copyright (c) 2024 Harry Lachenmayer

public typealias SubscribeHandler = @Sendable () -> Void

extension Observable {
  public func tap(_ next: @escaping NextHandler<Value>) -> Observable<Value> {
    tap(next: next)
  }

  public func tap(
    next onNext: NextHandler<Value>? = nil,
    error onError: ErrorHandler? = nil,
    complete onComplete: CompleteHandler? = nil,
    subscribe onSubscribe: SubscribeHandler? = nil,
    unsubscribe onUnsubscribe: SubscribeHandler? = nil
  ) -> Observable<Value> {
    Observable<Value> { subscriber in
      onSubscribe?()
      let subscription = self.subscribe(
        next: { value in
          onNext?(value)
          subscriber.next(value)
        },
        error: { error in
          onError?(error)
          subscriber.error(error)
        },
        complete: {
          onComplete?()
          subscriber.complete()
        }
      )
      return {
        onUnsubscribe?()
        subscription.unsubscribe()
      }
    }
  }
}
