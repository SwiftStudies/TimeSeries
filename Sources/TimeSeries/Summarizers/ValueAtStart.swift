//
//  ValueAtEnd.swift
//  TimeSeries
//
//

import Foundation

/// Summarizes a period by sampling the start  at the start of the period and returning that value
public struct ValueAtStart<S:Sampleable> : Summarizer{
    public typealias DataType = S
    public typealias SampleType = S
    
    public func summarize(series: Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        return DataPoint<DataType>(value: series[start], timeInterval: start)
    }
}
