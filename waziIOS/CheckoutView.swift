//
//  CheckoutView.swift
//  waziIOS
//
//  Created by Eric on 2026/4/15.
//

import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject private var store: ShopStore

    let selectedColor: SockColor

    @State private var showingQRCode = false
    @State private var createdOrder: SockOrder?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("支付页")
                    .font(.system(size: 30, weight: .bold, design: .serif))

                orderSummary
                paymentSection

                Button {
                    showingQRCode = true
                } label: {
                    Text("确认支付")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.black)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
            .padding(24)
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
        .sheet(isPresented: $showingQRCode) {
            qrCodeSheet
                .presentationDetents([.medium, .large])
        }
        .navigationDestination(item: $createdOrder) { order in
            AddressFormView(orderID: order.id)
                .environmentObject(store)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var orderSummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            summaryRow(title: "商品", value: store.product.name)
            summaryRow(title: "颜色", value: selectedColor.name)
            summaryRow(title: "套餐", value: store.product.packDescription)

            Divider()

            HStack {
                Text("应付金额")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("¥\(store.price)")
                    .font(.system(size: 30, weight: .bold, design: .serif))
            }
        }
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("支付方式")
                .font(.system(size: 18, weight: .semibold))

            HStack {
                Image(systemName: "circle.inset.filled")
                    .foregroundStyle(.black)
                Text("支付宝")
                Spacer()
                Text("扫码付款")
                    .foregroundStyle(.secondary)
            }
            .padding(18)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text("MVP 版本不接官方支付接口，点击确认支付后展示收款二维码，由用户自行扫码完成付款。")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
    }

    private var qrCodeSheet: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.secondary.opacity(0.25))
                .frame(width: 54, height: 6)
                .padding(.top, 8)

            Text("支付宝收款码")
                .font(.system(size: 24, weight: .bold, design: .serif))

            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white)
                    .frame(width: 240, height: 240)

                Image(systemName: "qrcode")
                    .font(.system(size: 120))
            }

            Text("请使用支付宝扫码支付 ¥\(store.price)")
                .foregroundStyle(.secondary)

            Button {
                showingQRCode = false
                createdOrder = store.createPaidOrder(color: selectedColor)
            } label: {
                Text("我已完成付款")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.black)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.95, green: 0.94, blue: 0.91).ignoresSafeArea())
    }

    private func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationStack {
        CheckoutView(selectedColor: .black)
            .environmentObject(ShopStore())
    }
}
