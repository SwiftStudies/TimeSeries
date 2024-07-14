//
//  TimeSeries.swift
//  TimeSeries
//
//
import Testing
@testable import TimeSeries

@Test func defaults() async throws {
    #expect(TimeSeries<Double>()[10] == 0)
    #expect(TimeSeries<Double>(20)[10] == 20)
}

@Test func interpolation() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    var timeSeries = TimeSeries<Double>()
    
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

@Test func descriptions() async throws {
    var timeSeries = TimeSeries<Int>()
    
    try timeSeries.capture(1, at: 0)
    #expect(timeSeries.description == "(0.0: 1)")
    
    try timeSeries.capture(2, at: 10)
    #expect(timeSeries.description == "(0.0: 1), (10.0: 2)")
        
    try timeSeries.capture(3, at: 20)
    #expect(timeSeries.description == "(0.0: 1), (10.0: 2), (20.0: 3)")
}
