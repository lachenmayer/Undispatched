// Copyright (c) 2024 Harry Lachenmayer

extension Observable {
  public static var empty: Observable<Value> {
    Observable { observer in
      observer.complete()
      return nil
    }
  }
}
