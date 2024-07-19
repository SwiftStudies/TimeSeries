//
//  DateTests.swift
//  TimeSeries
//
//

import Testing
import Foundation
@testable import TimeSeries

fileprivate var calendar : Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt
    
    return calendar
}

fileprivate var baseDate : Date {
    return Date(timeIntervalSinceReferenceDate: 3.weeks+10.days+4.hours+34.minutes+32.seconds+324324.nanoseconds)
}

@Test func testDayRounding() async throws {
    guard let expectation = Calendar.current.date(from: DateComponents(calendar: Calendar.current, year: 2001, month: 2, day: 1, hour: 0, minute: 0, second: 0)) else {
        #expect(Bool(false),"Did not create expectation")
        return
    }
    
    #expect(baseDate.dayRoundedUp ==  expectation)
}

@Test func testHourRounding() async throws {
    let expectation = try Date("2001-02-01T05:00:00Z", strategy: .iso8601)
    
    #expect(baseDate.hourRoundedUp ==  expectation)
}

@Test func testMinuteRounding() async throws {
    let expectation = try Date("2001-02-01T04:35:00Z", strategy: .iso8601)
    
    #expect(baseDate.minuteRoundedUp ==  expectation)
}
