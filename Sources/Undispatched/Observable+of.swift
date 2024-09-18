//
//  Observable+of.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 18/09/2024.
//

public extension Observable {
  static func of(_ values: Value...) -> Observable<Value> {
    Observable { observer in
      for value in values {
        observer.next(value)
      }
      observer.complete()
      return nil
    }
  }
}
