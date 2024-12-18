// Copyright (c) 2024 Harry Lachenmayer

extension Observable {
  public static func async(_ create: @Sendable @escaping () async throws -> Value) -> Observable<
    Value
  > {
    Observable { observer in
      let task = Task {
        do {
          let value = try await create()
          observer.next(value)
          observer.complete()
        } catch is CancellationError {
          // Do nothing.
        } catch {
          observer.error(error)
        }
      }
      return task.cancel
    }
  }
}
