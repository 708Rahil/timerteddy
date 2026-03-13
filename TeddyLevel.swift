// TeddyLevel.swift
// Timer Teddy 🧸
// Gamification levels based on total accumulated focus time

import SwiftUI

enum TeddyLevel: CaseIterable {
    case baby
    case student
    case focus
    case master

    /// Minimum total hours required to reach this level
    var minimumHours: Double {
        switch self {
        case .baby:    return 0
        case .student: return 5
        case .focus:   return 20
        case .master:  return 50
        }
    }

    /// Display title for the level
    var title: String {
        switch self {
        case .baby:    return "Baby Teddy"
        case .student: return "Student Teddy"
        case .focus:   return "Focus Teddy"
        case .master:  return "Master Teddy"
        }
    }

    /// Emoji badge for the level
    var badge: String {
        switch self {
        case .baby:    return "🐣"
        case .student: return "🎒"
        case .focus:   return "🔥"
        case .master:  return "🏆"
        }
    }

    /// Short motivational description
    var description: String {
        switch self {
        case .baby:    return "Just getting started! Keep going!"
        case .student: return "Learning the ropes. Great job!"
        case .focus:   return "You're on fire! Real dedication."
        case .master:  return "Legendary focus. Teddy bows to you!"
        }
    }

    /// Accent color for level badge
    var color: Color {
        switch self {
        case .baby:    return Color(hex: "A8D8EA")
        case .student: return Color(hex: "7EC8A4")
        case .focus:   return Color(hex: "FFB347")
        case .master:  return Color(hex: "E5855A")
        }
    }

    /// Hours needed to reach the next level (nil if already at max)
    var hoursToNext: Double? {
        let all = TeddyLevel.allCases
        guard let idx = all.firstIndex(of: self), idx + 1 < all.count else { return nil }
        return all[idx + 1].minimumHours
    }

    /// Determine level from total accumulated seconds
    static func level(for totalSeconds: Double) -> TeddyLevel {
        let hours = totalSeconds / 3600.0
        return TeddyLevel.allCases.reversed().first { hours >= $0.minimumHours } ?? .baby
    }
}

extension TeddyLevel: Equatable {}
