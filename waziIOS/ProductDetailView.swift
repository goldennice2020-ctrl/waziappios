//
//  ProductDetailView.swift
//  waziIOS
//
//  Created by Eric on 2026/4/15.
//

import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject private var store: ShopStore
    @State private var selectedColor: SockColor = .black

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                productHero

                VStack(alignment: .leading, spacing: 10) {
                    Text(store.product.name)
                        .font(.system(size: 32, weight: .bold, design: .serif))

                    Text(store.product.description)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }

                colorSection
                priceSection

                NavigationLink {
                    CheckoutView(selectedColor: selectedColor)
                        .environmentObject(store)
                } label: {
                    Text("立即购买")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.black)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
            }
            .padding(24)
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
        .navigationTitle("商品页")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var productHero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.9), Color(red: 0.90, green: 0.89, blue: 0.86)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 370)

            VStack(spacing: 20) {
                HStack(spacing: 28) {
                    SockShape(color: selectedColor, height: 230)
                    SockShape(color: selectedColor, height: 214)
                }

                Text(selectedColor.description)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("选择颜色")
                .font(.system(size: 18, weight: .semibold))

            HStack(spacing: 12) {
                ForEach(SockColor.allCases) { color in
                    Button {
                        selectedColor = color
                    } label: {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(color.tint)
                                .frame(width: 18, height: 18)
                                .overlay(Circle().stroke(color.stroke, lineWidth: 1))

                            Text(color.name)
                                .font(.system(size: 15, weight: .medium))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(selectedColor == color ? Color.black : Color.white)
                        .foregroundStyle(selectedColor == color ? .white : .black)
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.black.opacity(selectedColor == color ? 0 : 0.08), lineWidth: 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
            }
        }
    }

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("价格")
                .font(.system(size: 18, weight: .semibold))

            HStack(alignment: .bottom) {
                Text("¥\(store.product.price)")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                Text("/ \(store.product.packDescription)")
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 6)
            }

            Text("默认不支持数量选择，每个订单只包含一件商品。")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            Text("库存剩余 \(store.inventoryCount) 单")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.72))
        }
        .padding(22)
        .background(Color.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct SockShape: View {
    let color: SockColor
    let height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(color.tint)
            .frame(width: 86, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(color.stroke, lineWidth: 1)
            )
            .shadow(color: .black.opacity(color == .white ? 0.06 : 0.12), radius: 20, y: 10)
    }
}

#Preview {
    NavigationStack {
        ProductDetailView()
            .environmentObject(ShopStore())
    }
}
