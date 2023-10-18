//
//  AppDelegate.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/16.
//
import SwiftUI
import KeyboardShortcuts

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem?
    private let mainViewController = MainViewController()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建状态栏图标
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusBarItem?.button {
            if let image = NSImage(named: "AppIcon") {
                    image.size = NSSize(width: 16, height: 16)  // 调整为所需的大小
                    button.image = image
                }
            button.action = #selector(statusBarButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .leftMouseUp {
            // 左键点击逻辑
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "打开主窗口", action: #selector(openMainWindow), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: ""))
            
            statusBarItem?.menu = menu
            statusBarItem?.popUpMenu(menu)
            
            // 清除，使按钮下次可以直接触发action
            statusBarItem?.menu = nil
            }
        }
    
    @objc func openMainWindow() {
        if !mainViewController.window!.isVisible {
            mainViewController.showWindow(nil)
        }
        mainViewController.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
