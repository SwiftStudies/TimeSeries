//
//  Times.swift
//  TimeSeries
//
//
import Foundation

extension TimeInterval {
    var seconds: Self {
        return self
    }
    
    var minutes: Self {
        return self * 60
    }
    
    var hours: Self {
        return self.minutes * 60
    }
    
    var days: Self {
        return self.hours * 24
    }
    
    var weeks:Self {
        return self.days * 7
    }
}
