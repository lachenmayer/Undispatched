// Copyright (c) 2024 Harry Lachenmayer

import Synchronization

public final class Subscriber<Value: Sendable>: ObserverProtocol, Sendable {
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

  private let completedState = Mutex(false)

  public var isCompleted: Bool { completedState.withLock { $0 } }

  private func maybeComplete() -> Bool {
    completedState.withLock { completed in
      let alreadyCompleted = completed
      completed = true
      return alreadyCompleted
    }
  }

  private let finalizedState = Mutex(false)

  var isFinalized: Bool { finalizedState.withLock { $0 } }

  private func maybeFinalized() -> Bool {
    finalizedState.withLock { finalized in
      let alreadyFinalized = finalized
      finalized = true
      return alreadyFinalized
    }
  }

  // TODO: Should this be an ordered set?
  private let finalizers = Mutex(Set<Finalizer>())

  private func addFinalizer(_ finalizer: Finalizer) {
    let _ = finalizers.withLock { $0.insert(finalizer) }
  }

  private func removeFinalizer(_ finalizer: Finalizer) {
    let _ = finalizers.withLock { $0.remove(finalizer) }
  }

  public func next(_ value: Value) {
    if isCompleted { return }
    destinationNext?(value)
  }

  public func error(_ error: Error) {
    let alreadyCompleted = maybeComplete()
    if alreadyCompleted { return }
    destinationError?(error)
  }

  public func complete() {
    let alreadyCompleted = maybeComplete()
    if alreadyCompleted { return }
    destinationComplete?()
  }

  func unsubscribe() {
    let alreadyClosed = maybeFinalized()
    if alreadyClosed { return }
    completedState.withLock { $0 = true }
    let finalizers = finalizers.withLock { $0 }
    for finalizer in finalizers {
      finalizer.value()
    }
  }

  func add(_ unsubscribeLogic: UnsubscribeLogic?) {
    guard let unsubscribeLogic else { return }
    add(finalizer: Finalizer(unsubscribeLogic))
  }

  private func add(finalizer: Finalizer) {
    if isFinalized {
      finalizer.value()
    } else {
      addFinalizer(finalizer)
    }
  }

  private func add(subscriber: Subscriber<Value>) {
    guard subscriber !== self else { return }
    if isFinalized {
      subscriber.unsubscribe()
    } else {
      let unsubscribe = Finalizer { @Sendable in subscriber.unsubscribe() }
      let remove = Finalizer { [weak self] in self?.removeFinalizer(unsubscribe) }
      subscriber.add(finalizer: remove)
      add(finalizer: unsubscribe)
    }
  }
}
