//
//  ClipboardItemType.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/8.
//

import Foundation

enum ClipboardItemType: String, CaseIterable {
    case text = "文本"
    case richText = "富文本"
    case link = "链接"
    case image = "图片"
    case file = "文件"
    case multipleFiles = "多文件"
}

extension ClipboardItemType {
    var iconName: String {
        switch self {
        case .text: return "doc.plaintext"
        case .richText: return "doc.richtext"
        case .link: return "link"
        case .image: return "photo"
        case .file: return "doc"
        case .multipleFiles: return "doc.on.doc"
        }
    }
}
