//
//  AnimatedTeddyView.swift
//  Timer Teddy
//
//  Created by Rahil Gandhi on 2026-03-12.
//

// AnimatedTeddyView.swift
// Timer Teddy 🧸
// Fully SwiftUI-drawn animated teddy bear. No image assets required.
// Animations: float bob, ear wiggle, arm wave, random blink, sparkle pulse.

import SwiftUI

struct AnimatedTeddyView: View {

    @State private var bobOffset:   CGFloat = 0
    @State private var earRotation: Double  = 0
    @State private var eyeScaleY:   CGFloat = 1.0
    @State private var armAngle:    Double  = 0
    @State private var sparkle:     Double  = 0

    var body: some View {
        ZStack {
            // Soft glow behind teddy
            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: "C96B2F").opacity(0.22), .clear],
                    center: .center, startRadius: 0, endRadius: 55
                ))
                .frame(width: 110, height: 110)
                .offset(y: 10)

            // Sparkle dots
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.white.opacity(sparkle))
                    .frame(width: 4, height: 4)
                    .offset(
                        x: [18.0, -22.0, 10.0][i],
                        y: [-38.0, -30.0, -42.0][i]
                    )
            }

            teddyBody
                .offset(y: bobOffset)
        }
        .onAppear { startAnimations() }
    }

    // MARK: - Body layers

    private var teddyBody: some View {
        ZStack {
            // Shadow
            Ellipse()
                .fill(Color.black.opacity(0.12))
                .frame(width: 60, height: 12)
                .offset(y: 46)

            // Left ear
            earShape
                .rotationEffect(.degrees(-earRotation - 5), anchor: .bottomTrailing)
                .offset(x: -22, y: -36)

            // Right ear
            earShape
                .rotationEffect(.degrees(earRotation + 5), anchor: .bottomLeading)
                .offset(x: 22, y: -36)

            // Belly
            Ellipse()
                .fill(Color(hex: "D4956A").opacity(0.55))
                .frame(width: 34, height: 30)
                .offset(y: 14)

            // Body
            Ellipse()
                .fill(Color(hex: "C07840"))
                .frame(width: 64, height: 70)
                .offset(y: 20)

            // Left arm
            armShape
                .rotationEffect(.degrees(armAngle + 20), anchor: .init(x: 1.0, y: 0.1))
                .offset(x: -38, y: 10)

            // Right arm
            armShape
                .scaleEffect(x: -1)
                .rotationEffect(.degrees(-armAngle - 20), anchor: .init(x: 0.0, y: 0.1))
                .offset(x: 38, y: 10)

            // Head
            Circle()
                .fill(Color(hex: "C07840"))
                .frame(width: 66, height: 66)
                .offset(y: -18)

            // Muzzle
            Ellipse()
                .fill(Color(hex: "D4956A"))
                .frame(width: 32, height: 22)
                .offset(y: -6)

            // Nose
            Capsule()
                .fill(Color(hex: "3D1A0A"))
                .frame(width: 14, height: 8)
                .offset(y: -10)

            // Left eye
            eyeView.offset(x: -13, y: -26)

            // Right eye
            eyeView.offset(x: 13, y: -26)

            // Smile
            smileShape.offset(y: -2)

            // Tummy button
            Circle()
                .fill(Color(hex: "B06030").opacity(0.4))
                .frame(width: 8, height: 8)
                .offset(y: 16)
        }
    }

    // MARK: - Subshapes

    private var earShape: some View {
        ZStack {
            Circle().fill(Color(hex: "C07840")).frame(width: 26, height: 26)
            Circle().fill(Color(hex: "D4956A").opacity(0.7)).frame(width: 14, height: 14)
        }
    }

    private var armShape: some View {
        Capsule().fill(Color(hex: "B06828")).frame(width: 18, height: 36)
    }

    private var eyeView: some View {
        ZStack {
            Circle().fill(Color.white).frame(width: 14, height: 14)
            Ellipse().fill(Color(hex: "2A1005")).frame(width: 8, height: 8 * eyeScaleY)
            Circle().fill(Color.white.opacity(0.8)).frame(width: 3, height: 3).offset(x: 2, y: -2)
        }
    }

    private var smileShape: some View {
        Path { p in
            p.addArc(center: CGPoint(x: 0, y: 0), radius: 9,
                     startAngle: .degrees(20), endAngle: .degrees(160), clockwise: false)
        }
        .stroke(Color(hex: "3D1A0A"), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        .frame(width: 18, height: 9)
        .offset(y: -3)
    }

    // MARK: - Animations

    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            bobOffset = -8
        }
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(0.4)) {
            earRotation = 8
        }
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            armAngle = 18
        }
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(0.6)) {
            sparkle = 0.7
        }
        scheduleBlink()
    }

    private func scheduleBlink() {
        let delay = Double.random(in: 3.0...5.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeIn(duration: 0.07))  { eyeScaleY = 0.05 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeOut(duration: 0.1)) { eyeScaleY = 1.0 }
                scheduleBlink()
            }
        }
    }
}

#Preview {
    ZStack {
        Color(hex: "2C1A0E").ignoresSafeArea()
        AnimatedTeddyView().frame(width: 130, height: 130)
    }
}
