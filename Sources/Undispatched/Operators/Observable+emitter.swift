// Copyright (c) 2024 Harry Lachenmayer

extension Observable {
  public static func emitter(
    _ create: @Sendable @escaping (NextHandler<Value>) async throws -> Void
  )
    -> Observable<Value>
  {
    Observable { subscriber in
      let task = Task {
        do {
          try await create(subscriber.next)
          subscriber.complete()
        } catch {
          subscriber.error(error)
        }
      }
      return task.cancel
    }
  }
}
