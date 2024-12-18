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

public protocol ObservableProtocol: Sendable {
  associatedtype Value: Sendable

  func subscribe(next: NextHandler<Value>?, error: ErrorHandler?, complete: CompleteHandler?)
    -> AnySubscriber
}

extension ObservableProtocol {
  public func subscribe<S: SubscriberProtocol>(_ subscriber: S) -> AnySubscriber
  where Self.Value == S.Value {
    subscribe(next: subscriber.next, error: subscriber.error, complete: subscriber.complete)
  }
}

public protocol SubjectProtocol: SubscriberProtocol, ObservableProtocol {}
