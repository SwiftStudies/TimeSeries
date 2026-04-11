//
//  IntervalGenerator.swift
//  TimeSeries
//
//

import Foundation

/// A ``SeriesGenerator`` that produces regular, equally spaced time intervals.
///
/// Use this when all periods should have the same length (e.g., hourly intervals over a day).
///
/// ```swift
/// let generator = IntervalGenerator(
///     start: Date.now.timeIntervalSinceReferenceDate,
///     totalDuration: 24.hours,
///     periodLength: 1.hours
/// )
/// // Produces 24 one-hour periods
/// ```
public struct IntervalGenerator : SeriesGenerator {
    let start : TimeInterval
    let totalDuration : TimeInterval
    let periodLength : TimeInterval
    
    /// Creates new instance of an `IntervalGenerator`
    /// - Parameters:
    ///   - start: The start of the series
    ///   - totalDuration: The total length of the series
    ///   - periodLength: The length of each period in the series
    public init(start: TimeInterval, totalDuration: TimeInterval, periodLength: TimeInterval) {
        self.start = start
        self.totalDuration = totalDuration
        self.periodLength = periodLength
    }
    
    /// Generates equally spaced periods of length ``periodLength`` covering ``totalDuration``.
    public func generate() -> any Sequence<ClosedRange<TimeInterval>> {
        var result : [ClosedRange<TimeInterval>] = []

        for time in stride(from: start, to: start+totalDuration, by: periodLength){
            result.append(time...(time+periodLength))
        }
        
        return result
    }
    
}
