//
//  Count.swift
//  TimeSeries
//
//

import Foundation

/// Counts the number of captured data points within a time period.
///
/// Works with any source type, including both ``EventSeries`` and ``SampleSeries`` data.
/// The output type is always `Int`.
public struct Count<PointType> : Summarizer {
    public typealias DataType = Int
    public typealias SourceType = PointType
    
    /// Returns the count of data points captured within the period.
    public func summarize(series: any Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<Int> {
        return DataPoint<Int>(value: series[dataPointsFrom: start...(start+period)].count, timeInterval: start)
    }
}
