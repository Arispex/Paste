//
//  ClipboardItemView.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/9.
//

import SwiftUI

struct ClipboardItemView: View {
    @Binding var item: ClipboardItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                item.appIconURL.appIcon()
                    .resizable()
                    .frame(width: 20, height: 20)
                Spacer()
                Text(item.formattedTime)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            item.displayContent
                .frame(maxHeight: .infinity)
                .clipped()
            Spacer()
            HStack {
                Image(systemName: item.type.iconName)
                    .foregroundColor(.gray)
                Text(item.displayString)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(width: 250)
        .frame(height: 250)
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}
