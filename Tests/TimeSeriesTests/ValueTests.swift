//
//  ValueTests.swift
//  TimeSeries
//
//

import Testing
@testable import TimeSeries

@Test func floatTests() async throws {
    let floatValue : any Value = Float(from: Double(-1.0))
    
    #expect(floatValue.doubleValue == -1.0)
    #expect(floatValue.absoluteValue.doubleValue == 1.0)
}

@Test func intTests() async throws {
    let intValue : any Value = Int(from: Double(-1.0))
    
    #expect(intValue.doubleValue == -1.0)
    #expect(intValue.absoluteValue.doubleValue == 1.0)
}
