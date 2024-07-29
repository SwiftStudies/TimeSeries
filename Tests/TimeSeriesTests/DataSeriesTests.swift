//
//  DataSeriesTests.swift
//  TimeSeries
//
//

import Testing
@testable import TimeSeries
import Foundation

public enum TestEvent {
    case personDetected, petDetected, vehicleDetected
}

@Test func testEventSeries() async throws {
    var series = EventSeries<TestEvent>()
    
    try series.capture(.personDetected, at: 0)
    try series.capture(.petDetected, at: 0)
    try series.capture(.petDetected, at: 0.5)
    try series.capture(.petDetected, at: 1.5)
    try series.capture(.petDetected, at: 1.5)
    try series.capture(.vehicleDetected, at: 2)
    try series.capture(.personDetected, at: 2.5)
    try series.capture(.personDetected, at: 3)
    
    #expect(series.timeRange == 0...3)
    #expect(series[0].count == 2)
    #expect(series[1.5].count == 2)
    #expect(series[3].count == 1)
    #expect(series[dataPointsFrom: 0...3].count == 8)
    #expect(series[dataPointsFrom: 1...2-1.nanoseconds].count == 2)

    
    series.clear(after: 1.5)
    #expect(series.timeRange == 0...1.5)

    
    series.clear()
    #expect(series.dataPoints.count == 0)
    #expect(series[2].count == 0)
    #expect(series[dataPointsFrom: 0...3].count == 0)
    #expect(series.timeRange == 0...0)
}
