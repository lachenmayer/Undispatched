//
//  BehaviorSubject.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 18/09/2024.
//

import Synchronization

final class StateSubject<Value: Sendable>: Sendable {
  private let state: Mutex<Value>
  
  init(initialState: Value) {
    state = Mutex(initialState)
  }
  
  func next(_ value: Value) {
    
  }
  
  func error(_ error: Error) {
    
  }
  
  func complete() {
    
  }
}
