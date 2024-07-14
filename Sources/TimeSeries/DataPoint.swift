//
//  DataPoint.swift
//  TimeSeries
//
//
import Foundation

struct DataPoint<T : Value> {
    let value   : T
    let time    : TimeInterval
}
