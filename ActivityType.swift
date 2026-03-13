// ActivityType.swift
// Timer Teddy 🧸
// Defines all activity types with display info and associated teddy images.
// Colors and gradients are defined in ColorExtensions.swift as ActivityType extensions.

import SwiftUI

enum ActivityType: String, CaseIterable, Codable {
    case study
    case work
    case sleep
    case fun
    case exercise
    case custom

    /// Human-readable display name
    var displayName: String {
        switch self {
        case .study:    return "Study"
        case .work:     return "Work"
        case .sleep:    return "Sleep"
        case .fun:      return "Fun"
        case .exercise: return "Exercise"
        case .custom:   return "Custom"
        }
    }

    /// Emoji representing the activity
    var emoji: String {
        switch self {
        case .study:    return "📚"
        case .work:     return "💻"
        case .sleep:    return "😴"
        case .fun:      return "🎮"
        case .exercise: return "🏃"
        case .custom:   return "⏱️"
        }
    }

    /// Asset name for the teddy bear image
    var teddyImageName: String {
        switch self {
        case .study:    return "teddy_reading"
        case .work:     return "teddy_laptop"
        case .sleep:    return "teddy_sleeping"
        case .fun:      return "teddy_playing"
        case .exercise: return "teddy_exercise"
        case .custom:   return "teddy_default"
        }
    }

    /// Default suggested duration in seconds
    var defaultDuration: Int {
        switch self {
        case .study:    return 25 * 60
        case .work:     return 50 * 60
        case .sleep:    return 8 * 60 * 60
        case .fun:      return 30 * 60
        case .exercise: return 45 * 60
        case .custom:   return 15 * 60
        }
    }
}
