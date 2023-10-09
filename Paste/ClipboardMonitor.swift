//
//  ClipboardMonitor.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/9.
//

import Cocoa

extension NSNotification.Name {
    public static let NSPasteboardDidChange: NSNotification.Name = .init(rawValue: "pasteboardDidChangeNotification")
}

class ClipboardMonitor: NSObject, NSApplicationDelegate {
    var timer: Timer!
    let pasteboard: NSPasteboard = .general
    var lastChangeCount: Int = 0

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 1. 开始监听
        startListening()

        // 2. 注册通知观察者
        NotificationCenter.default.addObserver(self, selector: #selector(handlePasteboardChange), name: .NSPasteboardDidChange, object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        timer.invalidate()
    }

    func startListening() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (t) in
            if self.lastChangeCount != self.pasteboard.changeCount {
                self.lastChangeCount = self.pasteboard.changeCount
                NotificationCenter.default.post(name: .NSPasteboardDidChange, object: self.pasteboard)
            }
        }
    }

    @objc func handlePasteboardChange(_ notification: Notification) {
        // 获取最新的剪贴板内容
        if let newType = PasteboardHelper.shared.getCurrentType() {
            print("New item type in pasteboard: '\(newType)'")
            // 在这里您可以处理新的剪贴板内容，例如保存到数据库或更新UI
        }
        if let newItem = PasteboardHelper.shared.getCurrentContent() {
            print("New item in pasteboard: '\(newItem)'")
            // 在这里您可以处理新的剪贴板内容，例如保存到数据库或更新UI
        }
    }
}
