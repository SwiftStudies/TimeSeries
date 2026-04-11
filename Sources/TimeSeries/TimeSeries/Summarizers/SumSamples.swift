//
//  SumSamples.swift
//  TimeSeries
//
//

import Foundation

/// Sums all captured data point values within a time period. Returns zero if no data points exist in the period.
/// Requires `SignedNumeric`.
public struct SumSamples<S:Sampleable> : Summarizer  where S:SignedNumeric {
    public typealias DataType = S
    public typealias SourceType = S
    
    public func summarize(series: any Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        let sum = series[dataPointsFrom: start...(start+period)].map{$0.value}.reduce(0,+)
        return DataPoint<S>(value: sum, timeInterval: start)
    }
}
