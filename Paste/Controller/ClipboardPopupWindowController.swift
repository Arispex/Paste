//
//  ClipboardPopupWindowController.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/7.import SwiftUI
import AppKit
import SwiftUI

class ClipboardPopupWindowController: NSWindowController {
    private var hasRegisteredObserver = false

    
    convenience init() {
        let screenHeight = NSScreen.main?.frame.height ?? 800
        let windowHeight: CGFloat = 400
        let windowY = 0 - windowHeight

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: windowY, width: NSScreen.main?.frame.width ?? 800, height: windowHeight),
            styleMask: [.borderless, .resizable, .nonactivatingPanel],
            backing: .buffered, defer: false)
        
        // 设置NSPanel的属性
        panel.level = .mainMenu
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        panel.isReleasedWhenClosed = false
        panel.hasShadow = true

        let hostingView = NSHostingView(rootView: ClipboardPopupView())
        panel.contentView = hostingView

        self.init(window: panel)

        NotificationCenter.default.addObserver(self, selector: #selector(hideWindowAnimated), name: NSNotification.Name("HideClipboardPopup"), object: nil)
    }


    func showWindowAnimated() {
        if !hasRegisteredObserver {
            NotificationCenter.default.addObserver(self, selector: #selector(hideWindowAnimated), name: NSApplication.willResignActiveNotification, object: nil)
            hasRegisteredObserver = true
        }
        guard let window = self.window else { return }
        
        NotificationCenter.default.post(name: NSNotification.Name("ResetClipboardSelection"), object: nil)

        // 从下方开始
        let startFrame = NSRect(x: 0, y: -window.frame.height, width: window.frame.width, height: window.frame.height)
        // 最终位置
        let endFrame = NSRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height)
        
        window.setFrame(startFrame, display: true)
        window.makeKeyAndOrderFront(nil)
        
        NSApp.activate(ignoringOtherApps: true)
        
        // 使用动画更改窗口位置
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.1
            window.animator().setFrame(endFrame, display: true)
        })
    }

    @objc func hideWindowAnimated() {
        guard let window = self.window else { return }
        
        // 最终位置
        let endFrame = NSRect(x: 0, y: -window.frame.height, width: window.frame.width, height: window.frame.height)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.1
            window.animator().setFrame(endFrame, display: true)
        }, completionHandler: {
            window.orderOut(nil)
        })
    }
}

