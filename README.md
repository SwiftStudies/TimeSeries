[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftStudies%2FTimeSeries%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/SwiftStudies/TimeSeries)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftStudies%2FTimeSeries%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/SwiftStudies/TimeSeries)

# TimeSeries

A Swift package for working with sampled real-time data such as IoT sensors, weather stations, home automation, and fitness trackers. It efficiently captures, stores, and queries time-indexed data with automatic interpolation and summarization.

## Architecture Overview

The package is organized into three layers, each building on the previous:

### Layer 1: Data Series (storage)

`DataSeries` is a protocol for storing chronologically ordered data points. Two concrete implementations are provided:

- **`EventSeries<T>`** -- Stores discrete events. Multiple events can occur at the same timestamp. Best for logs, detections, and notifications.
- **`SampleSeries<T: Sampleable>`** -- Stores continuously changing values. Only one value exists at any point in time, and the series can interpolate between captured values. Best for sensor readings, measurements, and metrics.

Both store `DataPoint<T>` values, which pair a value with a `TimeInterval` (seconds since reference date).

### Layer 2: Interpolation and Sampling

`SampleSeries` uses an `Interpolator` to calculate values between captured data points:

- **`LinearInterpolator`** -- Linearly interpolates between values (default for numeric types: `Double`, `Float`, `Int`)
- **`RoundingInterpolator`** -- Returns the nearer of the two surrounding values (switches at the midpoint)
- **`StepInterpolator`** -- Holds the previous value until the next capture (default for non-numeric types)

Custom interpolation can be provided by conforming to the `Interpolator` protocol. Numeric types conform to `NumericallyInterpolateable` to enable linear interpolation.

Types used in `SampleSeries` must conform to `Sampleable`, which requires `Equatable`, a `default` value, and an `inTolerance(_:and:)` method. Default conformances are provided for `Int`, `Double`, and `Float`.

### Layer 3: Time Series (summarization)

`TimeSeries<DataSeriesPointType, TimeSeriesPointType>` generates fixed-interval summary data points from a `DataSeries`. This is the primary type for producing chart-ready data. It uses a `Summarizer` to reduce each time interval to a single value.

Built-in summarizers:

| Summarizer | Input | Output | Description |
|---|---|---|---|
| `MeasureValue<S>` | `Sampleable` | Same | Value at beginning, middle, or end of period |
| `AverageFloatingPointValue<S>` | `FloatingPoint` | Same | Average across sub-samples in period |
| `AverageIntegerValue<S>` | `BinaryInteger` | Same | Average across sub-samples in period |
| `Count<T>` | Any | `Int` | Number of data points in period |
| `CountIf<T>` | `Sendable` | `Int` | Count of data points matching a condition |
| `MinimumValue<S>` | `Comparable & SignedNumeric` | Same | Minimum value in period |
| `MaximumValue<S>` | `Comparable & SignedNumeric` | Same | Maximum value in period |
| `SumSamples<S>` | `SignedNumeric` | Same | Sum of all values in period |

### Series Generators

`SeriesGenerator` produces sequences of non-overlapping time ranges for calendar-aware summarization:

- **`IntervalGenerator`** -- Regular fixed-length intervals
- **`WeekSeries`** -- 7 daily periods starting from a given date
- **`MonthSeries`** -- One period per day for the month containing a given date
- **`Rolling12MonthsSeries`** -- 12 monthly periods starting from a given date

### Time Convenience Extensions

`TimeInterval` extensions provide readable duration literals:

```swift
3.hours      // 10800.0 seconds
10.minutes   // 600.0 seconds
1.days       // 86400.0 seconds
2.weeks      // 1209600.0 seconds
```

`Date` extensions provide rounding: `dayRoundedUp`, `hourRoundedUp`, `minuteRoundedUp`, and `mask(excluding:)` for zeroing date components.

## Quick Start

### Event Series

`EventSeries` captures discrete events. Multiple events can occur at the same time.

```swift
import TimeSeries

enum SecurityEvent {
    case personDetected, petDetected, vehicleDetected
}

var events = EventSeries<SecurityEvent>()

try events.capture(.personDetected, at: Date.now.timeIntervalSinceReferenceDate)
try events.capture(.petDetected, at: Date.now.timeIntervalSinceReferenceDate)
```

### Sample Series

`SampleSeries` captures continuously changing values and interpolates between them.

```swift
import TimeSeries

var temps = SampleSeries<Double>()

let now = Date.now.timeIntervalSinceReferenceDate
try temps.capture(21.4, at: now)
try temps.capture(22.1, at: now + 1.hours)

// Query at any time -- the value is interpolated automatically
print(temps[now + 30.minutes]) // ~21.75 via linear interpolation
```

Efficient storage: if consecutive captured values are the same (or within tolerance), intermediate points are collapsed so only boundary changes are stored.

```swift
// With tolerance -- values within 0.5 of each other are collapsed
var smoothTemps = SampleSeries<Double>(tolerance: 0.5)
```

### Time Series

`TimeSeries` generates fixed-interval summaries from a data series, ideal for charting.

```swift
import TimeSeries

var samples = SampleSeries<Double>()
// ... capture temperature data over time ...

// Summarize the last 24 hours into hourly averages
let hourlyAvg = TimeSeries<Double, Double>(
    from: Date.now,
    for: -24.hours,
    every: 1.hours,
    using: samples,
    summarizer: AverageFloatingPointValue<Double>()
)

// Access generated data points by index
for point in hourlyAvg.dataPoints {
    print("\(point.date): \(point.value)")
}
```

When `DataSeriesPointType` and `TimeSeriesPointType` are the same `Sampleable` type, a convenience initializer is available that defaults to `MeasureValue` at the beginning of each period:

```swift
let hourlyTemps = TimeSeries<Double, Double>(
    from: Date.now,
    for: -24.hours,
    every: 1.hours,
    using: samples
)
```

### Custom Interpolation

Conform to `Interpolator` to define custom interpolation behavior:

```swift
struct MyInterpolator: Interpolator {
    func interpolate(at fraction: Double, between start: Double, and end: Double) -> Double {
        // fraction is 0.0 at start, 1.0 at end
        return start + (fraction * fraction) * (end - start) // quadratic ease-in
    }
}

var series = SampleSeries<Double>(interpolatedWith: MyInterpolator())
```

### Custom Summarization

Conform to `Summarizer` to define how a time period is reduced to a single value:

```swift
struct MedianValue: Summarizer {
    typealias SourceType = Double
    typealias DataType = Double

    func summarize(series: any Series, for period: TimeInterval, startingAt start: TimeInterval) -> DataPoint<Double> {
        let points = series[dataPointsFrom: start...(start + period)].map(\.value).sorted()
        let median = points.isEmpty ? 0.0 : points[points.count / 2]
        return DataPoint(value: median, timeInterval: start)
    }
}
```

## Key Concepts

- **All times are `TimeInterval`** (seconds since reference date, i.e. `Date.timeIntervalSinceReferenceDate`). Use `DataPoint.date` to convert back to `Date`.
- **Captures must be chronological.** Calling `capture(_:at:)` with a time before the last capture throws `CaptureError.captureOutOfOrder`.
- **`SampleSeries` always returns a value** when subscripted, using interpolation or the default value if no data exists.
- **`EventSeries` returns an empty array** if no events exist at the queried time.
- **`TimeSeries` is a value type.** After creation, capturing new data on the original `SampleSeries` does not update the `TimeSeries`. Use `TimeSeries.capture(_:at:)` to add data and automatically regenerate summaries.
- **Negative durations** in `TimeSeries` treat the `from` date as the end, looking backward in time.

## Requirements

- Swift 6.0+
- macOS 12+, iOS 15+, tvOS 15+, watchOS 10+, Mac Catalyst 15+
