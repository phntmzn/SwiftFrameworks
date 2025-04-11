import Foundation

/// A generic thunk that delays the evaluation of a computation until its value is needed.
public struct Thunk<T> {
    private let computation: () -> T
    private lazy var _value: T = self.computation()
    
    /// Initializes the thunk with a computation.
    /// - Parameter computation: The closure whose result will be lazily computed.
    public init(_ computation: @escaping () -> T) {
        self.computation = computation
    }
    
    /// Returns the computed value, executing the computation if necessary.
    public var value: T {
        mutating get {
            return _value
        }
    }
}

// MARK: - Example Usage

/// Demonstrates the use of Thunk.
/// The computation won't run until `thunk.value` is accessed.
public func exampleThunkUsage() {
    var thunk = Thunk { () -> Int in
        print("Computing value...")
        return 42
    }
    
    // The computation is delayed until this line is executed.
    print("Before accessing thunk.value")
    let result = thunk.value
    print("Result is: \(result)")
}
