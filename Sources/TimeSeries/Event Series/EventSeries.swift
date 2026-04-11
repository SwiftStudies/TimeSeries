//
//  EventSeries.swift
//  TimeSeries
//
//

import Foundation

/// A ``DataSeries`` for storing discrete events in chronological order.
///
/// Unlike ``SampleSeries``, multiple events can share the same timestamp, and no interpolation
/// is performed between events. This makes `EventSeries` suitable for logs, detections, or
/// notifications where each occurrence is independent.
///
/// ```swift
/// var events = EventSeries<String>()
/// let now = Date.now.timeIntervalSinceReferenceDate
/// try events.capture("doorbell", at: now)
/// try events.capture("motion", at: now) // two events at the same time is fine
/// ```
///
/// When used with ``TimeSeries``, the ``Count`` and ``CountIf`` summarizers are typically
/// the most appropriate choices for summarizing event data into fixed intervals.
public struct EventSeries<EventType> : DataSeries {
    public typealias DataPointType = EventType

    var dataPoints: [DataPoint<EventType>] = []

    /// Creates an empty event series.
    public init(){

    }
    
    /// The closed range from the earliest to the latest event time. Returns `0...0` if empty.
    public var timeRange: ClosedRange<TimeInterval> {
        guard let first = dataPoints.first, let last = dataPoints.last else {
            return 0...0
        }

        return first.timeInterval...last.timeInterval
    }
    
    /// Removes all events from the series.
    mutating public func clear() {
        dataPoints.removeAll()
    }

    /// Removes all events captured after the specified time. Events at exactly `time` are kept.
    mutating public func clear(after time: TimeInterval) {
        dataPoints = dataPoints.filter { dataPoint in
            return dataPoint.timeInterval <= time
        }
    }
    
    /// Appends an event. The time must be >= the most recent capture.
    /// - Throws: ``CaptureError/captureOutOfOrder`` if `time` is before the most recent event.
    mutating public func capture(_ point: EventType, at time: TimeInterval) throws(CaptureError) {
        if let last = dataPoints.last {
            guard last.timeInterval <= time else {
                throw CaptureError.captureOutOfOrder
            }
        }
        dataPoints.append(DataPoint<DataPointType>(value: point, timeInterval: time))
    }
    
    /// Returns all events within the given closed time range, in chronological order.
    public subscript(dataPointsFrom range: ClosedRange<TimeInterval>) -> [DataPoint<EventType>] {
        return dataPoints.filter { dataPoint in
            return dataPoint.timeInterval >= range.lowerBound && dataPoint.timeInterval <= range.upperBound
        }
    }
    
    /// Returns all event values at exactly the specified time, or an empty array if none.
    public subscript(time: TimeInterval) -> [EventType] {
        return dataPoints.filter { dataPoint in
            return dataPoint.timeInterval == time
        }.map({$0.value})
    }
    
    /// The earliest captured event, or `nil` if the series is empty.
    public var oldest: DataPoint<EventType>? {
        return dataPoints.first
    }

    /// The most recently captured event, or `nil` if the series is empty.
    public var newest: DataPoint<EventType>?{
        return dataPoints.last
    }
}
