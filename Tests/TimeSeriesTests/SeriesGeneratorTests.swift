//
//  SeriesGeneratorTests.swift
//  TimeSeries
//
//

import Testing
import Foundation
@testable import TimeSeries



@Test func intervalGenerator() async throws {
    let generator = IntervalGenerator(start: 0, totalDuration: 1.hours, periodLength: 1.minutes)
    
    var periods = [ClosedRange<TimeInterval>]()
    periods.append(contentsOf: generator.generate())
    
    #expect(periods.count == 60)
    #expect(periods[0]==0.minutes...1.minutes)
    #expect(periods[29]==29.minutes...30.minutes)
    #expect(periods[59]==59.minutes...60.minutes)
}

@Test func weeklyGenerator() async throws {
    let initialDate = Date(timeIntervalSinceReferenceDate: 13.hours+12.minutes+3.seconds+1.0242)
    
    let generator = WeekSeries(startingOn: initialDate)
    
    let startDate = generator.startDate.timeIntervalSinceReferenceDate
    
    var periods = [ClosedRange<TimeInterval>]()
    periods.append(contentsOf: generator.generate())
    
    #expect(periods.count == 7)
    #expect(periods[0]==startDate...startDate+1.days)
    #expect(periods[6]==startDate+6.days...startDate+7.days)
}

@Test func annualGenerator() async throws {
    let initialDate = Date(timeIntervalSinceReferenceDate: 13.days+13.hours+12.minutes+3.seconds+1.0242)
    
    let generator = Rolling12MonthsSeries(startingOn: initialDate)
    
    let startDate = generator.startDate.timeIntervalSinceReferenceDate
    
    var periods = [ClosedRange<TimeInterval>]()
    periods.append(contentsOf: generator.generate())
    
    #expect(periods.count == 12)
    #expect(periods[0]==startDate...startDate+31.days-1.minutes)
    #expect(periods[2]==startDate+59.days...startDate+90.days-1.minutes)
}

@Test func monthGenerator() async throws {
    let initialDate = Date(timeIntervalSinceReferenceDate: 32.days+13.hours+12.minutes+3.seconds+1.0242)
    
    let generator = MonthSeries(startingOn: initialDate)
    
    let startDate = generator.startDate.timeIntervalSinceReferenceDate
    
    var periods = [ClosedRange<TimeInterval>]()
    periods.append(contentsOf: generator.generate())
    
    #expect(periods.count == 28)
    #expect(periods[0]==startDate...startDate+1.days)
}
