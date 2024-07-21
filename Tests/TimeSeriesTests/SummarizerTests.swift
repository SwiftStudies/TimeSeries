//
//  SummarizerTests.swift
//  TimeSeries
//
//

import Testing
import Foundation
@testable import TimeSeries

@Test func sampleAtStart() async throws {
    var timeSeries = TimeSeries<SampleSeries<Int>,Int>(from: 0.date, for: 10.seconds, every: 1.seconds, using: SampleSeries<Int>(), summarizer: MeasureValue<Int>())

    for time:TimeInterval in stride(from: 0, through: 10, by: 1){
        try timeSeries.capture(Int(time), at: time)
        try timeSeries.capture(Int(time)+1, at: (time+1.seconds)-1.nanoseconds)
    }
    
    #expect(timeSeries.dataPoints[0].value == 0)
    #expect(timeSeries.dataPoints[5].value == 5)
    #expect(timeSeries.dataPoints[9].value == 9)
}

@Test func sampleAtEnd() async throws {
    var timeSeries = TimeSeries<SampleSeries<Int>,Int>(from: 0.date, for: 10.seconds, every: 1.seconds, using: SampleSeries<Int>(), summarizer: MeasureValue<Int>(at:.end))

    for time:TimeInterval in stride(from: 0, through: 10, by: 1){
        try timeSeries.capture(Int(time), at: time)
        try timeSeries.capture(Int(time)+1, at: (time+1.seconds)-1.nanoseconds)
    }

    #expect(timeSeries.dataPoints[0].value == 1)
    #expect(timeSeries.dataPoints[5].value == 6)
    #expect(timeSeries.dataPoints[9].value == 10)
}

@Test func sampleInMiddle() async throws {
    var timeSeries = TimeSeries<SampleSeries<Double>,Double>(from: 0.date, for: 10.seconds, every: 1.seconds, using: SampleSeries<Double>(), summarizer: MeasureValue<Double>(at:.middle))

    for time:TimeInterval in stride(from: 0, through: 10, by: 1){
        try timeSeries.capture(time, at: time)
    }

    #expect(timeSeries.dataPoints[0].value == 0.5)
    #expect(timeSeries.dataPoints[5].value == 5.5)
    #expect(timeSeries.dataPoints[9].value == 9.5)
}

@Test func countSamples() async throws {
    var timeSeries = TimeSeries<SampleSeries<Double>,Int>(from: 0.date, for: 10.seconds, every: 1.seconds, using: SampleSeries<Double>(), summarizer: CountSamples<Double>())
    
    try timeSeries.capture(0, at: 0)
    try timeSeries.capture(1, at: 0.5)
    try timeSeries.capture(2, at: 0.6)
    try timeSeries.capture(2, at: 0.75)
    try timeSeries.capture(1, at: 0.9)
    try timeSeries.capture(1, at: 1)
    try timeSeries.capture(4, at: 4)
    try timeSeries.capture(6, at: 6)
    try timeSeries.capture(10, at: 10)

    #expect(timeSeries.dataPoints[0].value == 5)
    #expect(timeSeries.dataPoints[1].value == 1)
    #expect(timeSeries.dataPoints[2].value == 0)
}

@Test func averagesFloatingPointValues() async throws{
    var timeSeries = TimeSeries<SampleSeries<Double>,Double>(from: 0.date, for: 10.seconds, every: 1.seconds, using: SampleSeries<Double>(), summarizer: AverageFloatingPointValue<Double>())

    try timeSeries.capture(0, at: 0)
    try timeSeries.capture(2, at: 0.2)
    try timeSeries.capture(1, at: 1)
    try timeSeries.capture(4, at: 4)
    try timeSeries.capture(6, at: 6)
    try timeSeries.capture(10, at: 10)

    #expect(timeSeries.dataPoints[0].value == 1.35)
    #expect(timeSeries.dataPoints[1].value == 1.45)
    #expect(timeSeries.dataPoints[5].value == 5.45)
}

@Test func averagesIntegerValues() async throws{
    var timeSeries = TimeSeries<SampleSeries<Int>,Int>(from: 0.date, for: 10.seconds, every: 1.seconds, using: SampleSeries<Int>(), summarizer: AverageIntegerValue<Int>())

    try timeSeries.capture(0, at: 0)
    try timeSeries.capture(2, at: 0.5)
    try timeSeries.capture(2, at: 0.6)
    try timeSeries.capture(2, at: 0.75)
    try timeSeries.capture(1, at: 0.9)
    try timeSeries.capture(1, at: 1)
    try timeSeries.capture(4, at: 4)
    try timeSeries.capture(6, at: 6)
    try timeSeries.capture(10, at: 10)

    #expect(timeSeries.dataPoints[0].value == 1)
    #expect(timeSeries.dataPoints[1].value == 1)
    #expect(timeSeries.dataPoints[5].value == 5)
}

@Test func minMaxSum() async throws {
    var timeSeries = TimeSeries<SampleSeries<Int>,Int>(from: 0.date, for: 10.seconds, every: 1.seconds, using: SampleSeries<Int>(), summarizer: MaximumValue<Int>())

    try timeSeries.capture(0, at: 0)
    try timeSeries.capture(1, at: 0.5)
    try timeSeries.capture(2, at: 0.6)
    try timeSeries.capture(2, at: 0.75)
    try timeSeries.capture(1, at: 0.9)
    try timeSeries.capture(1, at: 1)
    try timeSeries.capture(4, at: 4)
    try timeSeries.capture(6, at: 6)
    try timeSeries.capture(10, at: 10)

    #expect(timeSeries.dataPoints[0].value == 2)
    #expect(timeSeries.dataPoints[5].value == 5)
    #expect(timeSeries.dataPoints[9].value == 9)
    
    timeSeries.summarizer = MinimumValue<Int>()
    
    #expect(timeSeries.dataPoints[0].value == 0)
    #expect(timeSeries.dataPoints[5].value == 5)
    #expect(timeSeries.dataPoints[9].value == 9)
    
    timeSeries.summarizer = SumSamples<Int>()
    
    #expect(timeSeries.dataPoints[0].value == 6)
    #expect(timeSeries.dataPoints[5].value == 0)
    #expect(timeSeries.dataPoints[4].value == 4)

}
