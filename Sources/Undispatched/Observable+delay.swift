//
//  Observable+delay.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 18/12/2024.
//

import Foundation

extension Observable {
  public func delay(_ time: TimeInterval) -> Observable<Value> {
    mergeMap { value in
      try await Task.sleep(for: .seconds(time))
      return value
    }
  }
}
