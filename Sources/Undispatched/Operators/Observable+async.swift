// Copyright (c) 2024 Harry Lachenmayer

extension Observable {
  public static func async(_ create: @Sendable @escaping () async throws -> Value) -> Observable<
    Value
  > {
    Observable { subscriber in
      let task = Task {
        if subscriber.isCompleted { return }
        do {
          let value = try await create()
          subscriber.next(value)
          subscriber.complete()
        } catch is CancellationError {
          // Do nothing.
        } catch {
          subscriber.error(error)
        }
      }
      return task.cancel
    }
  }
}
