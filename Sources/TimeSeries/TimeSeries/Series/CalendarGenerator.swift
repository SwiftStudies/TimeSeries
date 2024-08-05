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

/// A series that takes any date and generates a series start at midnight that day and extending out for the next 7 days
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

/// A series that takes any date and generates a series start at midnight that day and extending out for the next 7 days
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

/// Creates a series with a period for each day of the month of the date supplied
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
