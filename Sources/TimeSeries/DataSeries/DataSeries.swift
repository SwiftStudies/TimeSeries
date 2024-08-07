//
//  DataSeries.swift
//  TimeSeries
//
//

import Foundation

/// Errors that can occur when a new sample is captured in a SampleSeries
public enum CaptureError : Error {
    case captureOutOfOrder
}

/// Any series of points in (and captured in) chronological order
public protocol DataSeries<DataPointType> {
    associatedtype DataPointType
    
    /// The time the a point was first captured, to the time of the last point
    var timeRange : ClosedRange<TimeInterval> { get }

    /// Removes all points
    mutating func clear()
    
    
    /// Removes all points after the specified time
    /// - Parameter time: Interval since reference data after which all data points should be cleared
    mutating func clear(after time: TimeInterval)
    

    /// Adds a new point, which must always be no sooner than the most recent sample. An error will be thrown if not.
    ///
    /// - Parameters:
    ///     - point: The new sample
    ///     - at: The time the point was captured
    ///
    /// - Throws: `CaptureError.captureOutOfOrder` if the time is before the most recent capture
    mutating func capture(_ point:DataPointType, at time: TimeInterval) throws(CaptureError)

    /// Provides data points for the supplied time range. If none were taken in this range it will be empty
    ///
    /// - Parameters:
    /// - time: The  range of times to capture samples between
    ///
    /// - Returns: An `Array` of `DataPoint`s containing samples in chronological order
    subscript(dataPointsFrom range:ClosedRange<TimeInterval>)->[DataPoint<DataPointType>] { get }
    
    /// All points captured at the specified time (since reference date)
    ///
    /// - Parameters:
    /// - time: The `TimeInterval` to capture at
    ///
    /// - Returns: An array of all points at that time`
    subscript (_ time: TimeInterval) -> [DataPointType] { get }
    
    /// The last captured data-point
    var newest : DataPoint<DataPointType>? { get }

    /// The first captured data-point
    var oldest : DataPoint<DataPointType>? { get }
}

