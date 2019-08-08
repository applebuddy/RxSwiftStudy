
extension Promise: CustomStringConvertible {
    /// - Returns: A description of the state of this promise.
    public var description: String {
        switch result {
        case nil:
            return "Promise(…\(T.self))"
        case let .rejected(error)?:
            return "Promise(\(error))"
        case let .fulfilled(value)?:
            return "Promise(\(value))"
        }
    }
}

extension Promise: CustomDebugStringConvertible {
    /// - Returns: A debug-friendly description of the state of this promise.
    public var debugDescription: String {
        switch box.inspect() {
        case let .pending(handlers):
            return "Promise<\(T.self)>.pending(handlers: \(handlers.bodies.count))"
        case let .resolved(.rejected(error)):
            return "Promise<\(T.self)>.rejected(\(type(of: error)).\(error))"
        case let .resolved(.fulfilled(value)):
            return "Promise<\(T.self)>.fulfilled(\(value))"
        }
    }
}

#if !SWIFT_PACKAGE
    extension AnyPromise {
        /// - Returns: A description of the state of this promise.
        open override var description: String {
            switch box.inspect() {
            case .pending:
                return "AnyPromise(…)"
            case let .resolved(obj?):
                return "AnyPromise(\(obj))"
            case .resolved(nil):
                return "AnyPromise(nil)"
            }
        }
    }
#endif
