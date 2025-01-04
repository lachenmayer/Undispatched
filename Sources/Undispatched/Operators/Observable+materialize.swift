//
//  Observable+materialize.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 04/01/2025.
//

extension Observable {

  public func materialize() -> Observable<ObservableEvent<Value>> {
    Observable<ObservableEvent<Value>> { observer in
      self.subscribe(
        next: { value in
          observer.next(ObservableEvent.next(value))
        },
        error: { error in
          observer.next(ObservableEvent.error(AnyError(error)))
          observer.complete()
        },
        complete: {
          observer.next(ObservableEvent.complete)
          observer.complete()
        })
    }
  }
}
