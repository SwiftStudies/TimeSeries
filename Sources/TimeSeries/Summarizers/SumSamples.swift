//
//  SumSamples.swift
//  TimeSeries
//
//

import Foundation

public struct SumSamples<S:Sampleable> : Summarizer  where S:SignedNumeric {
    public typealias DataType = S
    public typealias SampleType = S
    
    public func summarize(series: Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        let sum = series[samplesIn: start...(start+period)].map{$0.value}.reduce(0,+)
        return DataPoint<S>(value: sum, timeInterval: start)
    }
}
