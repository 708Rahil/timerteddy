// TimerView.swift
// Timer Teddy 🧸
// Dark warm timer — matches home screen aesthetic.

import SwiftUI

struct TimerView: View {
    let activity: ActivityType

    @EnvironmentObject private var store: SessionStore
    @StateObject private var vm:    TimerViewModel
    @StateObject private var audio: AmbientAudioPlayer
    @Environment(\.dismiss) private var dismiss

    @State private var pickerHours    = 0
    @State private var pickerMinutes  = 25
    @State private var showEndConfirm = false
    @State private var sessionSaved   = false

    init(activity: ActivityType) {
        self.activity = activity
        _vm    = StateObject(wrappedValue: TimerViewModel(activity: activity))
        _audio = StateObject(wrappedValue: AmbientAudioPlayer())
        let mins = activity.defaultDuration / 60
        _pickerHours   = State(initialValue: mins / 60)
        _pickerMinutes = State(initialValue: mins % 60)
    }

    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "1A0D06").ignoresSafeArea()

            // Subtle ambient glow in activity colour
            Circle()
                .fill(RadialGradient(
                    colors: [activity.accentColor.opacity(0.12), .clear],
                    center: .center, startRadius: 0, endRadius: 280
                ))
                .frame(width: 560, height: 560)
                .offset(x: 160, y: -240)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                headerBand
                Spacer()
                mainContent
                Spacer()
                soundPickerPanel
                controlsPanel
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(vm.state == .running || vm.state == .paused)
        .toolbar { toolbarContent }
        .confirmationDialog("End this session?", isPresented: $showEndConfirm, titleVisibility: .visible) {
            Button("Save & End", role: .destructive) {
                audio.stop()
                saveAndEnd(elapsed: vm.endSession())
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Progress so far will be saved to your stats.")
        }
        .onAppear {
            vm.requestNotificationPermission()
            syncPicker()
        }
        .onChange(of: vm.state) { _, newState in
            switch newState {
            case .running:  audio.resume()
            case .paused:   audio.pause()
            case .finished:
                audio.stop()
                saveSession(seconds: vm.selectedDurationSeconds)
            case .idle: break
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: vm.state)
    }

    // MARK: - Header Band

    private var headerBand: some View {
        ZStack {
            // Same gradient as home hero but tinted with activity colour
            LinearGradient(
                colors: [Color(hex: "2C1A0E"), Color(hex: "5C3218")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            // Activity colour glow
            Circle()
                .fill(RadialGradient(
                    colors: [activity.accentColor.opacity(0.28), .clear],
                    center: .center, startRadius: 0, endRadius: 140
                ))
                .frame(width: 280, height: 280)
                .offset(x: 120, y: -60)
                .allowsHitTesting(false)

            HStack(spacing: 14) {
                // Activity badge
                ZStack {
                    Circle()
                        .fill(activity.accentColor.opacity(0.22))
                        .frame(width: 52, height: 52)
                    Text(activity.emoji).font(.system(size: 26))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(activity.displayName)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(vm.state == .idle     ? "Set your duration below"
                       : vm.state == .paused   ? "Session paused"
                       : vm.state == .finished ? "Session complete! 🎉"
                       :                         "Focus session running")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.55))
                }

                Spacer()

                if vm.state == .running && audio.currentSound != .off {
                    Text(audio.currentSound.emoji)
                        .font(.system(size: 20))
                        .padding(8)
                        .background(Color.white.opacity(0.12), in: Circle())
                }
            }
            .padding(.horizontal, 70)
            .padding(.top, 10)
            .padding(.bottom, 18)
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        if vm.state == .idle {
            durationPickerPanel
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                    removal:   .opacity.combined(with: .scale(scale: 0.95))
                ))
        } else {
            countdownDisplay
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.9)),
                    removal:   .opacity
                ))
        }
    }

    // MARK: - Duration Picker

    private var durationPickerPanel: some View {
        VStack(spacing: 20) {
            Text("Set Duration")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.35))
                .textCase(.uppercase)
                .tracking(0.8)

            HStack(spacing: 0) {
                Picker("Hours", selection: $pickerHours) {
                    ForEach(0..<24) { Text("\($0) hr").tag($0) }
                }
                .pickerStyle(.wheel)
                .frame(width: 140)
                .clipped()

                Picker("Minutes", selection: $pickerMinutes) {
                    ForEach([0,5,10,15,20,25,30,45,60], id: \.self) { Text("\($0) min").tag($0) }
                }
                .pickerStyle(.wheel)
                .frame(width: 140)
                .clipped()
            }
            .onChange(of: pickerHours)   { _, _ in updateDuration() }
            .onChange(of: pickerMinutes) { _, _ in updateDuration() }
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.white.opacity(0.09), lineWidth: 1))
            // Force white text on wheel picker
            .colorScheme(.dark)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Countdown Display

    private var countdownDisplay: some View {
        VStack(spacing: 6) {
            ZStack {
                // Track
                Circle()
                    .stroke(activity.accentColor.opacity(0.12), lineWidth: 14)
                    .frame(width: 220, height: 220)

                // Progress arc
                Circle()
                    .trim(from: 0, to: CGFloat(1 - vm.progress))
                    .stroke(
                        AngularGradient(
                            colors: [activity.accentColor.opacity(0.5), activity.accentColor],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle:   .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: vm.progress)

                VStack(spacing: 6) {
                    Text(vm.timeString)
                        .font(.system(size: 54, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())

                    Text(vm.state == .paused ? "Paused" : vm.state == .finished ? "Done!" : "remaining")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.4))
                }
            }

            if vm.state == .running || vm.state == .paused {
                Text("\(Int(round((1 - vm.progress) * 100)))% complete")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(activity.accentColor.opacity(0.8))
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Sound Picker

    private var soundPickerPanel: some View {
        VStack(spacing: 10) {
            HStack {
                Label("Ambient Sound", systemImage: "speaker.wave.2.fill")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.35))
                Spacer()
                if audio.currentSound != .off {
                    HStack(spacing: 6) {
                        Image(systemName: "speaker.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.white.opacity(0.25))
                        Slider(value: Binding(
                            get: { Double(audio.volume) },
                            set: { audio.setVolume(Float($0)) }
                        ), in: 0...1)
                        .tint(activity.accentColor)
                        .frame(width: 90)
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.white.opacity(0.25))
                    }
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .padding(.horizontal, 70)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AmbientSound.allCases) { sound in
                        SoundChip(sound: sound, isActive: audio.currentSound == sound, accentColor: activity.accentColor) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                audio.select(sound)
                                if vm.state == .running { audio.resume() }
                            }
                        }
                    }
                }
                .padding(.horizontal, 70)
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 6)
        .animation(.easeInOut(duration: 0.2), value: audio.currentSound)
    }

    // MARK: - Controls Panel

    private var controlsPanel: some View {
        VStack(spacing: 12) {
            // Subtle dark divider
            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(height: 1)
                .padding(.horizontal, 70)

            VStack(spacing: 10) {
                if vm.state == .idle || vm.state == .paused {
                    primaryButton(
                        title: vm.state == .paused ? "Resume" : "Start Timer",
                        icon:  "play.fill",
                        color: activity.accentColor
                    ) { vm.start() }
                }

                if vm.state == .running {
                    primaryButton(title: "Pause", icon: "pause.fill", color: Color(hex: "4A3728")) {
                        vm.pause()
                    }
                }

                if vm.state == .finished {
                    primaryButton(title: "Done — Great work! 🎉", icon: "checkmark.circle.fill", color: Color(hex: "3A9E72")) {
                        dismiss()
                    }
                }

                if vm.state != .idle && vm.state != .finished {
                    HStack(spacing: 10) {
                        secondaryButton(title: "Reset", icon: "arrow.counterclockwise") {
                            audio.stop(); vm.reset()
                        }
                        secondaryButton(title: "End Session", icon: "stop.fill", tint: Color(hex: "D94F3D")) {
                            showEndConfirm = true
                        }
                    }
                }
            }
            .padding(.horizontal, 70)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Button Helpers

    private func primaryButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [color.opacity(0.9), color.opacity(0.7)],
                        startPoint: .leading, endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 18)
                )
                .shadow(color: color.opacity(0.35), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
    }

    private func secondaryButton(title: String, icon: String, tint: Color = Color.white, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.09), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if vm.state == .running || vm.state == .paused {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("End") { showEndConfirm = true }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white)
            }
        }
    }

    // MARK: - Helpers

    private func updateDuration() {
        let total = pickerHours * 3600 + pickerMinutes * 60
        vm.selectedDurationSeconds = max(total, 60)
        vm.remainingSeconds        = vm.selectedDurationSeconds
    }

    private func syncPicker() {
        let mins = activity.defaultDuration / 60
        pickerHours = mins / 60; pickerMinutes = mins % 60
    }

    private func saveSession(seconds: Int) {
        guard !sessionSaved, seconds > 0 else { return }
        sessionSaved = true
        store.add(Session(activityType: activity, durationInSeconds: seconds))
    }

    private func saveAndEnd(elapsed: Int) {
        saveSession(seconds: elapsed)
        dismiss()
    }
}

// MARK: - Sound Chip

private struct SoundChip: View {
    let sound:       AmbientSound
    let isActive:    Bool
    let accentColor: Color
    let onTap:       () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Text(sound.emoji).font(.system(size: 15))
                Text(sound.label)
                    .font(.system(size: 13, weight: isActive ? .bold : .medium, design: .rounded))
                    .foregroundStyle(isActive ? accentColor : Color.white.opacity(0.45))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isActive ? accentColor.opacity(0.15) : Color.white.opacity(0.06), in: Capsule())
            .overlay(Capsule().strokeBorder(
                isActive ? accentColor.opacity(0.5) : Color.white.opacity(0.09),
                lineWidth: 1.5
            ))
            .scaleEffect(isActive ? 1.04 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.28, dampingFraction: 0.7), value: isActive)
    }
}

#Preview {
    NavigationStack {
        TimerView(activity: .study).environmentObject(SessionStore())
    }
}
