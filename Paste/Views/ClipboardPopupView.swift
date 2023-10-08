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
    var timestamp: String
    var content: String
    var charCount: Int
    var appIcon: Image

    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        return lhs.id == rhs.id
    }
}

class ScrollViewManager: ObservableObject {
    @Published var offset: CGFloat = 0
}

struct ClipboardPopupView: View {
    let clipboardItems = [
        ClipboardItem(appName: "Safari", timestamp: "15:30", content: "This is a clipboard content from Safari.", charCount: 50, appIcon: Image(systemName: "safari.fill")),
        ClipboardItem(appName: "QQ", timestamp: "14:15", content: "Clipboard content from Notes.", charCount: 30, appIcon: Image(systemName: "note.text.fill")),
        ClipboardItem(appName: "QQ", timestamp: "14:15", content: "Clipboard content from Notes.", charCount: 30, appIcon: Image(systemName: "note.text.fill")),
        ClipboardItem(appName: "QQ", timestamp: "14:15", content: "Clipboard content from Notes.", charCount: 30, appIcon: Image(systemName: "note.text.fill")),
        ClipboardItem(appName: "QQ", timestamp: "14:15", content: "Clipboard content from Notes.", charCount: 30, appIcon: Image(systemName: "note.text.fill")),
        ClipboardItem(appName: "QQ", timestamp: "14:15", content: "Clipboard content from Notes.", charCount: 30, appIcon: Image(systemName: "note.text.fill")),
        ClipboardItem(appName: "QQ", timestamp: "14:15", content: "Clipboard content from Notes.", charCount: 30, appIcon: Image(systemName: "note.text.fill")),
        ClipboardItem(appName: "QQ", timestamp: "14:15", content: "Clipboard content from Notes.", charCount: 30, appIcon: Image(systemName: "note.text.fill")),
        ClipboardItem(appName: "QQ", timestamp: "14:15", content: "Clipboard content from Notes.", charCount: 30, appIcon: Image(systemName: "note.text.fill")),
        // ... (您可以添加更多的项)
    ]

    @State private var selectedItem: UUID?

        var body: some View {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(clipboardItems) { item in
                            VStack {
                                HStack {
                                    item.appIcon
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.blue)
                                    Text(item.timestamp)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                                Divider()
                                Text(item.content)
                                    .lineLimit(3)
                                    .truncationMode(.tail)
                                Spacer()
                                Text("\(item.charCount) characters")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
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
            proxy.scrollTo(selectedItem!, anchor: .center)  // 修改这里
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
