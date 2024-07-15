//
//  TimeSeriesTests.swift
//  TimeSeries
//
//
import Testing
import Foundation

@testable import TimeSeries

@Test func timeSeries() async throws {
    var series = TimeSeries<Int>(relativeTo: Date(timeIntervalSinceReferenceDate: 9.hours), dataPointEvery: 1.hours, capturing: 10, defaultValue: 0, tolerance: 0)
    
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

    for test in Array(zip(series.values, [0,10,20,20,20,21,21,21,21,20].reversed())){
        #expect(test.0 == test.1)
    }
}

@Test func description() async throws {
    var series = TimeSeries<Int>(relativeTo: Date(timeIntervalSinceReferenceDate: 9.hours), dataPointEvery: 1.hours, capturing: 10, defaultValue: 0, tolerance: 0)
    
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
    
    print(series.description)
    
    #expect(series.description == "(32400.0: 20), (28800.0: 21), (25200.0: 21), (21600.0: 21), (18000.0: 21), (14400.0: 20), (10800.0: 20), (7200.0: 20), (3600.0: 10), (0.0: 0)")
}

@Test func tolerance() async throws {
    var series = TimeSeries<Int>(relativeTo: Date(timeIntervalSinceReferenceDate: 9.hours), dataPointEvery: 1.hours, capturing: 10, defaultValue: 0, tolerance: 1)
    
    for value in series.values {
        #expect(value == 0)
    }
    
    try series.capture(0, at: 0.hours)
    try series.capture(10, at: 1.hours)
    try series.capture(20, at: 2.hours)
    try series.capture(21, at: 5.hours)
    try series.capture(19, at: 7.hours)
    try series.capture(21, at: 8.hours)
    try series.capture(20, at: 10.hours)

    for test in Array(zip(series.values, [0,10,20,20,20,20,20,20,20,20].reversed())){
        #expect(test.0 == test.1)
    }
}
