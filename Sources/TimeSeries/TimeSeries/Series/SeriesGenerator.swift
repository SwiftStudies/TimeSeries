//
//  SeriesGenerator.swift
//  TimeSeries
//
//

import Foundation

/// A protocol for generating sequences of non-overlapping time periods, used for calendar-aware summarization.
///
/// Unlike the fixed-interval approach in ``TimeSeries/summarize(from:to:with:)``, a `SeriesGenerator`
/// can produce irregular periods (e.g., months of varying length). Built-in implementations:
/// - ``IntervalGenerator`` -- regular fixed-length intervals
/// - ``WeekSeries`` -- 7 daily periods starting from a date
/// - ``MonthSeries`` -- one period per day for the month containing a date
/// - ``Rolling12MonthsSeries`` -- 12 monthly periods starting from a date
public protocol SeriesGenerator {
    /// Produces the sequence of time periods.
    /// - Returns: A sequence of non-overlapping `ClosedRange<TimeInterval>` values in chronological order.
    func generate() -> any Sequence<ClosedRange<TimeInterval>>
}
