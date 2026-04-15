//
//  ProductVisuals.swift
//  waziIOS
//
//  Created by Codex on 2026/4/16.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct SockDisplayScene: View {
    let primaryColor: SockColor
    let secondaryColor: SockColor?
    let layout: SockDisplayLayout

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ambientShadow(size: geometry.size)
                foldedFabric(size: geometry.size)

                switch layout {
                case .editorial:
                    editorialLayout(size: geometry.size)
                case .product:
                    productLayout(size: geometry.size)
                }
            }
        }
    }

    private func editorialLayout(size: CGSize) -> some View {
        ZStack {
            SockIllustration(color: secondaryColor ?? .gray, scale: 0.92, tilt: -10)
                .frame(width: size.width * 0.30, height: size.height * 0.74)
                .offset(x: -size.width * 0.16, y: -size.height * 0.02)

            SockIllustration(color: primaryColor, scale: 1.0, tilt: 7)
                .frame(width: size.width * 0.34, height: size.height * 0.82)
                .offset(x: size.width * 0.03, y: size.height * 0.03)

            SockIllustration(color: .white, scale: 0.86, tilt: 18)
                .frame(width: size.width * 0.26, height: size.height * 0.68)
                .offset(x: size.width * 0.24, y: -size.height * 0.08)
                .opacity(primaryColor == .white ? 0.55 : 0.9)
        }
    }

    private func productLayout(size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: size.width * 0.12, style: .continuous)
                .fill(Color.white.opacity(0.44))
                .frame(width: size.width * 0.78, height: size.height * 0.84)
                .blur(radius: 2)

            SockIllustration(color: primaryColor, scale: 1.04, tilt: -5)
                .frame(width: size.width * 0.34, height: size.height * 0.78)
                .offset(x: -size.width * 0.11, y: -size.height * 0.02)

            SockIllustration(color: primaryColor, scale: 0.96, tilt: 8)
                .frame(width: size.width * 0.32, height: size.height * 0.72)
                .offset(x: size.width * 0.14, y: size.height * 0.04)
        }
    }

    private func ambientShadow(size: CGSize) -> some View {
        Ellipse()
            .fill(Color.black.opacity(0.12))
            .frame(width: size.width * 0.62, height: size.height * 0.18)
            .blur(radius: 22)
            .offset(y: size.height * 0.29)
    }

    private func foldedFabric(size: CGSize) -> some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.48))
                .frame(width: size.width * 0.34, height: size.width * 0.34)
                .blur(radius: 6)
                .offset(x: -size.width * 0.28, y: -size.height * 0.24)

            Circle()
                .fill(Color.black.opacity(0.05))
                .frame(width: size.width * 0.44, height: size.width * 0.44)
                .blur(radius: 10)
                .offset(x: size.width * 0.30, y: -size.height * 0.14)
        }
    }
}

enum SockDisplayLayout {
    case editorial
    case product
}

private struct SockIllustration: View {
    let color: SockColor
    let scale: CGFloat
    let tilt: Double

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                sockBody(width: width, height: height)
                ribbedNeck(width: width, height: height)
                toeCap(width: width, height: height)
                heelPatch(width: width, height: height)
            }
            .scaleEffect(scale)
            .rotationEffect(.degrees(tilt))
        }
    }

    private func sockBody(width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: width * 0.24, style: .continuous)
                .fill(sockGradient)
                .frame(width: width * 0.52, height: height * 0.64)
                .offset(y: height * 0.02)

            RoundedRectangle(cornerRadius: width * 0.23, style: .continuous)
                .fill(sockGradient)
                .frame(width: width * 0.70, height: height * 0.28)
                .offset(x: width * 0.10, y: height * 0.52)

            RoundedRectangle(cornerRadius: width * 0.12, style: .continuous)
                .fill(sockGradient)
                .frame(width: width * 0.28, height: height * 0.22)
                .offset(x: width * 0.18, y: height * 0.42)
        }
        .overlay {
            RoundedRectangle(cornerRadius: width * 0.20, style: .continuous)
                .stroke(color == .white ? color.stroke : Color.white.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: .black.opacity(color == .white ? 0.08 : 0.18), radius: 20, y: 12)
    }

    private func ribbedNeck(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: height * 0.018) {
            ForEach(0..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.white.opacity(color == .white ? 0.30 : 0.12))
                    .frame(width: width * 0.44, height: height * 0.013)
            }
        }
        .offset(y: -height * 0.17)
    }

    private func toeCap(width: CGFloat, height: CGFloat) -> some View {
        Capsule(style: .continuous)
            .fill(Color.white.opacity(color == .white ? 0.20 : 0.10))
            .frame(width: width * 0.24, height: height * 0.09)
            .offset(x: width * 0.26, y: height * 0.58)
    }

    private func heelPatch(width: CGFloat, height: CGFloat) -> some View {
        Circle()
            .fill(Color.white.opacity(color == .white ? 0.18 : 0.10))
            .frame(width: width * 0.15, height: width * 0.15)
            .offset(x: width * 0.02, y: height * 0.42)
    }

    private var sockGradient: LinearGradient {
        let top = color.tint.opacity(color == .white ? 1.0 : 0.96)
        let bottom = shade(color.tint, amount: color == .white ? -0.05 : -0.12)

        return LinearGradient(
            colors: [top, bottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func shade(_ color: Color, amount: Double) -> Color {
        #if canImport(UIKit)
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Color(
            red: min(max(Double(red) + amount, 0), 1),
            green: min(max(Double(green) + amount, 0), 1),
            blue: min(max(Double(blue) + amount, 0), 1),
            opacity: Double(alpha)
        )
        #else
        return color
        #endif
    }
}
