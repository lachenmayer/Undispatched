// Copyright (c) 2024 Harry Lachenmayer

public extension Observable {
  static var empty: Observable<Value> {
    Observable { observer in
      observer.complete()
      return nil
    }
  }
}
