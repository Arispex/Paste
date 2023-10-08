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
        HStack {
            Text("开关剪贴板")
            Spacer()
            KeyboardShortcuts.Recorder(for: .toggleClipboard)  // `toggleSidebar` 是我们将在下一步定义的快捷键名称
        }
        .padding(20)
    }
}
