//
//  FeedbackView.swift
//  Timer Teddy
//
//  Created by Rahil Gandhi on 2026-03-12.
//
// FeedbackView.swift
// Timer Teddy 🧸
// In-app feedback form that opens Mail with a pre-filled message.

import SwiftUI
import MessageUI

// MARK: - Feedback View

struct FeedbackView: View {

    // ⚠️ Replace with your actual support email address
    private let feedbackEmail = "support@timerteddy.app"

    @State private var selectedType: FeedbackType  = .suggestion
    @State private var feedbackText: String         = ""
    @State private var name: String                 = ""
    @State private var rating: Int                  = 5
    @State private var showMailUnavailable          = false
    @State private var showMailComposer             = false
    @State private var showSuccess                  = false

    @FocusState private var focusedField: Field?
    enum Field { case name, feedback }

    var body: some View {
        ZStack {
            Color.teddyBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    pageHeader
                    ratingCard
                    feedbackTypeSelector
                    formCard
                    sendButton
                    footerNote
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 48)
            }
        }
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.large)
        .onTapGesture { focusedField = nil }
        .alert("Mail Not Available", isPresented: $showMailUnavailable) {
            Button("Copy Email") {
                UIPasteboard.general.string = feedbackEmail
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Mail isn't set up on this device. You can reach us at \(feedbackEmail)")
        }
        .sheet(isPresented: $showMailComposer) {
            MailComposerView(
                toAddress:  feedbackEmail,
                subject:    "[\(selectedType.displayName)] Timer Teddy Feedback",
                body:       composedEmailBody()
            ) { _ in
                showSuccess = true
            }
        }
        .overlay(alignment: .top) {
            if showSuccess {
                successToast
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation { showSuccess = false }
                        }
                    }
            }
        }
        .animation(.spring(response: 0.4), value: showSuccess)
    }

    // MARK: - Page Header

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("We'd Love to Hear From You")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.teddyText)
            Text("Your feedback helps us make Timer Teddy better for everyone.")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Color.teddySubtext)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    // MARK: - Rating Card

    private var ratingCard: some View {
        VStack(spacing: 16) {
            Text("How would you rate Timer Teddy?")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.teddyText)

            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            rating = star
                        }
                    } label: {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.system(size: 32))
                            .foregroundStyle(star <= rating ? Color(hex: "F5A623") : Color.teddyBorder)
                            .scaleEffect(star == rating ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3), value: rating)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(ratingLabel)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.teddySubtext)
                .animation(.easeInOut, value: rating)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.teddyCard, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.teddyBorder, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 2)
    }

    // MARK: - Feedback Type Selector

    private var feedbackTypeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Type of Feedback", icon: "tag.fill")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(FeedbackType.allCases, id: \.self) { type in
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedType = type }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(selectedType == type ? .white : type.color)
                                .frame(width: 20)
                            Text(type.displayName)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(selectedType == type ? .white : Color.teddyText)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 13)
                        .background(
                            selectedType == type ? type.color : Color.teddyCard,
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(selectedType == type ? Color.clear : Color.teddyBorder, lineWidth: 1)
                        )
                        .shadow(color: selectedType == type ? type.color.opacity(0.2) : .clear, radius: 6, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Name field
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Name (optional)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.teddySubtext)
                    .textCase(.uppercase)
                    .tracking(0.4)

                TextField("e.g. Alex", text: $name)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(Color.teddyText)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .feedback }
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 16)

            Divider().padding(.horizontal, 18)

            // Message field
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Message")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.teddySubtext)
                    .textCase(.uppercase)
                    .tracking(0.4)

                ZStack(alignment: .topLeading) {
                    if feedbackText.isEmpty {
                        Text(selectedType.placeholder)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundStyle(Color.teddyCaption)
                            .padding(.top, 1)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $feedbackText)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(Color.teddyText)
                        .focused($focusedField, equals: .feedback)
                        .frame(minHeight: 120)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 18)

            // Character count
            HStack {
                Spacer()
                Text("\(feedbackText.count) characters")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Color.teddyCaption)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 14)
        }
        .background(Color.teddyCard, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.teddyBorder, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 2)
    }

    // MARK: - Send Button

    private var sendButton: some View {
        Button {
            focusedField = nil
            sendFeedback()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .bold))
                Text("Send Feedback")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? Color.teddyCaption
                    : Color.teddyAccent,
                in: RoundedRectangle(cornerRadius: 18)
            )
            .shadow(
                color: feedbackText.isEmpty ? .clear : Color.teddyAccent.opacity(0.25),
                radius: 10, y: 4
            )
        }
        .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .animation(.easeInOut(duration: 0.2), value: feedbackText.isEmpty)
    }

    // MARK: - Footer Note

    private var footerNote: some View {
        VStack(spacing: 14) {
            Divider()

            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.teddyCaption)
                Text("Your feedback is sent directly via email. We never share your information with third parties.")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Color.teddyCaption)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Success Toast

    private var successToast: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.teddySuccess)
            Text("Feedback sent! Thanks 🧸")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.teddyText)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.teddyCard, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.teddySuccess.opacity(0.3), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
        .padding(.horizontal, 22)
        .padding(.top, 12)
    }

    // MARK: - Logic

    private func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            showMailComposer = true
        } else {
            showMailUnavailable = true
        }
    }

    private func composedEmailBody() -> String {
        var body = ""
        if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            body += "From: \(name)\n\n"
        }
        body += "Rating: \(String(repeating: "⭐️", count: rating)) (\(rating)/5)\n"
        body += "Type: \(selectedType.displayName)\n\n"
        body += "---\n\n"
        body += feedbackText
        body += "\n\n---\nSent from Timer Teddy for iOS"
        return body
    }

    private var ratingLabel: String {
        switch rating {
        case 1: return "😞  Not good — help us improve!"
        case 2: return "😕  Needs work — we hear you."
        case 3: return "😐  It's okay — what could be better?"
        case 4: return "😊  Pretty good — thanks!"
        case 5: return "🤩  Amazing — you made our day!"
        default: return ""
        }
    }

    private func sectionLabel(_ t: String, icon: String) -> some View {
        Label(t, systemImage: icon)
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(Color.teddyText)
    }
}

// MARK: - Feedback Type Enum

enum FeedbackType: String, CaseIterable {
    case suggestion, bugReport, question, compliment, other

    var displayName: String {
        switch self {
        case .suggestion: return "Suggestion"
        case .bugReport:  return "Bug Report"
        case .question:   return "Question"
        case .compliment: return "Compliment"
        case .other:      return "Other"
        }
    }

    var icon: String {
        switch self {
        case .suggestion: return "lightbulb.fill"
        case .bugReport:  return "ant.fill"
        case .question:   return "questionmark.circle.fill"
        case .compliment: return "heart.fill"
        case .other:      return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .suggestion: return Color(hex: "3B6FD4")
        case .bugReport:  return Color(hex: "D94F3D")
        case .question:   return Color(hex: "C08B28")
        case .compliment: return Color(hex: "2A9D6E")
        case .other:      return Color(hex: "7254C8")
        }
    }

    var placeholder: String {
        switch self {
        case .suggestion: return "What feature would make Timer Teddy better?"
        case .bugReport:  return "Describe what happened and how to reproduce it…"
        case .question:   return "What would you like to know?"
        case .compliment: return "Tell Teddy what you love! 🧸"
        case .other:      return "Share whatever is on your mind…"
        }
    }
}

// MailComposerView has moved to SettingsView.swift

// MARK: - Preview

#Preview {
    NavigationStack {
        FeedbackView()
            .environmentObject(SessionStore())
    }
}
