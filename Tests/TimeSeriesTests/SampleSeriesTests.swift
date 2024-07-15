//
//  SampleSeriesTests.swift
//  TimeSeries
//
//
import Testing
import Foundation
@testable import TimeSeries

@Test func defaults() async throws {
    #expect(SampleSeries<Double>()[10] == 0)
    #expect(SampleSeries<Double>(20)[10] == 20)
}

@Test func interpolation() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    var timeSeries = SampleSeries<Double>()
    
    do {
        try timeSeries.capture(0, at: 0)
        try timeSeries.capture(1, at: 10)
    } catch {
        #expect(Bool(false), "Exception thrown: \(error)")
    }
    
    #expect(timeSeries[-1] == 0)
    #expect(timeSeries[0] == 0)
    #expect(timeSeries[5] == 0.5)
    #expect(timeSeries[10] == 1)
    #expect(timeSeries[11] == 1)
}

@Test func compressionWithBounce() async throws {
    var series = SampleSeries<Int>(tolerance: 1)
    
    try series.capture(0, at: 0.hours)
    try series.capture(10, at: 1.hours)
    try series.capture(20, at: 2.hours)
    try series.capture(21, at: 5.hours)
    try series.capture(19, at: 7.hours)
    try series.capture(21, at: 8.hours)
    try series.capture(20, at: 9.hours)
    
    #expect(series.dataPoints.count == 7)
}

@Test func samplesToTimeSeries() async throws {
    var series = SampleSeries<Int>()
    
    for i in 0..<20 {
        try series.capture(i, at: TimeInterval(i).hours)
    }
    
    let betweenSeries = series.dataPoints(from: 5.hours, to: 10.hours, with: 1.hours)
    #expect(betweenSeries.count == 5)
    for test in zip(betweenSeries, [5,6,7,8,9,10]){
        #expect(test.0.value == test.1)
    }
    
    let periodSeries = series.dataPoints(from: 5.hours, for: 5.hours, sampleEvery: 1.hours)
    #expect(betweenSeries.count == 5)
    for test in zip(periodSeries, [5,6,7,8,9]){
        #expect(test.0.value == test.1)
    }

}

@Test func descriptions() async throws {
    var timeSeries = SampleSeries<Int>()
    
    try timeSeries.capture(1, at: 0)
    #expect(timeSeries.description == "(0.0: 1)")
    
    try timeSeries.capture(2, at: 10)
    #expect(timeSeries.description == "(0.0: 1), (10.0: 2)")
        
    try timeSeries.capture(3, at: 20)
    #expect(timeSeries.description == "(0.0: 1), (10.0: 2), (20.0: 3)")
}
