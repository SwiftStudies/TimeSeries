//
//  TimeSeries.swift
//  TimeSeries
//
//
import Foundation

/// Errors that can occur when a new sample is captured in a SampleSeries
public enum SampleError : Error {
    case sampleBeforeEndOfTimeSeries
    case sampleNotInTimeSeries
}

/// A data series of samples captured in temporal order (each new point must be captured at or after the time of the previous point).
///
/// The series will be efficiently captured, that is multiple samples of the same value (wihtin a specifialble tolerance) will result in only as many data ponts as
/// absolutely necessary to capture. The sample series can be queried at any point in time and value will always be reported even if it must be interpolated. Accessing values is done with a subscript with a specifed time interval (since reference date).
///
/// ```swift
///  var samples = SampleSeries<Double>()
///
///  samples.capture(21.4, at: Date.now.timeIntervalSinceReferenceDate)
///
///  print(samples[Date.now.timeIntervalueSinceReferenceDate+3600]) // It will be assumed the value will not change with no future data points, and 21.4 will be printed
///```

public struct SampleSeries<T:Sampleable> {

    let `default` : T
    let tolerance : T?
    let interpolator : any Interpolator<T>
    
    var dataPoints = [DataPoint<T>]()
    
    /// Creates a new object
    /// - Parameters:
    ///   - defaultValue: The default value to use if no reference points exist, defaults to zero
    ///   - tolerance: The tolerance that must be met before a new data point is stored in the series, defaults to zero.
    public init(_ defaultValue: T = T.default, tolerance: T? = nil, interpolatedWith interpolator: any Interpolator<T>){
        self.default = defaultValue
        self.tolerance = tolerance
        self.interpolator = interpolator
    }

    /// Creates a new object
    /// - Parameters:
    ///   - defaultValue: The default value to use if no reference points exist, defaults to zero
    ///   - tolerance: The tolerance that must be met before a new data point is stored in the series, defaults to zero.
    public init(_ defaultValue: T = T.default, tolerance: T? = nil)  {
        self.default = defaultValue
        self.tolerance = tolerance
        
        if defaultValue is NumericallyInterpolateable{
            self.interpolator = LinearInterpolator<T>()
        } else {
            self.interpolator = StepInterpolator<T>()
        }
    }

    var sampleTimes: [TimeInterval] {
        return dataPoints.map { $0.timeInterval }
    }
    
    /// Removes all samples
    public mutating func clear() {
        dataPoints.removeAll()
    }
    
    /// Adds a new sample, which must always be no sooner than the most recent sample. An error will be thrown if not.
    ///
    /// - Parameters:
    ///     - value: The new sample
    ///     - at: The time the sample was taken, defaults to the current time
    ///
    /// - Throws: `SampleError.sampleBeforeEndOfTimeSeries` if the sample is before the most recent sample
    public mutating func capture(_ value:T, at time: TimeInterval = Date.now.timeIntervalSinceReferenceDate) throws(SampleError) {
        let newDataPoint = DataPoint(value: value, timeInterval: time)
                
        //If the series is empty just add it
        guard !dataPoints.isEmpty  else {
            dataPoints.append(newDataPoint)
            return
        }

        //Validate it's not before the end of the series
        let lastIndex = dataPoints.index(before: dataPoints.endIndex)
        guard dataPoints[lastIndex].timeInterval <= time else {
            throw SampleError.sampleBeforeEndOfTimeSeries
        }
        
        //If it's at the same time as the end of the series just over write it
        guard dataPoints[lastIndex].timeInterval != time else {
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
        
        let lastValue = dataPoints[lastIndex].value
        let lastButOneValue = dataPoints[lastButOneIndex].value
        
        if let tolerance {
            if tolerance.inTolerance(value, and: lastValue) && tolerance.inTolerance(value, and: lastButOneValue) && tolerance.inTolerance(lastValue, and: lastButOneValue){
                dataPoints.removeLast()
                dataPoints.append(newDataPoint)
            } else {
                dataPoints.append(newDataPoint)
            }
        } else {
            if lastValue == value {
                dataPoints.removeLast()
                dataPoints.append(newDataPoint)
            } else {
                dataPoints.append(newDataPoint)
            }
        }
    }
    
    func interpolatedValue(at time: TimeInterval, between a: DataPoint<T>, and b: DataPoint<T>) -> T {
        let duration = b.timeInterval - a.timeInterval
        
        let fraction = (time - a.timeInterval) / duration
        
        return interpolator.interpolate(at: fraction, between: a.value, and: b.value)
    }
    
    /// Returns sample at a precise time, or nil if there is none
    ///
    /// - Parameter time: The time being searched for
    /// - Returns: The `DataPoint` or `nil` if none is found
    private func dataPoint(atExactly time:TimeInterval)->DataPoint<T>?{
        for dataPoint in dataPoints {
            if dataPoint.timeInterval == time {
                return dataPoint
            } else if dataPoint.timeInterval > time {
                return nil
            }
        }
        
        return nil
    }
    
    /// Provides samples for the supplied time range. It will always include (interpolating if necessary) one at exactly the start and end of the supplied
    /// `ClosedRange`. If any samples are in between those times they will be included too
    ///
    /// - Parameters:
    /// - time: The  range of times to capture samples between
    ///
    /// - Returns: An `Array` of `DataPoint`s containing samples in chronological order
    public subscript(valuesFor range:ClosedRange<TimeInterval>)->[DataPoint<T>]{
        var samples = [DataPoint<T>]()
    
        if let sampleAtStart = dataPoint(atExactly: range.lowerBound) {
            samples.append(sampleAtStart)
        } else {
            samples.append(DataPoint<T>(value: self[range.lowerBound], timeInterval: range.lowerBound))
        }
        
        for dataPoint in dataPoints {
            if dataPoint.timeInterval > range.lowerBound && dataPoint.timeInterval < range.upperBound {
                samples.append(dataPoint)
            }
        }
        
        if let sampleAtEnd = dataPoint(atExactly: range.upperBound) {
            samples.append(sampleAtEnd)
        } else {
            samples.append(DataPoint<T>(value: self[range.upperBound], timeInterval: range.upperBound))
        }
        
        return samples
    }
    
    /// Provides samples for the supplied time range. If none were taken in this range it will be empty
    ///
    /// - Parameters:
    /// - time: The  range of times to capture samples between
    ///
    /// - Returns: An `Array` of `DataPoint`s containing samples in chronological order
    public subscript(samplesIn range:ClosedRange<TimeInterval>)->[DataPoint<T>]{
        var samples = [DataPoint<T>]()
            
        for dataPoint in dataPoints {
            if dataPoint.timeInterval >= range.lowerBound && dataPoint.timeInterval < range.upperBound {
                samples.append(dataPoint)
            }
        }
        
        return samples
    }
    
    /// Indexes the sample series by a `TimeInterval` (since reference date)
    ///
    /// - Parameters:
    /// - time: The `TimeInterval` to capture at
    ///
    /// - Returns: The value at that time interpolating or infering as necessary to ensure a value is always created
    public subscript (time: TimeInterval) -> T {
        if dataPoints.count == 0 {
            return self.default
        } else if dataPoints.count == 1 {
            return dataPoints[0].value
        }
        
        if time <= dataPoints[0].timeInterval {
            return dataPoints[0].value
        }
        
        let lastIndex = dataPoints.index(before: dataPoints.endIndex)
        if time >= dataPoints[lastIndex].timeInterval {
            return dataPoints[lastIndex].value
        }
        
        var lastDataPoint : DataPoint<T>!
        
        for dataPoint in dataPoints {
            if dataPoint.timeInterval == time {
                return dataPoint.value
            }
            if dataPoint.timeInterval > time {
                return interpolatedValue(at: time, between: lastDataPoint, and: dataPoint)
            }
            lastDataPoint = dataPoint
        }
        
        return self.default
    }
    
}
