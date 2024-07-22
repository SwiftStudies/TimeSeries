//
//  CountIf.swift
//  TimeSeries
//
//

import Foundation

/// Counts the number of samples in the period providing they meet a supplied condition
public struct CountIf<PointType:Sendable> : Summarizer {
    public typealias DataType = Int
    public typealias SourceType = PointType
    
    public typealias Condition = @Sendable (PointType) -> Bool
    
    fileprivate let condition : Condition
    
    public init(_ condition: @escaping Condition){
        self.condition = condition
    }
    
    public func summarize(series: any Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<Int> {
        return DataPoint<Int>(value: series[dataPointsFrom: start...(start+period)].filter({condition($0.value)}).count, timeInterval: start)
    }
}
