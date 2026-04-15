//
//  SupabaseOrderRepository.swift
//  waziIOS
//
//  Created by Codex on 2026/4/16.
//

import Foundation

struct SupabaseOrderRepository: OrderRepository {
    let product = ProductSnapshot(
        name: "好一点的袜子",
        subtitle: "高品质袜子",
        packDescription: "5双装",
        description: "一款足够好的基础袜，减少选择，减少犹豫。",
        price: 15
    )

    let inventoryCount = 88

    private let client = SupabaseRESTClient()

    func loadOrders() async throws -> [SockOrder] {
        let rows: [SupabaseOrderRow] = try await client.request(
            path: "rest/v1/orders?select=*&order=created_at.desc",
            method: "GET"
        )
        return rows.map { $0.toDomain() }
    }

    func createPaidOrder(color: SockColor, existingOrdersCount: Int) async throws -> SockOrder {
        let order = SockOrder(
            id: UUID(),
            orderNumber: "\(currentDatePrefix())-\(existingOrdersCount + 10001)",
            color: color,
            amount: product.price,
            packDescription: product.packDescription,
            createdAt: Date(),
            paymentState: .paid,
            shippingState: .waitingForAddress,
            address: nil,
            trackingNumber: nil
        )

        let rows: [SupabaseOrderRow] = try await client.request(
            path: "rest/v1/orders",
            method: "POST",
            body: [SupabaseOrderMutation.from(order: order)],
            extraHeaders: ["Prefer": "return=representation"]
        )

        return rows.first?.toDomain() ?? order
    }

    func saveAddress(orderID: UUID, address: ShippingAddress) async throws {
        let _: [SupabaseOrderRow] = try await client.request(
            path: "rest/v1/orders?id=eq.\(orderID.uuidString.lowercased())",
            method: "PATCH",
            body: SupabaseAddressMutation(
                receiver_name: address.name,
                receiver_phone: address.phone,
                receiver_address: address.detail,
                shipping_state: ShippingState.readyToShip.rawValue
            ),
            extraHeaders: ["Prefer": "return=representation"]
        )
    }

    func markShipped(orderID: UUID, trackingNumber: String) async throws {
        let _: [SupabaseOrderRow] = try await client.request(
            path: "rest/v1/orders?id=eq.\(orderID.uuidString.lowercased())",
            method: "PATCH",
            body: SupabaseShippingMutation(
                tracking_number: trackingNumber.isEmpty ? "待补充" : trackingNumber,
                shipping_state: ShippingState.shipped.rawValue
            ),
            extraHeaders: ["Prefer": "return=representation"]
        )
    }

    private func currentDatePrefix() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }
}

private struct SupabaseRESTClient {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    func request<Response: Decodable>(
        path: String,
        method: String,
        extraHeaders: [String: String] = [:]
    ) async throws -> Response {
        try await request(path: path, method: method, body: Optional<String>.none, extraHeaders: extraHeaders)
    }

    func request<Response: Decodable, Body: Encodable>(
        path: String,
        method: String,
        body: Body? = nil,
        extraHeaders: [String: String] = [:]
    ) async throws -> Response {
        guard let baseURL = URL(string: SupabaseConfig.projectURL) else {
            throw SupabaseError.invalidConfiguration
        }

        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw SupabaseError.invalidConfiguration
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        for (key, value) in extraHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "unknown"
            throw SupabaseError.httpFailure(statusCode: httpResponse.statusCode, message: message)
        }

        return try decoder.decode(Response.self, from: data)
    }
}

private struct SupabaseOrderRow: Decodable {
    let id: UUID
    let order_number: String
    let color: String
    let amount: Int
    let pack_description: String
    let payment_state: String
    let shipping_state: String
    let receiver_name: String?
    let receiver_phone: String?
    let receiver_address: String?
    let tracking_number: String?
    let created_at: Date

    func toDomain() -> SockOrder {
        SockOrder(
            id: id,
            orderNumber: order_number,
            color: SockColor(rawValue: color) ?? .black,
            amount: amount,
            packDescription: pack_description,
            createdAt: created_at,
            paymentState: PaymentState(rawValue: payment_state) ?? .paid,
            shippingState: ShippingState(rawValue: shipping_state) ?? .pending,
            address: makeAddress(),
            trackingNumber: tracking_number
        )
    }

    private func makeAddress() -> ShippingAddress? {
        guard let receiver_name, let receiver_phone, let receiver_address else {
            return nil
        }

        return ShippingAddress(name: receiver_name, phone: receiver_phone, detail: receiver_address)
    }
}

private struct SupabaseOrderMutation: Encodable {
    let id: UUID
    let order_number: String
    let product_name: String
    let color: String
    let amount: Int
    let pack_description: String
    let payment_state: String
    let shipping_state: String
    let created_at: Date

    static func from(order: SockOrder) -> SupabaseOrderMutation {
        SupabaseOrderMutation(
            id: order.id,
            order_number: order.orderNumber,
            product_name: "好一点的袜子",
            color: order.color.rawValue,
            amount: order.amount,
            pack_description: order.packDescription,
            payment_state: order.paymentState.rawValue,
            shipping_state: order.shippingState.rawValue,
            created_at: order.createdAt
        )
    }
}

private struct SupabaseAddressMutation: Encodable {
    let receiver_name: String
    let receiver_phone: String
    let receiver_address: String
    let shipping_state: String
}

private struct SupabaseShippingMutation: Encodable {
    let tracking_number: String
    let shipping_state: String
}

private enum SupabaseError: Error {
    case invalidConfiguration
    case invalidResponse
    case httpFailure(statusCode: Int, message: String)
}
