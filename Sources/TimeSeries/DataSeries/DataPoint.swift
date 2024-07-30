//
//  DataPoint.swift
//  TimeSeries
//
//
import Foundation

/// A  value captured or calculated in a series at a certain point in time
public struct DataPoint<T> {
    /// The value
    public let value   : T
    
    /// Time in seconds since reference date when data point was captured
    public let timeInterval    : TimeInterval
    
    /// Date sample was taken
    public var date    : Date {
        return Date(timeIntervalSinceReferenceDate: timeInterval)
    }
    
    /// Creates a new instance of a `DataPoint`
    /// - Parameters:
    ///   - value: The value captured
    ///   - timeInterval: The time the value was captured
    public init(value: T, timeInterval: TimeInterval) {
        self.value = value
        self.timeInterval = timeInterval
    }
}
