//
//  AdminDashboardView.swift
//  waziIOS
//
//  Created by Codex on 2026/4/16.
//

import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject private var store: ShopStore
    @State private var showPendingOnly = false

    private var displayedOrders: [SockOrder] {
        showPendingOnly ? store.pendingAddressOrders : store.orders
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("后台订单管理")
                    .font(.system(size: 30, weight: .bold, design: .serif))

                statusCard

                HStack(spacing: 14) {
                    statCard(title: "订单数量", value: "\(store.orderCount)")
                    statCard(title: "销售金额", value: "¥\(store.totalRevenue)")
                }

                Toggle("筛选未填地址订单", isOn: $showPendingOnly)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                    .padding(18)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                ForEach(displayedOrders) { order in
                    AdminOrderCard(order: order)
                        .environmentObject(store)
                }
            }
            .padding(24)
        }
        .background(Color(red: 0.96, green: 0.95, blue: 0.92).ignoresSafeArea())
        .task {
            await store.refreshOrders()
        }
        .alert("提示", isPresented: errorAlertBinding) {
            Button("知道了", role: .cancel) {
                store.errorMessage = nil
            }
        } message: {
            Text(store.errorMessage ?? "")
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("数据来源")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Circle()
                            .fill(AppEnvironment.backendMode == .supabase ? Color.green : Color.orange)
                            .frame(width: 10, height: 10)

                        Text(AppEnvironment.backendLabel)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }

                Spacer()

                Button {
                    Task {
                        await store.refreshOrders()
                    }
                } label: {
                    HStack(spacing: 6) {
                        if store.isLoading {
                            ProgressView()
                                .tint(.black)
                                .scaleEffect(0.8)
                        }
                        Text(store.isLoading ? "刷新中" : "刷新订单")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(store.isLoading)
            }

            Text(AppEnvironment.backendMode == .supabase ? "现在会读取真实订单数据，发货状态和地址修改也会回写 Supabase。" : "当前仍在使用本地演示数据，适合先看流程和界面。")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func statCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .serif))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func adminRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
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

private struct AdminOrderCard: View {
    @EnvironmentObject private var store: ShopStore

    let order: SockOrder

    @State private var trackingNumber = ""
    @State private var isSubmitting = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(order.orderNumber)
                .font(.system(size: 16, weight: .bold))

            adminRow(title: "商品", value: store.product.name)
            adminRow(title: "金额", value: "¥\(order.amount)")
            adminRow(title: "支付状态", value: order.paymentState.rawValue)
            adminRow(title: "地址状态", value: order.hasAddress ? "已填写" : "未填写")
            adminRow(title: "发货状态", value: order.shippingState.rawValue)

            if let address = order.address {
                VStack(alignment: .leading, spacing: 6) {
                    Text("收货信息")
                        .font(.system(size: 14, weight: .semibold))
                    Text(address.name)
                    Text(address.phone)
                    Text(address.detail)
                        .foregroundStyle(.secondary)
                }
            }

            if order.shippingState != .shipped {
                VStack(alignment: .leading, spacing: 10) {
                    Text("物流单号")
                        .font(.system(size: 14, weight: .semibold))

                    TextField("请输入物流单号", text: $trackingNumber)
                        .padding(14)
                        .background(Color.black.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            } else if let trackingNumber = order.trackingNumber {
                adminRow(title: "物流单号", value: trackingNumber)
            }

            Button {
                isSubmitting = true
                Task {
                    let fallback = "SF\(order.orderNumber.suffix(6))"
                    _ = await store.markShipped(
                        orderID: order.id,
                        trackingNumber: trackingNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? fallback : trackingNumber
                    )
                    await MainActor.run {
                        isSubmitting = false
                    }
                }
            } label: {
                Text(order.shippingState == .shipped ? "已发货" : (isSubmitting ? "提交中..." : "确认发货"))
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(order.shippingState == .shipped ? Color.gray.opacity(0.18) : Color.black)
                    .foregroundStyle(order.shippingState == .shipped ? Color.black.opacity(0.5) : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .disabled(order.shippingState == .shipped || !order.hasAddress || isSubmitting)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func adminRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}
