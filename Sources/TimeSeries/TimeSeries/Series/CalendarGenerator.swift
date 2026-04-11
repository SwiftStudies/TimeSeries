//
//  CalendarGenerator.swift
//  TimeSeries
//
//

import Foundation

public extension Date {
    /// Enables you to mask out some components of a date (year, month, day, hour, minute, second, or nanosecond).
    /// - Parameter mask: A set of the components to mask out constrained by the set above
    /// - Returns: A new date
    func mask(excluding mask:Set<Calendar.Component>)->Date{
        var components = Calendar.current.dateComponents([.year,.month, .day,.hour, .minute, .second, .nanosecond], from: self)
        
        for component in mask {
            switch component {
            case .year:
                components.year = nil
            case .month:
                components.month = 1
            case .day:
                components.day = 1
            case .hour:
                components.hour = 0
            case .minute:
                components.minute = 0
            case .second:
                components.second = 0
            case .nanosecond:
                components.nanosecond = 0
            default: continue
            }
        }
        
        return Calendar.current.date(from: components)!
    }

}

/// A ``SeriesGenerator`` that produces 7 daily periods starting from midnight on the given date.
///
/// Hours, minutes, and seconds from the input date are stripped. Each period is exactly 24 hours.
public struct WeekSeries : SeriesGenerator {
    
    let startDate: Date
    
    /// Creates a new instance
    /// - Parameter date: The date to start from (hours, minutes and seconds will be ignored)
    public init(startingOn date: Date) {
        self.startDate = date.mask(excluding: [.hour, .minute, .second, .nanosecond])
    }
    
    public func generate() -> any Sequence<ClosedRange<TimeInterval>> {
        let start = startDate.timeIntervalSinceReferenceDate
        var result : [ClosedRange<TimeInterval>] = []
        
        for time in stride(from: start, to: start+7.days, by: 1.days){
            result.append(time...(time+1.days))
        }
        
        return result
    }
    
    
}

/// A ``SeriesGenerator`` that produces 12 monthly periods starting from the first day of the month containing the given date.
///
/// Each period spans from the first day of a month to one minute before the first day of the next month.
/// Month lengths vary naturally with the calendar.
public struct Rolling12MonthsSeries : SeriesGenerator {
    
    let startDate: Date
    
    /// Creates a new instance
    /// - Parameter date: The date to start from, it will be clipped to the first day of the month
    public init(startingOn date: Date) {
        self.startDate = date.mask(excluding: [.day,.hour, .minute, .second, .nanosecond])
    }
    
    public func generate() -> any Sequence<ClosedRange<TimeInterval>> {
        var result : [ClosedRange<TimeInterval>] = []
        
        for monthOffset in 0..<12 {
            var components = Calendar.current.dateComponents([.year,.month, .day], from: startDate)
            components.month! += monthOffset
            let newDate = Calendar.current.date(from: components)!
            let start = newDate.timeIntervalSinceReferenceDate
            
            components.month! += 1
            let endDate = Calendar.current.date(from: components)!.addingTimeInterval(-1.minutes)
            result.append(start...endDate.timeIntervalSinceReferenceDate)
        }
        
        return result
    }
}

/// A ``SeriesGenerator`` that produces one 24-hour period per day for the month containing the given date.
///
/// The input date is normalized to the first of the month. The number of periods matches
/// the actual number of days in that month (28-31).
public struct MonthSeries : SeriesGenerator {
    
    let startDate: Date
    
    /// Creates a new instance
    /// - Parameter date: The date to start from, which will be set to the first day of the month and the series will cover every day to the end of the month
    public init(startingOn date: Date) {
        self.startDate = date.mask(excluding: [.day,.hour, .minute, .second, .nanosecond])
    }
    
    public func generate() -> any Sequence<ClosedRange<TimeInterval>> {
        var result : [ClosedRange<TimeInterval>] = []
        
        for dayOffset in 0..<31 {
            var components = Calendar.current.dateComponents([.year,.month, .day], from: startDate)
            let month = components.month!
            components.day! += dayOffset
            if let newDate = Calendar.current.date(from: components) {
                if Calendar.current.component(.month, from: newDate) == month {
                    let start = newDate.timeIntervalSinceReferenceDate
                    result.append(start...start+1.days)
                }
            }
        }
        
        return result
    }
    
    
}
