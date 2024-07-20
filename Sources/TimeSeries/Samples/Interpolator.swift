//
//  Interpolator.swift
//  TimeSeries
//
//  Created by Nigel Hughes on 7/15/24.
//

/// A type implementing `Interpolator` can interpolate between any two values of its supported types. There are three default implementations, two of which can be used for any type at all, and the last is focused on numerical types (but will fall back to rounding)
public protocol Interpolator<T>{
    associatedtype T
    init()
    
    /// Produces a new value between start and end based on the supplied fraction
    /// - Parameters:
    ///   - fraction: How far from a start to end we would like the value in range 0.0 to 1.0. It is expected that 0.0 = start and 1.0 = end
    ///   - start: The first value
    ///   - end: The second value
    /// - Returns: A new value that is `fraction` between `start` and `end`
    func interpolate(at fraction:Double, between start:T, and end:T)->T
}

/// Roundung interpolator assumes that it should return end once it's at or over half-way between the two values
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

/// Step interpolator returns start until fraction == 1.0 and is the default for non-numerical types
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

/// Calculates a linear intpolation as long as the `T` is `NumericallyInterpolatable` and uses `RoundingInterpolator` if not
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

/// A protocol for types that can support  linear interpolation. The definition is currently pragmatic vs. stylish
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

