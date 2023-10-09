//
//  ClipboardItemImageView.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/9.
//

import SwiftUI

struct ClipboardItemImageView: View {
    let imagePath: String

    var body: some View {
        if let image = NSImage(contentsOfFile: imagePath) {
            VStack(spacing: 5) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                Text((imagePath as NSString).lastPathComponent)
                    .foregroundColor(.black)

                Text(imagePath)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        } else {
            ClipboardItemMissingFileInfoView(name: (imagePath as NSString).lastPathComponent, path: imagePath)
        }
    }
}
