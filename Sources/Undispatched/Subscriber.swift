// Copyright (c) 2024 Picnic Ventures, Ltd.

import Synchronization

final class Subscriber<Value: Sendable>: Observer, Sendable {
    private let destinationNext: NextHandler<Value>?
    private let destinationError: ErrorHandler?
    private let destinationComplete: CompleteHandler?
    private let destinationAddFinalizer: (@Sendable (Finalizer) -> Void)?
    private let destinationAddSubscriber: (@Sendable (Subscriber<Value>) -> Void)?

    init(
        next: NextHandler<Value>? = nil,
        error: ErrorHandler? = nil,
        complete: CompleteHandler? = nil
    ) {
        destinationNext = next
        destinationError = error
        destinationComplete = complete
        destinationAddFinalizer = nil
        destinationAddSubscriber = nil
    }

    init(
        destination: Subscriber<Value>
    ) {
        destinationNext = destination.next
        destinationError = destination.error
        destinationComplete = destination.complete
        destinationAddFinalizer = destination.add(finalizer:)
        destinationAddSubscriber = destination.add(subscriber:)
        destination.add(subscriber: self)
    }

    private let stopped = Mutex(false)

    private var isStopped: Bool {
        stopped.withLock { $0 }
    }

    private func stop() -> Bool {
        stopped.withLock { stopped in
            let alreadyStopped = stopped
            stopped = true
            return alreadyStopped
        }
    }

    private let closed = Mutex(false)
    private var isClosed: Bool { closed.withLock { $0 } }

    // TODO: Should this be an ordered set?
    private let finalizers = Mutex(Set<Finalizer>())

    private func addFinalizer(_ finalizer: Finalizer) {
        let _ = finalizers.withLock { $0.insert(finalizer) }
    }

    private func removeFinalizer(_ finalizer: Finalizer) {
        let _ = finalizers.withLock { $0.remove(finalizer) }
    }

    func next(_ value: Value) {
        if isStopped { return }
        destinationNext?(value)
    }

    func error(_ error: Error) {
        let alreadyStopped = stop()
        if alreadyStopped { return }
        destinationError?(error)
    }

    func complete() {
        let alreadyStopped = stop()
        if alreadyStopped { return }
        destinationComplete?()
    }

    func unsubscribe() {
        if isClosed { return }
        closed.withLock { $0 = true }
        let finalizers = finalizers.withLock { $0 }
        for finalizer in finalizers {
            finalizer.value()
        }
    }

    func add(_ teardown: TeardownHandler?) {
        guard let teardown else { return }
        add(finalizer: Finalizer(teardown))
    }

    private func add(finalizer: Finalizer) {
        if isClosed {
            finalizer.value()
        } else {
            addFinalizer(finalizer)
        }
    }

    private func add(subscriber: Subscriber<Value>) {
        guard subscriber !== self else { return }
        if isClosed {
            subscriber.unsubscribe()
        } else {
            let unsubscribe = Finalizer { @Sendable in subscriber.unsubscribe() }
            let remove = Finalizer { [weak self] in self?.removeFinalizer(unsubscribe) }
            subscriber.add(finalizer: remove)
            add(finalizer: unsubscribe)
        }
    }
}
