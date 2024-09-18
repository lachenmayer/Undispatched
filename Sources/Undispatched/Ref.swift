// Copyright (c) 2024 Picnic Ventures, Ltd.

final class Ref<Value: Sendable>: Equatable, Hashable, Sendable {
    var id: ObjectIdentifier { ObjectIdentifier(self) }
    let value: Value

    init(_ value: Value) {
        self.value = value
    }

    static func == (lhs: Ref, rhs: Ref) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
