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
    
    /// A closure that evaluates whether a data point should be counted.
    public typealias Condition = @Sendable (PointType) -> Bool

    fileprivate let condition : Condition

    /// Creates a new conditional counter with the given predicate.
    /// - Parameter condition: A closure that returns `true` for data points that should be counted.
    public init(_ condition: @escaping Condition){
        self.condition = condition
    }

    /// Counts data points in the period where ``condition`` returns `true`.
    public func summarize(series: any Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<Int> {
        return DataPoint<Int>(value: series[dataPointsFrom: start...(start+period)].filter({condition($0.value)}).count, timeInterval: start)
    }
}
