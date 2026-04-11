//
//  Interpolator.swift
//  TimeSeries
//
//  Created by Nigel Hughes on 7/15/24.
//

/// A strategy for computing intermediate values between two data points in a ``SampleSeries``.
///
/// When a ``SampleSeries`` is queried at a time between two captured data points, it uses
/// its `Interpolator` to calculate the result. Three built-in implementations are provided:
///
/// - ``StepInterpolator`` -- Holds the previous value until the next capture. Default for non-numeric types.
/// - ``RoundingInterpolator`` -- Returns the nearer value, switching at the midpoint.
/// - ``LinearInterpolator`` -- Linearly interpolates between values. Default for `Int`, `Double`, `Float`.
///
/// To provide custom interpolation, conform a type to this protocol and pass it to
/// `SampleSeries.init(_:tolerance:interpolatedWith:)`.
public protocol Interpolator<T>{
    associatedtype T
    /// Creates a default instance of the interpolator.
    init()

    /// Computes an intermediate value between `start` and `end`.
    /// - Parameters:
    ///   - fraction: A value from 0.0 (= `start`) to 1.0 (= `end`) indicating position between the two points.
    ///   - start: The earlier value.
    ///   - end: The later value.
    /// - Returns: The interpolated value at the given fraction.
    func interpolate(at fraction:Double, between start:T, and end:T)->T
}

/// Returns the nearer of two values, switching from `start` to `end` at the midpoint (fraction >= 0.5).
public struct RoundingInterpolator<T> : Interpolator {
    /// Creates a new rounding interpolator.
    public init(){

    }
    /// Returns `start` when `fraction` < 0.5, otherwise returns `end`.
    public func interpolate(at fraction:Double, between start:T, and end:T)->T{
        if fraction < 0.5 {
            return start
        }
        
        return end
    }
}

/// Holds the previous value until the exact next capture point (fraction == 1.0). Default for non-numeric types.
public struct StepInterpolator<T> : Interpolator {
    /// Creates a new step interpolator.
    public init(){

    }
    /// Returns `start` when `fraction` < 1.0, otherwise returns `end`.
    public func interpolate(at fraction:Double, between start:T, and end:T)->T{
        if fraction < 1.0 {
            return start
        }
        
        return end
    }
}

/// Linearly interpolates between two values when `T` conforms to ``NumericallyInterpolateable``.
/// Falls back to ``RoundingInterpolator`` for types that do not support numeric interpolation.
/// This is the default interpolator for `Int`, `Double`, and `Float` in ``SampleSeries``.
public struct LinearInterpolator<T> : Interpolator {
    let fallback = RoundingInterpolator<T>()

    /// Creates a new linear interpolator.
    public init(){

    }

    /// Computes a linearly interpolated value if `T` conforms to ``NumericallyInterpolateable``,
    /// otherwise delegates to ``RoundingInterpolator``.
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

/// A protocol enabling ``LinearInterpolator`` to perform arithmetic interpolation on a type.
///
/// Types conforming to this protocol can convert to and from `Double`, which is used as the
/// intermediate representation during linear interpolation. Default conformances are provided
/// for `Int`, `Double`, and `Float`.
///
/// Conform custom numeric types to this protocol to enable linear interpolation in ``SampleSeries``.
public protocol NumericallyInterpolateable {
    /// Creates a new instance from a `Double` value.
    /// - Parameter value: The `Double` to convert from.
    /// - Returns: The closest representable value of this type.
    func from(value:Double)->Self

    /// This value represented as a `Double`, used as the basis for interpolation arithmetic.
    var doubleValue:Double { get }
}

/// Enables ``LinearInterpolator`` support for `Int`. Truncates toward zero when converting from `Double`.
extension Int : NumericallyInterpolateable {
    public func from(value: Double) -> Int {
        return Int(value)
    }
    
    public var doubleValue:Double {
        return Double(self)
    }
}

/// Enables ``LinearInterpolator`` support for `Double`. No precision loss during conversion.
extension Double : NumericallyInterpolateable {
    public func from(value: Double) -> Double {
        return value
    }
    
    public var doubleValue:Double {
        return self
    }
}

/// Enables ``LinearInterpolator`` support for `Float`. May lose precision when converting through `Double`.
extension Float : NumericallyInterpolateable {
    public func from(value: Double) -> Float {
        return Float(value)
    }
    
    public var doubleValue:Double {
        return Double(self)
    }
}

