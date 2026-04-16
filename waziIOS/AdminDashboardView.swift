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

    private var shippedCount: Int {
        store.orders.filter { $0.shippingState == .shipped }.count
    }

    private var readyToShipCount: Int {
        store.orders.filter { $0.shippingState == .readyToShip }.count
    }

    private var missingAddressCount: Int {
        store.orders.filter { !$0.hasAddress }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("后台订单管理")
                    .font(.system(size: 30, weight: .bold, design: .serif))

                heroCard
                metricsGrid

                Toggle("仅看未填地址订单", isOn: $showPendingOnly)
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                    .padding(18)
                    .background(Color.white.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 14) {
                    Text(showPendingOnly ? "待补全订单" : "全部订单")
                        .font(.system(size: 20, weight: .semibold, design: .serif))

                    ForEach(displayedOrders) { order in
                        AdminOrderCard(order: order)
                            .environmentObject(store)
                    }
                }
            }
            .padding(24)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.95, blue: 0.92),
                    Color(red: 0.93, green: 0.92, blue: 0.88)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
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

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.black, Color.black.opacity(0.80)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("运营总览")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.62))

                        Text("现在你可以查看订单、筛选未填地址、填写物流单号并确认发货。")
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Button {
                        Task {
                            await store.refreshOrders()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if store.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.82)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }

                            Text(store.isLoading ? "刷新中" : "刷新")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.12))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .disabled(store.isLoading)
                }

                HStack(spacing: 10) {
                    dashboardChip(text: AppEnvironment.backendLabel, tint: AppEnvironment.backendMode == .supabase ? .green : .orange)
                    dashboardChip(text: "待发货 \(readyToShipCount)", tint: .white)
                    dashboardChip(text: "已发货 \(shippedCount)", tint: .white)
                }
            }
            .padding(24)
        }
        .frame(height: 224)
    }

    private var metricsGrid: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                metricCard(title: "订单数量", value: "\(store.orderCount)", subtitle: "全部订单")
                metricCard(title: "销售金额", value: "¥\(store.totalRevenue)", subtitle: "已支付累计")
            }

            HStack(spacing: 14) {
                metricCard(title: "待发货", value: "\(readyToShipCount)", subtitle: "地址已完善")
                metricCard(title: "缺地址", value: "\(missingAddressCount)", subtitle: "待用户补充")
            }
        }
    }

    private func metricCard(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 30, weight: .bold, design: .serif))

            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func dashboardChip(text: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(tint)
                .frame(width: 9, height: 9)
            Text(text)
                .font(.system(size: 13, weight: .semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color.white.opacity(0.12))
        .foregroundStyle(.white)
        .clipShape(Capsule())
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
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(order.orderNumber)
                        .font(.system(size: 16, weight: .bold))

                    HStack(spacing: 8) {
                        statusPill(text: order.paymentState.rawValue, style: .light)
                        statusPill(text: order.shippingState.rawValue, style: order.shippingState == .shipped ? .dark : .light)
                        if !order.hasAddress {
                            statusPill(text: "待填地址", style: .warning)
                        }
                    }
                }

                Spacer()

                SockDisplayScene(primaryColor: order.color, secondaryColor: nil, layout: .product)
                    .frame(width: 84, height: 96)
            }

            infoGroup(title: "订单摘要") {
                orderRow(title: "商品", value: store.product.name)
                orderRow(title: "颜色", value: order.color.name)
                orderRow(title: "金额", value: "¥\(order.amount)")
                orderRow(title: "套餐", value: order.packDescription)
            }

            if let address = order.address {
                infoGroup(title: "收货信息") {
                    orderRow(title: "收货人", value: address.name)
                    orderRow(title: "手机号", value: address.phone)
                    orderRow(title: "地址", value: address.detail, multiline: true)
                }
            } else {
                infoGroup(title: "收货信息") {
                    Text("用户还没有填写地址，暂时不能发货。")
                        .font(.system(size: 14))
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
                infoGroup(title: "物流信息") {
                    orderRow(title: "物流单号", value: trackingNumber)
                }
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
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private func infoGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
            content()
        }
        .padding(16)
        .background(Color.black.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func orderRow(title: String, value: String, multiline: Bool = false) -> some View {
        HStack(alignment: multiline ? .top : .center) {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: multiline)
        }
    }

    private func statusPill(text: String, style: AdminPillStyle) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(style.background)
            .foregroundStyle(style.foreground)
            .clipShape(Capsule())
    }
}

private enum AdminPillStyle {
    case light
    case dark
    case warning

    var background: Color {
        switch self {
        case .light: return Color.black.opacity(0.06)
        case .dark: return Color.black
        case .warning: return Color.orange.opacity(0.16)
        }
    }

    var foreground: Color {
        switch self {
        case .light: return Color.black
        case .dark: return Color.white
        case .warning: return Color.orange
        }
    }
}
