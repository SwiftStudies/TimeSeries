//
//  TimeSeries.swift
//  TimeSeries
//
//
import Foundation

@available(macOS 13, *)
struct TimeSeries<T : Value> {
    var values: [T]
    var sampleSeries : SampleSeries<T>
    var baseDate : Date {
        from ?? Date.now
    }
    
    let from : Date?
    let timeIntervals : [TimeInterval]
    
    public init(relativeTo from:Date? = nil, dataPointEvery seconds:TimeInterval, capturing count:Int, defaultValue value:T = T.zero, tolerance: T = T.zero){
        values = [T]()
        sampleSeries = SampleSeries<T>(value, tolerance: tolerance)
    
    
        var timeIntervals = [TimeInterval]()
        
        for delta in stride(from: 0, to: seconds*count.doubleValue, by: seconds){
            values.append(value)
            timeIntervals.append(-delta)
        }
        
        self.timeIntervals = timeIntervals
        self.from = from
    }
    
    public var dataPoints: [DataPoint<T>] {
        return zip(dates, values).map({DataPoint(value: $1, time:$0.timeIntervalSinceReferenceDate)}).reversed()
    }
    
    var dates: [Date] {
        return timeIntervals.map({baseDate.addingTimeInterval($0)})
    }
    
    mutating public func capture(_ value:T, at time: TimeInterval = Date.now.timeIntervalSinceReferenceDate) throws(SampleError) {
        try sampleSeries.capture(value, at: time)
        
        update()
    }
    
    mutating public func update(){
        var valueIndex = values.startIndex
        for delta in timeIntervals{
            let newValue = sampleSeries[baseDate.timeIntervalSinceReferenceDate + delta]
            
            if !newValue.approximatelyEquals(values[valueIndex], tolerance: sampleSeries.tolerance) {
                values[valueIndex] = newValue
            }
            
            valueIndex = valueIndex.advanced(by: 1)
        }
    }
}
