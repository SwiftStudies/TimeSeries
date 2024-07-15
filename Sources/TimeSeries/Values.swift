//
//  Values.swift
//  TimeSeries
//
//

/// Values can be include in series (i.e. `SampleSeries` and `TimeSeries`). `Double`, `Float`, and `Int` already conform and you can create an extension to add your own to other types as you need to
public protocol Value : SignedNumeric, Comparable {
    
    /// Create a new value based on the supplied `Double` value. This is used during interpolation
    /// - Parameter value: The value to create
    init(from value:Double)
    
    
    /// This `Value` represented as the nearest possible `Double`. Used during interpolation
    var doubleValue:Double { get }
}

extension Double : Value {
    public init(from value:Double) {
        self = value
    }
    
    public var doubleValue:Double {
        return self
    }
}

extension Float : Value {
    public init(from value:Double) {
        self = Float(value)
    }
    
    public var doubleValue:Double {
        return Double(self)
    }
    
}

extension Int : Value {
    public init(from value:Double) {
        self = Int(value)
    }
    
    public var doubleValue:Double {
        return Double(self)
    }    
}

extension Value {
    func approximatelyEquals(_ other: Self, tolerance: Self) -> Bool {
        return abs(self - other) <= tolerance
    }
}
