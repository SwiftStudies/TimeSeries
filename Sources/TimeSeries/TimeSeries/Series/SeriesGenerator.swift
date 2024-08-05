//
//  SeriesGenerator.swift
//  TimeSeries
//
//

import Foundation

/// Generates time periods to be used for `TimeSeries`
public protocol SeriesGenerator {
    /// Generates the full sequence of time periods used to summarize the original data
    /// - Returns: A sequence of closed ranges capturing distinct non-overlapping periods 
    func generate() -> any Sequence<ClosedRange<TimeInterval>>
}
