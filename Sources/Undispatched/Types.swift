// Copyright (c) 2024 Harry Lachenmayer

public typealias NextHandler<V: Sendable> = @Sendable (V) -> Void
public typealias ErrorHandler = @Sendable (Error) -> Void
public typealias CompleteHandler = @Sendable () -> Void
public typealias TeardownHandler = @Sendable () -> Void
public typealias SubscribeLogic<Value: Sendable> = @Sendable (Observer<Value>) throws
  -> TeardownHandler?
typealias Finalizer = Ref<TeardownHandler>

public protocol ObserverProtocol {
  associatedtype Value: Sendable

  func next(_ value: Value) -> Void
  func error(_ error: Error) -> Void
  func complete() -> Void
}

public protocol Subscribable {
  associatedtype Value: Sendable

  func subscribe(_ observer: Observer<Value>) -> TeardownHandler?
}
