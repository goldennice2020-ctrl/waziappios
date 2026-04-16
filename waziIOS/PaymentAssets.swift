//
//  PaymentAssets.swift
//  waziIOS
//
//  Created by Codex on 2026/4/16.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum PaymentAssetNames {
    static let alipayQRCode = "AlipayQRCode"
}

enum PaymentAssets {
    static var hasAlipayQRCode: Bool {
        #if canImport(UIKit)
        return UIImage(named: PaymentAssetNames.alipayQRCode) != nil
        #else
        return false
        #endif
    }
}
