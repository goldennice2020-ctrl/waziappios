//
//  OrderRepository.swift
//  waziIOS
//
//  Created by Codex on 2026/4/16.
//

import Foundation

protocol OrderRepository {
    var product: ProductSnapshot { get }
    var inventoryCount: Int { get }

    func seedOrders() -> [SockOrder]
    func createPaidOrder(color: SockColor, existingOrdersCount: Int) -> SockOrder
}

struct LocalOrderRepository: OrderRepository {
    let product = ProductSnapshot(
        name: "好一点的袜子",
        subtitle: "高品质袜子",
        packDescription: "5双装",
        description: "一款足够好的基础袜，减少选择，减少犹豫。",
        price: 15
    )

    let inventoryCount = 88

    func seedOrders() -> [SockOrder] {
        let prefix = currentDatePrefix()

        return [
            SockOrder(
                id: UUID(),
                orderNumber: "\(prefix)-10001",
                color: .black,
                amount: product.price,
                packDescription: product.packDescription,
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
                amount: product.price,
                packDescription: product.packDescription,
                createdAt: Date().addingTimeInterval(-43_200),
                paymentState: .paid,
                shippingState: .waitingForAddress,
                address: nil,
                trackingNumber: nil
            )
        ]
    }

    func createPaidOrder(color: SockColor, existingOrdersCount: Int) -> SockOrder {
        let nextIndex = existingOrdersCount + 10001

        return SockOrder(
            id: UUID(),
            orderNumber: "\(currentDatePrefix())-\(nextIndex)",
            color: color,
            amount: product.price,
            packDescription: product.packDescription,
            createdAt: Date(),
            paymentState: .paid,
            shippingState: .waitingForAddress,
            address: nil,
            trackingNumber: nil
        )
    }

    private func currentDatePrefix() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }
}
