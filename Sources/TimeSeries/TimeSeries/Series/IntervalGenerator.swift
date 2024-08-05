//
//  IntervalGenerator.swift
//  TimeSeries
//
//

import Foundation

/// Standard regular and consistent time intervals
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
    
    public func generate() -> any Sequence<ClosedRange<TimeInterval>> {
        var result : [ClosedRange<TimeInterval>] = []
        
        for time in stride(from: start, to: start+totalDuration, by: periodLength){
            result.append(time...(time+periodLength))
        }
        
        return result
    }
    
}
