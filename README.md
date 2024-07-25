[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftStudies%2FTimeSeries%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/SwiftStudies/TimeSeries)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftStudies%2FTimeSeries%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/SwiftStudies/TimeSeries)

# TimeSeries

TimeSeries is a simple Swift package making it very easy to work with sampled real-time data (such as IoT, weather, home, fitness data). 
Samples are captured and stored efficiently and once captured, can be solely referenced as points in time. 
The package has complete documentation and very high test coverage. Contributions are very welcome. 

`TimeSeries` can be built on top of two different `DataSeries` the exhibit different behaviours as they capture new data points. The first
and simplest is `EventSeries` which is designed to niavely capture data that represents events (which can be any type). The second is `SampleSeries` 
which is intended to capture changing values over time. It has more sophisticated behavior and is able to interpolate between different captures 
using customizable methods. 

## Event Series

`EventSeries` captures discrete events, such as a security system recording the detection of people, pets, and cars entering its field of view. More
than one event can be captured at the same time. When used with a `TimeSeries` summarizers include `Count` and `CountIf` at this time. 

```swift
import TimeSeries

enum SecurityEvents {
    case personDetected, petDetected, vehicleDetected
}

var drivewayCameraEvents = EventSeries<SecurityEvents>()

drivewayCameraEvents.capture(.personDetected, at: Date.now)
drivewayCameraEvents.capture(.petDetected, at: Date.now) 
```

## Sample Series

`SampleSeries` captures value types and can interpolate between them. For `Double`, `Float`, and `Int` there are a set of standard `Interpolator`s

 - `RoundingInterpolator` assumes the value changes from the previous to the next once half the time between them has passed
 - `StepInterpolator` assumes that the value changes only at the point the new value is captured (similar to an event)
 - `LinearInterpolator` linearly changes from one value to the next

Unlike events, only the value being sampled can only have one value at a time, so capturing two values at exactly 
the same time will mean the last call to capture overwrites the previous. Finally when used with `TimeSeries` there 
are a richer set of `Summarizer`s are availble. 

 - `Count` counts the number of samples in a time period
 - `CountIf` counts the numbers of samples in the period that meet a supplied condition
 - `Average` generates the average for the value in the period
 - `MeasureValue` measures the value at the specified point (beginning, middle, or end) in the time period
 - `MinimumValue` returns the minimum value for the time period
 - `MaximumValue` returns the maximum value for the time period
 - `SumSamples` returns the sum of all values in the period 
 
```swift
import TimeSeries

var temps = SampleSeries<Double>()

temps.capture(currentTemp, at: Date.now)
```

To subsequently retrieve a temperature you no longer reference by sample point but can do so purely indexing by time

```
print(temps[Date.now.addingTimeInterval(-2.hours)])
```

## Time Series

`TimeSeries` is specialized by a type used by its input `DataSeries` and provides a fixed interval set of data points based on it's own `TimeSeriesDataType`. It does this by using 
a `Summarizer` appropriate to the type of the `DataSeries` (see above). For example, if you were sampling temperatures continuously 
you may wish to have a time series covering the last 24 hours reporting the average temperature each hour. 

This is very useful for generating charts (for example to use in Swift Charts). 

```swift
let last24Hours = TimeSeries<Double,Double>(from: Date.now, for: -24.hours, every: 1.hours, using: SampleSeries<Double>())

// Print the temperature halfway through
print(last24Hours[11])
```
