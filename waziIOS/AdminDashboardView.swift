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
                    orderCard(order: order)
                }
            }
            .padding(24)
        }
        .background(Color(red: 0.96, green: 0.95, blue: 0.92).ignoresSafeArea())
        .alert("提示", isPresented: errorAlertBinding) {
            Button("知道了", role: .cancel) {
                store.errorMessage = nil
            }
        } message: {
            Text(store.errorMessage ?? "")
        }
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

    private func orderCard(order: SockOrder) -> some View {
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

            Button {
                Task {
                    _ = await store.markShipped(orderID: order.id, trackingNumber: "SF\(order.orderNumber.suffix(6))")
                }
            } label: {
                Text(order.shippingState == .shipped ? "已发货" : "修改发货状态")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(order.shippingState == .shipped ? Color.gray.opacity(0.18) : Color.black)
                    .foregroundStyle(order.shippingState == .shipped ? Color.black.opacity(0.5) : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .disabled(order.shippingState == .shipped || !order.hasAddress)
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
