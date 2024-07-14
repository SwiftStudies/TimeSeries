//
//  TimeSeries+Descriptions.swift
//  TimeSeries
//
//

@available(macOS 13, *)
extension TimeSeries : CustomStringConvertible {
    public var description: String {
        var output = ""
        
        for dataPoint in dataPoints {
            if !output.isEmpty {
                output += ", "
            }
            
            output += "(\(dataPoint.time): \(dataPoint.value))"
        }
        
        return output
    }
}
