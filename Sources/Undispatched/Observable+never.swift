// Copyright (c) 2024 Picnic Ventures, Ltd.

public extension Observable {
  static var never: Observable<Value> {
    Observable { _ in nil }
  }
}
