// Copyright (c) 2024 Harry Lachenmayer

public extension Observable {
  static func of(_ values: Value...) -> Observable<Value> {
    Observable { observer in
      for value in values {
        observer.next(value)
      }
      observer.complete()
      return nil
    }
  }
}
