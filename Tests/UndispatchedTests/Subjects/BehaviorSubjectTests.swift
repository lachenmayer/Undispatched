//
//  BehaviorSubjectTests.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 04/01/2025.
//

import Synchronization
import Testing
import Undispatched

enum BehaviorSubjectTests {
  @Test static func shouldHaveValue() async throws {
    let subject = BehaviorSubject(123)
    #expect(try subject.value == 123)
    subject.next(124)
    #expect(try subject.value == 124)
  }

  @Test static func shouldThrowAfterError() async throws {
    let subject = BehaviorSubject(0)
    subject.error(TestError())
    #expect(throws: TestError.self) {
      try subject.value
    }
  }

  @Test static func shouldBeClosedIfUnsubscribed() async throws {
    let subject = BehaviorSubject(123)
    #expect(!subject.isCompleted)
    subject.unsubscribe()
    #expect(subject.isCompleted)
  }

  @Test static func shouldBeClosedAfterError() async throws {
    let subject = BehaviorSubject(123)
    subject.error(TestError())
    #expect(subject.isCompleted)
  }

  @Test static func shouldBeClosedAfterComplete() async throws {
    let subject = BehaviorSubject(123)
    subject.complete()
    #expect(subject.isCompleted)
  }

  @Test static func shouldStartWithInitialValue() async throws {
    await confirmation { done in
      let subject = BehaviorSubject(123)
      let expecteds = Mutex([123, 124])

      let subscription = subject.subscribe(
        next: { actual in
          let expected = expecteds.withLock { $0.removeFirst() }
          #expect(actual == expected)
        },
        error: { error in fail(error) },
        complete: { done.confirm() }
      )

      subject.next(124)
      subject.complete()

      subscription.unsubscribe()
    }
  }

  @Test static func shouldSendValuesToMultipleSubscribers() async throws {
    await confirmation(expectedCount: 2) { done in
      let subject = BehaviorSubject<Int>(-1)

      let actuals1 = Mutex([-1, 0, 1, 2])
      let subscription1 = subject.subscribe(
        next: { expected in
          let actual = actuals1.withLock {
            $0.removeFirst()
          }
          #expect(expected == actual)
        },
        complete: { done.confirm() }
      )

      let actuals2 = Mutex([-1, 0, 1, 2])
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

  @Test static func shouldNotSendValuesAfterComplete() async throws {
    let subject = BehaviorSubject("init")
    let results = Mutex([String]())

    let subscription = subject.subscribe(next: { value in
      results.withLock { $0.append(value) }
    })

    #expect(results.withLock { $0 } == ["init"])

    subject.next("foo")

    #expect(results.withLock { $0 } == ["init", "foo"])

    subject.complete()

    #expect(results.withLock { $0 } == ["init", "foo"])

    subject.next("bar")

    #expect(results.withLock { $0 } == ["init", "foo"])

    subscription.unsubscribe()
  }

  @Test static func shouldReplayPreviousValueWhenSubscribed() async throws {
    await confirmation { done in
      let subject = BehaviorSubject(-1)
      let expecteds = Mutex([0, 1, 2])
      subject.next(0)
      let subscription = subject.subscribe(
        next: { actual in
          let expected = expecteds.withLock { $0.removeFirst() }
          #expect(expected == actual)
        },
        complete: { done.confirm() }
      )
      subject.next(1)
      subject.next(2)
      subject.complete()
      subscription.unsubscribe()
    }

  }
}
