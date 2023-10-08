//
//  PasteboardHelper.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/8.
//
import SwiftUI

class PasteboardHelper {
    static let shared = PasteboardHelper()
    private init() {}
    
    func copyToPasteboard(_ string: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(string, forType: .string)
    }
}
