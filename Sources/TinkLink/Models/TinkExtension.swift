import Foundation

public struct Tink<Base> {
    public var base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol TinkCompatible {
    static var tink: Tink<Self>.Type { get set }
    
    var tink: Tink<Self> { get set }
}

extension TinkCompatible {
    public static var tink: Tink<Self>.Type {
        get {
            return Tink<Self>.self
        }
        set {
        }
    }
    
    public var tink: Tink<Self> {
        get {
            return Tink(self)
        }
        set {
        }
    }
}
