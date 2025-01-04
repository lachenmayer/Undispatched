//
//  AnyError.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 04/01/2025.
//

public struct AnyError: Error {
  let error: Error

  public init(_ error: Error) {
    self.error = error
  }
}

extension AnyError: Equatable {
  public static func == (lhs: AnyError, rhs: AnyError) -> Bool {
    false
  }
}
