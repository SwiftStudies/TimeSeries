//
//  Dates.swift
//  TimeSeries
//
//

import Foundation

fileprivate let calendar = Calendar.current

public extension Date {

    // The date rounded up (ceiling) to the nearest hour
    var dayRoundedUp: Date {
        let newTime = addingTimeInterval(24.hours)
                
        let components = calendar.dateComponents([.hour,.minute, .second, .nanosecond], from: newTime)
        
        let clipHours       = TimeInterval(components.hour ?? 0).hours
        let clipMinutes     = TimeInterval(components.minute ?? 0).minutes
        let clipSeconds     = TimeInterval(components.second ?? 0).seconds
        let clipNanoseconds = TimeInterval(components.nanosecond ?? 0).nanoseconds
                
        return Date(timeIntervalSinceReferenceDate: round((newTime.timeIntervalSinceReferenceDate-(clipHours+clipMinutes+clipSeconds+clipNanoseconds))))

    }
    
    // The date rounded up (ceiling) to the nearest hour
    var hourRoundedUp: Date {
        let newTime = addingTimeInterval(1.hours)
                
        let components = calendar.dateComponents([.minute, .second, .nanosecond], from: newTime)
        
        let clipMinutes     = TimeInterval(components.minute ?? 0).minutes
        let clipSeconds     = TimeInterval(components.second ?? 0).seconds
        let clipNanoseconds = TimeInterval(components.nanosecond ?? 0).nanoseconds
                
        return Date(timeIntervalSinceReferenceDate: round((newTime.timeIntervalSinceReferenceDate-(clipMinutes+clipSeconds+clipNanoseconds))))
    }

    // The date rounded up (ceiling) the nearest minute
    var minuteRoundedUp: Date {
        let newTime = addingTimeInterval(1.minutes)
                
        let components = calendar.dateComponents([.second, .nanosecond], from: newTime)
        
        let clipSeconds     = TimeInterval(components.second ?? 0).seconds
        let clipNanoseconds = TimeInterval(components.nanosecond ?? 0).nanoseconds
                
        return Date(timeIntervalSinceReferenceDate: round((newTime.timeIntervalSinceReferenceDate-(clipSeconds+clipNanoseconds))))

    }
    
}
