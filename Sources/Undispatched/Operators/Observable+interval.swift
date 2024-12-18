// Copyright (c) 2024 Harry Lachenmayer

extension Observable<Int> {
  public static func interval<C>(
    _ duration: C.Instant.Duration,
    clock: C = ContinuousClock()
  ) -> Observable<Int> where C: Clock {
    Observable<Int>.emitter { next in
      var i = 0
      while true {
        try? await Task.sleep(for: duration, tolerance: .zero, clock: clock)
        if Task.isCancelled { return }
        next(i)
        i += 1
      }
    }
  }
}
