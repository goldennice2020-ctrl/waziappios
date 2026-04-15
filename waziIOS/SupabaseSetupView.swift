//
//  SupabaseSetupView.swift
//  waziIOS
//
//  Created by Codex on 2026/4/16.
//

import SwiftUI

struct SupabaseSetupView: View {
    private let steps = [
        "在 Supabase 后台创建项目",
        "打开 SQL Editor，执行仓库里的 supabase/schema.sql",
        "回到 Xcode，打开 Product -> Scheme -> Edit Scheme",
        "在 Run -> Arguments -> Environment Variables 中填写 SUPABASE_URL 和 SUPABASE_ANON_KEY",
        "重新运行 App，首页状态会从“本地演示数据”切换到“Supabase 已连接”"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Supabase 配置指南")
                    .font(.system(size: 30, weight: .bold, design: .serif))

                statusCard
                envCard
                fileCard
                stepsCard
            }
            .padding(24)
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
        .navigationTitle("配置指南")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(AppEnvironment.backendLabel, systemImage: AppEnvironment.backendMode == .supabase ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppEnvironment.backendMode == .supabase ? Color.green : Color.orange)

            Text(AppEnvironment.backendMode == .supabase ? "当前已经检测到 Supabase 配置，应用会读取真实订单。" : "当前还没有检测到完整 Supabase 配置，应用会继续使用本地演示数据。")
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var envCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("环境变量检查")
                .font(.system(size: 18, weight: .semibold))

            envRow(title: "SUPABASE_URL", isReady: !SupabaseConfig.projectURL.isEmpty)
            envRow(title: "SUPABASE_ANON_KEY", isReady: !SupabaseConfig.anonKey.isEmpty)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var fileCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("你会用到的文件")
                .font(.system(size: 18, weight: .semibold))

            setupFileRow(name: "supabase/schema.sql", note: "Supabase 数据表与 RLS 策略")
            setupFileRow(name: "Config/Supabase.xcconfig.example", note: "Xcode 配置模板")
            setupFileRow(name: "waziIOS/SupabaseOrderRepository.swift", note: "Supabase REST 数据仓储")
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("接入步骤")
                .font(.system(size: 18, weight: .semibold))

            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 24, height: 24)
                        .background(Color.black)
                        .foregroundStyle(.white)
                        .clipShape(Circle())

                    Text(step)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func envRow(title: String, isReady: Bool) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
            Spacer()
            Text(isReady ? "已配置" : "未配置")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isReady ? Color.green : Color.orange)
        }
    }

    private func setupFileRow(name: String, note: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
            Text(note)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        SupabaseSetupView()
    }
}
