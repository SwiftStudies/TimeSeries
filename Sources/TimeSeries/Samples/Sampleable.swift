//
//  Sampleable.swift
//  TimeSeries
//
//

/// A protocol that types must conform to in order to be used with ``SampleSeries`` and ``TimeSeries``.
///
/// `Sampleable` requires:
/// - `Equatable` conformance for detecting value changes.
/// - A ``default`` value returned when the series has no data.
/// - An ``inTolerance(_:and:)`` method used to determine if consecutive values are close enough
///   to collapse during efficient storage (see ``SampleSeries`` tolerance behavior).
///
/// Default conformances are provided for `Int`, `Double`, and `Float`. For numeric types
/// (`SignedNumeric & Comparable`), `default` returns `.zero` and tolerance compares using
/// absolute difference.
public protocol Sampleable : Equatable {
    /// The fallback value returned when a ``SampleSeries`` has no captured data.
    static var `default` : Self { get }

    /// Checks whether two values are within this tolerance value of each other.
    ///
    /// When `self` is used as the tolerance for a ``SampleSeries``, this method determines
    /// whether consecutive captured values are similar enough to be collapsed into fewer
    /// stored data points.
    ///
    /// - Parameters:
    ///   - one: The first value to compare.
    ///   - other: The second value to compare.
    /// - Returns: `true` if the two values are within tolerance of each other.
    func inTolerance(_ one: Self, and other: Self) -> Bool
}

public extension Sampleable where Self : Equatable{
    
    func inTolerance(_ one: Self, and other: Self) -> Bool {
        return one == other
    }
}

public extension Sampleable where Self : SignedNumeric, Self : Comparable {
    static var `default` : Self {
        return Self.zero
    }

    func inTolerance(_ one: Self, and other: Self) -> Bool {
        return abs(one - other) <= self
    }
}

extension Int : Sampleable {
}

extension Double : Sampleable {
}

extension Float : Sampleable {
}

