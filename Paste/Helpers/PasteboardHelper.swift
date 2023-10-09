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
    
    func copyToPasteboard(_ string: String) {
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(string, forType: .string)
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
                            if isImagePath(filePath) {
                                return .image
                            }
                            return items.count > 1 ? .multipleFiles : .file
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
