// HomeView.swift
// Timer Teddy 🧸
// Dark warm home screen — onboarding-matched aesthetic.

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store:       SessionStore
    @EnvironmentObject private var coordinator: OnboardingCoordinator
    @State private var selectedActivity: ActivityType? = nil
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {

                timerTab
                    .tabItem { Label("Timer", systemImage: selectedTab == 0 ? "timer.circle.fill" : "timer.circle") }
                    .tag(0)

                DashboardView()
                    .tabItem { Label("Stats", systemImage: selectedTab == 1 ? "chart.bar.fill" : "chart.bar") }
                    .tag(1)

                DailyGoalView()
                    .tabItem { Label("Goals", systemImage: "target") }
                    .tag(2)

                SettingsView()
                    .tabItem { Label("Settings", systemImage: selectedTab == 3 ? "gearshape.fill" : "gearshape") }
                    .tag(3)
            }
            .tint(Color(hex: "C96B2F"))
            .toolbarBackground(Color(hex: "1A0D06"), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
            .navigationDestination(item: $selectedActivity) { activity in
                TimerView(activity: activity)
            }
        }
    }

    // MARK: - Timer Tab

    private var timerTab: some View {
        ZStack {
            Color(hex: "1A0D06").ignoresSafeArea()

            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "C96B2F").opacity(0.10), .clear],
                    center: .center, startRadius: 0, endRadius: 260
                ))
                .frame(width: 520, height: 520)
                .offset(x: -160, y: 380)
                .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerHero
                    activitySection
                    streakBanner
                }
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Header Hero

    private var headerHero: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "2C1A0E"), Color(hex: "5C3218")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)
            .frame(height: 180)

            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "C96B2F").opacity(0.20), .clear],
                    center: .center, startRadius: 0, endRadius: 160
                ))
                .frame(width: 320, height: 320)
                .offset(x: 120, y: -80)
                .allowsHitTesting(false)

            // Teddy — right side
            HStack {
                Spacer()
                AnimatedTeddyView()
                    .frame(width: 240, height: 120)
                    .offset(x: -80, y: -24)
            }

            // Text — left side
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(timeGreeting)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.5))

                        Text(coordinator.profile.name.isEmpty
                             ? "Timer Teddy"
                             : "Hey, \(coordinator.profile.name) 👋")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("What are you focusing on?")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.45))
                    }

                    Spacer()

                    // Today pill
                    VStack(spacing: 2) {
                        Text(formatSeconds(store.todayTotalSeconds))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("today")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.5))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
                }
                .padding(.horizontal, 70)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Activity Section

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Start a session")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Tap an activity to begin tracking")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.35))
            }
            .padding(.horizontal, 70)
            .padding(.top, 24)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                spacing: 10
            ) {
                ForEach(ActivityType.allCases, id: \.self) { activity in
                    ActivityCard(activity: activity, todayMinutes: store.todaySeconds(for: activity) / 60) {
                        selectedActivity = activity
                    }
                }
            }
            .padding(.horizontal, 70)
        }
    }

    // MARK: - Streak Banner

    private var streakBanner: some View {
        let streak     = store.currentStreak
        let level      = TeddyLevel.level(for: store.allTimeTotalSeconds)
        let totalHours = store.allTimeTotalSeconds / 3600

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(streak > 0
                          ? Color(hex: "C96B2F").opacity(0.18)
                          : Color.white.opacity(0.06))
                    .frame(width: 50, height: 50)
                VStack(spacing: 0) {
                    Text(streak > 0 ? "🔥" : "🧸").font(.system(size: 20))
                    if streak > 0 {
                        Text("\(streak)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: "C96B2F"))
                    }
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(streak > 0 ? "\(streak) day streak 🔥" : level.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(streak > 0
                     ? "Keep it up! \(String(format: "%.1f", totalHours))h logged"
                     : "\(String(format: "%.1f", totalHours))h total · \(level.description)")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.4))
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.2))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 15)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18).strokeBorder(
                streak > 0 ? Color(hex: "C96B2F").opacity(0.35) : Color.white.opacity(0.08),
                lineWidth: 1
            )
        )
        .padding(.horizontal, 70)
        .padding(.top, 12)
        .onTapGesture { selectedTab = 1 }
    }

    // MARK: - Helpers

    private var timeGreeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12:  return "Good morning ☀️"
        case 12..<17: return "Good afternoon 🌤"
        case 17..<21: return "Good evening 🌇"
        default:      return "Good night 🌙"
        }
    }

    private func formatSeconds(_ s: Int) -> String {
        let h = s / 3600; let m = (s % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Activity Card
// ─────────────────────────────────────────────────────────────

private struct ActivityCard: View {
    let activity:     ActivityType
    let todayMinutes: Int
    let onTap:        () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(activity.accentColor.opacity(0.18))
                            .frame(width: 42, height: 42)
                        Text(activity.emoji).font(.system(size: 22))
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.2))
                        .padding(7)
                        .background(Color.white.opacity(0.06), in: Circle())
                }
                .padding(.bottom, 12)

                Text(activity.displayName)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(todayMinutes > 0 ? "\(todayMinutes)m today" : "Tap to start")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(todayMinutes > 0
                                     ? activity.accentColor.opacity(0.9)
                                     : Color.white.opacity(0.3))
                    .padding(.top, 2)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(DarkCardStyle(accentColor: activity.accentColor))
    }
}

private struct DarkCardStyle: ButtonStyle {
    let accentColor: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed
                    ? Color.white.opacity(0.10)
                    : Color.white.opacity(0.06),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18).strokeBorder(
                    configuration.isPressed
                        ? accentColor.opacity(0.5)
                        : Color.white.opacity(0.08),
                    lineWidth: 1.5
                )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .shadow(color: Color.black.opacity(0.25), radius: 8, y: 3)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    HomeView()
        .environmentObject(SessionStore())
        .environmentObject(OnboardingCoordinator())
}
