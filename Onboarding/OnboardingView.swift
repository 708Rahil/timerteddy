// OnboardingView.swift
// Timer Teddy 🧸
// Full onboarding flow: Welcome → Profile → Goals → Paywall
// Aesthetic: Glow-inspired — deep dark backgrounds, warm glows,
// large bold serif type, smooth slide transitions.

import SwiftUI

// MARK: - Root container

struct OnboardingView: View {
    @EnvironmentObject private var coordinator: OnboardingCoordinator
    @State private var step: Int = 0

    private let transition: AnyTransition = .asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal:   .move(edge: .leading).combined(with: .opacity)
    )

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1A0D06"), Color(hex: "2E160A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ambientGlows

            Group {
                switch step {
                case 0: WelcomeScreen(onNext: advance)
                case 1: ProfileScreen(onNext: advance, profile: $coordinator.profile)
                case 2: GoalsScreen(onNext: advance, profile: $coordinator.profile)
                case 3: PaywallScreen(
                            onFreeTrial: { coordinator.completeOnboarding(isPremium: false) },
                            onPremium:   { coordinator.completeOnboarding(isPremium: true)  }
                        )
                default: EmptyView()
                }
            }
            .transition(transition)
            .animation(.spring(response: 0.48, dampingFraction: 0.85), value: step)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if step < 3 {
                progressDots
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
        }
    }

    private func advance() {
        coordinator.saveProfile()
        withAnimation { step += 1 }
    }

    private var progressDots: some View {
        HStack(spacing: 7) {
            ForEach(0..<3) { i in
                Capsule()
                    .fill(i == step
                          ? Color(hex: "C96B2F")
                          : Color.white.opacity(0.2))
                    .frame(width: i == step ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.35), value: step)
            }
        }
    }

    private var ambientGlows: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "C96B2F").opacity(0.22), .clear],
                    center: .center, startRadius: 0, endRadius: 260
                ))
                .frame(width: 520, height: 520)
                .offset(x: 160, y: -280)
                .blur(radius: 2)

            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "4A2AE0").opacity(0.12), .clear],
                    center: .center, startRadius: 0, endRadius: 200
                ))
                .frame(width: 400, height: 400)
                .offset(x: -160, y: 340)
                .blur(radius: 2)
        }
        .allowsHitTesting(false)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Screen 1: Welcome
// ─────────────────────────────────────────────────────────────

struct WelcomeScreen: View {
    let onNext: () -> Void

    @State private var bobOffset:   CGFloat = 0
    @State private var glowPulse:   Double  = 0.7
    @State private var textVisible: Bool    = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [Color(hex: "C96B2F").opacity(glowPulse * 0.35), .clear],
                        center: .center, startRadius: 0, endRadius: 100
                    ))
                    .frame(width: 200, height: 200)
                    .blur(radius: 8)

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 145, height: 145)
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.1), lineWidth: 1))

                    AnimatedTeddyView()
                        .frame(width: 105, height: 105)
                }
                .offset(y: bobOffset)
            }
            .padding(.bottom, 24)

            VStack(spacing: 10) {
                Text("Meet Teddy.")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .opacity(textVisible ? 1 : 0)
                    .offset(y: textVisible ? 0 : 18)

                Text("Your personal focus companion.\nStudy smarter, work deeper,\nlive more intentionally.")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .opacity(textVisible ? 1 : 0)
                    .offset(y: textVisible ? 0 : 14)
            }
            .padding(.horizontal, 32)

            Spacer(minLength: 16)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    FeaturePill(icon: "timer",          label: "Focus Timer")
                    FeaturePill(icon: "flame.fill",     label: "Streaks")
                    FeaturePill(icon: "chart.bar.fill", label: "Stats")
                }
                .opacity(textVisible ? 1 : 0)
                .padding(.bottom, 16)

                OnboardingButton(title: "Let's Get Started", icon: "arrow.right") { onNext() }
                    .padding(.horizontal, 28)
                    .opacity(textVisible ? 1 : 0)
            }
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
        .onAppear { startAnimations() }
    }

    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { bobOffset = -10 }
        withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) { glowPulse = 1.0 }
        withAnimation(.easeOut(duration: 0.7).delay(0.3)) { textVisible = true }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Screen 2: Profile
// ─────────────────────────────────────────────────────────────

struct ProfileScreen: View {
    let onNext: () -> Void
    @Binding var profile: UserProfile

    @FocusState private var focusedField: Field?
    @State private var appeared = false

    private enum Field { case name, age }
    private let genders = ["Male", "Female", "Non-binary", "Prefer not to say"]

    var canContinue: Bool {
        !profile.name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                VStack(alignment: .leading, spacing: 8) {
                    Text("Tell us about\nyourself.")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .lineSpacing(2)

                    Text("Teddy wants to personalise your experience.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.5))
                }
                .padding(.top, 52)
                .padding(.horizontal, 70)
                .padding(.bottom, 28)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                VStack(spacing: 0) {
                    ProfileField(icon: "person.fill", placeholder: "Your first name", text: $profile.name)
                        .focused($focusedField, equals: .name)

                    Divider().background(Color.white.opacity(0.08))

                    ProfileField(icon: "calendar", placeholder: "Your age  (optional)", text: $profile.age)
                        .focused($focusedField, equals: .age)
                        .keyboardType(.numberPad)
                }
                .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                .padding(.horizontal, 70)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 24)

                VStack(alignment: .leading, spacing: 14) {
                    Text("Gender  (optional)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.4))
                        .padding(.horizontal, 70)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(genders, id: \.self) { g in
                                SelectionChip(label: g, isSelected: profile.gender == g) {
                                    profile.gender = (profile.gender == g) ? "" : g
                                }
                            }
                        }
                        .padding(.horizontal, 70)
                    }
                }
                .padding(.top, 20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 28)

                OnboardingButton(title: "Continue", icon: "arrow.right", enabled: canContinue, action: onNext)
                    .padding(.horizontal, 60)
                    .padding(.top, 28)
                    .padding(.bottom, 20)
                    .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.55).delay(0.1)) { appeared = true }
        }
        .onTapGesture { focusedField = nil }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Screen 3: Goals
// ─────────────────────────────────────────────────────────────

struct GoalsScreen: View {
    let onNext: () -> Void
    @Binding var profile: UserProfile

    @State private var appeared = false

    private let goalOptions: [(emoji: String, title: String, subtitle: String)] = [
        ("📚", "Study & Learn",     "Ace exams and build new skills"),
        ("💻", "Deep Work",         "Ship more, get distracted less"),
        ("🏃", "Stay Active",       "Build a consistent exercise habit"),
        ("😴", "Sleep Better",      "Track and improve sleep quality"),
        ("🧘", "Reduce Stress",     "Find calm with mindful breaks"),
        ("🎮", "Balance Free Time", "Enjoy leisure without the guilt"),
        ("🎯", "Build Habits",      "Small daily wins that compound"),
        ("⚡", "Boost Productivity","Do more of what actually matters"),
    ]

    var canContinue: Bool { !profile.goals.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            VStack(alignment: .leading, spacing: 8) {
                Text("What do you\nwant to improve?")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .lineSpacing(2)

                Text("Pick everything that applies — no pressure.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.5))
            }
            .padding(.top, 52)
            .padding(.horizontal, 70)
            .padding(.bottom, 20)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)

            ScrollView(showsIndicators: false) {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(goalOptions, id: \.title) { option in
                        let selected = profile.goals.contains(option.title)
                        GoalCard(
                            emoji: option.emoji, title: option.title,
                            subtitle: option.subtitle, isSelected: selected
                        ) {
                            withAnimation(.spring(response: 0.28)) {
                                if selected { profile.goals.removeAll { $0 == option.title } }
                                else { profile.goals.append(option.title) }
                            }
                        }
                    }
                }
                .padding(.horizontal, 70)
                .padding(.bottom, 16)
            }
            .opacity(appeared ? 1 : 0)

            OnboardingButton(
                title: canContinue ? "Continue  (\(profile.goals.count) selected)" : "Select at least one",
                icon: "arrow.right",
                enabled: canContinue,
                action: onNext
            )
            .padding(.horizontal, 70)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.55).delay(0.1)) { appeared = true }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Screen 4: Paywall
// ─────────────────────────────────────────────────────────────

struct PaywallScreen: View {
    let onFreeTrial: () -> Void
    let onPremium:   () -> Void

    @State private var appeared      = false
    @State private var glowPulse     = 0.6
    @State private var selectedPlan: Plan = .annual

    enum Plan { case annual, monthly }

    private let premiumPerks: [(icon: String, text: String)] = [
        ("waveform",             "Unlimited ambient sounds"),
        ("flame.fill",           "Advanced streak insights"),
        ("square.grid.3x3.fill", "Full activity calendar history"),
        ("paintbrush.fill",      "Exclusive Teddy themes"),
        ("bell.badge.fill",      "Smart focus reminders"),
        ("chart.xyaxis.line",    "Detailed weekly reports"),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Crown + glow
                ZStack {
                    Circle()
                        .fill(RadialGradient(
                            colors: [Color(hex: "C96B2F").opacity(glowPulse * 0.45), .clear],
                            center: .center, startRadius: 0, endRadius: 80
                        ))
                        .frame(width: 160, height: 160)
                        .blur(radius: 6)

                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color(hex: "C96B2F"), Color(hex: "8C3A0A")],
                                startPoint: .top, endPoint: .bottom
                            ))
                            .frame(width: 72, height: 72)
                            .shadow(color: Color(hex: "C96B2F").opacity(0.6), radius: 16, y: 4)
                        Text("👑").font(.system(size: 32))
                    }
                }
                .padding(.top, 32)
                .padding(.bottom, 16)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.8)

                // Headline
                VStack(spacing: 6) {
                    Text("Go Premium.")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(.white)

                    Text("Unlock everything Teddy has to offer\nand never look back.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 70)
                .padding(.bottom, 18)
                .opacity(appeared ? 1 : 0)

                // Perks list
                VStack(spacing: 0) {
                    ForEach(Array(premiumPerks.enumerated()), id: \.offset) { idx, perk in
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "C96B2F").opacity(0.15))
                                    .frame(width: 30, height: 30)
                                Image(systemName: perk.icon)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color(hex: "C96B2F"))
                            }
                            Text(perk.text)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.85))
                            Spacer()
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color(hex: "3A9E72"))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                        if idx < premiumPerks.count - 1 {
                            Divider()
                                .background(Color.white.opacity(0.06))
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                .padding(.horizontal, 70)
                .padding(.bottom, 18)
                .opacity(appeared ? 1 : 0)

                // Plan toggle
                HStack(spacing: 12) {
                    PlanToggle(title: "Annual",  price: "$29.99 / yr", badge: "Save 58%", isSelected: selectedPlan == .annual)  { selectedPlan = .annual }
                    PlanToggle(title: "Monthly", price: "$5.99 / mo",  badge: nil,        isSelected: selectedPlan == .monthly) { selectedPlan = .monthly }
                }
                .padding(.horizontal, 70)
                .padding(.bottom, 14)
                .opacity(appeared ? 1 : 0)

                // ── Primary CTA: Premium ──
                Button(action: onPremium) {
                    HStack(spacing: 8) {
                        Text("👑").font(.system(size: 18))
                        Text(selectedPlan == .annual ? "Start Premium — $29.99/yr" : "Start Premium — $5.99/mo")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "D4793A"), Color(hex: "9C3E0E")],
                            startPoint: .leading, endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .shadow(color: Color(hex: "C96B2F").opacity(0.4), radius: 14, y: 5)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 70)
                .opacity(appeared ? 1 : 0)

                // ── Secondary CTA: Free trial ──
                Button(action: onFreeTrial) {
                    HStack(spacing: 8) {
                        Image(systemName: "star")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(hex: "C96B2F"))
                        Text("Free 14 day trial — No credit card needed")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.75))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 70)
                .padding(.top, 10)
                .opacity(appeared ? 1 : 0)

                // ── Tertiary CTA: Continue free ──
                Button(action: onFreeTrial) {
                    Text("Continue with free version")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.35))
                        .underline()
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .padding(.top, 6)
                .opacity(appeared ? 1 : 0)

                // Legal
                Text("Cancel anytime. Managed via App Store.")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.2))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 70)
                    .padding(.top, 10)
                    .padding(.bottom, 48)
                    .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) { appeared = true }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { glowPulse = 1.0 }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Reusable subcomponents
// ─────────────────────────────────────────────────────────────

struct OnboardingButton: View {
    let title:   String
    let icon:    String
    var enabled: Bool = true
    let action:  () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(enabled ? .white : Color.white.opacity(0.3))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                enabled
                    ? AnyShapeStyle(LinearGradient(
                        colors: [Color(hex: "D4793A"), Color(hex: "9C3E0E")],
                        startPoint: .leading, endPoint: .trailing))
                    : AnyShapeStyle(Color.white.opacity(0.07)),
                in: RoundedRectangle(cornerRadius: 18)
            )
            .shadow(color: enabled ? Color(hex: "C96B2F").opacity(0.35) : .clear, radius: 14, y: 5)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

struct ProfileField: View {
    let icon:        String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(hex: "C96B2F"))
                .frame(width: 22)

            TextField("", text: $text, prompt:
                Text(placeholder).foregroundColor(Color.white.opacity(0.25))
            )
            .font(.system(size: 16, design: .rounded))
            .foregroundStyle(.white)
            .autocorrectionDisabled()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }
}

struct SelectionChip: View {
    let label:      String
    let isSelected: Bool
    let onTap:      () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(.system(size: 14, weight: isSelected ? .bold : .medium, design: .rounded))
                .foregroundStyle(isSelected ? Color(hex: "C96B2F") : Color.white.opacity(0.6))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(isSelected ? Color(hex: "C96B2F").opacity(0.15) : Color.white.opacity(0.06), in: Capsule())
                .overlay(Capsule().strokeBorder(
                    isSelected ? Color(hex: "C96B2F").opacity(0.6) : Color.white.opacity(0.1),
                    lineWidth: 1.5
                ))
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.28), value: isSelected)
    }
}

struct GoalCard: View {
    let emoji:      String
    let title:      String
    let subtitle:   String
    let isSelected: Bool
    let onTap:      () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(emoji).font(.system(size: 26))
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(hex: "C96B2F"))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.45))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color(hex: "C96B2F").opacity(0.12) : Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(
                isSelected ? Color(hex: "C96B2F").opacity(0.5) : Color.white.opacity(0.09),
                lineWidth: 1.5
            ))
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(color: isSelected ? Color(hex: "C96B2F").opacity(0.18) : .clear, radius: 10, y: 3)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isSelected)
    }
}

struct FeaturePill: View {
    let icon:  String
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(hex: "C96B2F"))
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.65))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.07), in: Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
    }
}

struct PlanToggle: View {
    let title:      String
    let price:      String
    let badge:      String?
    let isSelected: Bool
    let onTap:      () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                if let badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "3A9E72"), in: Capsule())
                }
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(price)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color(hex: "C96B2F").opacity(0.14) : Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(
                isSelected ? Color(hex: "C96B2F").opacity(0.7) : Color.white.opacity(0.1),
                lineWidth: isSelected ? 2 : 1
            ))
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.28), value: isSelected)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Preview
// ─────────────────────────────────────────────────────────────

#Preview {
    OnboardingView()
        .environmentObject(OnboardingCoordinator())
        .environmentObject(SessionStore())
}
