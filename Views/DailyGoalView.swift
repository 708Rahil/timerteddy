// DailyGoalView.swift
// Timer Teddy 🧸

import SwiftUI

struct DailyGoalView: View {
    @EnvironmentObject private var store: SessionStore

    @State private var selectedActivity: ActivityType = .study
    @State private var editingGoal: Int = 120
    @State private var showSavedFeedback = false

    private let presets: [Int] = [30, 60, 90, 120, 180, 240, 360, 480]

    private var currentMinutes: Int { store.todaySeconds(for: selectedActivity) / 60 }
    private var goalReached: Bool   { currentMinutes >= editingGoal }
    private var progress: Double {
        guard editingGoal > 0 else { return 0 }
        return min(Double(currentMinutes) / Double(editingGoal), 1.0)
    }

    var body: some View {
        GeometryReader { geo in
            let hp = max(geo.safeAreaInsets.leading, 16)  // respect safe area

            ZStack {
                Color(hex: "1A0D06").ignoresSafeArea()

                Circle()
                    .fill(RadialGradient(
                        colors: [selectedActivity.accentColor.opacity(0.07), .clear],
                        center: .center, startRadius: 0, endRadius: 260
                    ))
                    .frame(width: 520, height: 520)
                    .offset(x: 180, y: -100)
                    .allowsHitTesting(false)
                    .animation(.easeInOut(duration: 0.5), value: selectedActivity)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        pageHeader(hp: hp)
                        activitySelector(hp: hp)
                        progressRingCard(hp: hp)
                        if goalReached {
                            goalReachedBanner(hp: hp).transition(.scale.combined(with: .opacity))
                        }
                        presetGrid(hp: hp)
                        stepperControl(hp: hp)
                        saveBtn(hp: hp)
                        allGoalsList(hp: hp)
                    }
                    .padding(.bottom, 40)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear { syncGoal() }
        .onChange(of: selectedActivity) { _, _ in
            withAnimation(.spring(response: 0.4)) { syncGoal(); showSavedFeedback = false }
        }
        .animation(.spring(response: 0.4), value: goalReached)
    }

    // MARK: - Page Header

    private func pageHeader(hp: CGFloat) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Daily Goals")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Set targets for each activity")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.45))
            }
            Spacer()
            VStack(spacing: 1) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                Text("of goal")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.5))
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 11))
            .overlay(RoundedRectangle(cornerRadius: 11).strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
        }
        .padding(.horizontal, hp)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background {
            LinearGradient(
                colors: [Color(hex: "2C1A0E"), Color(hex: "5C3218")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)
            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "C96B2F").opacity(0.22), .clear],
                    center: .center, startRadius: 0, endRadius: 140
                ))
                .frame(width: 240, height: 240)
                .offset(x: 140, y: -30)
        }
    }

    // MARK: - Activity Selector

    private func activitySelector(hp: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ActivityType.allCases, id: \.self) { activity in
                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                            selectedActivity = activity
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Text(activity.emoji).font(.system(size: 14))
                            Text(activity.displayName)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(selectedActivity == activity ? .white : Color.white.opacity(0.6))
                        }
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(
                            selectedActivity == activity ? activity.accentColor : Color.white.opacity(0.07),
                            in: Capsule()
                        )
                        .overlay(
                            Capsule().strokeBorder(
                                selectedActivity == activity ? Color.clear : Color.white.opacity(0.1),
                                lineWidth: 1.5
                            )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, hp)
            .padding(.vertical, 2)
        }
    }

    // MARK: - Progress Ring Card

    private func progressRingCard(hp: CGFloat) -> some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(selectedActivity.accentColor.opacity(0.12), lineWidth: 10)
                    .frame(width: 86, height: 86)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(selectedActivity.accentColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 86, height: 86)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.7, dampingFraction: 0.8), value: progress)
                VStack(spacing: 1) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    Text("done")
                        .font(.system(size: 9, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.35))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    Text((selectedActivity.displayName + " Goal").uppercased())
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.35))
                        .tracking(0.5)
                    Text(formatMins(editingGoal))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }
                HStack(spacing: 14) {
                    miniStat(label: "Done", value: "\(currentMinutes)m", color: selectedActivity.accentColor)
                    miniStat(label: "Left", value: "\(max(editingGoal - currentMinutes, 0))m", color: Color.white.opacity(0.4))
                }
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(selectedActivity.accentColor.opacity(0.18), lineWidth: 1))
        .padding(.horizontal, hp)
    }

    // MARK: - Goal Reached Banner

    private func goalReachedBanner(hp: CGFloat) -> some View {
        HStack(spacing: 12) {
            Text("🏅").font(.title3)
            VStack(alignment: .leading, spacing: 1) {
                Text("Teddy is proud of you! 🎉")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "4ECBA0"))
                Text("\(selectedActivity.displayName) goal achieved today.")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Color(hex: "4ECBA0").opacity(0.75))
            }
            Spacer()
        }
        .padding(14)
        .background(Color(hex: "4ECBA0").opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color(hex: "4ECBA0").opacity(0.3), lineWidth: 1))
        .padding(.horizontal, hp)
    }

    // MARK: - Preset Grid

    private func presetGrid(hp: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Quick Presets", icon: "bolt.fill")
                .padding(.horizontal, hp)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(presets, id: \.self) { p in
                    Button {
                        withAnimation(.spring(response: 0.3)) { editingGoal = p }
                    } label: {
                        Text(presetLabel(p))
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(editingGoal == p ? .white : Color.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(
                                editingGoal == p ? Color(hex: "C96B2F") : Color.white.opacity(0.06),
                                in: RoundedRectangle(cornerRadius: 11)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 11)
                                    .strokeBorder(editingGoal == p ? Color.clear : Color.white.opacity(0.09), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.25), value: editingGoal)
                }
            }
            .padding(.horizontal, hp)
        }
    }

    // MARK: - Stepper Control

    private func stepperControl(hp: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Custom", icon: "slider.horizontal.3")
                .padding(.horizontal, hp)

            HStack(spacing: 0) {
                Button {
                    if editingGoal > 15 { withAnimation { editingGoal -= 15 } }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(editingGoal <= 15 ? Color.white.opacity(0.2) : Color.white)
                        .frame(width: 52, height: 48)
                }
                .disabled(editingGoal <= 15)

                Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 24)

                Text(formatMins(editingGoal))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .contentTransition(.numericText())

                Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 24)

                Button {
                    if editingGoal < 720 { withAnimation { editingGoal += 15 } }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(editingGoal >= 720 ? Color.white.opacity(0.2) : Color.white)
                        .frame(width: 52, height: 48)
                }
                .disabled(editingGoal >= 720)
            }
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.09), lineWidth: 1))
            .padding(.horizontal, hp)
        }
    }

    // MARK: - Save Button

    private func saveBtn(hp: CGFloat) -> some View {
        Button {
            store.setGoal(editingGoal, for: selectedActivity)
            withAnimation { showSavedFeedback = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation { showSavedFeedback = false }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: showSavedFeedback ? "checkmark.circle.fill" : "target")
                    .font(.system(size: 16, weight: .bold))
                Text(showSavedFeedback ? "Goal Saved!" : "Save \(selectedActivity.displayName) Goal")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                showSavedFeedback ? Color(hex: "4ECBA0") : Color(hex: "C96B2F"),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .shadow(color: Color(hex: "C96B2F").opacity(0.3), radius: 8, y: 3)
            .animation(.spring(response: 0.3), value: showSavedFeedback)
        }
        .padding(.horizontal, hp)
    }

    // MARK: - All Goals List

    private func allGoalsList(hp: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("All Goals", icon: "list.bullet.clipboard.fill")
                .padding(.horizontal, hp)

            VStack(spacing: 0) {
                ForEach(Array(ActivityType.allCases.enumerated()), id: \.element) { idx, activity in
                    GoalRow(
                        activity: activity,
                        goalMinutes: store.goal(for: activity),
                        completedMinutes: store.todaySeconds(for: activity) / 60,
                        isActive: activity == selectedActivity
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                            selectedActivity = activity
                            syncGoal()
                        }
                    }
                    if idx < ActivityType.allCases.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
            .padding(.horizontal, hp)
        }
    }

    // MARK: - Helpers

    private func syncGoal() { editingGoal = store.goal(for: selectedActivity) }

    private func sectionLabel(_ t: String, icon: String) -> some View {
        Label(t, systemImage: icon)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
    }

    private func miniStat(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.3))
        }
    }

    private func formatMins(_ m: Int) -> String {
        m >= 60 ? (m % 60 > 0 ? "\(m/60)h \(m%60)m" : "\(m/60) hr") : "\(m) min"
    }

    private func presetLabel(_ m: Int) -> String {
        m >= 60 ? "\(m/60)h" : "\(m)m"
    }
}

// MARK: - Goal Row

private struct GoalRow: View {
    let activity:         ActivityType
    let goalMinutes:      Int
    let completedMinutes: Int
    let isActive:         Bool
    let onTap:            () -> Void

    private var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return min(Double(completedMinutes) / Double(goalMinutes), 1.0)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(activity.accentColor.opacity(isActive ? 0.22 : 0.12))
                        .frame(width: 36, height: 36)
                    Text(activity.emoji).font(.system(size: 18))
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(activity.displayName)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(completedMinutes) / \(goalMinutes)m")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.35))
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(activity.accentColor.opacity(0.12))
                                .frame(height: 3)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(progress >= 1.0 ? Color(hex: "4ECBA0") : activity.accentColor)
                                .frame(width: geo.size.width * CGFloat(progress), height: 3)
                                .animation(.spring(response: 0.5), value: progress)
                        }
                    }
                    .frame(height: 3)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(isActive ? activity.accentColor.opacity(0.07) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DailyGoalView().environmentObject(SessionStore())
}
