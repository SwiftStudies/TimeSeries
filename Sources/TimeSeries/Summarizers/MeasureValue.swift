//
//  ValueAt.swift
//  TimeSeries
//
//

import Foundation

/// Captures where in an an interval
public enum Position {
    case beginning, middle, end
}

/// Summarizes a period by sampling at the end of the period and returning that value (defined as 1 nanosecond before the start of the next period)
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
