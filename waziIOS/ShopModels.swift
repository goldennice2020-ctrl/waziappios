//
//  ShopModels.swift
//  waziIOS
//
//  Created by Codex on 2026/4/16.
//

import SwiftUI
import Combine

enum SockColor: String, CaseIterable, Identifiable, Codable {
    case black
    case white
    case gray

    var id: String { rawValue }

    var name: String {
        switch self {
        case .black: return "黑色"
        case .white: return "白色"
        case .gray: return "灰色"
        }
    }

    var tint: Color {
        switch self {
        case .black: return Color(red: 0.12, green: 0.12, blue: 0.13)
        case .white: return Color.white
        case .gray: return Color(red: 0.63, green: 0.65, blue: 0.68)
        }
    }

    var stroke: Color {
        switch self {
        case .white: return Color.black.opacity(0.12)
        default: return Color.clear
        }
    }

    var description: String {
        switch self {
        case .black: return "低调耐看，适合任何场景"
        case .white: return "干净清爽，日常最好搭"
        case .gray: return "克制柔和，介于黑白之间"
        }
    }
}

struct ShippingAddress: Hashable, Codable {
    var name: String = ""
    var phone: String = ""
    var detail: String = ""
}

enum PreviewData {
    @MainActor static let store = ShopStore()
}

enum PaymentState: String, Codable {
    case pending = "待人工确认"
    case paid = "已支付"
}

enum ShippingState: String, Codable {
    case pending = "待处理"
    case waitingForAddress = "未填写地址"
    case readyToShip = "待发货"
    case shipped = "已发货"
}

struct SockOrder: Identifiable, Hashable, Codable {
    let id: UUID
    let orderNumber: String
    let color: SockColor
    let amount: Int
    let packDescription: String
    let createdAt: Date
    var paymentState: PaymentState
    var shippingState: ShippingState
    var address: ShippingAddress?
    var trackingNumber: String?

    var hasAddress: Bool {
        address != nil
    }

    var statusText: String {
        switch shippingState {
        case .pending:
            return "待人工确认"
        case .waitingForAddress:
            return "已支付 / 待填写地址"
        case .readyToShip:
            return "已支付 / 待发货"
        case .shipped:
            return "已发货"
        }
    }
}

@MainActor
final class ShopStore: ObservableObject {
    let productName = "好一点的袜子"
    let subtitle = "高品质袜子"
    let packDescription = "5双装"
    let productDescription = "一款足够好的基础袜，减少选择，减少犹豫。"
    let price = 15

    @Published var inventoryCount = 88
    @Published var orders: [SockOrder] = []

    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let prefix = formatter.string(from: Date())

        orders = [
            SockOrder(
                id: UUID(),
                orderNumber: "\(prefix)-10001",
                color: .black,
                amount: 15,
                packDescription: "5双装",
                createdAt: Date().addingTimeInterval(-86_400),
                paymentState: .paid,
                shippingState: .readyToShip,
                address: ShippingAddress(name: "张三", phone: "13800008888", detail: "上海市静安区南京西路 188 号"),
                trackingNumber: nil
            ),
            SockOrder(
                id: UUID(),
                orderNumber: "\(prefix)-10002",
                color: .white,
                amount: 15,
                packDescription: "5双装",
                createdAt: Date().addingTimeInterval(-43_200),
                paymentState: .paid,
                shippingState: .waitingForAddress,
                address: nil,
                trackingNumber: nil
            )
        ]
    }

    var orderCount: Int {
        orders.count
    }

    var totalRevenue: Int {
        orders.filter { $0.paymentState == .paid }.reduce(0) { $0 + $1.amount }
    }

    var pendingAddressOrders: [SockOrder] {
        orders.filter { $0.address == nil }
    }

    func createPaidOrder(color: SockColor) -> SockOrder {
        if inventoryCount > 0 {
            inventoryCount -= 1
        }

        let nextIndex = (orders.count + 10001)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let prefix = formatter.string(from: Date())

        let order = SockOrder(
            id: UUID(),
            orderNumber: "\(prefix)-\(nextIndex)",
            color: color,
            amount: price,
            packDescription: packDescription,
            createdAt: Date(),
            paymentState: .paid,
            shippingState: .waitingForAddress,
            address: nil,
            trackingNumber: nil
        )

        orders.insert(order, at: 0)
        return order
    }

    func saveAddress(for orderID: UUID, address: ShippingAddress) {
        guard let index = orders.firstIndex(where: { $0.id == orderID }) else { return }
        orders[index].address = address
        orders[index].shippingState = .readyToShip
    }

    func markShipped(orderID: UUID, trackingNumber: String) {
        guard let index = orders.firstIndex(where: { $0.id == orderID }) else { return }
        orders[index].trackingNumber = trackingNumber.isEmpty ? "待补充" : trackingNumber
        orders[index].shippingState = .shipped
    }

    func order(for id: UUID) -> SockOrder? {
        orders.first(where: { $0.id == id })
    }
}
