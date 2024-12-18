// Copyright (c) 2024 Harry Lachenmayer

extension Observable {
  public static func error(_ error: Error) -> Observable<Value> {
    Observable { subscriber in
      subscriber.error(error)
      return nil
    }
  }
}
