//
//  ClipboardItemMissingFileInfoView.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/9.
//

import SwiftUI

struct ClipboardItemMissingFileInfoView: View {
    let name: String
    let path: String

    var body: some View {
        VStack(spacing: 5) {
            Color.clear
                .frame(width: 100, height: 100)
            
            HStack(spacing: 5){
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)

                Text(name)
                    .foregroundColor(.black)
            }

            Text(path)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}
