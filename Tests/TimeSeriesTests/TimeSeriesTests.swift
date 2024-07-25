//
//  TimeSeriesTests.swift
//  TimeSeries
//
//
import Testing
import Foundation

@testable import TimeSeries

extension TimeSeries {
    var values : [TimeSeriesPointType] {
        return dataPoints.map({$0.value})
    }
}

@Test func timeSeries() async throws {
    
    var series = TimeSeries<Int,Int>(from: Date(timeIntervalSinceReferenceDate: 10.hours), for: -10.hours, every: 1.hours, using: SampleSeries<Int>.init(0, tolerance: 0))

    for value in series.values {
        #expect(value == 0)
    }
    
    #expect(series.dataPoints.count == 10)
    
    try series.capture(0, at: 0.hours)
    try series.capture(10, at: 1.hours)
    try series.capture(20, at: 2.hours)
    try series.capture(21, at: 5.hours)
    try series.capture(21, at: 7.hours)
    try series.capture(21, at: 8.hours)
    try series.capture(20, at: 10.hours)

    for test in Array(zip(series.values, [0,10,20,20,20,21,21,21,21,20])){
        #expect(test.0 == test.1)
    }
}

@Test func description() async throws {
    var series = TimeSeries<Int,Int>(from: Date(timeIntervalSinceReferenceDate: 10.hours), for: -10.hours, every: 1.hours, using: SampleSeries<Int>(0,tolerance: 0))
    
    for value in series.values {
        #expect(value == 0)
    }
    
    try series.capture(0, at: 0.hours)
    try series.capture(10, at: 1.hours)
    try series.capture(20, at: 2.hours)
    try series.capture(21, at: 5.hours)
    try series.capture(21, at: 7.hours)
    try series.capture(21, at: 8.hours)
    try series.capture(20, at: 10.hours)
    
    #expect(series.description == "(0.0: 0), (3600.0: 10), (7200.0: 20), (10800.0: 20), (14400.0: 20), (18000.0: 21), (21600.0: 21), (25200.0: 21), (28800.0: 21), (32400.0: 20)")
}

@Test func forward() async throws {
    var series = TimeSeries<Int,Int>(from: Date(timeIntervalSinceReferenceDate: 0.hours), for: 10.hours, every: 1.hours, using: SampleSeries<Int>())

    for value in series.values {
        #expect(value == 0)
    }
    
    try series.capture(0, at: 0.hours)
    try series.capture(10, at: 1.hours)
    try series.capture(20, at: 2.hours)
    try series.capture(21, at: 5.hours)
    try series.capture(19, at: 7.hours)
    try series.capture(21, at: 8.hours)
    try series.capture(20, at: 9.hours)

    for test in Array(zip(series.values, [0,10,20,20,20,21,20,19,21,20])){
        #expect(test.0 == test.1)
    }
}

@Test func tolerance() async throws {
    var series = TimeSeries<Int,Int>(from: Date(timeIntervalSinceReferenceDate: 10.hours), for: -10.hours, every: 1.hours, using: SampleSeries<Int>(0,tolerance: 0))

    for value in series.values {
        #expect(value == 0)
    }
    
    try series.capture(0, at: 0.hours)
    try series.capture(10, at: 1.hours)
    try series.capture(20, at: 2.hours)
    try series.capture(21, at: 5.hours)
    try series.capture(19, at: 7.hours)
    try series.capture(21, at: 8.hours)
    try series.capture(20, at: 9.hours)

    for test in Array(zip(series.values, [0,10,20,20,20,21,20,19,21,20])){
        #expect(test.0 == test.1)
    }
}
