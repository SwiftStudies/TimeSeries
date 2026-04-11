//
//  Times.swift
//  TimeSeries
//
//
import Foundation

/// Convenience properties for expressing `TimeInterval` values in human-readable time units.
///
/// These allow writing durations as natural literals throughout the package and in client code:
/// ```swift
/// 3.hours      // 10800.0 (seconds)
/// 10.minutes   // 600.0
/// 1.days       // 86400.0
/// 500.milliseconds // 0.5
/// ```
///
/// The conversion direction depends on the unit:
/// - `.nanoseconds` and `.milliseconds` **divide** (converting smaller units to seconds).
/// - `.minutes`, `.hours`, `.days`, `.weeks` **multiply** (converting larger units to seconds).
/// - `.seconds` is the identity (returns `self`).
public extension TimeInterval {

    /// Interprets `self` as a count of nanoseconds and converts to seconds.
    /// Example: `500_000_000.nanoseconds` equals `0.5` seconds.
    var nanoseconds : Self {
        return self / 1_000_000_000
    }

    /// Interprets `self` as a count of milliseconds and converts to seconds.
    /// Example: `1500.milliseconds` equals `1.5` seconds.
    var milliseconds : Self {
        return self / 1000
    }

    /// Identity -- `self` is already in seconds. Provided for readability.
    var seconds: Self {
        return self
    }

    /// Interprets `self` as a count of minutes and converts to seconds.
    /// Example: `10.minutes` equals `600.0` seconds.
    var minutes: Self {
        return self * 60
    }

    /// Interprets `self` as a count of hours and converts to seconds.
    /// Example: `3.hours` equals `10800.0` seconds.
    var hours: Self {
        return self.minutes * 60
    }

    /// Interprets `self` as a count of days (24 hours each) and converts to seconds.
    /// Example: `1.days` equals `86400.0` seconds.
    var days: Self {
        return self.hours * 24
    }

    /// Interprets `self` as a count of weeks (7 days each) and converts to seconds.
    /// Example: `2.weeks` equals `1209600.0` seconds.
    var weeks:Self {
        return self.days * 7
    }
}
