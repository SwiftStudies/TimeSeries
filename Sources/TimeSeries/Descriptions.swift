//
//  SampleSeries+Descriptions.swift
//  TimeSeries
//
//

extension SampleSeries : CustomStringConvertible {
    public var description: String {
        var output = ""
        
        for dataPoint in dataPoints {
            if !output.isEmpty {
                output += ", "
            }
            
            output += "(\(dataPoint.timeInterval): \(dataPoint.value))"
        }
        
        return output
    }
}


extension TimeSeries : CustomStringConvertible {
    public var description: String {
        var output = ""
        
        for dataPoint in dataPoints {
            if !output.isEmpty {
                output += ", "
            }
            
            output += "(\(dataPoint.timeInterval): \(dataPoint.value))"
        }
        
        return output
    }
}
