//
//  MainViewController.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/18.
//
import SwiftUI

class MainViewController: NSWindowController {
    var contentView: some View {
        MainView()
    }

    init() {
        let windowWidth: CGFloat = 780
        let windowHeight: CGFloat = 550
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable, .fullSizeContentView], // 移除 .resizable
            backing: .buffered,
            defer: false)
        super.init(window: window)
        window.center()
        window.contentView = NSHostingView(rootView: contentView)

        // 设置最小和最大窗口大小为相同的大小，以此来锁定窗口大小。
        window.minSize = NSSize(width: windowWidth, height: windowHeight)
        window.maxSize = NSSize(width: windowWidth, height: windowHeight)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
