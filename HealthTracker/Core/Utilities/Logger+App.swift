import OSLog

// MARK: - Logger categories
// Usage in Xcode console: filter by subsystem "com.yourapp.HealthTracker"
// or by category (e.g. "AI") to isolate relevant entries.
// .debug entries are redacted in release builds automatically by OSLog.

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "HealthTracker"

    /// AI prompt construction and API call lifecycle.
    static let ai = Logger(subsystem: subsystem, category: "AI")
}
