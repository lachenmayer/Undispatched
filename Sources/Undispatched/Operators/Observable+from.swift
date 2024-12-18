//
//  Observable+from.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 18/12/2024.
//

extension Observable {
  public static func from<InnerValue>(_ values: [InnerValue]) -> Observable<InnerValue> {
    Observable<InnerValue> { subscriber in
      for value in values {
        if subscriber.isCompleted { return nil }
        subscriber.next(value)
      }
      subscriber.complete()
      return nil
    }
  }
}
