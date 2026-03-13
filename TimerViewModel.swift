// TimerViewModel.swift
// Timer Teddy 🧸
// MVVM ViewModel managing timer state, countdown logic, and notifications.

import Foundation
import Combine
import UserNotifications

/// All possible states the timer can be in.
enum TimerState {
    case idle        // Not yet started
    case running     // Actively counting down
    case paused      // Paused mid-session
    case finished    // Reached zero
}

@MainActor
final class TimerViewModel: ObservableObject {

    // MARK: - Published State

    @Published var state: TimerState = .idle
    @Published var remainingSeconds: Int = 0
    @Published var selectedDurationSeconds: Int = 25 * 60  // default 25 min

    // MARK: - Private

    private var cancellable: AnyCancellable?
    private var startedSeconds: Int = 0   // total duration when session began
    private let activity: ActivityType

    // MARK: - Init

    init(activity: ActivityType) {
        self.activity = activity
        self.selectedDurationSeconds = activity.defaultDuration
        self.remainingSeconds        = activity.defaultDuration
    }

    // MARK: - Computed

    /// Elapsed seconds so far in this session.
    var elapsedSeconds: Int {
        startedSeconds - remainingSeconds
    }

    /// 0.0 → 1.0 progress through the session.
    var progress: Double {
        guard startedSeconds > 0 else { return 0 }
        return Double(startedSeconds - remainingSeconds) / Double(startedSeconds)
    }

    /// Remaining time as "MM:SS" string.
    var timeString: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Controls

    /// Start or resume the countdown.
    func start() {
        guard state != .running else { return }

        // If idle, set the initial duration
        if state == .idle {
            remainingSeconds = selectedDurationSeconds
            startedSeconds   = selectedDurationSeconds
        }

        state = .running
        scheduleNotification()

        // Combine timer fires every second on main run loop
        cancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    self.finish()
                }
            }
    }

    /// Pause the countdown.
    func pause() {
        guard state == .running else { return }
        state = .paused
        cancellable?.cancel()
        cancelPendingNotification()
    }

    /// Reset to the chosen duration without saving a session.
    func reset() {
        cancellable?.cancel()
        cancelPendingNotification()
        remainingSeconds = selectedDurationSeconds
        startedSeconds   = selectedDurationSeconds
        state = .idle
    }

    /// Manually end the session early — saves whatever was completed.
    /// Returns the elapsed seconds so the caller can persist the session.
    @discardableResult
    func endSession() -> Int {
        cancellable?.cancel()
        cancelPendingNotification()
        let elapsed = elapsedSeconds
        state = .idle
        remainingSeconds = selectedDurationSeconds
        startedSeconds   = 0
        return elapsed
    }

    // MARK: - Private helpers

    private func finish() {
        cancellable?.cancel()
        state = .finished
        // Caller (TimerView) is responsible for saving the session.
    }

    // MARK: - Notifications

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func scheduleNotification() {
        cancelPendingNotification()
        guard remainingSeconds > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Timer Teddy ⏰"
        content.body  = "Your \(activity.displayName) session has finished!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(remainingSeconds),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: "timerTeddy_session",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelPendingNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["timerTeddy_session"])
    }
}
