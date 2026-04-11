//
//  CountIf.swift
//  TimeSeries
//
//

import Foundation

/// Counts data points within a time period that satisfy a given condition.
///
/// The condition closure is evaluated for each data point in the period.
/// The output type is always `Int`.
///
/// ```swift
/// // Count how many temperature readings exceeded 30 degrees
/// let hotCount = CountIf<Double> { $0 > 30.0 }
/// ```
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
