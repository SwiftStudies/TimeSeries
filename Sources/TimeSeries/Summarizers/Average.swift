//
//  Average.swift
//  TimeSeries
//
//

import Foundation

/// Summarizes a period by sampling a specified number of times across the period and averaging them. This supports Integer types.
/// If you need to do the same for `Double` or `Float` use `AverageFloatingPointValue`
public struct AverageIntegerValue<S:Sampleable> : Summarizer where S : BinaryInteger {
    public typealias DataType = S
    public typealias SampleType = S
    
    /// How many sub-samples to capture
    let subSamples : Int
    
    init(_ subSamplesPerInterval:Int = 10) {
        subSamples = subSamplesPerInterval
    }
    
    public func summarize(series: Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        var sum   = S.zero
        var count = S.zero
        
        for sampleAt in stride(from: start, to: start+period, by: period/TimeInterval(subSamples)){
            sum += series[sampleAt]
            count += 1
        }
        
        return DataPoint<DataType>(value: sum/count, timeInterval: start)
    }
}

/// Summarizes a period by sampling a specified number of times across the period and averaging them. This supports floatingn point types.
/// If you need to do the same for Integer types  use `AverageIntPointValue`
public struct AverageFloatingPointValue<S:Sampleable> : Summarizer where S : FloatingPoint {
    public typealias DataType = S
    public typealias SampleType = S
    
    /// How many sub-samples to capture
    let subSamples : Int
    
    init(_ subSamplesPerInterval:Int = 10) {
        subSamples = subSamplesPerInterval
    }
    
    public func summarize(series: Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        var sum   = S.zero
        var count = S.zero
        
        for sampleAt in stride(from: start, to: start+period, by: period/TimeInterval(subSamples)){
            sum += series[sampleAt]
            count += 1
        }
        
        return DataPoint<DataType>(value: sum/count, timeInterval: start)
    }
}
