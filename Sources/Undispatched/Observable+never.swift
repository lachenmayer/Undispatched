// Copyright (c) 2024 Harry Lachenmayer

public extension Observable {
  static var never: Observable<Value> {
    Observable { _ in nil }
  }
}
