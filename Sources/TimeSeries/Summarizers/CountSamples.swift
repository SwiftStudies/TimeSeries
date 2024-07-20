//
//  CountSamples.swift
//  TimeSeries
//
//

import Foundation

/// Counts the number of samples in the period
public struct CountSamples<S:Sampleable> : Summarizer {
    public typealias DataType = Int
    public typealias SampleType = S
    
    public func summarize(series: Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<Int> {
        return DataPoint<Int>(value: series[samplesIn: start...(start+period)].count, timeInterval: start)
    }
}
