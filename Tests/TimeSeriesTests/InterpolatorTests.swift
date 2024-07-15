//
//  InterpolatorTests.swift
//  TimeSeries
//
//

import Testing
@testable import TimeSeries

@Test func testRounding() async throws {
    let interpolator = RoundingInterpolator<Character>()
    
    #expect(interpolator.interpolate(at: 0.0, between: "a", and: "b") == "a")
    #expect(interpolator.interpolate(at: 0.4999999, between: "a", and: "b") == "a")
    #expect(interpolator.interpolate(at: 0.5, between: "a", and: "b") == "b")
    #expect(interpolator.interpolate(at: 0.75, between: "a", and: "b") == "b")
    #expect(interpolator.interpolate(at: 1.0, between: "a", and: "b") == "b")
}

@Test func testStep() async throws {
    let interpolator = StepInterpolator<Character>()
    
    #expect(interpolator.interpolate(at: 0.0, between: "a", and: "b") == "a")
    #expect(interpolator.interpolate(at: 0.4999999, between: "a", and: "a") == "a")
    #expect(interpolator.interpolate(at: 0.5, between: "a", and: "b") == "a")
    #expect(interpolator.interpolate(at: 0.75, between: "a", and: "b") == "a")
    #expect(interpolator.interpolate(at: 1.0, between: "a", and: "b") == "b")
}

@Test func testLinear() async throws {
    let interpolator = LinearInterpolator<Int>()
    
    #expect(interpolator.interpolate(at: 0.0, between: 0, and: 10) == 0)
    #expect(interpolator.interpolate(at: 0.25, between: 0, and: 10) == 2)
    #expect(interpolator.interpolate(at: 0.3, between: 0, and: 10) == 3)
    #expect(interpolator.interpolate(at: 0.5, between: 0, and: 10) == 5)
    #expect(interpolator.interpolate(at: 1.0, between: 0, and: 10) == 10)
}
