// Copyright (c) 2024 Harry Lachenmayer

import Testing
import Undispatched

@Test func trivial() async throws {
  let observable = Observable<Int> { subscriber in
    subscriber.next(1)
    subscriber.complete()
    return nil
  }
  let subscription = await confirmation { done in
    observable.subscribe(
      next: { value in #expect(value == 1) },
      complete: { done.confirm() }
    )
  }
  subscription.unsubscribe()
}

@Test func errorInConstructor() async throws {
  let observable = Observable<Int> { _ in
    throw TestError()
  }
  let subscription = await confirmation { done in
    observable.subscribe(
      next: { _ in
        fail()
      },
      error: { _ in
        done.confirm()
      },
      complete: {
        fail()
      }
    )
  }
  subscription.unsubscribe()
}

@Test func empty() async throws {
  let subscription = await confirmation { done in
    Observable<Int>.empty.subscribe(
      next: { _ in fail() }, error: { _ in fail() }, complete: { done.confirm() }
    )
  }
  subscription.unsubscribe()
}

@Test func never() async throws {
  let subscription = Observable<Int>.never.subscribe(
    next: { _ in fail() }, error: { _ in fail() }, complete: { fail() }
  )
  // Should probably wait for some time...
  subscription.unsubscribe()
}

@Test func of() async throws {
  let values = try await Observable.of(1, 2, 3).values()
  #expect(values == [1, 2, 3])
}

@Test func map() async throws {
  let doubled = try await Observable.of(1, 2, 3).map { $0 * 2 }.values()
  #expect(doubled == [2, 4, 6])
  _ = await confirmation { done in
    Observable.of(1, 2, 3).map { value in
      if value == 2 { throw TestError() }
      return value
    }.subscribe(
      next: { #expect($0 == 1) },
      error: { _ in done.confirm() },
      complete: { fail() }
    )
  }
}

@Test func filter() async throws {
  let evens = try await Observable.of(1, 2, 3, 4, 5, 6).filter { $0.isMultiple(of: 2) }
    .values()
  #expect(evens == [2, 4, 6])
  await #expect(throws: TestError.self) {
    try await Observable.error(TestError()).filter { true }.values()
  }
}

@Test func switchMap() async throws {
  let values = try await Observable.of(1, 2, 3).switchMap { n in
    .of(n * 10, n * 10 + 1, n * 10 + 2)
  }.values()
  #expect(values == [10, 11, 12, 20, 21, 22, 30, 31, 32])
}

@Test func switchMapUnsubscribesFromInnerObservables() async throws {
  _ = await confirmation { done in
    _ = await confirmation(expectedCount: 2) { unsubscribe in
      Observable.of(1, 2, 3)
        .switchMap { n in
          Observable<Void> { _ in
            return { unsubscribe.confirm() }
          }
        }
        .subscribe(complete: { done.confirm() })
    }
  }
}

@Test func mergeMapSync() async throws {
  let values = try await Observable.of(1, 2, 3).mergeMap { n in
    .of(n * 10, n * 10 + 1, n * 10 + 2)
  }.values()
  #expect(values == [10, 11, 12, 20, 21, 22, 30, 31, 32])
}

@Test func mergeMapDelay() async throws {
  let values = try await Observable.of(1, 2, 3).mergeMap { n in
    Observable.merge(.of(n * 10), .of(n * 10 + 1).delay(0.01 * n))
  }.values()
  #expect(values == [10, 20, 30, 11, 21, 31])
}

@Test func take() async throws {
  let two = try await Observable.of(1, 2, 3, 4, 5).take(2).values()
  #expect(two == [1, 2])
  let one = try await Observable.of(1, 2, 3, 4, 5).take(1).values()
  #expect(one == [1])
  let zero = try await Observable.of(1, 2, 3, 4, 5).take(0).values()
  #expect(zero == [])
  let negative = try await Observable.of(1, 2, 3, 4, 5).take(-2).values()
  #expect(negative == [])
}

@Test func combineLatest() async throws {
  let left = Observable.interval(.seconds(0.1))
  let right = Observable.interval(.seconds(0.25))
  let values = try await Observable.combineLatest(left, right).take(4).values()
  #expect(values[0] == (1, 0))
  #expect(values[1] == (2, 0))
  #expect(values[2] == (3, 0))
  #expect(values[3] == (3, 1))
  #expect(values.count == 4)
}

@Test func withLatestFrom() async throws {
  let left = Observable.interval(.seconds(0.1))
  let right = Observable.interval(.seconds(0.25))
  let values = try await left.withLatestFrom(right).take(4).values()
  #expect(values[0] == (2, 0))
  #expect(values[1] == (3, 0))
  #expect(values[2] == (4, 1))
  #expect(values[3] == (5, 1))
  #expect(values.count == 4)
}

@Test func when() async throws {
  let left = Observable.interval(.seconds(0.1))
  let right = Observable.interval(.seconds(0.25))
  let values = try await left.when(right).take(4).values()
  #expect(values == [1, 3, 6, 8])
}

@Test func mainActor() async throws {
  @MainActor func runTest() async throws -> [Int] {
    try await Observable.of(1, 2, 3)
      .switchMap { @MainActor i in
        MainActor.assertIsolated()
        return i
      }
      .values()
  }
  let values = try await runTest()
  #expect(values == [])
}

@Test func subject() async throws {
  let subject = Subject<Int>()
  let valuesTask1 = Task { try await subject.observable.values() }
  let valuesTask2 = Task { try await subject.observable.values() }
  let valuesTask3 = Task { try await subject.observable.values() }
  Task {
    for i in (0...3) {
      try await Task.sleep(for: .milliseconds(50))
      subject.next(i)
    }
    subject.complete()
  }
  let values1 = try await valuesTask1.value
  #expect(values1 == [0, 1, 2, 3])
  let values2 = try await valuesTask2.value
  #expect(values2 == [0, 1, 2, 3])
  let values3 = try await valuesTask3.value
  #expect(values3 == [0, 1, 2, 3])
}

@Test func behaviorSubject() async throws {
  let subject = BehaviorSubject(0)
  let valuesTask1 = Task { try await subject.observable.values() }
  let valuesTask2 = Task { try await subject.observable.values() }
  let valuesTask3 = Task { try await subject.observable.values() }
  Task {
    for i in (0...3) {
      try await Task.sleep(for: .milliseconds(50))
      subject.next(i)
      #expect(try subject.value == i)
    }
    subject.complete()
  }
  let values1 = try await valuesTask1.value
  #expect(values1 == [0, 1, 2, 3])
  let values2 = try await valuesTask2.value
  #expect(values2 == [0, 1, 2, 3])
  let values3 = try await valuesTask3.value
  #expect(values3 == [0, 1, 2, 3])
}

@Test func distinctUntilChanged() async throws {
  let actual = try await Observable.of(1, 1, 1, 2, 3, 3, 4).distinctUntilChanged().values()
  #expect(actual == [1, 2, 3, 4])
}

private struct TestError: Error {}

func fail() {
  #expect(Bool(false))
}
