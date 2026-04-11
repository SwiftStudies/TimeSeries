//
//  MinMax.swift
//  TimeSeries
//
//

import Foundation

fileprivate extension Sequence where Element : Comparable, Element : Sampleable, Element:SignedNumeric {
    var minimum : Element {
        return self.min() ?? Self.Element.default
    }
    
    var maximum : Element {
        return self.max() ?? Self.Element.default
    }
}

/// Returns the minimum value within a time period. Requires `Comparable & SignedNumeric`.
public struct MinimumValue<S:Sampleable> : Summarizer where S : Comparable, S : SignedNumeric{
    public typealias DataType = S
    public typealias SourceType = S

    /// Returns the minimum value found across all samples in the period (including interpolated boundary values).
    public func summarize(series: any Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        return DataPoint<S>(value: series[samplesFor: start...(start+period)-1.nanoseconds].map({$0.value}).minimum, timeInterval: start)
    }
}

/// Returns the maximum value within a time period. Requires `Comparable & SignedNumeric`.
public struct MaximumValue<S:Sampleable> : Summarizer where S : Comparable, S : SignedNumeric{
    public typealias DataType = S
    public typealias SourceType = S

    /// Returns the maximum value found across all samples in the period (including interpolated boundary values).
    public func summarize(series: any Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        return DataPoint<S>(value: series[samplesFor: start...(start+period)-1.nanoseconds].map({$0.value}).maximum, timeInterval: start)
    }
}
