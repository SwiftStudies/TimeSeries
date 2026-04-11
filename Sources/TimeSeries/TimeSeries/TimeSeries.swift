//
//  TimeSeries.swift
//  TimeSeries
//
//
import Foundation

public extension TimeSeries where DataSeriesPointType == TimeSeriesPointType, DataSeriesPointType : Sampleable {
    /// Convenience initializer that uses ``MeasureValue`` (at `.beginning`) as the default summarizer.
    ///
    /// Available when `DataSeriesPointType` and `TimeSeriesPointType` are the same ``Sampleable`` type.
    ///
    /// - Parameters:
    ///   - from: The reference date for the time series.
    ///   - duration: The span to cover. If negative, `from` is treated as the end and the series looks backward.
    ///   - interval: The length of each summarization period, in seconds.
    ///   - dataSeries: The source ``DataSeries`` to summarize.
    init(from:Date, for duration:TimeInterval, every interval:TimeInterval, using dataSeries:any DataSeriesType){
        self.dataSeries = dataSeries
        timeSeriesStart = from.timeIntervalSinceReferenceDate
        self.duration = duration
        self.interval = interval
        self.summarizer = MeasureValue<DataSeriesPointType>()

        update()
    }
}

/// Generates fixed-interval summary data points from a ``DataSeries``, ideal for charting and analysis.
///
/// `TimeSeries` reads from a source ``DataSeries`` and uses a ``Summarizer`` to reduce each
/// time interval to a single ``DataPoint``. The generic parameters are:
/// - `DataSeriesPointType`: The type stored in the source ``DataSeries``.
/// - `TimeSeriesPointType`: The type of the summarized output (may differ, e.g., ``Count`` produces `Int`).
///
/// **Value type semantics:** `TimeSeries` is a struct. After creation, mutations to the original
/// source series do not propagate. Use ``capture(_:at:)`` on the `TimeSeries` itself to add data
/// and automatically regenerate the summary.
///
/// **Negative durations:** When `duration` is negative, the `from` date is treated as the end of
/// the window, and the series looks backward in time.
///
/// ```swift
/// var samples = SampleSeries<Double>()
/// // ... capture data ...
///
/// // Last 24 hours, hourly averages
/// let ts = TimeSeries<Double, Double>(
///     from: Date.now, for: -24.hours, every: 1.hours,
///     using: samples, summarizer: AverageFloatingPointValue<Double>()
/// )
///
/// for point in ts.dataPoints {
///     print("\(point.date): \(point.value)")
/// }
/// ```
public struct TimeSeries<DataSeriesPointType, TimeSeriesPointType> {
    /// A type-erased ``DataSeries`` whose data point type matches `DataSeriesPointType`.
    public typealias DataSeriesType = DataSeries<DataSeriesPointType>

    /// The generated summary data points. Automatically regenerated when ``capture(_:at:)``,
    /// ``start``, or ``summarizer`` are changed.
    public private(set) var dataPoints = [DataPoint<TimeSeriesPointType>]()
    
    var dataSeries : any DataSeriesType
    
    /// The strategy used to reduce each time interval to a single value. Changing this property
    /// causes ``dataPoints`` to be regenerated immediately.
    public var summarizer   : any Summarizer<DataSeriesPointType, TimeSeriesPointType> {
        didSet {
            update()
        }
    }
    
    /// The reference date for the time series window. Setting this regenerates ``dataPoints``.
    ///
    /// When `duration` is positive, this is the start of the window. When negative, this is the end.
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
    
    /// Creates a `TimeSeries` with a specified summarizer.
    ///
    /// The source `dataSeries` is copied (value type semantics). Subsequent mutations to the
    /// original series do not affect this `TimeSeries`. Use ``capture(_:at:)`` to add data.
    ///
    /// - Parameters:
    ///   - from: The reference date for the time series.
    ///   - duration: The span to cover. If negative, `from` is treated as the end and the series looks backward.
    ///   - interval: The length of each summarization period, in seconds.
    ///   - dataSeries: The source ``DataSeries`` to summarize.
    ///   - summarizer: The ``Summarizer`` strategy to reduce each period to a single value.
    public init(from:Date, for duration:TimeInterval, every interval:TimeInterval, using dataSeries:any DataSeriesType, summarizer: any Summarizer<DataSeriesPointType, TimeSeriesPointType>){
        self.dataSeries = dataSeries
        timeSeriesStart = from.timeIntervalSinceReferenceDate
        self.duration = duration
        self.interval = interval
        self.summarizer = summarizer

        update()
    }
        
    /// Appends a new data point to the underlying series and regenerates ``dataPoints``.
    ///
    /// - Parameters:
    ///     - value: The new value to capture.
    ///     - at: The time the value was observed, as seconds since the reference date. Defaults to `Date.now`.
    ///
    /// - Throws: ``CaptureError/captureOutOfOrder`` if `time` is before the most recent capture.
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
    
    /// Generates summary data points for a custom time range using the current ``summarizer``.
    ///
    /// This is the lower-level method used internally by ``update()``. It can also be called
    /// directly to summarize an arbitrary range without changing the stored ``dataPoints``.
    ///
    /// - Parameters:
    ///   - startTime: The start of the range, as seconds since the reference date.
    ///   - endTime: The end of the range, as seconds since the reference date.
    ///   - interval: The length of each summarization period, in seconds.
    /// - Returns: An array of ``DataPoint`` values, one per period, in chronological order.
    public func summarize(from startTime: TimeInterval, to endTime: TimeInterval, with interval: TimeInterval) -> [DataPoint<TimeSeriesPointType>] {
        var dataPoints = [DataPoint<TimeSeriesPointType>]()
        for time in stride(from: startTime, to: endTime, by: interval){
            dataPoints.append(summarizer.summarize(series: dataSeries, for: interval, startingAt: time))
        }
        
        return dataPoints
    }
}

extension TimeSeries : CustomStringConvertible {
    /// A comma-separated list of `(timeInterval: value)` pairs for all summary data points.
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
