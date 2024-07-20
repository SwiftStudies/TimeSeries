//
//  MinMax.swift
//  TimeSeries
//
//

import Foundation

fileprivate extension Sequence where Element : Comparable, Element : Sampleable, Element:SignedNumeric {
    var minimum : Element {
        return self.min() ?? Self.Element.default
    }
    
    var maximum : Element {
        return self.max() ?? Self.Element.default
    }
}

public struct MinimumValue<S:Sampleable> : Summarizer where S : Comparable, S : SignedNumeric{
    public typealias DataType = S
    public typealias SampleType = S
    
    public func summarize(series: Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        return DataPoint<S>(value: series[valuesFor: start...(start+period)-1.nanoseconds].map({$0.value}).minimum, timeInterval: start)
    }
}

public struct MaximumValue<S:Sampleable> : Summarizer where S : Comparable, S : SignedNumeric{
    public typealias DataType = S
    public typealias SampleType = S
    
    public func summarize(series: Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<S> {
        return DataPoint<S>(value: series[valuesFor: start...(start+period)-1.nanoseconds].map({$0.value}).maximum, timeInterval: start)
    }
}
