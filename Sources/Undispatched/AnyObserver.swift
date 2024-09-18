// Copyright (c) 2024 Picnic Ventures, Ltd.

public struct AnyObserver<Value: Sendable>: Observer {
    private let _next: NextHandler<Value>?
    private let _error: ErrorHandler?
    private let _complete: CompleteHandler?

    init(next: NextHandler<Value>?, error: ErrorHandler?, complete: CompleteHandler?) {
        _next = next
        _error = error
        _complete = complete
    }

    public func next(_ value: Value) {
        _next?(value)
    }

    public func error(_ error: Error) {
        _error?(error)
    }

    public func complete() {
        _complete?()
    }
}
