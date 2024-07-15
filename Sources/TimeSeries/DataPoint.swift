//
//  DataPoint.swift
//  TimeSeries
//
//
import Foundation

/// A  value captured or calculated in a series at a certain point in time
public struct DataPoint<T : Value> {
    /// The value
    let value   : T
    
    /// Time in seconds since reference date
    let time    : TimeInterval
}
