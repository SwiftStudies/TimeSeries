//
//  TimeSeries.swift
//  TimeSeries
//
//
import Foundation

/// A ``DataSeries`` for continuously changing values, with automatic interpolation and efficient storage.
///
/// `SampleSeries` stores values in chronological order and can be queried at any point in time.
/// If the queried time falls between two captured data points, the configured ``Interpolator``
/// calculates the result. If queried before the first or after the last capture, the nearest
/// boundary value is returned. If the series is empty, the ``Sampleable/default`` value is returned.
///
/// **Efficient storage:** When consecutive captured values are identical (or within the optional
/// `tolerance`), intermediate data points are collapsed. For example, capturing the value `20.0`
/// ten times only stores two data points (the first and last occurrence), since the value didn't change.
///
/// **Interpolation defaults:** Numeric types (`Int`, `Double`, `Float`) use ``LinearInterpolator``
/// by default. All other ``Sampleable`` types use ``StepInterpolator``. A custom ``Interpolator``
/// can be provided via `init(_:tolerance:interpolatedWith:)`.
///
/// ```swift
/// var temps = SampleSeries<Double>()
/// let now = Date.now.timeIntervalSinceReferenceDate
///
/// try temps.capture(20.0, at: now)
/// try temps.capture(22.0, at: now + 1.hours)
///
/// print(temps[now + 30.minutes]) // [21.0] -- linearly interpolated
/// ```

public struct SampleSeries<SampleType:Sampleable> : DataSeries {
    public typealias DataPointType = SampleType

    let `default` : SampleType
    let tolerance : SampleType?
    let interpolator : any Interpolator<SampleType>
    
    var dataPoints = [DataPoint<SampleType>]()
    
    /// Creates a new sample series with a specific interpolator.
    /// - Parameters:
    ///   - defaultValue: The value returned when the series is empty. Defaults to `SampleType.default` (zero for numeric types).
    ///   - tolerance: Optional tolerance for efficient storage. When set, consecutive values within tolerance are collapsed. Pass `nil` for exact equality comparison.
    ///   - interpolator: The ``Interpolator`` to use when querying between captured data points.
    public init(_ defaultValue: SampleType = SampleType.default, tolerance: SampleType? = nil, interpolatedWith interpolator: any Interpolator<SampleType>){
        self.default = defaultValue
        self.tolerance = tolerance
        self.interpolator = interpolator
    }

    /// Creates a new sample series with an automatically selected interpolator.
    ///
    /// Uses ``LinearInterpolator`` for types conforming to ``NumericallyInterpolateable``
    /// (`Int`, `Double`, `Float`), and ``StepInterpolator`` for all other types.
    ///
    /// - Parameters:
    ///   - defaultValue: The value returned when the series is empty. Defaults to `SampleType.default`.
    ///   - tolerance: Optional tolerance for efficient storage. See ``init(_:tolerance:interpolatedWith:)``.
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
    
    /// The closed range from the earliest to the latest captured time. Returns `0...0` if empty.
    public var timeRange: ClosedRange<TimeInterval>{
        if let first = sampleTimes.first, let last = sampleTimes.last {
            return first...last
        }
        return 0...0
    }
    
    /// Removes all captured samples from the series.
    public mutating func clear() {
        dataPoints.removeAll()
    }
    
    /// Removes all samples captured after the specified time. Samples at exactly `time` are kept.
    mutating public func clear(after time: TimeInterval) {
        dataPoints = dataPoints.filter { dataPoint in
            return dataPoint.timeInterval <= time
        }
    }

    /// Returns the data point at or immediately before the specified time.
    ///
    /// Unlike the subscript (which interpolates), this returns the actual stored data point
    /// without any interpolation.
    ///
    /// - Parameter time: The time to query, as seconds since the reference date.
    /// - Returns: The data point at exactly `time`, or the nearest earlier one. Returns `nil` if no data points exist before the given time.
    public func sample(onOrBefore time: TimeInterval)->DataPoint<DataPointType>?{
        var lastSample : DataPoint<DataPointType>?
        
        for dataPoint in dataPoints {
            if dataPoint.timeInterval > time {
                return lastSample
            } else if dataPoint.timeInterval < time {
                lastSample = dataPoint
            } else if dataPoint.timeInterval == time {
                return dataPoint
            }
        }
        
        return lastSample
    }
    
    /// Appends a new sample to the series.
    ///
    /// The time must be >= the most recent capture. If a sample is captured at the exact same time
    /// as the last entry, it overwrites that entry. Consecutive identical values (or values within
    /// tolerance) are automatically collapsed for efficient storage.
    ///
    /// - Parameters:
    ///     - point: The new sample value.
    ///     - at: The time the sample was taken, as seconds since the reference date. Defaults to `Date.now`.
    ///
    /// - Throws: ``CaptureError/captureOutOfOrder`` if `time` is before the most recent capture.
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

    
    /// Returns actually captured data points within the given closed time range (no interpolation).
    ///
    /// - Parameter range: The closed range of `TimeInterval` values to query.
    /// - Returns: An array of ``DataPoint`` values in chronological order, or empty if none were captured in the range.
    public subscript(dataPointsFrom range:ClosedRange<TimeInterval>)->[DataPoint<SampleType>] {
        var samples = [DataPoint<SampleType>]()
            
        for dataPoint in dataPoints {
            if dataPoint.timeInterval >= range.lowerBound && dataPoint.timeInterval < range.upperBound {
                samples.append(dataPoint)
            }
        }
        
        return samples
    }
    
    /// Returns the interpolated value at the given time as a single-element array.
    ///
    /// Always returns exactly one value:
    /// - If the series is empty, returns ``Sampleable/default``.
    /// - If the time is before the first or after the last capture, returns the nearest boundary value.
    /// - Otherwise, interpolates between the two surrounding data points using the configured ``Interpolator``.
    ///
    /// - Parameter time: The time to query, as seconds since the reference date.
    /// - Returns: A single-element array containing the value at that time.
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
    
    /// The most recently captured data point, or `nil` if the series is empty.
    public var newest: DataPoint<SampleType>? {
        return dataPoints.last
    }

    /// The earliest captured data point, or `nil` if the series is empty.
    public var oldest: DataPoint<SampleType>? {
        return dataPoints.first
    }
}

extension DataSeries where DataPointType: Sampleable {
    /// Returns data points for the given time range, always including interpolated values at the range boundaries.
    ///
    /// Unlike `subscript(dataPointsFrom:)`, which only returns actually captured data points,
    /// this subscript guarantees a data point at both the start and end of the range
    /// (interpolating if necessary). Any captured data points between those boundaries are
    /// also included. This is useful for summarizers that need complete coverage of a time period.
    ///
    /// - Parameter range: The closed time range to query.
    /// - Returns: Data points in chronological order, with interpolated boundary values.
    public subscript(samplesFor range: ClosedRange<TimeInterval>) -> [DataPoint<DataPointType>] {
        // Get's all of the actual samples in the range
        var samples = self[dataPointsFrom: range]

        // Determine if we need to calculate a value for the start of the range
        var calculateFirst = true
        if let first = samples.first, first.timeInterval == range.lowerBound{
            calculateFirst = false
        }
        
        if calculateFirst {
            if let calculatedFirst = self[range.lowerBound].first {
                samples.insert(DataPoint<DataPointType>(value: calculatedFirst, timeInterval: range.lowerBound), at: 0)
            }
        }

        // Now do the same for the end
        var calculateLast = true
        if let last = samples.last, last.timeInterval == range.upperBound{
            calculateLast = false
        }
        if calculateLast {
            if let calculatedLast = self[range.upperBound].first {
                samples.append(DataPoint<DataPointType>(value: calculatedLast, timeInterval: range.lowerBound))
            }
        }
        
        return samples
    }
}

extension SampleSeries : CustomStringConvertible {
    /// A comma-separated list of `(timeInterval: value)` pairs for all stored data points.
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
