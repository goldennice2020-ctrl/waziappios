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
    @State private var isSubmitting = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("支付页")
                    .font(.system(size: 30, weight: .bold, design: .serif))

                paymentHero
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
        .alert("提示", isPresented: errorAlertBinding) {
            Button("知道了", role: .cancel) {
                store.errorMessage = nil
            }
        } message: {
            Text(store.errorMessage ?? "")
        }
    }

    private var paymentHero: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("确认你要的颜色，然后完成付款。")
                .font(.system(size: 24, weight: .semibold, design: .serif))

            Text("这一版采用支付宝收款码确认支付。付款完成后，再填写收货地址。")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .lineSpacing(3)

            HStack(spacing: 12) {
                heroBadge(title: selectedColor.name, tint: selectedColor.tint, useStroke: selectedColor == .white)
                heroBadge(title: store.product.packDescription, tint: Color.black, useStroke: false)
                heroBadge(title: "¥\(store.product.price)", tint: Color(red: 0.07, green: 0.58, blue: 0.95), useStroke: false)
            }
        }
        .padding(22)
        .background(Color.white.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var orderSummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("订单信息")
                .font(.system(size: 18, weight: .semibold))

            summaryRow(title: "商品", value: store.product.name)
            summaryRow(title: "颜色", value: selectedColor.name)
            summaryRow(title: "套餐", value: store.product.packDescription)
            summaryRow(title: "下单规则", value: "每单一件")

            Divider()

            HStack {
                Text("应付金额")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("¥\(store.product.price)")
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

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(red: 0.07, green: 0.58, blue: 0.95))
                            .frame(width: 40, height: 40)

                        Text("支")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("支付宝")
                            .font(.system(size: 16, weight: .semibold))
                        Text("扫码付款")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("推荐")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.06))
                        .clipShape(Capsule())
                }

                VStack(alignment: .leading, spacing: 10) {
                    paymentStep(index: 1, text: "点击确认支付，展示支付宝收款码")
                    paymentStep(index: 2, text: "用支付宝扫码并完成转账")
                    paymentStep(index: 3, text: "返回 App，点击“我已完成付款”")
                }
            }
            .padding(18)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text("MVP 版本暂不接官方支付回调，所以订单会先进入“待人工确认 / 待填写地址”流程。")
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

            qrPanel

            Text("请使用支付宝扫码支付 ¥\(store.product.price)")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                paymentInfoRow(title: "收款说明", value: "WAZI 袜子商店")
                paymentInfoRow(title: "订单内容", value: "\(selectedColor.name) / \(store.product.packDescription)")
                paymentInfoRow(title: "到账后", value: "继续填写收货地址")
            }
            .padding(.horizontal, 24)

            Button {
                isSubmitting = true
                Task {
                    let order = await store.createPaidOrder(color: selectedColor)
                    await MainActor.run {
                        createdOrder = order
                        if order != nil {
                            showingQRCode = false
                        }
                        isSubmitting = false
                    }
                }
            } label: {
                Text(isSubmitting ? "提交中..." : "我已完成付款")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.black)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .disabled(isSubmitting)
            .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.95, green: 0.94, blue: 0.91).ignoresSafeArea())
    }

    private var qrPanel: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.white)
                    .frame(width: PaymentAssets.hasAlipayQRCode ? 308 : 272, height: PaymentAssets.hasAlipayQRCode ? 540 : 312)
                    .shadow(color: .black.opacity(0.08), radius: 24, y: 10)

                VStack(spacing: 18) {
                    if PaymentAssets.hasAlipayQRCode {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("支付宝收款海报")
                                .font(.system(size: 16, weight: .semibold))
                            Text("当前已加载真实图片资源，页面将完整展示这张收款海报。")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        HStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(red: 0.07, green: 0.58, blue: 0.95))
                                    .frame(width: 34, height: 34)

                                Text("支")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("支付宝扫码付款")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("示意收款页")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    qrContent
                        .frame(width: PaymentAssets.hasAlipayQRCode ? 228 : 188, height: PaymentAssets.hasAlipayQRCode ? 406 : 188)

                    Text(PaymentAssets.hasAlipayQRCode ? "当前已使用本地支付宝收款码海报" : "未检测到本地收款码资源，当前使用演示二维码")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    @ViewBuilder
    private var qrContent: some View {
        if PaymentAssets.hasAlipayQRCode {
            Image(PaymentAssetNames.alipayQRCode)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 18, y: 8)
        } else {
            FauxQRCodeView()
        }
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

    private func heroBadge(title: String, tint: Color, useStroke: Bool) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(tint)
                .frame(width: 12, height: 12)
                .overlay(Circle().stroke(useStroke ? Color.black.opacity(0.15) : Color.clear, lineWidth: 1))

            Text(title)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.05))
        .clipShape(Capsule())
    }

    private func paymentStep(index: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(index)")
                .font(.system(size: 12, weight: .bold))
                .frame(width: 22, height: 22)
                .background(Color.black)
                .foregroundStyle(.white)
                .clipShape(Circle())

            Text(text)
                .font(.system(size: 14))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func paymentInfoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
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
}

private struct FauxQRCodeView: View {
    private let cells = 17

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<cells, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<cells, id: \.self) { column in
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(isDark(row: row, column: column) ? Color.black : Color.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func isDark(row: Int, column: Int) -> Bool {
        if isFinderZone(row: row, column: column, top: 0, left: 0) { return true }
        if isFinderZone(row: row, column: column, top: 0, left: cells - 7) { return true }
        if isFinderZone(row: row, column: column, top: cells - 7, left: 0) { return true }

        let seed = (row * 31 + column * 17 + row * column) % 7
        return seed == 0 || seed == 3 || (row + column).isMultiple(of: 5)
    }

    private func isFinderZone(row: Int, column: Int, top: Int, left: Int) -> Bool {
        let rowRange = top..<(top + 7)
        let columnRange = left..<(left + 7)
        guard rowRange.contains(row), columnRange.contains(column) else {
            return false
        }

        let localRow = row - top
        let localColumn = column - left

        let isOuter = localRow == 0 || localRow == 6 || localColumn == 0 || localColumn == 6
        let isInner = (2...4).contains(localRow) && (2...4).contains(localColumn)
        return isOuter || isInner
    }
}

#Preview {
    NavigationStack {
        CheckoutView(selectedColor: .black)
            .environmentObject(ShopStore())
    }
}
