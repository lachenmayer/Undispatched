//
//  Subject.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 14/11/2024.
//

import Synchronization

public final class Subject<Value: Sendable>: Sendable, SubjectProtocol {
  enum State {
    case completed
    case errored(_ error: Error)
    case open(_ observers: Observers)
  }

  struct Observers: Sendable {
    fileprivate let nextId: Int
    private let observers: [Int: Observer<Value>]

    typealias Values = [Int: Observer<Value>].Values

    fileprivate init() {
      nextId = 0
      observers = [:]
    }

    private init(nextId: Int, observers: [Int: Observer<Value>]) {
      self.nextId = nextId
      self.observers = observers
    }

    var values: Values { observers.values }

    fileprivate func add(_ observer: Observer<Value>) -> Observers {
      var observers = self.observers
      observers[self.nextId] = observer
      return Observers(nextId: self.nextId + 1, observers: observers)
    }

    fileprivate func remove(_ id: Int) -> Observers {
      var observers = self.observers
      observers.removeValue(forKey: id)
      return Observers(nextId: self.nextId, observers: observers)
    }
  }

  let state = Mutex<State>(State.open(Observers()))

  public var isClosed: Bool {
    state.withLock {
      if case .open = $0 { return false }
      return true
    }
  }

  public init() {}

  // MARK: Observer

  public func next(_ value: Value) {
    if isClosed { return }
    let observers = state.withLock { state -> Observers.Values? in
      if case let .open(observers) = state {
        return observers.values
      }
      return nil
    }
    guard let observers else { return /* Completed/errored already. */ }
    for observer in observers {
      observer.next(value)
    }
  }

  public func error(_ error: any Error) {
    let observers = state.withLock { state -> Observers? in
      if case let .open(observers) = state {
        state = .errored(error)
        return observers
      }
      return nil
    }
    guard let observers else { return /* Completed/errored already. */ }
    for observer in observers.values {
      observer.error(error)
    }
  }

  public func complete() {
    let observers = state.withLock { state -> Observers? in
      if case let .open(observers) = state {
        state = .completed
        return observers
      }
      return nil
    }
    guard let observers else { return /* Completed/errored already. */ }
    for observer in observers.values {
      observer.complete()
    }
  }

  // MARK: Subscription

  public func unsubscribe() {
    state.withLock {
      if case .open = $0 { $0 = .completed }
    }
  }

  // MARK: Observable

  public func subscribe(
    next: NextHandler<Value>? = nil,
    error: ErrorHandler? = nil,
    complete: CompleteHandler? = nil
  ) -> Subscription {
    let subscriber = Subscriber(next: next, error: error, complete: complete)
    let observer = Observer(
      next: subscriber.next,
      error: subscriber.error,
      complete: subscriber.complete
    )
    let observerId = state.withLock { state -> Int? in
      if case let .open(observers) = state {
        let observerId = observers.nextId
        state = .open(observers.add(observer))
        return observerId
      }
      return nil
    }
    guard let observerId else {
      // Already closed.
      return Subscription.empty
    }
    subscriber.add { [weak self] in
      self?.state.withLock { state in
        if case let .open(observers) = state {
          state = .open(observers.remove(observerId))
        }
      }
    }
    return Subscription(subscriber: subscriber)
  }

  public var observable: Observable<Value> {
    Observable { observer in
      let subscription = self.subscribe(observer)
      return subscription.unsubscribe
    }
  }
}
