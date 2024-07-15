//
//  TimeSeries.swift
//  TimeSeries
//
//
import Foundation

fileprivate typealias TimerCallback = @Sendable (_ timer:Timer) -> Void

@available(macOS 13, *)
struct TimeSeries<T : Value> {
    public private(set) var dataPoints = [DataPoint<T>]()
    
    var sampleSeries : SampleSeries<T>

    var baseDate : Date {
        from ?? Date.now
    }
    
    let from : Date?
    let duration : TimeInterval
    let interval : TimeInterval
    
    public init(from:Date? = nil, for duration:TimeInterval, interval:TimeInterval, defaultValue value:T = T.zero, tolerance: T = T.zero){
        sampleSeries = SampleSeries<T>(value, tolerance: tolerance)
        self.from = from
        self.duration = duration
        self.interval = interval
        
        update()
    }
        
    mutating public func capture(_ value:T, at time: TimeInterval = Date.now.timeIntervalSinceReferenceDate) throws(SampleError) {
        try sampleSeries.capture(value, at: time)
        
        update()
    }
    
    mutating public func update(){
        var start : TimeInterval
        var end : TimeInterval
        if duration > 0 {
            start = baseDate.timeIntervalSinceReferenceDate
            end = start + duration
        } else {
            end = baseDate.timeIntervalSinceReferenceDate
            start = end - duration.magnitude
        }
        
        dataPoints = sampleSeries.timeSeries(from: start, to: end, with: interval)
    }
}
