//
//  Summarizer.swift
//  TimeSeries
//
//

import Foundation

/// A strategy for reducing a time period of source data into a single ``DataPoint``.
///
/// Summarizers are used by ``TimeSeries`` to convert raw data from a ``DataSeries`` into
/// fixed-interval summary values. The `SourceType` is the type stored in the source series,
/// and `DataType` is the type of the summarized output (these can differ, e.g., ``Count``
/// produces `Int` output from any source type).
///
/// Built-in summarizers:
/// - ``MeasureValue`` -- samples at a position (beginning, middle, or end) within the period
/// - ``AverageFloatingPointValue`` / ``AverageIntegerValue`` -- averages across sub-samples
/// - ``Count`` -- counts data points in the period
/// - ``CountIf`` -- counts data points matching a condition
/// - ``MinimumValue`` / ``MaximumValue`` -- extremes within the period
/// - ``SumSamples`` -- sums all values in the period
///
/// To create a custom summarizer, conform to this protocol and implement ``summarize(series:for:startingAt:)``.
public protocol Summarizer<SourceType, DataType> {
    /// The type of values in the source ``DataSeries``.
    associatedtype SourceType

    /// The type of the summarized output value.
    associatedtype DataType
    typealias Series = DataSeries<SourceType>

    /// Reduces a time period in the source series to a single data point.
    /// - Parameters:
    ///   - series: The source ``DataSeries`` to read from.
    ///   - period: The length of the time period to summarize, in seconds.
    ///   - start: The start of the period, as seconds since the reference date.
    /// - Returns: A ``DataPoint`` representing the summarized value, timestamped at `start`.
    func summarize(series:any Series, for period:TimeInterval, startingAt start:TimeInterval) -> DataPoint<DataType>
}
