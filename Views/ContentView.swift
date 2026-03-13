// ContentView.swift
// Timer Teddy 🧸
// Root content view — just hosts HomeView so the app has a clean entry point.

// ContentView.swift
// Timer Teddy 🧸
// Root view — gates on onboarding completion, then shows HomeView.

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var coordinator: OnboardingCoordinator

    var body: some View {
        if coordinator.hasCompletedOnboarding {
            HomeView()
                .transition(.opacity)
        } else {
            OnboardingView()
                .transition(.opacity)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionStore())
        .environmentObject(OnboardingCoordinator())
}
