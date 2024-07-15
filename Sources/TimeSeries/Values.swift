//
//  Values.swift
//  TimeSeries
//
//

/// Sampleable captures the basic requirements for any type to be used in a sample or time series
public protocol Sampleable : Equatable {
    /// The default value of an instance of this type
    static var `default` : Self { get }
    
    /// Are the two values in tolerance against this value?
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

