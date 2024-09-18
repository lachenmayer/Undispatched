//
//  Observable+Empty,Never.swift
//  Undispatched
//
//  Created by Harry Lachenmayer on 18/09/2024.
//

extension Observable {
    static var empty: Observable<Value> {
        Observable { observer in
            observer.complete()
            return nil
        }
    }

    static var never: Observable<Value> {
        Observable { _ in nil }
    }
}
