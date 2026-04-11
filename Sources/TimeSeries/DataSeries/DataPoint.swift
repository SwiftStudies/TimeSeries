//
//  DataPoint.swift
//  TimeSeries
//
//
import Foundation

/// A single value associated with a point in time, used as the fundamental element in all series types.
///
/// `DataPoint` pairs a generic value with a `TimeInterval` (seconds since the reference date,
/// matching `Date.timeIntervalSinceReferenceDate`). It is used as both input (captured data) and
/// output (summarized results) throughout the library.
///
/// ```swift
/// let point = DataPoint(value: 21.5, timeInterval: Date.now.timeIntervalSinceReferenceDate)
/// print(point.date)  // Converts back to a Date
/// print(point.value) // 21.5
/// ```
public struct DataPoint<T> {
    /// The stored value at this point in time.
    public let value   : T

    /// The time this data point represents, expressed as seconds since the reference date
    /// (i.e., the same epoch as `Date.timeIntervalSinceReferenceDate`).
    public let timeInterval    : TimeInterval

    /// A convenience property that converts `timeInterval` back to a `Date`.
    public var date    : Date {
        return Date(timeIntervalSinceReferenceDate: timeInterval)
    }

    /// Creates a new data point.
    /// - Parameters:
    ///   - value: The value to store.
    ///   - timeInterval: The time this value was captured or calculated, as seconds since the reference date.
    public init(value: T, timeInterval: TimeInterval) {
        self.value = value
        self.timeInterval = timeInterval
    }
}
