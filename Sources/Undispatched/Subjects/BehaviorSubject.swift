//
//  BehaviorSubject.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 14/11/2024.
//

import Synchronization

public final class BehaviorSubject<Value: Sendable>: SubjectProtocol {
  private let currentValue: Mutex<Value>
  private let subject = Subject<Value>()

  public init(_ value: Value) {
    self.currentValue = Mutex(value)
  }

  public var isCompleted: Bool {
    subject.isCompleted
  }

  public var value: Value {
    get throws {
      let error = subject.state.withLock { state -> Error? in
        if case let .errored(error) = state { return error }
        return nil
      }
      if let error { throw error }
      return currentValue.withLock { $0 }
    }
  }

  public func next(_ value: Value) {
    currentValue.withLock { $0 = value }
    subject.next(value)
  }

  public func error(_ error: any Error) {
    subject.error(error)
  }

  public func complete() {
    subject.complete()
  }

  public func subscribe(
    next: NextHandler<Value>? = nil, error: ErrorHandler? = nil, complete: CompleteHandler? = nil
  )
    -> Subscription
  {
    let subscription = subject.subscribe(next: next, error: error, complete: complete)
    if !subscription.isCompleted, let currentValue = try? value {
      next?(currentValue)
    }
    return subscription
  }

  public func unsubscribe() {
    subject.unsubscribe()
  }
}
