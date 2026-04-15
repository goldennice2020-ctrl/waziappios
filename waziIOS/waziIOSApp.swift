//
//  waziIOSApp.swift
//  waziIOS
//
//  Created by Eric on 2026/4/15.
//

import SwiftUI

@main
struct waziIOSApp: App {
    @StateObject private var store = ShopStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
