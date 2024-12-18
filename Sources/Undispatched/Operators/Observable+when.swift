//
//  Observable+when.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 18/12/2024.
//

extension Observable {
  public func when<Whatever>(_ trigger: Observable<Whatever>) -> Observable<Value> {
    trigger.withLatestFrom(self).map { $0.1 }
  }
}
