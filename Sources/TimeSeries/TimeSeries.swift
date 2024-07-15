//
//  TimeSeries.swift
//  TimeSeries
//
//
import Foundation

@available(macOS 13, *)
struct TimeSeries<T : Value> {
    public private(set) var dataPoints = [DataPoint<T>]()
    
    var sampleSeries : SampleSeries<T>
    
    let start : TimeInterval
    let duration : TimeInterval
    let interval : TimeInterval
    
    public init(from:Date, for duration:TimeInterval, every interval:TimeInterval, defaultValue value:T = T.zero, tolerance: T = T.zero){
        sampleSeries = SampleSeries<T>(value, tolerance: tolerance)
        start = from.timeIntervalSinceReferenceDate
        self.duration = duration
        self.interval = interval
        
        update()
    }
        
    mutating public func capture(_ value:T, at time: TimeInterval = Date.now.timeIntervalSinceReferenceDate) throws(SampleError) {
        try sampleSeries.capture(value, at: time)
        
        update()
    }
    
    mutating public func update(){
        var startAt : TimeInterval
        var end : TimeInterval
        if duration > 0 {
            startAt = start
            end = start + duration
        } else {
            end = start
            startAt = end - duration.magnitude
        }
        
        dataPoints = sampleSeries.timeSeries(from: startAt, to: end, with: interval)
    }
}
