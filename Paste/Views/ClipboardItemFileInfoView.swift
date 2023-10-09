//
//  ClipboardItemFileInfoView.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/9.
//

import SwiftUI

func ClipboardItemFileInfoView(name: String, path: String) -> some View {
    VStack(spacing: 5) {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
            Text(name)
                .font(.headline)
                .foregroundColor(.black)
        }
        Text(path)
            .font(.caption)
            .foregroundColor(.gray)
            .lineLimit(1)
            .truncationMode(.middle)
    }
}
