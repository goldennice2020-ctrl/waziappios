//
//  AddressFormView.swift
//  waziIOS
//
//  Created by Codex on 2026/4/16.
//

import SwiftUI
import UIKit

struct AddressFormView: View {
    @EnvironmentObject private var store: ShopStore

    let orderID: UUID

    @State private var name = ""
    @State private var phone = ""
    @State private var detail = ""
    @State private var goToOrder = false
    @State private var isSubmitting = false

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        phone.count >= 11 &&
        !detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("地址填写页")
                    .font(.system(size: 30, weight: .bold, design: .serif))

                if let order = store.order(for: orderID) {
                    heroCard(order: order)
                    infoCard(order: order)
                }

                inputCard(title: "收货人", text: $name, keyboardType: .default, prompt: "请输入姓名")
                inputCard(title: "手机号", text: $phone, keyboardType: .numberPad, prompt: "请输入手机号")

                VStack(alignment: .leading, spacing: 12) {
                    Text("详细地址")
                        .font(.system(size: 15, weight: .semibold))

                    TextField("请输入详细地址", text: $detail, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                        .padding(18)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(20)
                .background(Color.white.opacity(0.82))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                Button {
                    isSubmitting = true
                    let address = ShippingAddress(name: name, phone: phone, detail: detail)
                    Task {
                        let success = await store.saveAddress(for: orderID, address: address)
                        await MainActor.run {
                            isSubmitting = false
                            if success {
                                goToOrder = true
                            }
                        }
                    }
                } label: {
                    Text(isSubmitting ? "提交中..." : "提交地址")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(isValid ? Color.black : Color.gray.opacity(0.35))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .disabled(!isValid || isSubmitting)
            }
            .padding(24)
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
        .navigationDestination(isPresented: $goToOrder) {
            SuccessView(orderID: orderID)
                .environmentObject(store)
        }
        .alert("提示", isPresented: errorAlertBinding) {
            Button("知道了", role: .cancel) {
                store.errorMessage = nil
            }
        } message: {
            Text(store.errorMessage ?? "")
        }
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { store.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    store.errorMessage = nil
                }
            }
        )
    }

    private func heroCard(order: SockOrder) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("支付完成后，请填写收货信息。")
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.76))

            HStack(alignment: .bottom, spacing: 18) {
                SockDisplayScene(primaryColor: order.color, secondaryColor: nil, layout: .product)
                    .frame(width: 132, height: 152)

                VStack(alignment: .leading, spacing: 10) {
                    Text(order.color.name)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(.white)

                    Text(store.product.packDescription)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.72))

                    statusChip(text: "已付款待完善地址", dark: true)
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.black, Color.black.opacity(0.82)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func infoCard(order: SockOrder) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("订单信息")
                .font(.system(size: 18, weight: .semibold))

            row(title: "订单号", value: order.orderNumber)
            row(title: "商品", value: store.product.name)
            row(title: "颜色", value: order.color.name)
            row(title: "金额", value: "¥\(order.amount)")
        }
        .padding(20)
        .background(Color.white.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func inputCard(title: String, text: Binding<String>, keyboardType: UIKeyboardType, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))

            TextField(prompt, text: text)
                .keyboardType(keyboardType)
                .padding(18)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(20)
        .background(Color.white.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func row(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }

    private func statusChip(text: String, dark: Bool) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(dark ? Color.white.opacity(0.16) : Color.black.opacity(0.06))
            .foregroundStyle(dark ? .white : .black)
            .clipShape(Capsule())
    }
}
