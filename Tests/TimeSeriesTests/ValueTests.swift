//
//  ValueTests.swift
//  TimeSeries
//
//

import Testing
@testable import TimeSeries

@Test func floatTests() async throws {
    let floatValue : any NumericallyInterpolateable = Float(10).from(value: Double(-1.0))
    
    #expect(floatValue.doubleValue == -1.0)
}

@Test func intTests() async throws {
    let intValue : any NumericallyInterpolateable = Int(10).from(value: Double(-1.0))
    
    #expect(intValue.doubleValue == -1.0)
}

@Test func timeExtentionTests() async throws {
    #expect(1.seconds == 1)
    #expect(4.seconds == 4)
    #expect(1.minutes == 60)
    #expect(4.minutes == 240)
    #expect(1.hours == 3600)
    #expect(4.hours == 14400)
    #expect(1.days == 86400)
    #expect(4.days == 345600)
    #expect(1.weeks == 604800)
    #expect(4.weeks == 2419200)
}
