// Copyright (c) 2024 Harry Lachenmayer

import Synchronization

extension Observable {
  public func values() async throws -> [Value] {
    let subscription = Mutex<AnySubscriber?>(nil)
    let values = ConcurrentArray<Value>()
    try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { continuation in
        let valueSubscription = subscribe(
          next: { value in values.append(value) },
          error: { error in continuation.resume(throwing: error) },
          complete: { continuation.resume(returning: ()) }
        )
        subscription.withLock {
          $0 = valueSubscription
        }
      }
    } onCancel: {
      subscription.withLock { $0 }?.unsubscribe()
    }
    return values.values
  }
}

private final class ConcurrentArray<Value: Sendable>: Sendable {
  private let array = Mutex([Value]())

  func append(_ value: Value) {
    array.withLock { $0.append(value) }
  }

  var values: [Value] {
    array.withLock { $0 }
  }
}
