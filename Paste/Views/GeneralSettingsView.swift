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
    // 复制时声音提醒
    static let soundReminderWhenCopying = "SoundReminderWhenCopyingKey"
    // 提示音
    static let sound = "SoundKey"
    // 剪贴板中回车
    static let enterInClipboard = "EnterInClipboardKey"
}


struct GeneralSettingsView: View {
    @AppStorage("ClipboardMonitorKey") var clipboardMonitor: Bool = false
    @AppStorage("SoundReminderWhenCopyingKey") var soundReminderWhenCopying: Bool = false
    @AppStorage("SoundKey") var sound: String = "Tink"
    @AppStorage("EnterInClipboardKey") var enterInClipboard: String = "copy"
    
    let sounds = ["Tink", "Frog", "Bottle", "Purr"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section: 通用设置
            Text("通用设置")
                .foregroundColor(.gray)
                .font(.headline)
                .padding(.bottom, 10)
            
            HStack {
                Toggle(isOn: $clipboardMonitor) {
                    Text("启用")
                }
                .toggleStyle(SwitchToggleStyle())
            }
            
            Divider()
                .padding(.bottom, 20)
            
            // Section: 复制&粘贴
            Text("复制&粘贴")
                .foregroundColor(.gray)
                .font(.headline)
                .padding(.bottom, 10)
            
            Toggle("复制时声音提醒", isOn: $soundReminderWhenCopying)
                .toggleStyle(SwitchToggleStyle())
                .padding(.bottom, 20)
            
            HStack {
                Text("提示音")
                    .frame(alignment: .leading)
                Spacer()
                Picker("", selection: $sound) {
                    ForEach(sounds, id: \.self) { sound in
                        Text(sound).tag(sound)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)  // 调整宽度以适应你的需求
            }
            
            Divider()
                .padding(.bottom, 20)
            
            // Section: 复制&粘贴
            Text("剪贴板")
                .foregroundColor(.gray)
                .font(.headline)
                .padding(.bottom, 10)
            
            HStack {
                Text("回车")
                    .frame(alignment: .leading)
                Spacer()
                Picker("", selection: $enterInClipboard) {
                    Text("复制").tag("copy")
                    Text("粘贴").tag("paste")
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)  // 调整宽度以适应你的需求
            }
        }
        .padding(EdgeInsets(top: 20, leading: 50, bottom: 20, trailing: 50))  // 优化了内边距
    }
}

