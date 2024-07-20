//
//  ValueAtEnd.swift
//  TimeSeries
//
//

import Foundation

/// Summarizes a period by sampling at the end of the period and returning that value (defined as 1 nanosecond before the start of the next period)
public struct ValueAtEnd<S:Sampleable> : Summarizer{
    public typealias DataType = S
    public typealias SampleType = S
    
    public func summarize(series: Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        let sampleAt = (start+period)-1.nanoseconds
        return DataPoint<DataType>(value: series[sampleAt], timeInterval: start)
    }
}
