//
//  ClipboardPopupView.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/7.
//

import SwiftUI
import AppKit

struct ClipboardItem: Identifiable, Equatable {
    var id = UUID()
    var appName: String
    var timestamp: TimeInterval
    var content: String
    var appIconURL: URL
    var type: ClipboardItemType
    var sizeInBytes: Int {
        return Data(content.utf8).count
    }
    var formattedTime: String {
            let currentTime = Date().timeIntervalSince1970
            let difference = currentTime - timestamp
            let minute = 60.0
            let hour = minute * 60
            let day = hour * 24
            
            if difference < minute {
                return "刚刚"
            } else if difference < hour {
                return "\(Int(difference/minute)) 分钟前"
            } else if difference < day {
                return "\(Int(difference/hour)) 小时前"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.string(from: Date(timeIntervalSince1970: timestamp))
            }
        }
    var displayString: String {
        switch type {
        case .text, .link, .richText:
            return "\(sizeInBytes) 个字符"
        case .image, .file:
            if sizeInBytes < 1_000_000 {
                return "\(sizeInBytes/1_000) KB"
            } else {
                return "\(sizeInBytes/1_000_000) MB"
            }
        case .multipleFiles:
            let fileCount = content.components(separatedBy: ",").count
            return "\(fileCount) 个文件"
        }
    }

    
    var displayContent: some View {
        switch type {
        case .text:
            return AnyView(Text(content))
        case .image:
            return AnyView(ClipboardItemImageView(imagePath: content))
        case .file:
            return AnyView(ClipboardItemFileIconView(filePath: content))
        case .multipleFiles:
                return AnyView(ClipboardItemMultipleFilesIconView(filePath: content))
        default:
            return AnyView(Text(content))
        }
    }


    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        return lhs.id == rhs.id
    }
}



extension URL {
    func appIcon() -> Image {
        let icon = NSWorkspace.shared.icon(forFile: self.path)
        return Image(nsImage: icon)
    }
}


class ScrollViewManager: ObservableObject {
    @Published var offset: CGFloat = 0
}

struct ClipboardPopupView: View {
    @ObservedObject var clipboardManager = ClipboardManager()
    @State private var selectedItem: UUID?
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(clipboardManager.items) { item in
                            ClipboardItemView(item: item)
                                .id(item.id)
                                .onTapGesture {
                                    withAnimation {
                                        selectedItem = item.id
                                        proxy.scrollTo(item.id, anchor: .center)
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedItem == item.id ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                    .padding()
                }
            .background(BlurView())
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    @AppStorage("EnterInClipboardKey") var enterInClipboard: String = "copy"
                    
                    switch event.keyCode {
                    case 123: // Left arrow
                        self.moveSelection(by: -1, with: proxy)
                        return nil // 不再返回事件
                    case 124: // Right arrow
                        self.moveSelection(by: 1, with: proxy)
                        return nil // 不再返回事件
                    case 36: // Return key
                        if let itemToCopy = clipboardManager.items.first(where: { $0.id == selectedItem }) {
                            PasteboardHelper.shared.copyToPasteboard(itemToCopy.content, type: itemToCopy.type)
                            if enterInClipboard == "paste" {
                                PasteboardHelper.shared.pasteToCurrentFocusedElement()
                            }
                            NotificationCenter.default.post(name: NSNotification.Name("HideClipboardPopup"), object: nil)
                        }
                        return nil
                    case 53:
                        NotificationCenter.default.post(name: NSNotification.Name("HideClipboardPopup"), object: nil)
                        return nil
                    case 51: // Delete key
                        if let indexToDelete = clipboardManager.items.firstIndex(where: { $0.id == selectedItem }) {
                            clipboardManager.deleteItem(with: clipboardManager.items[indexToDelete].id)
                                        
                            if clipboardManager.items.isEmpty {
                                selectedItem = nil
                            } else if indexToDelete == 0 { // If the first item is deleted
                                selectedItem = clipboardManager.items.first?.id
                            } else {
                                let newSelectionIndex = min(indexToDelete, clipboardManager.items.count - 1)
                                selectedItem = clipboardManager.items[newSelectionIndex].id
                            }
                        }
                        return nil
                    default:
                        break
                    }
                    return event
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ResetClipboardSelection"))) { _ in
                selectedItem = clipboardManager.items.first?.id
                proxy.scrollTo(clipboardManager.items.first?.id, anchor: .center)
            }
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                    // 当垂直滚轮移动时，改变水平滚动偏移量
                    self.scrollOffset += event.scrollingDeltaY
                    
                    // 根据您的需要调整此值以更改滚动速度
                    let scrollSpeed: CGFloat = 5
                    
                    if abs(self.scrollOffset) > scrollSpeed {
                        if self.scrollOffset > 0 {
                            self.moveSelection(by: 1, with: proxy)
                        } else {
                            self.moveSelection(by: -1, with: proxy)
                        }
                        self.scrollOffset = 0
                    }
                    
                    return nil // 阻止默认的事件处理
                }
            }
        }
    }

    func moveSelection(by delta: Int, with proxy: ScrollViewProxy) {
        guard let currentItem = clipboardManager.items.first(where: { $0.id == selectedItem }),
              let currentIndex = clipboardManager.items.firstIndex(of: currentItem) else { return }

        let targetIndex = min(max(currentIndex + delta, 0), clipboardManager.items.count - 1)
        selectedItem = clipboardManager.items[targetIndex].id
        withAnimation {
            proxy.scrollTo(selectedItem!, anchor: .center)
        }
    }
}


struct BlurView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.material = .sidebar
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

struct ClipboardPopupView_Previews: PreviewProvider {
    static var previews: some View {
        ClipboardPopupView()
    }
}
