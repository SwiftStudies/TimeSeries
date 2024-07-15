//
//  TimeSeries.swift
//  TimeSeries
//
//
import Foundation

/// The type provides a window with fixed interval samples from the provided samples or SampleSeries.
@available(macOS 13, *)
public struct TimeSeries<T:Sampleable> {
    /// Datapoints, which will be automatically updated when new samples are captured or the start date is changed
    public private(set) var dataPoints = [DataPoint<T>]()
    
    var sampleSeries : SampleSeries<T>
    
    /// Reference date for the time series calculation (working forwards or backward depending on if `duration` is positive or negative)
    public var start : Date  {
        get {
            return Date(timeIntervalSinceReferenceDate: timeSeriesStart)
        }
        
        set {
            timeSeriesStart = newValue.timeIntervalSinceReferenceDate
            update()
        }
    }
    
    var timeSeriesStart : TimeInterval
    let duration : TimeInterval
    let interval : TimeInterval
    
    
    /// Creates a `TimeSeries` that will update as new samples are captured
    /// - Parameters:
    ///   - from: The start point of the generated TimeSeries
    ///   - duration: The `TimeInterval` the time series should cover. If negative the `from` date will be used a to date
    ///   - interval: The period between data points in the series
    ///   - defaultValue: The default value to use if no reference points exist, defaults to zero
    ///   - tolerance: The tolerance that must be met before a new data point is stored in the series, defaults to zero.
    public init(from:Date, for duration:TimeInterval, every interval:TimeInterval, defaultValue value:T = T.default, tolerance: T = T.default){
        sampleSeries = SampleSeries<T>(value, tolerance: tolerance)
        timeSeriesStart = from.timeIntervalSinceReferenceDate
        self.duration = duration
        self.interval = interval
        
        update()
    }
    
    /// Creates a `TimeSeries` that will update as new samples are captured. Note, no further updates will be made if new samples are captured in the original `SampleSeries` as it is a value type
    /// - Parameters:
    ///   - from: The start point of the generated TimeSeries
    ///   - duration: The `TimeInterval` the time series should cover. If negative the `from` date will be used a to date
    ///   - interval: The period between data points in the series
    public init(from:Date, for duration:TimeInterval, every interval:TimeInterval, using sampleSeries:SampleSeries<T>){
        self.sampleSeries = sampleSeries
        timeSeriesStart = from.timeIntervalSinceReferenceDate
        self.duration = duration
        self.interval = interval
        
        update()
    }
        
    /// Adds a new sample, which must always be no sooner than the most recent sample. An error will be thrown if not. `dataPoints` will be updated automatically
    ///
    /// - Parameters:
    ///     - value: The new sample
    ///     - at: The time the sample was taken, defaults to the current time
    ///
    /// - Throws: `SampleError.sampleBeforeEndOfTimeSeries` if the sample is before the most recent sample
    mutating public func capture(_ value:T, at time: TimeInterval = Date.now.timeIntervalSinceReferenceDate) throws(SampleError) {
        try sampleSeries.capture(value, at: time)
        
        update()
    }
    
    /// Regenerates the data points
    mutating func update(){
        var startAt : TimeInterval
        var end : TimeInterval
        if duration > 0 {
            startAt = timeSeriesStart
            end = timeSeriesStart + duration
        } else {
            end = timeSeriesStart
            startAt = end - duration.magnitude
        }
        
        dataPoints = sampleSeries.dataPoints(from: startAt, to: end, with: interval)
    }
}
