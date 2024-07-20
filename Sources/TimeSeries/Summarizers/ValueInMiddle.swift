//
//  ValueInMiddle.swift
//  TimeSeries
//
//

import Foundation

/// Summarizes a period by sampling in the middle  of the period and returning that value
public struct ValueInMiddle<S:Sampleable> : Summarizer{
    public typealias DataType = S
    public typealias SampleType = S
    
    public func summarize(series: Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        let sampleAt = (start+(period/2))
        return DataPoint<DataType>(value: series[sampleAt], timeInterval: start)
    }
}
