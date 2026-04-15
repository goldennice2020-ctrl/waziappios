//
//  SupabaseConfig.swift
//  waziIOS
//
//  Created by Codex on 2026/4/16.
//

import Foundation

enum SupabaseConfig {
    static let projectURL = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""
    static let anonKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? ""

    static var isConfigured: Bool {
        !projectURL.isEmpty && !anonKey.isEmpty
    }
}

enum BackendMode: String {
    case localMock
    case supabase
}

enum AppEnvironment {
    static var backendMode: BackendMode {
        SupabaseConfig.isConfigured ? .supabase : .localMock
    }
}
