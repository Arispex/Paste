//
//  ClipboardPopupView.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/7.
//

import SwiftUI
import AppKit
import Combine

struct ClipboardItem: Identifiable, Equatable {
    var id = UUID()
    var appName: String
    var timestamp: TimeInterval
    var content: String
    var appIconURL: URL
    var type: ClipboardItemType
    var sizeInBytes: Int {
            switch type {
            case .text, .link, .richText:
                return Data(content.utf8).count
            case .image, .file:
                return fileSize(forPath: content) ?? 0
            case .multipleFiles:
                let paths = content.components(separatedBy: ",")
                return paths.count
            }
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
    
    var timeUpdater = PassthroughSubject<Void, Never>()
    
    func startUpdating() {
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                self.timeUpdater.send()
            }
        }


    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    private func fileSize(forPath path: String) -> Int? {
        let fileURL = URL(fileURLWithPath: path)
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let size = fileAttributes[.size] as? Int {
                return size
            }
        } catch {
            print("Error getting file size: \(error)")
        }
        return nil
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
    @State private var selectedCategory: ClipboardItemType? {
        didSet {
            // 当选中一个新类别时，将选中的项设置为该类别的第一个条目
            if let firstItem = filteredItems.first {
                selectedItem = firstItem.id
            } else {
                selectedItem = nil
            }
        }
    }
    
    @State private var lastTapTime = Date()
    @AppStorage("EnterInClipboardKey") var enterInClipboard: String = "copy"
    @AppStorage("DoubleClickInClipboardKey") var doubleClickInClipboard: String = "copy"
    
    var filteredItems: [ClipboardItem] {
        if let category = selectedCategory {
            return clipboardManager.items.filter { $0.type == category }
        }
        return clipboardManager.items
    }

    var body: some View {
        VStack(spacing: 0) {
            // 类别选择器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    Spacer()  // 添加 Spacer 使内容居中
                    ForEach(ClipboardItemType.allCases, id: \.self) { category in
                        Text(category.rawValue)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? Color.blue.opacity(0.7) : Color.gray.opacity(0.2))
                            .cornerRadius(16)
                            .foregroundColor(selectedCategory == category ? Color.white : Color.black)
                            .onTapGesture {
                                withAnimation {
                                    selectedCategory = (selectedCategory == category) ? nil : category
                                }
                            }
                    }
                    Spacer()  // 添加 Spacer 使内容居中
                }
                .frame(minHeight: 80, alignment: .center)
            }
            .background(BlurView())

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 20) {
                        ForEach(filteredItems, id: \.id) { item in
                            ClipboardItemView(item: Binding.constant(item))
                                .id(item.id)
                                .onTapGesture {
                                    let now = Date()
                                    let timeSinceLastTap = now.timeIntervalSince(self.lastTapTime)

                                    if timeSinceLastTap < 0.3 { // 300 毫秒以内的点击认为是双击
                                        if let itemToCopy = filteredItems.first(where: { $0.id == selectedItem }) {
                                            PasteboardHelper.shared.copyPainTextToPasteboard(itemToCopy.content)
                                            if doubleClickInClipboard == "paste" {
                                                PasteboardHelper.shared.pasteToCurrentFocusedElement()
                                            }
                                            NotificationCenter.default.post(name: NSNotification.Name("HideClipboardPopup"), object: nil)
                                        }
                                    } else {
                                        withAnimation {
                                            selectedItem = item.id
                                            proxy.scrollTo(item.id, anchor: .center)
                                        }
                                    }

                                    self.lastTapTime = now
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedItem == item.id ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                    .padding()
                    .frame(minHeight: 300)
                }
                .background(BlurView())
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                        
                        switch event.keyCode {
                        case 123, 126: // Left and up arrow
                            self.moveSelection(by: -1, with: proxy)
                            return nil // 不再返回事件
                        case 124, 125: // Right and down arrow
                            self.moveSelection(by: 1, with: proxy)
                            return nil // 不再返回事件
                        case 36: // Return key
                            if event.modifierFlags.contains(.shift) {
                                if let itemToCopy = filteredItems.first(where: { $0.id == selectedItem }) {
                                    PasteboardHelper.shared.copyPainTextToPasteboard(itemToCopy.content)
                                    if enterInClipboard == "paste" {
                                        PasteboardHelper.shared.pasteToCurrentFocusedElement()
                                    }
                                    NotificationCenter.default.post(name: NSNotification.Name("HideClipboardPopup"), object: nil)
                                }
                                return nil
                            } else {
                                if let itemToCopy = filteredItems.first(where: { $0.id == selectedItem }) {
                                    PasteboardHelper.shared.copyToPasteboard(itemToCopy.content, type: itemToCopy.type)
                                    if enterInClipboard == "paste" {
                                        PasteboardHelper.shared.pasteToCurrentFocusedElement()
                                    }
                                    NotificationCenter.default.post(name: NSNotification.Name("HideClipboardPopup"), object: nil)
                                }
                                return nil
                            }
                        case 53:
                            NotificationCenter.default.post(name: NSNotification.Name("HideClipboardPopup"), object: nil)
                            return nil
                        case 51: // Delete key
                            if let indexToDelete = filteredItems.firstIndex(where: { $0.id == selectedItem }) {
                                clipboardManager.deleteItem(with: filteredItems[indexToDelete].id)
                                        
                                if filteredItems.isEmpty {
                                    selectedItem = nil
                                } else if indexToDelete == 0 { // If the first item is deleted
                                    selectedItem = filteredItems.first?.id
                                } else {
                                    let newSelectionIndex = min(indexToDelete, filteredItems.count - 1)
                                    selectedItem = filteredItems[newSelectionIndex].id
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
                    withAnimation(.none) {
                        selectedItem = filteredItems.first?.id
                        selectedCategory = nil
                        if let firstID = filteredItems.first?.id {
                            proxy.scrollTo(firstID, anchor: .center)
                        }
                    }
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
    }

    func moveSelection(by delta: Int, with proxy: ScrollViewProxy) {
        guard let currentItem = filteredItems.first(where: { $0.id == selectedItem }),
              let currentIndex = filteredItems.firstIndex(of: currentItem) else { return }

        let targetIndex = min(max(currentIndex + delta, 0), filteredItems.count - 1)
        selectedItem = filteredItems[targetIndex].id
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
