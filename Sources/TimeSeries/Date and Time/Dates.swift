//
//  Dates.swift
//  TimeSeries
//
//

import Foundation

/// Convenience properties for rounding `Date` values up to common calendar boundaries.
///
/// These are useful for aligning time series start/end points to clean boundaries.
public extension Date {

    /// Rounds the date up (ceiling) to the start of the next day (midnight).
    /// If the date is already exactly midnight, it advances to the following midnight.
    var dayRoundedUp: Date {
        let calendar = Calendar.current
        
        let newTime = addingTimeInterval(24.hours)
                
        let components = calendar.dateComponents([.hour,.minute, .second, .nanosecond], from: newTime)
        
        let clipHours       = TimeInterval(components.hour ?? 0).hours
        let clipMinutes     = TimeInterval(components.minute ?? 0).minutes
        let clipSeconds     = TimeInterval(components.second ?? 0).seconds
        let clipNanoseconds = TimeInterval(components.nanosecond ?? 0).nanoseconds
                
        return Date(timeIntervalSinceReferenceDate: round((newTime.timeIntervalSinceReferenceDate-(clipHours+clipMinutes+clipSeconds+clipNanoseconds))))

    }
    
    /// Rounds the date up (ceiling) to the start of the next hour.
    /// If the date is already exactly on the hour, it advances to the following hour.
    var hourRoundedUp: Date {
        let calendar = Calendar.current

        let newTime = addingTimeInterval(1.hours)
                
        let components = calendar.dateComponents([.minute, .second, .nanosecond], from: newTime)
        
        let clipMinutes     = TimeInterval(components.minute ?? 0).minutes
        let clipSeconds     = TimeInterval(components.second ?? 0).seconds
        let clipNanoseconds = TimeInterval(components.nanosecond ?? 0).nanoseconds
                
        return Date(timeIntervalSinceReferenceDate: round((newTime.timeIntervalSinceReferenceDate-(clipMinutes+clipSeconds+clipNanoseconds))))
    }

    /// Rounds the date up (ceiling) to the start of the next minute.
    /// If the date is already exactly on the minute, it advances to the following minute.
    var minuteRoundedUp: Date {
        let calendar = Calendar.current

        let newTime = addingTimeInterval(1.minutes)
                
        let components = calendar.dateComponents([.second, .nanosecond], from: newTime)
        
        let clipSeconds     = TimeInterval(components.second ?? 0).seconds
        let clipNanoseconds = TimeInterval(components.nanosecond ?? 0).nanoseconds
                
        return Date(timeIntervalSinceReferenceDate: round((newTime.timeIntervalSinceReferenceDate-(clipSeconds+clipNanoseconds))))

    }
    
}
