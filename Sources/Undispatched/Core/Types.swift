// Copyright (c) 2024 Harry Lachenmayer

public typealias NextHandler<V: Sendable> = @Sendable (V) -> Void
public typealias ErrorHandler = @Sendable (Error) -> Void
public typealias CompleteHandler = @Sendable () -> Void
public typealias TeardownHandler = @Sendable () -> Void
public typealias SubscribeLogic<Value: Sendable> = @Sendable (Observer<Value>) throws
  -> TeardownHandler?
typealias Finalizer = Ref<TeardownHandler>

public protocol ObserverProtocol: Sendable {
  associatedtype Value: Sendable

  func next(_ value: Value)
  func error(_ error: Error)
  func complete()
}

public protocol ObservableProtocol: Sendable {
  associatedtype Value: Sendable

  func subscribe(next: NextHandler<Value>?, error: ErrorHandler?, complete: CompleteHandler?)
    -> Subscription
}

extension ObservableProtocol {
  public func subscribe<O: ObserverProtocol>(_ observer: O) -> Subscription
  where Self.Value == O.Value {
    subscribe(next: observer.next, error: observer.error, complete: observer.complete)
  }
}

public protocol SubjectProtocol: ObserverProtocol, ObservableProtocol {}
