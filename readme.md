# Undispatched

Reactive extensions (Rx) implemented using Swift 6 concurrency.

The goal is to align this as closely to the RxJS design, but safely multi-threaded, without using `DispatchGroup` or any other 'legacy' concurrency features.

## TODO

- [ ] `BehaviorSubject`: emit current value before others
- [ ] `ReplaySubject` - implement with `replay: 1`
- [ ] `share`
- [ ] `shareReplay`
