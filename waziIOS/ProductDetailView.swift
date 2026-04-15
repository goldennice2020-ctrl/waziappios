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
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.96),
                            Color(red: 0.92, green: 0.90, blue: 0.86)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 370)

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedColor.name)
                            .font(.system(size: 22, weight: .bold, design: .serif))

                        Text(selectedColor.description)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("WAZI ONE")
                        .font(.system(size: 11, weight: .bold))
                        .kerning(1.6)
                        .foregroundStyle(Color.black.opacity(0.44))
                }

                Spacer()

                SockDisplayScene(primaryColor: selectedColor, secondaryColor: nil, layout: .product)
                    .frame(height: 230)

                HStack(spacing: 10) {
                    detailChip(text: "精梳棉质感")
                    detailChip(text: "轻微弹性")
                    detailChip(text: "日常通勤")
                }
            }
            .padding(24)
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

    private func detailChip(text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.84))
            .clipShape(Capsule())
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

#Preview {
    NavigationStack {
        ProductDetailView()
            .environmentObject(ShopStore())
    }
}
