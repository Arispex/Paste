//
//  PasteboardHelper.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/8.
//
import SwiftUI
import Cocoa

class PasteboardHelper {
    static let shared = PasteboardHelper()
    private let pasteboard: NSPasteboard = .general
    
    private init() {}
    

    func copyToPasteboard(_ string: String, type: ClipboardItemType) {
        let pasteboard = NSPasteboard.general

        switch type {
        case .text, .richText, .link:
            pasteboard.declareTypes([.string], owner: nil)
            pasteboard.setString(string, forType: .string)

        case .file, .multipleFiles, .image:
            let filePaths = string.split(separator: ",").map { String($0) }
            let fileUrls = filePaths.map { URL(fileURLWithPath: $0) }
            
            pasteboard.clearContents()
            pasteboard.writeObjects(fileUrls as [NSPasteboardWriting])
        }
    }
    
    func pasteToCurrentFocusedElement() {
        // 创建并发送按键事件的方法
        func sendPasteKeyPress() {
            // 创建一个模拟 Command 键按下的事件
            let cmdKeyDown = CGEvent(keyboardEventSource: nil, virtualKey: 0x37, keyDown: true)
            cmdKeyDown?.flags = .maskCommand

            // 创建一个模拟 'V' 键按下的事件
            let vKeyDown = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: true)
            vKeyDown?.flags = .maskCommand

            // 创建一个模拟 'V' 键释放的事件
            let vKeyUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: false)
            vKeyUp?.flags = .maskCommand

            // 创建一个模拟 Command 键释放的事件
            let cmdKeyUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x37, keyDown: false)
            cmdKeyUp?.flags = .maskCommand

            // 发送事件到当前的聚焦点
            let location = CGEventTapLocation.cghidEventTap
            cmdKeyDown?.post(tap: location)
            vKeyDown?.post(tap: location)
            vKeyUp?.post(tap: location)
            cmdKeyUp?.post(tap: location)
        }

        // 添加0.1秒的延迟，然后发送按键事件
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sendPasteKeyPress()
        }
    }


    
    func getCurrentText() -> String? {
        return pasteboard.string(forType: .string)
    }
    
    func getCurrentURL() -> URL? {
        return pasteboard.readObjects(forClasses: [NSURL.self], options: nil)?.first as? URL
    }
    
    func getCurrentFilePath() -> String? {
        if let items = NSPasteboard.general.pasteboardItems {
            for item in items {
                for type in item.types {
                    if type == .fileURL {
                        if let fileURL = item.string(forType: type) {
                            return fileURL
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func isImagePath(_ path: String) -> Bool {
        let imageExtensions: Set<String> = ["png", "jpg", "jpeg", "gif", "bmp", "tiff", "heic", "webp"] // 可以根据需要增加或减少
        let fileExtension = URL(fileURLWithPath: path).pathExtension.lowercased()
        return imageExtensions.contains(fileExtension)
    }


    
    func getCurrentRichText() -> NSAttributedString? {
        if let data = pasteboard.data(forType: .rtf) {
            return try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
        }
        return nil
    }
    
    func getCurrentType() -> ClipboardItemType? {
        let pasteboard = NSPasteboard.general
        if let items = pasteboard.pasteboardItems {
            for item in items {
                for type in item.types {
                    // Check for file URL
                    if type == .fileURL {
                        if let filePath = item.string(forType: type) {
                            if (items.count > 1) {
                                return .multipleFiles
                            }
                            if isImagePath(filePath) {
                                return .image
                            }
                            return .file
                        }
                    }
                    
                    // Check for rich text
                    if type == .rtf || type == .rtfd {
                        return .richText
                    }

                    // Check for link (assuming a URL is a link)
                    if type == .URL {
                        return .link
                    }
                }
            }
        }
        
        // If none of the above types were found, but there's a plain text, return text.
        if pasteboard.string(forType: .string) != nil {
            return .text
        }

        return nil
    }


    
    func getCurrentContent() -> String? {
        let pasteboard = NSPasteboard.general
        if let items = pasteboard.pasteboardItems {
            var filePaths: [String] = []
            
            for item in items {
                for type in item.types {
                    // Check for file URL
                    if type == .fileURL {
                                if let url = item.data(forType: type), let fileURL = NSURL(dataRepresentation: url, relativeTo: nil) as URL? {
                                    filePaths.append(fileURL.path)
                                }
                            }
                    
                    // Check for rich text
                    if (type == .rtf || type == .rtfd) && filePaths.isEmpty {
                        return item.string(forType: .string)
                    }

                    // Check for link (assuming a URL is a link) and not file paths found yet
                    if type == .URL && filePaths.isEmpty {
                        return item.string(forType: .string)
                    }
                }
            }
            
            // Return paths joined by commas if any
            if !filePaths.isEmpty {
                return filePaths.joined(separator: ",")
            }
        }
        
        // If none of the above types were found, but there's a plain text, return it.
        return pasteboard.string(forType: .string)
    }
}
