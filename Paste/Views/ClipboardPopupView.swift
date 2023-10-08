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
            case .image, .file, .multipleFiles:
                if sizeInBytes < 1_000_000 {
                    return "\(sizeInBytes/1_000) KB"
                } else {
                    return "\(sizeInBytes/1_000_000) MB"
                }
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
    let clipboardItems = [
        // 示例项，您需要确保URL指向正确的应用程序
        ClipboardItem(appName: "Safari", timestamp: 1696749514, content: "This is a clipboard content from Safari.", appIconURL: URL(fileURLWithPath: "/Applications/Safari.app"), type: .text),
        ClipboardItem(appName: "Safari", timestamp: 1696750414, content: "This is a clipboard content from Safari.", appIconURL: URL(fileURLWithPath: "/Applications/Safari.app"), type: .image),
        ClipboardItem(appName: "Safari", timestamp: 1696736014, content: "This is a clipboard content from Safari.", appIconURL: URL(fileURLWithPath: "/Applications/Safari.app"), type: .link),
        ClipboardItem(appName: "Safari", timestamp: 1696217614, content: "This is a clipboard content from Safari.", appIconURL: URL(fileURLWithPath: "/Applications/Safari.app"), type: .link),
    ]

    @State private var selectedItem: UUID?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(clipboardItems) { item in
                        VStack(alignment: .leading) {
                            HStack {
                                item.appIconURL.appIcon()
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Spacer()
                                Text(item.formattedTime)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            Text(item.content)
                                .lineLimit(10)
                                .truncationMode(.tail)
                            Spacer()
                            HStack {
                                Image(systemName: item.type.iconName) // 显示对应的图标
                                    .foregroundColor(.gray)
                                Text(item.displayString)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .frame(height: 250)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
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
            .onAppear {
                selectedItem = clipboardItems.first?.id
            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    switch event.keyCode {
                    case 123: // Left arrow
                        self.moveSelection(by: -1, with: proxy)
                        return nil // 不再返回事件
                    case 124: // Right arrow
                        self.moveSelection(by: 1, with: proxy)
                        return nil // 不再返回事件
                    case 36: // Return key
                        if let itemToCopy = clipboardItems.first(where: { $0.id == selectedItem }) {
                            PasteboardHelper.shared.copyToPasteboard(itemToCopy.content)
                            NotificationCenter.default.post(name: NSNotification.Name("HideClipboardPopup"), object: nil)
                        }
                        return nil
                    default:
                        break
                    }
                    return event
                }
            }
        }
    }

    func moveSelection(by delta: Int, with proxy: ScrollViewProxy) {
        guard let currentItem = clipboardItems.first(where: { $0.id == selectedItem }),
              let currentIndex = clipboardItems.firstIndex(of: currentItem) else { return }

        let targetIndex = min(max(currentIndex + delta, 0), clipboardItems.count - 1)
        selectedItem = clipboardItems[targetIndex].id
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
