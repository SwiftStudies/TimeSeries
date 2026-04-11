//
//  ValueAt.swift
//  TimeSeries
//
//

import Foundation

/// Specifies a position within a time interval for ``MeasureValue`` sampling.
public enum Position {
    /// The start of the interval.
    case beginning
    /// The midpoint of the interval.
    case middle
    /// One nanosecond before the end of the interval (to avoid overlap with the next period).
    case end
}

/// Samples the value at a specific position (beginning, middle, or end) within each time period.
///
/// This is the default summarizer when `DataSeriesPointType` and `TimeSeriesPointType` are the
/// same ``Sampleable`` type. It defaults to sampling at the `.beginning` of each period.
public struct MeasureValue<S:Sampleable> : Summarizer{
    public typealias DataType = S
    public typealias SourceType = S
    
    private let position : Position
    
    
    /// Creates a new instance that will measure a sample period at the specified position in the interval.
    /// - Parameter position: The desired position, defaults to `beginning` if not supplied
    public init(at position: Position = .beginning) {
        self.position = position
    }
    
    public func summarize(series: any Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        let sampleAt : TimeInterval
        switch position {
        case .beginning:
            sampleAt = start
        case .middle:
            sampleAt = (start+(period/2))
        case .end:
            sampleAt = (start+period)-1.nanoseconds
        }
        
        return DataPoint<DataType>(value: series[sampleAt][0], timeInterval: start)
    }
}
