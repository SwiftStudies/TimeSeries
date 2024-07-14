import Testing
@testable import TimeSeries

@Test func interpolation() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    var timeSeries = TimeSeries<Double>()
    
    do {
        try timeSeries.capture(0, at: 0)
        try timeSeries.capture(1, at: 10)
    } catch {
        #expect(Bool(false), "Exception thrown: \(error)")
    }
    
    #expect(timeSeries[-1] == 0)
    #expect(timeSeries[0] == 0)
    #expect(timeSeries[5] == 0.5)
    #expect(timeSeries[10] == 1)
    #expect(timeSeries[11] == 1)
}

@Test func compression() async throws {
    var timeSeries = TimeSeries<Double>()

    try timeSeries.capture(0, at: 0)
    try timeSeries.capture(1, at: 10)
    try timeSeries.capture(1, at: 20)
    try timeSeries.capture(1, at: 30)
    
    #expect(!timeSeries.sampleTimes.contains(20))
    
    timeSeries.clear()
    #expect(timeSeries.sampleTimes.isEmpty)
    
    try timeSeries.capture(0, at: 0)
    try timeSeries.capture(0, at: 10)
    try timeSeries.capture(0, at: 10)
    try timeSeries.capture(0, at: 20)
    try timeSeries.capture(0, at: 20)
    try timeSeries.capture(0, at: 30)
    try timeSeries.capture(0, at: 30)

    #expect(timeSeries.sampleTimes.count == 2)
    #expect(timeSeries.sampleTimes.contains(0))
    #expect(timeSeries.sampleTimes.contains(30))
    
    try timeSeries.capture(10, at: 30)
    #expect(timeSeries[30] == 10)
    #expect(timeSeries[40] == 10)
}

@Test func defaults() async throws {
    #expect(TimeSeries<Double>()[10] == 0)
    #expect(TimeSeries<Double>(20)[10] == 20)
}

@Test func creation() async throws {
    var timeSeries = TimeSeries<Double>()

    try timeSeries.capture(5, at: 5)
    #expect(timeSeries[10] == 5)
    #expect(timeSeries[5] == 5)
    #expect(timeSeries[0] == 5)
    
    try timeSeries.capture(10, at: 10)
    try timeSeries.capture(15, at: 15)
    #expect(timeSeries[10] == 10)

    timeSeries.clear()
    
    try timeSeries.capture(0, at: 0)
    
    #expect(throws: SampleError.sampleBeforeEndOfTimeSeries, performing: {
        try timeSeries.capture(10, at: -1)
    })
    
    try timeSeries.capture(1, at: 10)

    #expect(throws: SampleError.sampleBeforeEndOfTimeSeries, performing: {
        try timeSeries.capture(5, at: -1)
    })
    
    #expect(timeSeries[5] == 0.5)
}
