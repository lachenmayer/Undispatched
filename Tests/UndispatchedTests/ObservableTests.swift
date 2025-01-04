// Copyright (c) 2024 Harry Lachenmayer

import Testing
import Undispatched

enum ObservableTests {
  @Test static func trivial() async throws {
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
  
  @Test static func errorInConstructor() async throws {
    let observable = Observable<Int> { _ -> Void in
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
  
}
