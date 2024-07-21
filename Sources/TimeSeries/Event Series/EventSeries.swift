//
//  EventSeries.swift
//  TimeSeries
//
//

import Foundation

/// `EventSeries` are useful for capturing a stream of events that you subsequently want to count or process. Unlike a `SampleSeries` they do not have a single value at any point
/// in time but many events could theoretically occur at the same time
/// 
struct EventSeries<EventType> : DataSeries {
    typealias PointType = EventType
    
    var dataPoints: [DataPoint<EventType>] = []
    
    var timeRange: ClosedRange<TimeInterval> {
        guard let first = dataPoints.first, let last = dataPoints.last else {
            return 0...0
        }

        return first.timeInterval...last.timeInterval
    }
    
    mutating func clear() {
        dataPoints.removeAll()
    }
    
    mutating func capture(_ point: EventType, at time: TimeInterval) throws(CaptureError) {
        if let last = dataPoints.last {
            guard last.timeInterval <= time else {
                throw CaptureError.captureOutOfOrder
            }
        }
        dataPoints.append(DataPoint<PointType>(value: point, timeInterval: time))
    }
    
    subscript(dataPointsFrom range: ClosedRange<TimeInterval>) -> [DataPoint<EventType>] {
        return dataPoints.filter { dataPoint in
            return dataPoint.timeInterval >= range.lowerBound && dataPoint.timeInterval <= range.upperBound
        }
    }
    
    subscript(time: TimeInterval) -> [EventType] {
        return dataPoints.filter { dataPoint in
            return dataPoint.timeInterval == time
        }.map({$0.value})
    }
    
}
