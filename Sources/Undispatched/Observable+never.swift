// Copyright (c) 2024 Harry Lachenmayer

extension Observable {
  public static var never: Observable<Value> {
    Observable { _ in nil }
  }
}
