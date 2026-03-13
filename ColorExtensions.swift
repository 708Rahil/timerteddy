// ColorExtensions.swift
// Timer Teddy 🧸
// Professional design token system and hex color initializer.

import SwiftUI

extension Color {
    /// Initialize from a 6-character hex string (e.g. "FF5733").
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Design System

extension Color {
    // Backgrounds
    static let teddyBackground  = Color(hex: "F7F3EE")
    static let teddyCard        = Color(hex: "FFFFFF")
    static let teddySurface     = Color(hex: "F0EBE4")

    // Text
    static let teddyText        = Color(hex: "1A1208")
    static let teddySubtext     = Color(hex: "8A7968")
    static let teddyCaption     = Color(hex: "B5A898")

    // Borders
    static let teddyBorder      = Color(hex: "E8E0D6")
    static let teddySeparator   = Color(hex: "F0E8DF")

    // Brand
    static let teddyAccent      = Color(hex: "C96B2F")
    static let teddyAccentLight = Color(hex: "F5E6D8")

    // Semantic
    static let teddySuccess     = Color(hex: "3A9E72")
    static let teddyWarning     = Color(hex: "E8A020")
    static let teddyDanger      = Color(hex: "D94F3D")
}

// MARK: - Activity Colors

extension ActivityType {
    var accentColor: Color {
        switch self {
        case .study:    return Color(hex: "3B6FD4")   // Royal blue
        case .work:     return Color(hex: "C05E28")   // Burnt orange
        case .sleep:    return Color(hex: "7254C8")   // Deep violet
        case .fun:      return Color(hex: "2A9D6E")   // Forest green
        case .exercise: return Color(hex: "D0433A")   // Energetic red
        case .custom:   return Color(hex: "C08B28")   // Warm gold
        }
    }

    var accentLight: Color {
        switch self {
        case .study:    return Color(hex: "EEF3FF")
        case .work:     return Color(hex: "FFF1EB")
        case .sleep:    return Color(hex: "F3EEFF")
        case .fun:      return Color(hex: "EAFAF4")
        case .exercise: return Color(hex: "FFF0EF")
        case .custom:   return Color(hex: "FFF8E8")
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .study:    return [Color(hex: "F5F8FF"), Color(hex: "E8EFFF")]
        case .work:     return [Color(hex: "FFF8F5"), Color(hex: "FFEDE4")]
        case .sleep:    return [Color(hex: "F8F5FF"), Color(hex: "EDE6FF")]
        case .fun:      return [Color(hex: "F5FFFA"), Color(hex: "E4F7EE")]
        case .exercise: return [Color(hex: "FFF5F5"), Color(hex: "FFE4E3")]
        case .custom:   return [Color(hex: "FFFDF5"), Color(hex: "FFF5E0")]
        }
    }
}
