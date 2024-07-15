//
//  Times.swift
//  TimeSeries
//
//
import Foundation

public extension TimeInterval {
    /// The time interval as it's value as a number of seconds.
    var seconds: Self {
        return self
    }
    
    /// The time interval as it's value as a number of minutes.
    ///
    /// To get a `TimeInterval` of 10 minutes you would use the code below
    /// ```swift
    /// 10.minutes // equals 60
    /// ```
    var minutes: Self {
        return self * 60
    }
    
    /// The time interval as it's value as a number of hours
    ///
    /// To get a `TimeInterval` of 3 hours you would use the code below
    /// ```swift
    /// 3.hours // equals 10,800
    /// ```
    var hours: Self {
        return self.minutes * 60
    }
    
    /// The time interval as it's value as a number of days.
    ///
    /// To get a `TimeInterval` of 1 day  you would use the code below
    /// ```swift
    /// 1.days // equals 86,400
    /// ```
    var days: Self {
        return self.hours * 24
    }
    
    /// The time interval as it's value as a number of weeks.
    ///
    /// To get a `TimeInterval` of 2 weeks you would use the code below
    /// ```swift
    /// 2.weeks // equals 1,209,600
    /// ```
    var weeks:Self {
        return self.days * 7
    }
}
