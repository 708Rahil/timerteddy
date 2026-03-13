// DashboardView.swift
// Timer Teddy 🧸
// Dark warm stats dashboard — matches home screen aesthetic.

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: SessionStore

    var body: some View {
        ZStack {
            Color(hex: "1A0D06").ignoresSafeArea()

            // Ambient glow bottom-right
            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "C96B2F").opacity(0.08), .clear],
                    center: .center, startRadius: 0, endRadius: 280
                ))
                .frame(width: 560, height: 560)
                .offset(x: 180, y: 400)
                .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    pageHeader
                    VStack(spacing: 22) {
                        streakSection
                        summaryRow
                        heatmapSection
                        activityBreakdownSection
                        recentSessionsSection
                        teddyLevelSection
                    }
                    .padding(.horizontal, 70)
                    .padding(.top, 24)
                    .padding(.bottom, 48)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    // MARK: - Page Header (matches home hero style)

    private var pageHeader: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "2C1A0E"), Color(hex: "5C3218")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)
            .frame(height: 110)

            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "C96B2F").opacity(0.20), .clear],
                    center: .center, startRadius: 0, endRadius: 160
                ))
                .frame(width: 320, height: 320)
                .offset(x: 120, y: -60)
                .allowsHitTesting(false)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Progress")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Keep the streak going 🔥")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.45))
                }
                Spacer()
                // All-time hours pill
                VStack(spacing: 2) {
                    Text(formatTime(Int(store.allTimeTotalSeconds)))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("all time")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.5))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
            }
            .padding(.horizontal, 70)
            .padding(.bottom, 16)
        }
    }

    // MARK: - Streak Tiles

    private var streakSection: some View {
        HStack(spacing: 10) {
            streakTile(value: store.currentStreak,  label: "Day Streak",  icon: "flame.fill",          color: Color(hex: "E8630A"))
            streakTile(value: store.longestStreak,  label: "Best Streak", icon: "trophy.fill",          color: Color(hex: "C08B28"))
            streakTile(value: activeDayCount,       label: "Days Active", icon: "checkmark.seal.fill",  color: Color(hex: "3A9E72"))
        }
    }

    private func streakTile(value: Int, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
            Text("\(value)")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(color.opacity(0.25), lineWidth: 1))
    }

    // MARK: - Summary Row

    private var summaryRow: some View {
        HStack(spacing: 10) {
            darkStatCard(
                title: "Today",
                value: formatTime(store.todayTotalSeconds),
                subtitle: "\(store.todaySessions.count) sessions",
                icon: "sun.max.fill",
                color: Color(hex: "E8A020")
            )
            darkStatCard(
                title: "This Week",
                value: formatTime(store.weekTotalSeconds),
                subtitle: "\(store.weekSessions.count) sessions",
                icon: "calendar",
                color: Color(hex: "3B6FD4")
            )
        }
    }

    private func darkStatCard(title: String, value: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.18))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.35))
            }
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.25))
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(color.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Heatmap

    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Activity Calendar", icon: "square.grid.3x3.fill")
            StreakHeatmap()
                .environmentObject(store)
        }
    }

    // MARK: - Activity Breakdown

    private var activityBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Today's Breakdown", icon: "chart.bar.fill")

            VStack(spacing: 2) {
                ForEach(Array(ActivityType.allCases.enumerated()), id: \.element) { idx, activity in
                    let secs = store.todaySeconds(for: activity)
                    DarkBreakdownRow(activity: activity, seconds: secs, totalSeconds: max(store.todayTotalSeconds, 1))
                    if idx < ActivityType.allCases.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
        }
    }

    // MARK: - Recent Sessions

    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Recent Sessions", icon: "clock.fill")

            if store.recentSessions.isEmpty {
                emptyState
            } else {
                VStack(spacing: 2) {
                    ForEach(Array(store.recentSessions.enumerated()), id: \.element.id) { idx, session in
                        DarkRecentRow(session: session)
                        if idx < store.recentSessions.count - 1 {
                            Rectangle()
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 1)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
            }
        }
    }

    // MARK: - Teddy Level

    private var teddyLevelSection: some View {
        let level      = TeddyLevel.level(for: store.allTimeTotalSeconds)
        let totalHours = store.allTimeTotalSeconds / 3600
        let nextHours  = level.hoursToNext
        let progress: Double = nextHours.map { h -> Double in
            let prev = level.minimumHours
            return max(0, min(1, Double(totalHours - prev) / Double(h - prev)))
        } ?? 1.0

        return VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Teddy Level", icon: "star.fill")

            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle().fill(level.color.opacity(0.18)).frame(width: 56, height: 56)
                        Text(level.badge).font(.system(size: 28))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(level.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(level.description)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.4))
                            .lineLimit(2)
                    }
                    Spacer()
                }

                VStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(level.color.opacity(0.15))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(level.color)
                                .frame(width: geo.size.width * CGFloat(progress), height: 8)
                                .animation(.spring(response: 0.7), value: progress)
                        }
                    }
                    .frame(height: 8)

                    HStack {
                        Text(String(format: "%.1f hrs earned", Double(totalHours)))
                        Spacer()
                        if let next = nextHours {
                            Text(String(format: "%.0f hrs to next level", Double(next)))
                        } else {
                            Text("Maximum level! 🏆")
                        }
                    }
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.35))
                }
            }
            .padding(18)
            .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("🧸").font(.system(size: 44))
            Text("No sessions yet")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Text("Complete a timer session to see your stats here.")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.35))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: - Helpers

    private func sectionLabel(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
    }

    private func formatTime(_ s: Int) -> String {
        let h = s / 3600; let m = (s % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    private var activeDayCount: Int {
        let cal = Calendar.current
        return Set(store.sessions.map { cal.startOfDay(for: $0.dateCompleted) }).count
    }
}

// MARK: - Dark Breakdown Row

private struct DarkBreakdownRow: View {
    let activity:     ActivityType
    let seconds:      Int
    let totalSeconds: Int

    private var ratio: Double { Double(seconds) / Double(max(totalSeconds, 1)) }
    private func fmt(_ s: Int) -> String {
        let m = s / 60
        return m >= 60 ? "\(m/60)h \(m%60)m" : "\(m)m"
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(activity.accentColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Text(activity.emoji).font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(activity.displayName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(seconds > 0 ? fmt(seconds) : "—")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(seconds > 0 ? activity.accentColor : Color.white.opacity(0.2))
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(activity.accentColor.opacity(0.10))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(activity.accentColor)
                            .frame(width: geo.size.width * CGFloat(ratio), height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}

// MARK: - Dark Recent Row

private struct DarkRecentRow: View {
    let session: Session

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(session.activityType.accentColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(session.activityType.emoji).font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(session.activityType.displayName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(session.relativeDateLabel)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.35))
            }

            Spacer()

            Text(session.formattedDuration)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(session.activityType.accentColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(session.activityType.accentColor.opacity(0.12), in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    DashboardView().environmentObject(SessionStore())
}
