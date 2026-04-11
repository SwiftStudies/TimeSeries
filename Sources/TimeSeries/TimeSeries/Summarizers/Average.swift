//
//  Average.swift
//  TimeSeries
//
//

import Foundation

/// Computes the average value across a time period for integer types (`BinaryInteger`).
///
/// Takes `subSamples` evenly spaced readings across the period and returns their mean.
/// For floating-point types, use ``AverageFloatingPointValue`` instead.
public struct AverageIntegerValue<S:Sampleable> : Summarizer where S : BinaryInteger {
    public typealias DataType = S
    public typealias SourceType = S
    
    /// The number of evenly spaced readings taken across each period.
    let subSamples : Int

    /// Creates a new integer averaging summarizer.
    /// - Parameter subSamplesPerInterval: The number of evenly spaced readings per period. Defaults to 10.
    init(_ subSamplesPerInterval:Int = 10) {
        subSamples = subSamplesPerInterval
    }

    /// Computes the average of `subSamples` evenly spaced readings across the period.
    public func summarize(series: any Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        var sum   = S.zero
        var count = S.zero

        for sampleAt in stride(from: start, to: start+period, by: period/TimeInterval(subSamples)){
            sum += series[sampleAt][0]
            count += 1
        }

        return DataPoint<DataType>(value: sum/count, timeInterval: start)
    }
}

/// Computes the average value across a time period for floating-point types (`FloatingPoint`).
///
/// Takes `subSamples` evenly spaced readings across the period and returns their mean.
/// For integer types, use ``AverageIntegerValue`` instead.
public struct AverageFloatingPointValue<S:Sampleable> : Summarizer where S : FloatingPoint {
    public typealias DataType = S
    public typealias SourceType = S

    /// The number of evenly spaced readings taken across each period.
    let subSamples : Int

    /// Creates a new floating-point averaging summarizer.
    /// - Parameter subSamplesPerInterval: The number of evenly spaced readings per period. Defaults to 10.
    init(_ subSamplesPerInterval:Int = 10) {
        subSamples = subSamplesPerInterval
    }

    /// Computes the average of `subSamples` evenly spaced readings across the period.
    public func summarize(series: any Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        var sum   = S.zero
        var count = S.zero
        
        for sampleAt in stride(from: start, to: start+period, by: period/TimeInterval(subSamples)){
            sum += series[sampleAt][0]
            count += 1
        }
        
        return DataPoint<DataType>(value: sum/count, timeInterval: start)
    }
}
