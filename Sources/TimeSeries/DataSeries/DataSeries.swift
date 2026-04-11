//
//  DataSeries.swift
//  TimeSeries
//
//

import Foundation

/// Thrown when `capture(_:at:)` is called with a time earlier than the most recent data point.
///
/// All series require data to be captured in chronological order.
public enum CaptureError : Error {
    /// The supplied time was before the most recently captured data point.
    case captureOutOfOrder
}

/// A protocol for any chronologically ordered collection of time-stamped data points.
///
/// `DataSeries` is the core storage abstraction in this library. Concrete implementations include:
/// - ``EventSeries`` -- for discrete events (multiple values allowed at the same time)
/// - ``SampleSeries`` -- for continuously changing values (one value per time, with interpolation)
///
/// All times are `TimeInterval` values representing seconds since the reference date
/// (matching `Date.timeIntervalSinceReferenceDate`).
///
/// Data must be captured in chronological order. Attempting to capture a point before the
/// most recent one throws ``CaptureError/captureOutOfOrder``.
public protocol DataSeries<DataPointType> {
    /// The type of value stored in each ``DataPoint`` of this series.
    associatedtype DataPointType

    /// The closed range from the earliest to the latest captured time.
    /// Returns `0...0` if the series is empty.
    var timeRange : ClosedRange<TimeInterval> { get }

    /// Removes all data points from the series.
    mutating func clear()

    /// Removes all data points captured after the specified time.
    /// - Parameter time: The cutoff time (seconds since reference date). Points at exactly this time are kept.
    mutating func clear(after time: TimeInterval)

    /// Appends a new data point. The time must be >= the most recent capture.
    ///
    /// - Parameters:
    ///     - point: The value to capture.
    ///     - at: The time the value was observed, as seconds since the reference date.
    ///
    /// - Throws: ``CaptureError/captureOutOfOrder`` if `time` is before the most recent capture.
    mutating func capture(_ point:DataPointType, at time: TimeInterval) throws(CaptureError)

    /// Returns all data points within the given closed time range.
    ///
    /// - Parameter range: A closed range of `TimeInterval` values to query.
    /// - Returns: An array of ``DataPoint`` values in chronological order, or empty if none exist in the range.
    subscript(dataPointsFrom range:ClosedRange<TimeInterval>)->[DataPoint<DataPointType>] { get }

    /// Returns values at exactly the specified time.
    ///
    /// For ``EventSeries``, this may return multiple values. For ``SampleSeries``, this returns
    /// a single-element array with the interpolated value (or the default if the series is empty).
    ///
    /// - Parameter time: The time to query, as seconds since the reference date.
    /// - Returns: An array of values at that time.
    subscript (_ time: TimeInterval) -> [DataPointType] { get }

    /// The most recently captured data point, or `nil` if the series is empty.
    var newest : DataPoint<DataPointType>? { get }

    /// The earliest captured data point, or `nil` if the series is empty.
    var oldest : DataPoint<DataPointType>? { get }
}

