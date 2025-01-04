//
//  TestHelpers.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 04/01/2025.
//

import Testing

struct TestError: Error {}

func fail(_ comment: Comment? = nil, sourceLocation: SourceLocation = #_sourceLocation) {
  try! #require(Bool(false), comment, sourceLocation: sourceLocation)
}

func fail(_ error: Error, sourceLocation: SourceLocation = #_sourceLocation) {
  fail("\(error.localizedDescription)", sourceLocation: sourceLocation)
}
