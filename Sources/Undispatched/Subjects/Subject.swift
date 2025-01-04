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
    case open(_ subscribers: Subscribers)
  }

  struct Subscribers: Sendable {
    fileprivate let nextId: Int
    private let subscribers: [Int: Subscriber<Value>]

    typealias Values = [Int: Subscriber<Value>].Values

    fileprivate init() {
      nextId = 0
      subscribers = [:]
    }

    private init(nextId: Int, subscribers: [Int: Subscriber<Value>]) {
      self.nextId = nextId
      self.subscribers = subscribers
    }

    var values: Values { subscribers.values }

    fileprivate func add(_ subscriber: Subscriber<Value>) -> Subscribers {
      var subscribers = self.subscribers
      subscribers[self.nextId] = subscriber
      return Subscribers(nextId: self.nextId + 1, subscribers: subscribers)
    }

    fileprivate func remove(_ id: Int) -> Subscribers {
      var subscribers = self.subscribers
      subscribers.removeValue(forKey: id)
      return Subscribers(nextId: self.nextId, subscribers: subscribers)
    }
  }

  let state = Mutex<State>(State.open(Subscribers()))

  public var isCompleted: Bool {
    state.withLock {
      if case .open = $0 { return false }
      return true
    }
  }

  public init() {}

  // MARK: Observer

  public func next(_ value: Value) {
    if isCompleted { return }
    let subscribers = state.withLock { state -> Subscribers.Values? in
      if case let .open(subscribers) = state {
        return subscribers.values
      }
      return nil
    }
    guard let subscribers else { return /* Completed/errored already. */ }
    for subscriber in subscribers {
      subscriber.next(value)
    }
  }

  public func error(_ error: any Error) {
    let subscribers = state.withLock { state -> Subscribers? in
      if case let .open(subscribers) = state {
        state = .errored(error)
        return subscribers
      }
      return nil
    }
    guard let subscribers else { return /* Completed/errored already. */ }
    for subscriber in subscribers.values {
      subscriber.error(error)
    }
  }

  public func complete() {
    let subscribers = state.withLock { state -> Subscribers? in
      if case let .open(subscribers) = state {
        state = .completed
        return subscribers
      }
      return nil
    }
    guard let subscribers else { return /* Completed/errored already. */ }
    for subscriber in subscribers.values {
      subscriber.complete()
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
    let subscriberId = state.withLock { state -> Int? in
      if case let .open(subscribers) = state {
        let subscriberId = subscribers.nextId
        state = .open(subscribers.add(subscriber))
        return subscriberId
      }
      return nil
    }
    guard let subscriberId else {
      // Already closed.
      return Subscription.empty
    }
    subscriber.add { [weak self] in
      self?.state.withLock { state in
        if case let .open(subscribers) = state {
          state = .open(subscribers.remove(subscriberId))
        }
      }
    }
    return Subscription(subscriber: subscriber)
  }
}
