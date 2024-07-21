//
//  CountSamples.swift
//  TimeSeries
//
//

import Foundation

/// Counts the number of samples in the period
public struct CountSamples<S:Sampleable> : Summarizer {
    public typealias DataType = Int
    public typealias SourceType = S
    
    public func summarize(series: any Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<Int> {
        return DataPoint<Int>(value: series[dataPointsFrom: start...(start+period)].count, timeInterval: start)
    }
}
