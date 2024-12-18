//
//  Observable+merge.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 18/12/2024.
//

extension Observable {
  public static func merge(_ observables: Observable<Value>...) -> Observable<Value> {
    merge(observables)
  }

  public static func merge(_ observables: [Observable<Value>]) -> Observable<Value> {
    Observable.from(observables).mergeMap(Function.identity)
  }
}
