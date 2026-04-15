//
//  SuccessView.swift
//  waziIOS
//
//  Created by Eric on 2026/4/16.
//

import SwiftUI

struct SuccessView: View {
    @EnvironmentObject private var store: ShopStore
    @Environment(\.dismiss) private var dismiss

    let orderID: UUID

    var body: some View {
        ScrollView {
            if let order = store.order(for: orderID) {
                VStack(alignment: .leading, spacing: 22) {
                    Text("订单页")
                        .font(.system(size: 30, weight: .bold, design: .serif))

                    heroCard(order: order)
                    timelineCard(order: order)
                    infoSection(order: order)
                    addressSection(order: order)

                    Button {
                        dismiss()
                    } label: {
                        Text("完成")
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
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private func heroCard(order: SockOrder) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.black, Color.black.opacity(0.82)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    statusChip(text: order.statusText)
                    Spacer()
                    Text(order.color.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.52))
                        .kerning(1.2)
                }

                HStack(alignment: .bottom, spacing: 18) {
                    SockDisplayScene(primaryColor: order.color, secondaryColor: nil, layout: .product)
                        .frame(width: 126, height: 148)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.product.name)
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundStyle(.white)

                        Text("订单已生成，可以在这里查看状态和收货信息。")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.72))
                            .lineSpacing(3)
                    }
                }
            }
            .padding(24)
        }
        .frame(height: 272)
    }

    private func timelineCard(order: SockOrder) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("订单进度")
                .font(.system(size: 18, weight: .semibold))

            timelineRow(title: "支付完成", subtitle: "你已完成付款确认", isActive: true)
            timelineRow(title: "地址已提交", subtitle: order.address == nil ? "等待填写收货信息" : "收货信息已保存", isActive: order.address != nil)
            timelineRow(title: "商家发货", subtitle: order.shippingState == .shipped ? "物流单号已生成" : "等待商家处理", isActive: order.shippingState == .shipped)
        }
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func infoSection(order: SockOrder) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("订单信息")
                .font(.system(size: 18, weight: .semibold))

            detailRow(title: "订单号", value: order.orderNumber)
            detailRow(title: "商品", value: store.product.name)
            detailRow(title: "颜色", value: order.color.name)
            detailRow(title: "套餐", value: order.packDescription)
            detailRow(title: "支付金额", value: "¥\(order.amount)")
            detailRow(title: "支付状态", value: order.paymentState.rawValue)
            detailRow(title: "订单状态", value: order.statusText)
        }
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func addressSection(order: SockOrder) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("收货信息")
                .font(.system(size: 18, weight: .semibold))

            if let address = order.address {
                Text(address.name)
                    .fontWeight(.medium)
                Text(address.phone)
                Text(address.detail)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
            }

            if let trackingNumber = order.trackingNumber {
                Divider()
                detailRow(title: "物流单号", value: trackingNumber)
            }
        }
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func timelineRow(title: String, subtitle: String, isActive: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(isActive ? Color.black : Color.black.opacity(0.14))
                .frame(width: 12, height: 12)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }

    private func statusChip(text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.14))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        SuccessView(orderID: PreviewData.store.orders[0].id)
            .environmentObject(PreviewData.store)
    }
}
