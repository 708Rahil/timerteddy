// Session.swift
// Timer Teddy 🧸
// Data model representing a single completed timer session

import Foundation

/// A record of one completed (or manually ended) timer session.
struct Session: Identifiable, Codable {
    var id: UUID
    var activityType: ActivityType
    /// Total seconds the user actually ran the timer (may be less than intended if ended early)
    var durationInSeconds: Int
    var dateCompleted: Date

    init(
        id: UUID = UUID(),
        activityType: ActivityType,
        durationInSeconds: Int,
        dateCompleted: Date = Date()
    ) {
        self.id = id
        self.activityType = activityType
        self.durationInSeconds = durationInSeconds
        self.dateCompleted = dateCompleted
    }

    // MARK: - Computed helpers

    /// Duration formatted as "X min" or "X hr Y min"
    var formattedDuration: String {
        let minutes = durationInSeconds / 60
        let hours   = minutes / 60
        let rem     = minutes % 60
        if hours > 0 {
            return rem > 0 ? "\(hours) hr \(rem) min" : "\(hours) hr"
        }
        return "\(max(minutes, 1)) min"
    }

    /// Relative date label: "Today", "Yesterday", or formatted date
    var relativeDateLabel: String {
        if Calendar.current.isDateInToday(dateCompleted)     { return "Today" }
        if Calendar.current.isDateInYesterday(dateCompleted) { return "Yesterday" }
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return fmt.string(from: dateCompleted)
    }
}
