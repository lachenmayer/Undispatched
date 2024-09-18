// Copyright (c) 2024 Harry Lachenmayer

import os

let logger = Logger(subsystem: "me.lachenmayer.Undispatched", category: "Undispatched")

public extension Observable {
  func log(
    prefix: String? = nil,
    file: StaticString = #fileID,
    function: StaticString = #function,
    line: UInt = #line
  ) -> Observable<Value> {
    let logPrefix = if let prefix {
      "\(prefix) (\(file) \(function):\(line))"
    } else {
      "\(file) \(function):\(line)"
    }
    return tap(
      next: { value in
        logger.debug("\(logPrefix)\nnext \(String(describing: value))")
      },
      error: { error in
        logger.debug("\(logPrefix)\nerror \(error)")
      },
      complete: {
        logger.debug("\(logPrefix)\ncomplete")
      },
      subscribe: {
        logger.debug("\(logPrefix)\nsubscribe")
      },
      unsubscribe: {
        logger.debug("\(logPrefix)\nunsubscribe")
      }
    )
  }
}
