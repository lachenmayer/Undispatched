//
//  Observable+materialize.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 04/01/2025.
//

extension Observable {

  public func materialize() -> Observable<ObservableEvent<Value>> {
    Observable<ObservableEvent<Value>> { subscriber in
      self.subscribe(
        next: { value in
          subscriber.next(ObservableEvent.next(value))
        },
        error: { error in
          subscriber.next(ObservableEvent.error(AnyError(error)))
          subscriber.complete()
        },
        complete: {
          subscriber.next(ObservableEvent.complete)
          subscriber.complete()
        })
    }
  }
}
