// SessionStore.swift
// Timer Teddy 🧸
// Handles local persistence of sessions and per-activity daily goals.

import Foundation
import Combine
import SwiftUI

/// Observable store that persists sessions and per-activity daily goals to UserDefaults.
final class SessionStore: ObservableObject {

    // MARK: - Published State

    @Published private(set) var sessions: [Session] = []

    /// Per-activity daily goals in minutes, keyed by ActivityType.rawValue
    @Published private(set) var activityGoals: [String: Int] = [:]

    // MARK: - Keys

    private let sessionsKey = "timerTeddy_sessions"
    private let goalsKey    = "timerTeddy_activityGoals"

    // MARK: - Defaults (minutes)

    private let defaultGoals: [ActivityType: Int] = [
        .study:    120,
        .work:     240,
        .sleep:    480,
        .fun:      60,
        .exercise: 60,
        .custom:   60
    ]

    // MARK: - Init

    init() {
        load()
    }

    // MARK: - Goal API

    /// Returns the saved goal (minutes) for a given activity, falling back to the default.
    func goal(for activity: ActivityType) -> Int {
        activityGoals[activity.rawValue] ?? defaultGoals[activity] ?? 60
    }

    /// Saves a new goal (minutes) for the given activity and persists immediately.
    func setGoal(_ minutes: Int, for activity: ActivityType) {
        activityGoals[activity.rawValue] = minutes
        saveGoals()
        objectWillChange.send()
    }

    // MARK: - Session API

    /// Append a newly completed session and persist.
    func add(_ session: Session) {
        sessions.append(session)
        saveSessions()
    }

    /// Remove sessions at the given offsets.
    func remove(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        saveSessions()
    }

    // MARK: - Analytics Helpers

    /// All sessions completed today.
    var todaySessions: [Session] {
        sessions.filter { Calendar.current.isDateInToday($0.dateCompleted) }
    }

    /// Total seconds across ALL activities for today.
    var todayTotalSeconds: Int {
        todaySessions.reduce(0) { $0 + $1.durationInSeconds }
    }

    /// Sessions completed within the past 7 days.
    var weekSessions: [Session] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions.filter { $0.dateCompleted >= cutoff }
    }

    /// Total seconds this week across all activities.
    var weekTotalSeconds: Int {
        weekSessions.reduce(0) { $0 + $1.durationInSeconds }
    }

    /// Total seconds for a specific activity type (all time).
    func totalSeconds(for type: ActivityType) -> Int {
        sessions
            .filter { $0.activityType == type }
            .reduce(0) { $0 + $1.durationInSeconds }
    }

    /// Total seconds today for a specific activity type.
    func todaySeconds(for type: ActivityType) -> Int {
        todaySessions
            .filter { $0.activityType == type }
            .reduce(0) { $0 + $1.durationInSeconds }
    }

    /// Grand total of all recorded seconds (used for Teddy level).
    var allTimeTotalSeconds: Double {
        Double(sessions.reduce(0) { $0 + $1.durationInSeconds })
    }

    /// Five most recent sessions, newest first.
    var recentSessions: [Session] {
        Array(sessions.sorted { $0.dateCompleted > $1.dateCompleted }.prefix(5))
    }

    // MARK: - Streak

    /// Current consecutive-day streak. A day counts if at least 1 session was completed.
    var currentStreak: Int {
        let cal = Calendar.current
        guard !sessions.isEmpty else { return 0 }

        // Unique days with at least one session, sorted newest → oldest
        let activeDays = Set(sessions.map { cal.startOfDay(for: $0.dateCompleted) })
            .sorted(by: >)

        guard let mostRecent = activeDays.first else { return 0 }

        // Streak only alive if user logged something today or yesterday
        let today     = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        guard mostRecent == today || mostRecent == yesterday else { return 0 }

        var streak   = 1
        var checking = mostRecent
        for day in activeDays.dropFirst() {
            let expected = cal.date(byAdding: .day, value: -1, to: checking)!
            if day == expected { streak += 1; checking = day } else { break }
        }
        return streak
    }

    /// Longest streak ever recorded.
    var longestStreak: Int {
        let cal = Calendar.current
        guard !sessions.isEmpty else { return 0 }

        let activeDays = Set(sessions.map { cal.startOfDay(for: $0.dateCompleted) })
            .sorted(by: >)

        var longest = 1, current = 1
        var prev = activeDays[0]
        for day in activeDays.dropFirst() {
            let expected = cal.date(byAdding: .day, value: -1, to: prev)!
            current = (day == expected) ? current + 1 : 1
            longest = max(longest, current)
            prev    = day
        }
        return longest
    }

    // MARK: - Heatmap helper

    /// Total seconds logged on a specific calendar day.
    func totalSeconds(on date: Date) -> Int {
        let cal = Calendar.current
        let day = cal.startOfDay(for: date)
        return sessions
            .filter { cal.startOfDay(for: $0.dateCompleted) == day }
            .reduce(0) { $0 + $1.durationInSeconds }
    }

    // MARK: - Persistence

    private func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: sessionsKey)
        }
    }

    private func saveGoals() {
        if let data = try? JSONEncoder().encode(activityGoals) {
            UserDefaults.standard.set(data, forKey: goalsKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([Session].self, from: data) {
            sessions = decoded
        }
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            activityGoals = decoded
        }
    }

    // MARK: - Legacy compatibility shim
    var dailyGoalMinutes: Int {
        get { goal(for: .study) }
        set { setGoal(newValue, for: .study) }
    }
    func saveDailyGoal() { /* no-op — setGoal persists immediately */ }
}
