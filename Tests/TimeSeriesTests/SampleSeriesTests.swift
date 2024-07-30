//
//  SampleSeriesTests.swift
//  TimeSeries
//
//
import Testing
import Foundation
@testable import TimeSeries

@Test func defaults() async throws {
    #expect(SampleSeries<Double>()[10][0] == 0)
    #expect(SampleSeries<Double>(20)[10][0] == 20)
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
    
    #expect(timeSeries[-1][0] == 0)
    #expect(timeSeries[0][0] == 0)
    #expect(timeSeries[5][0] == 0.5)
    #expect(timeSeries[10][0] == 1)
    #expect(timeSeries[11][0] == 1)
}

@Test func interpolatorOverride() async throws {
    var series = SampleSeries<Int>(interpolatedWith: StepInterpolator<Int>())
    
    try series.capture(0, at: 0)
    try series.capture(10, at: 10)
    
    #expect(series[0][0] == 0)
    #expect(series[5][0] == 0)
    #expect(series[9][0] == 0)
    #expect(series[10][0] == 10)
}

extension Character : Sampleable {
    public static var `default`: Character {
        return "x"
    }
}

@Test func nonNumericDefaultInterpolator() async throws {
    
    var series = SampleSeries<Character>()
    
    try series.capture("a", at: 0)
    try series.capture("b", at: 10)
    
    #expect(series[0][0] == "a")
    #expect(series[5][0] == "a")
    #expect(series[9][0] == "a")
    #expect(series[10][0] == "b")
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

@Test func sampleOnOrBefore() async throws {
    var series = SampleSeries<Int>(tolerance: 1)
    
    try series.capture(0, at: 0.hours)
    try series.capture(10, at: 1.hours)
    try series.capture(20, at: 2.hours)
    try series.capture(21, at: 5.hours)
    try series.capture(19, at: 7.hours)
    try series.capture(21, at: 8.hours)
    try series.capture(20, at: 9.hours)
    
    #expect(series.sample(onOrBefore: -1.hours) == nil)
    #expect(series.sample(onOrBefore: 1.5.hours)!.value == 10)
    #expect(series.sample(onOrBefore: 0.hours)!.value == 0)
    #expect(series.sample(onOrBefore: 9.hours)!.value == 20)
    #expect(series.sample(onOrBefore: 9.5.hours)!.value == 20)

}


@Test func clearing() async throws {
    var series = SampleSeries<Int>(tolerance: 1)
    
    try series.capture(0, at: 0.hours)
    try series.capture(10, at: 1.hours)
    try series.capture(20, at: 2.hours)
    try series.capture(21, at: 5.hours)
    try series.capture(19, at: 7.hours)
    try series.capture(21, at: 8.hours)
    try series.capture(20, at: 9.hours)
    
    series.clear(after: 5.hours)
    
    #expect(series.dataPoints.count == 4)
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
