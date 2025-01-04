//
//  SubjectTests.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 04/01/2025.
//

import Synchronization
import Testing
import Undispatched

enum SubjectTests {
  @Test static func shouldSendValuesToSubscriber() async throws {
    await confirmation { done in
      let subject = Subject<Int>()

      let actuals = Mutex([0, 1, 2])
      let subscription = subject.subscribe(
        next: { expected in
          let actual = actuals.withLock {
            $0.removeFirst()
          }
          #expect(expected == actual)
        },
        complete: { done.confirm() }
      )

      subject.next(0)
      subject.next(1)
      subject.next(2)
      subject.complete()

      #expect(subscription.isCompleted)
    }
  }

  @Test static func shouldSendValuesToMultipleSubscribers() async throws {
    await confirmation(expectedCount: 2) { done in
      let subject = Subject<Int>()

      let actuals1 = Mutex([0, 1, 2])
      let subscription1 = subject.subscribe(
        next: { expected in
          let actual = actuals1.withLock {
            $0.removeFirst()
          }
          #expect(expected == actual)
        },
        complete: { done.confirm() }
      )

      let actuals2 = Mutex([0, 1, 2])
      let subscription2 = subject.subscribe(
        next: { expected in
          let actual = actuals2.withLock {
            $0.removeFirst()
          }
          #expect(expected == actual)
        },
        complete: { done.confirm() }
      )

      subject.next(0)
      subject.next(1)
      subject.next(2)
      subject.complete()

      #expect(subscription1.isCompleted)
      #expect(subscription2.isCompleted)
    }
  }

  @Test static func shouldHandleSubscribersAtDifferentTimes() async throws {
    let subject = Subject<Int>()

    let events1 = Mutex([ObservableEvent<Int>]())
    let events2 = Mutex([ObservableEvent<Int>]())

    subject.next(1)
    subject.next(2)
    subject.next(3)
    subject.next(4)

    let subscription1 = subject.observable.materialize().subscribe(
      next: { value in events1.withLock { $0.append(value) } },
      error: { error in fail(error) },
      complete: {}
    )

    subject.next(5)

    let subscription2 = subject.observable.materialize().subscribe(
      next: { value in events2.withLock { $0.append(value) } },
      error: { error in fail(error) },
      complete: {}
    )

    subject.next(6)
    subject.next(7)

    subscription1.unsubscribe()

    subject.complete()

    subscription2.unsubscribe()

    let actual1 = events1.withLock { $0 }
    let actual2 = events2.withLock { $0 }

    #expect(actual1 == [.next(5), .next(6), .next(7)])
    #expect(actual2 == [.next(6), .next(7), .complete])

  }
}
