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

                    statusBanner(order: order)
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

    private func statusBanner(order: SockOrder) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("订单状态")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.72))

            Text(order.statusText)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(.white)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
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

    private func detailRow(title: String, value: String) -> some View {
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
        SuccessView(orderID: PreviewData.store.orders[0].id)
            .environmentObject(PreviewData.store)
    }
}
