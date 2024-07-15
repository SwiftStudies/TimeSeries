//
//  Interpolator.swift
//  TimeSeries
//
//  Created by Nigel Hughes on 7/15/24.
//

public protocol Interpolator<T>{
    associatedtype T
    init()
    func interpolate(at fraction:Double, between start:T, and end:T)->T
}

public struct RoundingInterpolator<T> : Interpolator {
    public init(){
        
    }
    public func interpolate(at fraction:Double, between start:T, and end:T)->T{
        if fraction < 0.5 {
            return start
        }
        
        return end
    }
}

public struct StepInterpolator<T> : Interpolator {
    public init(){
        
    }
    public func interpolate(at fraction:Double, between start:T, and end:T)->T{
        if fraction < 1.0 {
            return start
        }
        
        return end
    }
}

public struct LinearInterpolator<T> : Interpolator {
    let fallback = RoundingInterpolator<T>()
    
    
    
    public init(){
        
    }
    
    public func interpolate(at fraction:Double, between start:T, and end:T)->T {
        if let start = start as? NumericallyInterpolateable, let end = end as? NumericallyInterpolateable {
            let interpolatedValue = start.doubleValue + fraction * (end.doubleValue - start.doubleValue)
            if let value = start.from(value: interpolatedValue) as? T {
                return value
            }
        }
        
        return fallback.interpolate(at: fraction, between: start, and: end)
    }
}

public protocol NumericallyInterpolateable {
    /// Creates a new instance of self with a value based on the supplied `Double`
    /// - Parameter value: The `Double` value to create an equivalent of
    /// - Returns: An instance of the type
    func from(value:Double)->Self
    
    /// This `Value` represented as the nearest possible `Double`. Used during interpolation
    var doubleValue:Double { get }
}

extension Int : NumericallyInterpolateable {
    public func from(value: Double) -> Int {
        return Int(value)
    }
    
    public var doubleValue:Double {
        return Double(self)
    }
}

extension Double : NumericallyInterpolateable {
    public func from(value: Double) -> Double {
        return value
    }
    
    public var doubleValue:Double {
        return self
    }
}

extension Float : NumericallyInterpolateable {
    public func from(value: Double) -> Float {
        return Float(value)
    }
    
    public var doubleValue:Double {
        return Double(self)
    }
}

