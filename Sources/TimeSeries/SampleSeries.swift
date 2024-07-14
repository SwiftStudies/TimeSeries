//
//  TimeSeries.swift
//  TimeSeries
//
//
import Foundation

public enum SampleError : Error {
    case sampleBeforeEndOfTimeSeries
    case sampleNotInTimeSeries
}

@available(macOS 13, *)
public struct SampleSeries<T : Value> {
    let `default` : T
    let allowedDifference : T
    var dataPoints = [DataPoint<T>]()
        
    init (_ defaultValue: T = T.zero, allowedDifference: T = T.zero) {
        self.default = defaultValue
        self.allowedDifference = allowedDifference
    }
    
    var sampleTimes: [TimeInterval] {
        return dataPoints.map { $0.time }
    }
    
    func approximatelyEqual(_ value: T, to otherValue: T) -> Bool {
        return (value - otherValue).absoluteValue <= allowedDifference
    }
    
    mutating func clear() {
        dataPoints.removeAll()
    }
    
    mutating func capture(_ value:T, at time: TimeInterval = Date.now.timeIntervalSinceReferenceDate) throws(SampleError) {
        let newDataPoint = DataPoint(value: value, time: time)
                
        //If the series is empty just add it
        guard !dataPoints.isEmpty  else {
            dataPoints.append(newDataPoint)
            return
        }

        //Validate it's not before the end of the series
        let lastIndex = dataPoints.index(before: dataPoints.endIndex)
        guard dataPoints[lastIndex].time <= time else {
            throw SampleError.sampleBeforeEndOfTimeSeries
        }
        
        //If it's at the same time as the end of the series just over write it
        guard dataPoints[lastIndex].time != time else {
            dataPoints.removeLast()
            dataPoints.append(newDataPoint)
            return
        }
        
        //If there's only one data point in the list, then just add this after
        if dataPoints.count == 1 {
            dataPoints.append(newDataPoint)
            return
        }
        
        let lastButOneIndex = dataPoints.index(before: lastIndex)
        
        // If the last two values are the same, remove the last sample so this one will just extend the time without
        // interpolation
        if approximatelyEqual(dataPoints[lastIndex].value, to: value) && approximatelyEqual(dataPoints[lastButOneIndex].value, to: value) {
            dataPoints.removeLast()
            dataPoints.append(newDataPoint)
        } else {
            dataPoints.append(newDataPoint)
        }
    }
    
    func interpolatedValue(at time: TimeInterval, between a: DataPoint<T>, and b: DataPoint<T>) -> T {
        let duration = b.time - a.time
        
        let fraction = (time - a.time) / duration
        
        return T(from: a.value.doubleValue + fraction * (b.value.doubleValue - a.value.doubleValue))
    }
    
    public subscript (time: TimeInterval) -> T {
        if dataPoints.count == 0 {
            return self.default
        } else if dataPoints.count == 1 {
            return dataPoints[0].value
        }
        
        if time <= dataPoints[0].time {
            return dataPoints[0].value
        }
        
        let lastIndex = dataPoints.index(before: dataPoints.endIndex)
        if time >= dataPoints[lastIndex].time {
            return dataPoints[lastIndex].value
        }
        
        var lastDataPoint : DataPoint<T>!
        
        for dataPoint in dataPoints {
            if dataPoint.time == time {
                return dataPoint.value
            }
            if dataPoint.time > time {
                return interpolatedValue(at: time, between: lastDataPoint, and: dataPoint)
            }
            lastDataPoint = dataPoint
        }
        
        return self.default
    }
}
