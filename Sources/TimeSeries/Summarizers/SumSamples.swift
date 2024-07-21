//
//  SumSamples.swift
//  TimeSeries
//
//

import Foundation

/// Sums the values of all samples in the period. Result will be 0 if there are no samples in the period
public struct SumSamples<S:Sampleable> : Summarizer  where S:SignedNumeric {
    public typealias DataType = S
    public typealias SourceType = S
    
    public func summarize(series: any Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        let sum = series[dataPointsFrom: start...(start+period)].map{$0.value}.reduce(0,+)
        return DataPoint<S>(value: sum, timeInterval: start)
    }
}
