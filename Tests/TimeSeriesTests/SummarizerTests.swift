//
//  SummarizerTests.swift
//  TimeSeries
//
//

import Testing
import Foundation
@testable import TimeSeries

@Test func sampleAtStart() async throws {
    var timeSeries = TimeSeries<Int,Int>(from: 0.date, for: 10.seconds, every: 1.seconds, summarizer: ValueAtStart<Int>())

    for time:TimeInterval in stride(from: 0, through: 10, by: 1){
        try timeSeries.capture(Int(time), at: time)
        try timeSeries.capture(Int(time)+1, at: (time+1.seconds)-1.nanoseconds)
    }
    
    #expect(timeSeries.dataPoints[0].value == 0)
    #expect(timeSeries.dataPoints[5].value == 5)
    #expect(timeSeries.dataPoints[9].value == 9)
}

@Test func sampleAtEnd() async throws {
    var timeSeries = TimeSeries<Int,Int>(from: 0.date, for: 10.seconds, every: 1.seconds, summarizer: ValueAtEnd<Int>())

    for time:TimeInterval in stride(from: 0, through: 10, by: 1){
        try timeSeries.capture(Int(time), at: time)
        try timeSeries.capture(Int(time)+1, at: (time+1.seconds)-1.nanoseconds)
    }

    #expect(timeSeries.dataPoints[0].value == 1)
    #expect(timeSeries.dataPoints[5].value == 6)
    #expect(timeSeries.dataPoints[9].value == 10)
}
