//
//  TimeSeries.swift
//  TimeSeries
//
//
import Foundation

/// A `DataSeries` of samples captured in temporal order (each new point must be captured at or after the time of the previous point).
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

public struct SampleSeries<SampleType:Sampleable> : DataSeries {
    public typealias PointType = SampleType

    let `default` : SampleType
    let tolerance : SampleType?
    let interpolator : any Interpolator<SampleType>
    
    var dataPoints = [DataPoint<SampleType>]()
    
    /// Creates a new object
    /// - Parameters:
    ///   - defaultValue: The default value to use if no reference points exist, defaults to zero
    ///   - tolerance: The tolerance that must be met before a new data point is stored in the series, defaults to zero.
    public init(_ defaultValue: SampleType = SampleType.default, tolerance: SampleType? = nil, interpolatedWith interpolator: any Interpolator<SampleType>){
        self.default = defaultValue
        self.tolerance = tolerance
        self.interpolator = interpolator
    }

    /// Creates a new object
    /// - Parameters:
    ///   - defaultValue: The default value to use if no reference points exist, defaults to zero
    ///   - tolerance: The tolerance that must be met before a new data point is stored in the series, defaults to zero.
    public init(_ defaultValue: SampleType = SampleType.default, tolerance: SampleType? = nil)  {
        self.default = defaultValue
        self.tolerance = tolerance
        
        if defaultValue is NumericallyInterpolateable{
            self.interpolator = LinearInterpolator<SampleType>()
        } else {
            self.interpolator = StepInterpolator<SampleType>()
        }
    }

    var sampleTimes: [TimeInterval] {
        return dataPoints.map { $0.timeInterval }
    }
    
    public var timeRange: ClosedRange<TimeInterval>{
        if let first = sampleTimes.first, let last = sampleTimes.last {
            return first...last
        }
        return 0...0
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
    public mutating func capture(_ point: SampleType, at time: TimeInterval = Date.now.timeIntervalSinceReferenceDate) throws(CaptureError) {
        let newDataPoint = DataPoint(value: point, timeInterval: time)
                
        //If the series is empty just add it
        guard !dataPoints.isEmpty  else {
            dataPoints.append(newDataPoint)
            return
        }

        //Validate it's not before the end of the series
        let lastIndex = dataPoints.index(before: dataPoints.endIndex)
        guard dataPoints[lastIndex].timeInterval <= time else {
            throw CaptureError.captureOutOfOrder
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
            if tolerance.inTolerance(point, and: lastValue) && tolerance.inTolerance(point, and: lastButOneValue) && tolerance.inTolerance(lastValue, and: lastButOneValue){
                dataPoints.removeLast()
                dataPoints.append(newDataPoint)
            } else {
                dataPoints.append(newDataPoint)
            }
        } else {
            if lastValue == point && lastButOneValue == point{
                dataPoints.removeLast()
                dataPoints.append(newDataPoint)
            } else {
                dataPoints.append(newDataPoint)
            }
        }
    }
    
    func interpolatedValue(at time: TimeInterval, between a: DataPoint<SampleType>, and b: DataPoint<SampleType>) -> SampleType {
        let duration = b.timeInterval - a.timeInterval
        
        let fraction = (time - a.timeInterval) / duration
        
        return interpolator.interpolate(at: fraction, between: a.value, and: b.value)
    }

    
    /// Provides data points for the supplied time range. If none were taken in this range it will be empty
    ///
    /// - Parameters:
    /// - time: The  range of times to capture samples between
    ///
    /// - Returns: An `Array` of `DataPoint`s containing samples in chronological order
    public subscript(dataPointsFrom range:ClosedRange<TimeInterval>)->[DataPoint<SampleType>] {
        var samples = [DataPoint<SampleType>]()
            
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
    public subscript (time: TimeInterval) -> [SampleType] {
        if dataPoints.count == 0 {
            return [self.default]
        } else if dataPoints.count == 1 {
            return [dataPoints[0].value]
        }
        
        if time <= dataPoints[0].timeInterval {
            return [dataPoints[0].value]
        }
        
        let lastIndex = dataPoints.index(before: dataPoints.endIndex)
        if time >= dataPoints[lastIndex].timeInterval {
            return [dataPoints[lastIndex].value]
        }
        
        var lastDataPoint : DataPoint<SampleType>!
        
        for dataPoint in dataPoints {
            if dataPoint.timeInterval == time {
                return [dataPoint.value]
            }
            if dataPoint.timeInterval > time {
                return [interpolatedValue(at: time, between: lastDataPoint, and: dataPoint)]
            }
            lastDataPoint = dataPoint
        }
        
        return [self.default]
    }
    
}

extension DataSeries where PointType: Sampleable {
    /// Provides samples for the supplied time range. It will always include (interpolating if necessary) one at exactly the start and end of the supplied
    /// `ClosedRange`. If any samples are in between those times they will be included too
    ///
    /// - Parameters:
    /// - samplesFor: The  range of times to capture samples between
    ///
    /// - Returns: An `Array` of `DataPoint`s containing samples in chronological order
    public subscript(samplesFor range: ClosedRange<TimeInterval>) -> [DataPoint<PointType>] {
        // Get's all of the actual samples in the range
        var samples = self[dataPointsFrom: range]

        // Determine if we need to calculate a value for the start of the range
        var calculateFirst = true
        if let first = samples.first, first.timeInterval == range.lowerBound{
            calculateFirst = false
        }
        
        if calculateFirst {
            if let calculatedFirst = self[range.lowerBound].first {
                samples.insert(DataPoint<PointType>(value: calculatedFirst, timeInterval: range.lowerBound), at: 0)
            }
        }

        // Now do the same for the end
        var calculateLast = true
        if let last = samples.last, last.timeInterval == range.upperBound{
            calculateLast = false
        }
        if calculateLast {
            if let calculatedLast = self[range.upperBound].first {
                samples.append(DataPoint<PointType>(value: calculatedLast, timeInterval: range.lowerBound))
            }
        }
        
        return samples
    }
}

extension SampleSeries : CustomStringConvertible {
    public var description: String {
        var output = ""
        
        for dataPoint in dataPoints {
            if !output.isEmpty {
                output += ", "
            }
            
            output += "(\(dataPoint.timeInterval): \(dataPoint.value))"
        }
        
        return output
    }
}
