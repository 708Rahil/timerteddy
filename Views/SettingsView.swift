// SettingsView.swift
// Timer Teddy 🧸
// Settings: edit profile, upgrade to premium, send feedback, app info.

import SwiftUI
import MessageUI

struct SettingsView: View {
    @EnvironmentObject private var coordinator: OnboardingCoordinator
    @EnvironmentObject private var store:       SessionStore

    @State private var editName      = ""
    @State private var editAge       = ""
    @State private var editGender    = ""
    @State private var showEditSheet = false
    @State private var showPaywall   = false
    @State private var showFeedback  = false
    @State private var showMailError = false
    @State private var showMailSheet = false
    @FocusState private var focusedField: ProfileField?
    enum ProfileField { case name, age }

    private let genders = ["Male", "Female", "Non-binary", "Prefer not to say"]
    private let feedbackEmail = "support@timerteddy.app"

    var body: some View {
        ZStack {
            Color(hex: "1A0D06").ignoresSafeArea()

            // Ambient glow
            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "C96B2F").opacity(0.10), .clear],
                    center: .center, startRadius: 0, endRadius: 220
                ))
                .frame(width: 440, height: 440)
                .offset(x: 160, y: -200)
                .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    settingsHeader
                    profileCard
                    premiumCard
                    sectionRows
                    appInfoFooter
                }
                .padding(.bottom, 60)
            }
        }
        // Edit profile sheet
        .sheet(isPresented: $showEditSheet) {
            editProfileSheet
        }
        // Paywall sheet
        .sheet(isPresented: $showPaywall) {
            ZStack {
                Color(hex: "1A0D06").ignoresSafeArea()
                PaywallScreen(
                    onFreeTrial: { showPaywall = false },
                    onPremium:   {
                        coordinator.profile.isPremium = true
                        coordinator.saveProfile()
                        showPaywall = false
                    }
                )
                .environmentObject(coordinator)
            }
        }
        // Feedback mail
        .sheet(isPresented: $showMailSheet) {
            MailComposerView(
                toAddress: feedbackEmail,
                subject:   "Timer Teddy Feedback",
                body:      "Hi Teddy team,\n\n"
            ) { _ in }
        }
        .alert("Mail Not Available", isPresented: $showMailError) {
            Button("Copy Email") { UIPasteboard.general.string = feedbackEmail }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Mail isn't set up on this device. Email us at \(feedbackEmail)")
        }
    }

    // MARK: - Header

    private var settingsHeader: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "2C1A0E"), Color(hex: "5C3218")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)
            .frame(height: 160)

            HStack(spacing: 16) {
                // Avatar circle
                ZStack {
                    Circle()
                        .fill(Color(hex: "C96B2F").opacity(0.25))
                        .frame(width: 62, height: 62)
                    Text(avatarEmoji)
                        .font(.system(size: 30))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(coordinator.profile.name.isEmpty ? "Your Profile" : coordinator.profile.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(coordinator.profile.isPremium ? "✨ Premium member" : "Free plan")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(coordinator.profile.isPremium
                                         ? Color(hex: "C96B2F")
                                         : Color.white.opacity(0.4))
                }

                Spacer()

                Button { prepareEdit(); showEditSheet = true } label: {
                    Text("Edit")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "C96B2F"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color(hex: "C96B2F").opacity(0.15), in: Capsule())
                        .overlay(Capsule().strokeBorder(Color(hex: "C96B2F").opacity(0.35), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Profile card

    private var profileCard: some View {
        VStack(spacing: 0) {
            settingRow(icon: "person.fill",   label: "Name",   value: coordinator.profile.name.isEmpty   ? "—" : coordinator.profile.name)
            divider
            settingRow(icon: "calendar",      label: "Age",    value: coordinator.profile.age.isEmpty    ? "—" : coordinator.profile.age)
            divider
            settingRow(icon: "person.2.fill", label: "Gender", value: coordinator.profile.gender.isEmpty ? "—" : coordinator.profile.gender)
        }
        .darkCard()
        .padding(.horizontal, 22)
        .padding(.top, 24)
    }

    // MARK: - Premium card

    private var premiumCard: some View {
        Group {
            if coordinator.profile.isPremium {
                // Already premium
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "C96B2F").opacity(0.18))
                            .frame(width: 44, height: 44)
                        Text("👑").font(.system(size: 22))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Premium Active")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("All features unlocked ✨")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(Color(hex: "C96B2F"))
                    }
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color(hex: "C96B2F"))
                        .font(.system(size: 20))
                }
                .padding(16)
                .darkCard()
                .padding(.horizontal, 22)
                .padding(.top, 14)
            } else {
                // Upsell banner
                Button { showPaywall = true } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "C96B2F").opacity(0.2))
                                .frame(width: 44, height: 44)
                            Text("👑").font(.system(size: 22))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upgrade to Premium")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Unlock all features & sounds")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.45))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(hex: "C96B2F"))
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "C96B2F").opacity(0.18), Color(hex: "8C3A0A").opacity(0.12)],
                            startPoint: .leading, endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color(hex: "C96B2F").opacity(0.35), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 22)
                .padding(.top, 14)
            }
        }
    }

    // MARK: - Section rows

    private var sectionRows: some View {
        VStack(spacing: 0) {
            tappableRow(icon: "envelope.fill",  color: Color(hex: "3B6FD4"), label: "Send Feedback") {
                if MFMailComposeViewController.canSendMail() { showMailSheet = true }
                else { showMailError = true }
            }
            divider
            tappableRow(icon: "star.fill",      color: Color(hex: "F5A623"), label: "Rate the App") {
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id000000000") {
                    UIApplication.shared.open(url)
                }
            }
            divider
            tappableRow(icon: "arrow.2.circlepath", color: Color(hex: "2A9D6E"), label: "Reset Onboarding") {
                coordinator.resetOnboarding()
            }
        }
        .darkCard()
        .padding(.horizontal, 22)
        .padding(.top, 14)
    }

    // MARK: - App info footer

    private var appInfoFooter: some View {
        VStack(spacing: 6) {
            Text("🧸 Timer Teddy")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.3))
            Text("Version 1.0 · Made with ♥")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.18))
        }
        .padding(.top, 32)
    }

    // MARK: - Edit Profile Sheet

    private var editProfileSheet: some View {
        ZStack {
            Color(hex: "1A0D06").ignoresSafeArea()

            VStack(spacing: 0) {
                // Sheet handle
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 24)

                Text("Edit Profile")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.bottom, 28)

                // Fields
                VStack(spacing: 0) {
                    sheetField(icon: "person.fill", placeholder: "Name", text: $editName)
                        .focused($focusedField, equals: .name)
                    Divider().background(Color.white.opacity(0.08))
                    sheetField(icon: "calendar", placeholder: "Age (optional)", text: $editAge)
                        .focused($focusedField, equals: .age)
                        .keyboardType(.numberPad)
                }
                .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                .padding(.horizontal, 28)
                .padding(.bottom, 20)

                // Gender chips
                VStack(alignment: .leading, spacing: 12) {
                    Text("Gender (optional)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.35))
                        .padding(.horizontal, 28)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(genders, id: \.self) { g in
                                Button {
                                    editGender = (editGender == g) ? "" : g
                                } label: {
                                    Text(g)
                                        .font(.system(size: 13, weight: editGender == g ? .bold : .medium, design: .rounded))
                                        .foregroundStyle(editGender == g ? Color(hex: "C96B2F") : Color.white.opacity(0.55))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 9)
                                        .background(editGender == g ? Color(hex: "C96B2F").opacity(0.15) : Color.white.opacity(0.06), in: Capsule())
                                        .overlay(Capsule().strokeBorder(editGender == g ? Color(hex: "C96B2F").opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1.5))
                                }
                                .buttonStyle(.plain)
                                .animation(.spring(response: 0.25), value: editGender)
                            }
                        }
                        .padding(.horizontal, 28)
                    }
                }
                .padding(.bottom, 32)

                // Save
                Button {
                    coordinator.profile.name   = editName
                    coordinator.profile.age    = editAge
                    coordinator.profile.gender = editGender
                    coordinator.saveProfile()
                    showEditSheet = false
                } label: {
                    Text("Save Changes")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            LinearGradient(colors: [Color(hex: "D4793A"), Color(hex: "9C3E0E")], startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                        .shadow(color: Color(hex: "C96B2F").opacity(0.35), radius: 12, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)

                Button { showEditSheet = false } label: {
                    Text("Cancel")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.3))
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
        }
        .onTapGesture { focusedField = nil }
    }

    // MARK: - Sub-helpers

    private func prepareEdit() {
        editName   = coordinator.profile.name
        editAge    = coordinator.profile.age
        editGender = coordinator.profile.gender
    }

    private var avatarEmoji: String {
        switch coordinator.profile.gender {
        case "Male":        return "🧔"
        case "Female":      return "👩"
        case "Non-binary":  return "🧑"
        default:            return "🧸"
        }
    }

    private var divider: some View {
        Divider()
            .background(Color.white.opacity(0.07))
            .padding(.horizontal, 16)
    }

    private func settingRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(hex: "C96B2F"))
                .frame(width: 18)
            Text(label)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    private func tappableRow(icon: String, color: Color, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.18))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(color)
                }
                Text(label)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.2))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(.plain)
    }

    private func sheetField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(hex: "C96B2F"))
                .frame(width: 20)
            TextField("", text: text, prompt:
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

// MARK: - Dark card modifier

extension View {
    func darkCard() -> some View {
        self
            .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.09), lineWidth: 1))
    }
}

#Preview {
    SettingsView()
        .environmentObject(OnboardingCoordinator())
        .environmentObject(SessionStore())
}

// MARK: - Mail Composer Wrapper

import MessageUI

struct MailComposerView: UIViewControllerRepresentable {
    let toAddress:  String
    let subject:    String
    let body:       String
    let onDismiss:  (MFMailComposeResult) -> Void

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients([toAddress])
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onDismiss: onDismiss) }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDismiss: (MFMailComposeResult) -> Void
        init(onDismiss: @escaping (MFMailComposeResult) -> Void) { self.onDismiss = onDismiss }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            controller.dismiss(animated: true) { self.onDismiss(result) }
        }
    }
}
