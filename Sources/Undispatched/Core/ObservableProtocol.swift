//
//  ObservableProtocol.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 20/12/2024.
//

public protocol ObservableProtocol: Sendable {
  associatedtype Value: Sendable

  func subscribe(next: NextHandler<Value>?, error: ErrorHandler?, complete: CompleteHandler?)
    -> Subscription
}

extension ObservableProtocol {
  public func subscribe<S: SubscriberProtocol>(_ subscriber: S) -> Subscription
  where Self.Value == S.Value {
    subscribe(next: subscriber.next, error: subscriber.error, complete: subscriber.complete)
  }
}

extension ObservableProtocol {
  public var observable: Observable<Value> {
    Observable { subscriber in self.subscribe(subscriber) }
  }
}
