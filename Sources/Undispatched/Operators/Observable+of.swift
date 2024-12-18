// Copyright (c) 2024 Harry Lachenmayer

extension Observable {
  public static func of(_ values: Value...) -> Observable<Value> {
    Observable { subscriber in
      for value in values {
        subscriber.next(value)
      }
      subscriber.complete()
      return nil
    }
  }
}
