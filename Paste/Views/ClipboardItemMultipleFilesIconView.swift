//
//  ClipboardItemMultipleFilesIconView.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/12.
//

import Foundation
import SwiftUI

struct ClipboardItemMultipleFilesIconView: View {
    let filePaths: [String]
    
    init(filePath: String) {
        self.filePaths = filePath.components(separatedBy: ",")
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(filePaths.prefix(3), id: \.self) { path in
                    if FileManager.default.fileExists(atPath: path) {
                        let icon = NSWorkspace.shared.icon(forFile: path)
                        Image(nsImage: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .offset(x: CGFloat(filePaths.firstIndex(of: path)!) * 10 - CGFloat(filePaths.count - 1) * 5, y: CGFloat(filePaths.firstIndex(of: path)!) * 10 - CGFloat(filePaths.count - 1) * 5)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

