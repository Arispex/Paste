//
//  PasteApp.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/7.
//

import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleClipboard = Self("toggleClipboard")
}

@main
struct PasteApp: App {
    @NSApplicationDelegateAdaptor(ClipboardMonitor.self) var clipboardMonitor
    private let clipboardWindowController = ClipboardPopupWindowController()

    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    // 监听快捷键事件
                    KeyboardShortcuts.onKeyUp(for: .toggleClipboard) {
                        if let window = clipboardWindowController.window {
                            if window.isVisible {
                                withAnimation {
                                    clipboardWindowController.hideWindowAnimated()
                                }
                            } else {
                                withAnimation {
                                    clipboardWindowController.showWindowAnimated()
                                }
                            }
                        }
                    }
                }
        }
    }
}




