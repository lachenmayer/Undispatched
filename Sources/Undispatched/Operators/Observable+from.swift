//
//  Observable+from.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 18/12/2024.
//

extension Observable {
  public static func from<InnerValue>(_ values: [InnerValue]) -> Observable<InnerValue> {
    Observable<InnerValue> { observer in
      for value in values {
        observer.next(value)
      }
      observer.complete()
      return nil
    }
  }
}
