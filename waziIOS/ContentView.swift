//
//  ContentView.swift
//  waziIOS
//
//  Created by Eric on 2026/4/15.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ShopStore

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.97, green: 0.96, blue: 0.94),
                        Color(red: 0.93, green: 0.92, blue: 0.89)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        landingHeader
                        backendBadge
                        heroCard
                        philosophyCard

                        NavigationLink {
                            ProductDetailView()
                                .environmentObject(store)
                        } label: {
                            Text("进入商店")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.black)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }

                        NavigationLink {
                            AdminDashboardView()
                                .environmentObject(store)
                        } label: {
                            HStack {
                                Text("查看后台订单")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.72))
                            .padding(20)
                            .background(Color.white.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }

                        NavigationLink {
                            SupabaseSetupView()
                        } label: {
                            HStack {
                                Text("查看 Supabase 配置指南")
                                Spacer()
                                Image(systemName: "slider.horizontal.3")
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.72))
                            .padding(20)
                            .background(Color.white.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                    }
                    .padding(24)
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var landingHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WAZI")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .kerning(3)

            Text("好一点的袜子")
                .font(.system(size: 38, weight: .bold, design: .serif))

            Text(store.product.subtitle)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.65))
        }
        .padding(.top, 18)
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.12, green: 0.12, blue: 0.13),
                            Color(red: 0.23, green: 0.23, blue: 0.24)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 420)

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("EDITORIAL DROP")
                        .font(.system(size: 12, weight: .bold))
                        .kerning(1.8)
                        .foregroundStyle(.white.opacity(0.62))

                    Spacer()

                    Text("BLACK / GRAY / WHITE")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.48))
                }

                Spacer()

                SockDisplayScene(primaryColor: .black, secondaryColor: .gray, layout: .editorial)
                    .frame(height: 220)
                    .padding(.bottom, 6)

                Text("减少选择，只留下一双值得买的袜子。")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text("一双能覆盖大多数日常穿着场景的基础袜，用更少选择换来更好的决定。")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.68))
                    .lineSpacing(3)
            }
            .padding(28)
        }
    }

    private var backendBadge: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(AppEnvironment.backendMode == .supabase ? Color.green : Color.orange)
                .frame(width: 10, height: 10)

            Text(AppEnvironment.backendLabel)
                .font(.system(size: 14, weight: .medium))

            if store.isLoading {
                Spacer()
                ProgressView()
                    .tint(.black)
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var philosophyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("我们相信")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.5))

            Text("日常用品应该简单、耐用、不浪费时间。")
                .font(.system(size: 24, weight: .semibold, design: .serif))

            Text("只卖一种通用袜子，你只需要决定今天更想穿黑、白，还是灰。")
                .font(.system(size: 16))
                .foregroundStyle(Color.black.opacity(0.68))
                .lineSpacing(4)
        }
        .padding(24)
        .background(Color.white.opacity(0.74))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

#Preview {
    ContentView()
}
