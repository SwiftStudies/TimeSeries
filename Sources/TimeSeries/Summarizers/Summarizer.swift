//
//  Summarizer.swift
//  TimeSeries
//
//

import Foundation

/// Implementers of the protocol provide methods of generating a single data point from a `SampleSeries` base on a range of times in that data-series
public protocol Summarizer<SourceType, DataType> {
    /// The types of sample in the source series
    associatedtype SourceType 
    
    /// The type of the generated data type
    associatedtype DataType
    typealias Series = DataSeries<SourceType>
    
    
    /// Summarize the specified time period using a specific methodology
    /// - Parameters:
    ///   - series: The source series
    ///   - period: The period to summarize
    ///   - start: The start of the period
    /// - Returns: A `DataPoint` that represents the period
    func summarize(series:any Series, for period:TimeInterval, startingAt start:TimeInterval) -> DataPoint<DataType>
}
