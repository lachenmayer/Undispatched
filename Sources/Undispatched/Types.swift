// Copyright (c) 2024 Picnic Ventures, Ltd.

public typealias NextHandler<V: Sendable> = @Sendable (V) -> Void
public typealias ErrorHandler = @Sendable (Error) -> Void
public typealias CompleteHandler = @Sendable () -> Void
public typealias TeardownHandler = @Sendable () -> Void
public typealias SubscribeLogic<Value: Sendable> = @Sendable (AnyObserver<Value>) throws
    -> TeardownHandler?
typealias Finalizer = Ref<TeardownHandler>

public protocol Observer {
    associatedtype Value: Sendable

    func next(_ value: Value) -> Void
    func error(_ error: Error) -> Void
    func complete() -> Void
}
