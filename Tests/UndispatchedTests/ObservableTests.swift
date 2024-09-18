// Copyright (c) 2024 Picnic Ventures, Ltd.

import Testing
import Undispatched

enum ObservableTests {
  @Test static func trivial() async throws {
    let observable = Observable<Int> { observer in
      observer.next(1)
      observer.complete()
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

  @Test static func errorInConstructor() async throws {
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

  @Test static func empty() async throws {
    let subscription = await confirmation { done in
      Observable<Int>.empty.subscribe(
        next: { _ in fail() }, error: { _ in fail() }, complete: { done.confirm() }
      )
    }
    subscription.unsubscribe()
  }

  @Test static func never() async throws {
    let subscription = Observable<Int>.never.subscribe(
      next: { _ in fail() }, error: { _ in fail() }, complete: { fail() }
    )
    // Should probably wait for some time...
    subscription.unsubscribe()
  }

  @Test static func of() async throws {
    let values = try await Observable.of(1, 2, 3).values()
    #expect(values == [1, 2, 3])
  }

  @Test static func map() async throws {
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
}

private struct TestError: Error {}

func fail() {
  #expect(Bool(false))
}
