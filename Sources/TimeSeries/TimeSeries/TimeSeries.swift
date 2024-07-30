//
//  TimeSeries.swift
//  TimeSeries
//
//
import Foundation

public extension TimeSeries where DataSeriesPointType == TimeSeriesPointType, DataSeriesPointType : Sampleable {
    /// Creates a `TimeSeries` that will update as new samples are captured. Note, no further updates will be made if new samples are captured in the original `SampleSeries` as it is a value type. It will use
    /// a default summarizer that captures the value at the start of the series
    /// - Parameters:
    ///   - from: The start point of the generated TimeSeries
    ///   - duration: The `TimeInterval` the time series should cover. If negative the `from` date will be used a to date
    ///   - interval: The period between data points in the series
    init(from:Date, for duration:TimeInterval, every interval:TimeInterval, using dataSeries:any DataSeriesType){
        self.dataSeries = dataSeries
        timeSeriesStart = from.timeIntervalSinceReferenceDate
        self.duration = duration
        self.interval = interval
        self.summarizer = MeasureValue<DataSeriesPointType>()

        update()
    }
}

/// The type provides a window with fixed interval samples from the provided samples or SampleSeries.
public struct TimeSeries<DataSeriesPointType, TimeSeriesPointType> {
    public typealias DataSeriesType = DataSeries<DataSeriesPointType>
        
    /// Datapoints, which will be automatically updated when new samples are captured or the start date is changed
    public private(set) var dataPoints = [DataPoint<TimeSeriesPointType>]()
    
    var dataSeries : any DataSeriesType
    
    /// The way that values for an internval in the `TimeSeries` where the sample type and the time series types are the same, this defaults to the value at the start of the period, but any implementation of `Summarizer` can be used. Chaging the value causes the `dataPoints` to be recalculated
    public var summarizer   : any Summarizer<DataSeriesPointType, TimeSeriesPointType> {
        didSet {
            update()
        }
    }
    
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
    
    /// Creates a `TimeSeries` that will update as new samples are captured. Note, no further updates will be made if new samples are captured in the original `SampleSeries` as it is a value type
    /// - Parameters:
    ///   - from: The start point of the generated TimeSeries
    ///   - duration: The `TimeInterval` the time series should cover. If negative the `from` date will be used a to date
    ///   - interval: The period between data points in the series
    ///   - summarizer: The summarizer to use when summarizing data in the source series
    public init(from:Date, for duration:TimeInterval, every interval:TimeInterval, using dataSeries:any DataSeriesType, summarizer: any Summarizer<DataSeriesPointType, TimeSeriesPointType>){
        self.dataSeries = dataSeries
        timeSeriesStart = from.timeIntervalSinceReferenceDate
        self.duration = duration
        self.interval = interval
        self.summarizer = summarizer

        update()
    }
        
    /// Adds a new sample, which must always be no sooner than the most recent sample. An error will be thrown if not. `dataPoints` will be updated automatically
    ///
    /// - Parameters:
    ///     - value: The new sample
    ///     - at: The time the sample was taken, defaults to the current time
    ///
    /// - Throws: `SampleError.sampleBeforeEndOfTimeSeries` if the sample is before the most recent sample
    mutating public func capture(_ value:DataSeriesPointType, at time: TimeInterval = Date.now.timeIntervalSinceReferenceDate) throws(CaptureError) {
        try dataSeries.capture(value, at: time)
        
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
        
        dataPoints = summarize(from: startAt, to: end, with: interval)
    }
    
    /// Generates an array of DataPoints between two points in time, with equal amounts of time between each
    ///
    /// - Parameters:
    ///   - startTime: The time of the first sample to take in the series
    ///   - endTime: The end time of the series
    ///   - interval: The time between each set of points in the series
    /// - Returns: An array of `DataPoint`s with a sample for each point
    public func summarize(from startTime: TimeInterval, to endTime: TimeInterval, with interval: TimeInterval) -> [DataPoint<TimeSeriesPointType>] {
        var dataPoints = [DataPoint<TimeSeriesPointType>]()
        for time in stride(from: startTime, to: endTime, by: interval){
            dataPoints.append(summarizer.summarize(series: dataSeries, for: interval, startingAt: time))
        }
        
        return dataPoints
    }
}

extension TimeSeries : CustomStringConvertible {
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