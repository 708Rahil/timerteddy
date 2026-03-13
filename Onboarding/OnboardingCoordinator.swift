//
//  OnboardingCoordinator.swift
//  Timer Teddy
//
//  Created by Rahil Gandhi on 2026-03-12.
//
// OnboardingCoordinator.swift
// Timer Teddy 🧸
// Manages onboarding completion state and persists the user profile.

import SwiftUI
import Combine

// MARK: - User Profile

struct UserProfile: Codable {
    var name:        String = ""
    var age:         String = ""
    var gender:      String = ""
    var goals:       [String] = []
    var isPremium:   Bool = false
}

// MARK: - Coordinator

final class OnboardingCoordinator: ObservableObject {

    @Published var hasCompletedOnboarding: Bool = false
    @Published var profile = UserProfile()

    private let completedKey = "timerTeddy_onboardingDone"
    private let profileKey   = "timerTeddy_userProfile"

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: completedKey)
        if let data    = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
        }
    }

    func completeOnboarding(isPremium: Bool) {
        profile.isPremium = isPremium
        saveProfile()
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
        UserDefaults.standard.set(true, forKey: completedKey)
    }

    func saveProfile() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }

    /// Call from Settings if you want to re-show onboarding (debug / reset)
    func resetOnboarding() {
        hasCompletedOnboarding = false
        profile = UserProfile()
        UserDefaults.standard.removeObject(forKey: completedKey)
        UserDefaults.standard.removeObject(forKey: profileKey)
    }
}
