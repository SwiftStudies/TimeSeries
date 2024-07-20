//
//  Summarizer.swift
//  TimeSeries
//
//

import Foundation

/// Implementers of the protocol provide methods of generating a single data point from a `SampleSeries` base on a range of times in that data-series
public protocol Summarizer<SampleType, DataType> {
    /// The types of sample in the source series
    associatedtype SampleType : Sampleable
    
    /// The type of the generated data type
    associatedtype DataType
    typealias Series = SampleSeries<SampleType>
    
    
    /// Summarize the specified time period using a specific methodology
    /// - Parameters:
    ///   - series: The source series
    ///   - period: The period to summarize
    ///   - start: The start of the period
    /// - Returns: A `DataPoint` that represents the period
    func summarize(series:Series, for period:TimeInterval, startingAt start:TimeInterval) -> DataPoint<DataType>
}
