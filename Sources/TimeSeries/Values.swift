//
//  Values.swift
//  TimeSeries
//
//

public protocol Value : Numeric, Comparable {
    init(from value:Double)
    
    var doubleValue:Double { get }
    var absoluteValue:Self { get }
}

extension Double : Value {
    public init(from value:Double) {
        self = value
    }
    
    public var doubleValue:Double {
        return self
    }
    
    public var absoluteValue: Double{
        return abs(self)
    }
}

extension Float : Value {
    public init(from value:Double) {
        self = Float(value)
    }
    
    public var doubleValue:Double {
        return Double(self)
    }
    
    public var absoluteValue: Float{
        return abs(self)
    }
}

extension Int : Value {
    public init(from value:Double) {
        self = Int(value)
    }
    
    public var doubleValue:Double {
        return Double(self)
    }
    
    public var absoluteValue: Int{
        return abs(self)
    }
}
