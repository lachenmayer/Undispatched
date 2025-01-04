//
//  BehaviorSubjectTests.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 04/01/2025.
//

import Testing
import Undispatched

enum BehaviorSubjectTests {
  @Test static func shouldThrowAfterError() async throws {
    let subject = BehaviorSubject(0)
    subject.error(TestError())
    #expect(throws: TestError.self) {
      try subject.value
    }
  }

  @Test static func shouldBeClosedIfUnsubscribed() async throws {
    let subject = BehaviorSubject(123)
    //    subject.unsubscribe()
    #expect(subject.isCompleted)
  }
}
