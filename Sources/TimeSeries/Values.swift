//
//  Values.swift
//  TimeSeries
//
//

public protocol Value : SignedNumeric, Comparable {
    init(from value:Double)
    
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
