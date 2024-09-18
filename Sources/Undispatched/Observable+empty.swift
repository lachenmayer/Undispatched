// Copyright (c) 2024 Picnic Ventures, Ltd.

public extension Observable {
  static var empty: Observable<Value> {
    Observable { observer in
      observer.complete()
      return nil
    }
  }
}
