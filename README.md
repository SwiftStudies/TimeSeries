[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftStudies%2FTimeSeries%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/SwiftStudies/TimeSeries)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftStudies%2FTimeSeries%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/SwiftStudies/TimeSeries)

# TimeSeries

TimeSeries is a simple Swift package making it very easy to work with sampled real-time data (such as IoT, weather, fitness data). Samples are captured and stored efficiently and once captured, can be solely referenced as points in time. 

The package has complete documentation and very high test coverage. Contributions are very welcome. 

## Sample Series

Simply add the package to your repository and start sampling. 

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

TimeSeries type extends on sample series by providing an interface that generates data points automatically based on samples taken and updates to the reference date captured. This can be very useful for producing charts (for example Swift Charts). 

```swift
let last24Hours = TimeSeries(from: Date.now, for: -24.hours, every: 1.hours, using: temps)

// Print the temperature halfway through
print(last24Hours[11])
```
