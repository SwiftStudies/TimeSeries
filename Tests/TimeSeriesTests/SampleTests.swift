//
//  SampleTests.swift
//  TimeSeries
//
//

import Testing
import Foundation
@testable import TimeSeries



@Test func compression() async throws {
    var timeSeries = SampleSeries<Double>()

    try timeSeries.capture(0, at: 0)
    try timeSeries.capture(1, at: 10)
    try timeSeries.capture(1, at: 20)
    try timeSeries.capture(1, at: 30)
    
    #expect(!timeSeries.sampleTimes.contains(20))
    
    timeSeries.clear()
    #expect(timeSeries.sampleTimes.isEmpty)
    
    try timeSeries.capture(0, at: 0)
    try timeSeries.capture(0, at: 10)
    try timeSeries.capture(0, at: 10)
    try timeSeries.capture(0, at: 20)
    try timeSeries.capture(0, at: 20)
    try timeSeries.capture(0, at: 30)
    try timeSeries.capture(0, at: 30)

    #expect(timeSeries.sampleTimes.count == 2)
    #expect(timeSeries.sampleTimes.contains(0))
    #expect(timeSeries.sampleTimes.contains(30))
    
    try timeSeries.capture(10, at: 30)
    #expect(timeSeries[30] == 10)
    #expect(timeSeries[40] == 10)
}

@Test func tolerances() async throws {
    var timeSeries = SampleSeries<Double>(tolerance: 0.1)

    try timeSeries.capture(0, at: 0)
    try timeSeries.capture(1, at: 10)
    try timeSeries.capture(0.9, at: 20)
    try timeSeries.capture(1, at: 30)
    
    #expect(!timeSeries.sampleTimes.contains(20.0))
    
    timeSeries.clear()
    
    try timeSeries.capture(0, at: 0)
    try timeSeries.capture(0.05, at: 10)
    try timeSeries.capture(-0.05, at: 10)
    try timeSeries.capture(0.05, at: 20)
    try timeSeries.capture(0.05, at: 20)
    try timeSeries.capture(-0.05, at: 30)
    try timeSeries.capture(0.05, at: 30)

    #expect(timeSeries.sampleTimes.count == 2)
    #expect(timeSeries.sampleTimes.contains(0))
    #expect(timeSeries.sampleTimes.contains(30))
    
    try timeSeries.capture(10, at: 30)
    #expect(timeSeries[30] == 10)
    #expect(timeSeries[40] == 10)
}

@Test func creation() async throws {
    var timeSeries = SampleSeries<Double>()

    try timeSeries.capture(5, at: 5)
    #expect(timeSeries[10] == 5)
    #expect(timeSeries[5] == 5)
    #expect(timeSeries[0] == 5)
    
    try timeSeries.capture(10, at: 10)
    try timeSeries.capture(15, at: 15)
    #expect(timeSeries[10] == 10)

    timeSeries.clear()
    
    try timeSeries.capture(0, at: 0)
    
    #expect(throws: SampleError.sampleBeforeEndOfTimeSeries, performing: {
        try timeSeries.capture(10, at: -1)
    })
    
    try timeSeries.capture(1, at: 10)

    #expect(throws: SampleError.sampleBeforeEndOfTimeSeries, performing: {
        try timeSeries.capture(5, at: -1)
    })
    
    #expect(timeSeries[5] == 0.5)
}

@Test func dataPoints() async throws {
    let dataPoint = DataPoint(value: 1, timeInterval: 10)
    
    #expect(dataPoint.date == Date(timeIntervalSinceReferenceDate: 10))
}
