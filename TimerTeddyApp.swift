// TimerTeddyApp.swift
// Timer Teddy 🧸
// App entry point. Injects SessionStore and OnboardingCoordinator.

import SwiftUI

@main
struct TimerTeddyApp: App {
    @StateObject private var sessionStore  = SessionStore()
    @StateObject private var onboarding    = OnboardingCoordinator()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
                .environmentObject(onboarding)
                .tint(Color.teddyAccent)
                .animation(.easeInOut(duration: 0.4), value: onboarding.hasCompletedOnboarding)
        }
    }
}
