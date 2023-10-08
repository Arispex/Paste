//
//  GeneralSettingsView.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/7.
//

import Foundation
import SwiftUI

struct SwitchToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Button(action: { configuration.isOn.toggle() }) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? Color.blue : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 30, alignment: .center)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .shadow(radius: 2, x: 0, y: 2)
                            .padding(.all, 4)
                            .offset(x: configuration.isOn ? 10 : -10)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0.0, y: 2)
                    .animation(.easeInOut(duration: 0.2))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

extension String {
    // 剪贴板监听
    static let clipboardMonitor = "ClipboardMonitorKey"
}


struct GeneralSettingsView: View {
    @AppStorage("ClipboardMonitorKey") var clipboardMonitor: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section: 通用设置
            Text("通用设置")
                .foregroundColor(.gray)
                .font(.headline)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Spacer()
                    Toggle("启用", isOn: $clipboardMonitor)
                                    .toggleStyle(SwitchToggleStyle())
                    Text(clipboardMonitor ? "正在监听剪贴板中的新内容" : "暂未监听剪贴板中的内容")
                        .foregroundStyle(.gray)
                        .padding()
                }
            }
        }
        .padding(50)  // 添加一些周围的内边距，使内容不会贴近视图的边缘
    }
}
