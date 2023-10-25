//
//  ShortcutSettingsView.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/7.
//

import SwiftUI
import KeyboardShortcuts

struct ShortcutSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section: 自定义快捷键
            Text("自定义快捷键")
                .foregroundColor(.gray)
                .font(.headline)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("开关剪贴板")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .toggleClipboard)
                }
            }
            
            // Section: 固定快捷键
            Text("固定快捷键")
                .foregroundColor(.gray)
                .font(.headline)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("切换")
                    Spacer()
                    Image(systemName: "arrow.left").foregroundColor(.blue)
                    Image(systemName: "arrow.right").foregroundColor(.blue)
                    Image(systemName: "arrow.up").foregroundColor(.blue)
                    Image(systemName: "arrow.down").foregroundColor(.blue)
                    Image(systemName: "computermouse").foregroundColor(.blue)
                        .padding(.leading, 5) // 添加一些间距使图标不会紧挨在一起
                }
                HStack {
                    Text("关闭")
                    Spacer()
                    Text("ESC").foregroundColor(.blue)
                }
                HStack {
                    Text("复制")
                    Spacer()
                    Image(systemName: "command").foregroundColor(.blue)
                    Text("C").foregroundColor(.blue)
                }
                HStack {
                    Text("复制为纯文本")
                    Spacer()
                    Image(systemName: "command").foregroundColor(.blue)
                    Image(systemName: "shift").foregroundColor(.blue)
                    Text("C").foregroundColor(.blue)
                }
                HStack {
                    Text("复制或粘贴")
                    Spacer()
                    Image(systemName: "return").foregroundColor(.blue)
                }
                HStack {
                    Text("复制或粘贴纯文本")
                    Spacer()
                    Image(systemName: "shift").foregroundColor(.blue)
                    Image(systemName: "return").foregroundColor(.blue)
                }
                HStack {
                    Text("删除")
                    Spacer()
                    Image(systemName: "delete.left").foregroundColor(.blue)
                }
            }
        }
        .padding(50)  // 添加一些周围的内边距，使内容不会贴近视图的边缘
    }
}
