// Copyright (c) 2024 Harry Lachenmayer

extension Observable {
  public static var empty: Observable<Value> {
    Observable { subscriber in
      subscriber.complete()
      return nil
    }
  }
}
