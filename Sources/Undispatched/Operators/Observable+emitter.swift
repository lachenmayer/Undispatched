// Copyright (c) 2024 Harry Lachenmayer

extension Observable {
  public static func emitter(
    _ create: @Sendable @escaping (NextHandler<Value>) async throws -> Void
  )
    -> Observable<Value>
  {
    Observable { observer in
      let task = Task {
        do {
          try await create(observer.next)
          observer.complete()
        } catch {
          observer.error(error)
        }
      }
      return task.cancel
    }
  }
}
