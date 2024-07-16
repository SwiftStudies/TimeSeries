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
    
    /// Indexes the sampel series by a `TimeInterval` (since reference date)
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
    
    /// Generates an array of DataPoints between two points in time, with equal amounts of time between each
    ///
    /// - Parameters:
    ///   - startTime: The time of the first sample to take in the series
    ///   - endTime: The end time of the series
    ///   - interval: The time between each set of points in the series
    /// - Returns: An array of `DataPoint`s with a sample for each point
    public func dataPoints(from startTime: TimeInterval, to endTime: TimeInterval, with interval: TimeInterval) -> [DataPoint<T>] {
        var dataPoints = [DataPoint<T>]()
        for time in stride(from: startTime, to: endTime, by: interval){
            dataPoints.append(DataPoint<T>(value: self[time], timeInterval: time))
        }
        
        return dataPoints
    }
    
    /// Generates an array of DataPoints  from a specified time, with samples taken at regular intervals for a total period
    /// - Parameters:
    ///   - startTime: The time of the first same
    ///   - totalTime: The total duration covered by the time series
    ///   - interval: The period between samples
    /// - Returns: An array of `DataPoint`s with a sample for each point
    public func dataPoints(from startTime: TimeInterval, for totalTime: TimeInterval, sampleEvery interval:TimeInterval) -> [DataPoint<T>] {
        return dataPoints(from: startTime, to: startTime+totalTime, with: interval)
    }
    
    /// Creates a `TimeSeries` directly from the SampleSeries
    /// - Parameters:
    ///   - from: The start point of the generated TimeSeries
    ///   - duration: The `TimeInterval` the time series should cover. If negative the `from` date will be used a to date
    ///   - interval: The period between data points in the series
    /// - Returns: The `TimeSeries` object. Note, no further updates will be made if new samples are captured in the original `SampleSeries` as it is a value type
    public func timeSeries(from:Date, for duration:TimeInterval, every interval:TimeInterval)->TimeSeries<T>{
        return TimeSeries(from: from, for: duration, every: interval)
    }
}
