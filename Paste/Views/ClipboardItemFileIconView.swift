//
//  ClipboardItemFileIconView.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/9.
//

import SwiftUI

struct ClipboardItemFileIconView: View {
    let filePath: String

    var body: some View {
        if FileManager.default.fileExists(atPath: filePath) {
            let icon = NSWorkspace.shared.icon(forFile: filePath)
            return AnyView(VStack(spacing: 5) {
                Image(nsImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                Text((filePath as NSString).lastPathComponent)
                    .foregroundColor(.black)
                
                Text(filePath)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .frame(maxWidth: .infinity))
        } else {
            return AnyView(ClipboardItemMissingFileInfoView(name: (filePath as NSString).lastPathComponent, path: filePath)
                .frame(maxWidth: .infinity))
        }
    }
}
