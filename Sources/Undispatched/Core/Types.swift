// Copyright (c) 2024 Harry Lachenmayer

public typealias NextHandler<V: Sendable> = @Sendable (V) -> Void
public typealias ErrorHandler = @Sendable (Error) -> Void
public typealias CompleteHandler = @Sendable () -> Void
public typealias UnsubscribeLogic = @Sendable () -> Void
public typealias SubscribeLogic<Value: Sendable> = @Sendable (Subscriber<Value>) throws
  -> UnsubscribeLogic?

typealias Finalizer = Ref<UnsubscribeLogic>

public protocol SubscriberProtocol: Sendable {
  associatedtype Value: Sendable

  var isCompleted: Bool { get }

  func next(_ value: Value)
  func error(_ error: Error)
  func complete()
}

public protocol SubjectProtocol: SubscriberProtocol, ObservableProtocol {}

public enum ObservableEvent<Value> {
  case next(Value)
  case error(AnyError)
  case complete
}

extension ObservableEvent: Sendable where Value: Sendable {}
extension ObservableEvent: Equatable where Value: Equatable {}
