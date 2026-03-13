// StreakHeatmap.swift
// Timer Teddy 🧸
// A GitHub-style 12-week activity heatmap calendar showing daily focus time.

import SwiftUI

struct StreakHeatmap: View {
    @EnvironmentObject private var store: SessionStore

    // 84 days = 12 columns of 7 rows (weeks across, days of week down)
    private let totalDays  = 84
    private let columns    = 12
    private let rows       = 7   // Mon–Sun

    // The 84 days ending today, oldest first
    private var days: [Date] {
        let cal   = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<totalDays).compactMap {
            cal.date(byAdding: .day, value: -(totalDays - 1 - $0), to: today)
        }
    }

    // Max seconds in any single day (used to normalise intensity)
    private var maxSeconds: Int {
        max(1, days.map { store.totalSeconds(on: $0) }.max() ?? 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Month labels
            monthLabels

            // Grid
            GeometryReader { geo in
                let gap:      CGFloat = 3
                let cellSize: CGFloat = (geo.size.width - CGFloat(columns - 1) * gap) / CGFloat(columns)

                HStack(alignment: .top, spacing: gap) {
                    ForEach(0..<columns, id: \.self) { col in
                        VStack(spacing: gap) {
                            ForEach(0..<rows, id: \.self) { row in
                                let idx = col * rows + row
                                if idx < days.count {
                                    let date    = days[idx]
                                    let secs    = store.totalSeconds(on: date)
                                    let isToday = Calendar.current.isDateInToday(date)

                                    HeatCell(
                                        seconds:   secs,
                                        maxSeconds: maxSeconds,
                                        isToday:   isToday,
                                        date:      date
                                    )
                                    .frame(width: cellSize, height: cellSize)
                                } else {
                                    Color.clear.frame(width: cellSize, height: cellSize)
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: {
                // Dynamically compute height: will be set by GeometryReader parent
                // Use a fixed aspect-based height here
                let gap: CGFloat = 3
                let approxCell: CGFloat = (UIScreen.main.bounds.width - 44 - 32 - CGFloat(columns - 1) * gap) / CGFloat(columns)
                return CGFloat(rows) * approxCell + CGFloat(rows - 1) * gap
            }())

            // Legend
            legend
        }
        .padding(16)
        .background(Color.teddyCard, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.teddyBorder, lineWidth: 1))
    }

    // MARK: - Month Labels

    private var monthLabels: some View {
        // Show abbreviated month name above the first column of each new month
        GeometryReader { geo in
            let gap:      CGFloat = 3
            let cellSize: CGFloat = (geo.size.width - CGFloat(columns - 1) * gap) / CGFloat(columns)
            let cal = Calendar.current

            ZStack(alignment: .topLeading) {
                ForEach(0..<columns, id: \.self) { col in
                    let idx  = col * rows          // first day of this column
                    if idx < days.count {
                        let date = days[idx]
                        let day  = cal.component(.day, from: date)
                        // Only label if this is the first column for this month
                        if day <= 7 {
                            Text(monthAbbrev(date))
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.teddyCaption)
                                .offset(x: CGFloat(col) * (cellSize + gap))
                        }
                    }
                }
            }
        }
        .frame(height: 14)
    }

    private func monthAbbrev(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM"
        return f.string(from: date)
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(spacing: 6) {
            Text("Less")
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(Color.teddyCaption)

            ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { intensity in
                RoundedRectangle(cornerRadius: 3)
                    .fill(cellColor(intensity: intensity))
                    .frame(width: 12, height: 12)
            }

            Text("More")
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(Color.teddyCaption)

            Spacer()

            Text("Past 12 weeks")
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(Color.teddyCaption)
        }
    }

    // MARK: - Color helper

    static func color(for intensity: Double) -> Color {
        if intensity <= 0 { return Color(hex: "F0EBE4") }
        // Warm amber gradient matching app brand
        let stops: [(Double, String)] = [
            (0.01, "F5D9BE"),
            (0.25, "E8A86A"),
            (0.50, "D4793A"),
            (0.75, "C05A1E"),
            (1.00, "8C3A0A")
        ]
        for (threshold, hex) in stops.reversed() {
            if intensity >= threshold { return Color(hex: hex) }
        }
        return Color(hex: "F0EBE4")
    }

    func cellColor(intensity: Double) -> Color {
        StreakHeatmap.color(for: intensity)
    }
}

// MARK: - Individual Cell

private struct HeatCell: View {
    let seconds:    Int
    let maxSeconds: Int
    let isToday:    Bool
    let date:       Date

    @State private var showTooltip = false

    private var intensity: Double {
        seconds == 0 ? 0 : max(0.05, Double(seconds) / Double(maxSeconds))
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }

    private var tooltipText: String {
        if seconds == 0 { return "\(formattedDate): No activity" }
        let m = seconds / 60
        if m >= 60 { return "\(formattedDate): \(m / 60)h \(m % 60)m" }
        return "\(formattedDate): \(m)m"
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(StreakHeatmap.color(for: intensity))
            .overlay(
                // Today indicator — small white ring
                isToday ?
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(Color.white, lineWidth: 1.5)
                        .padding(1)
                        .eraseToAnyView()
                    : Color.clear.eraseToAnyView()
            )
            .overlay(
                // Tooltip
                showTooltip ?
                    Text(tooltipText)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color(hex: "2C1A0E"), in: RoundedRectangle(cornerRadius: 8))
                        .fixedSize()
                        .offset(y: -28)
                        .zIndex(10)
                        .eraseToAnyView()
                    : Color.clear.eraseToAnyView()
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.15)) { showTooltip.toggle() }
                // Auto-dismiss after 2 s
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: 0.2)) { showTooltip = false }
                }
            }
    }
}

// MARK: - eraseToAnyView helper

private extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}

#Preview {
    StreakHeatmap()
        .environmentObject(SessionStore())
        .padding()
}
