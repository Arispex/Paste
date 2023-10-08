//
//  ScrollViewHelpers.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/8.
//

import SwiftUI

struct ItemBoundsKey: PreferenceKey {
    static var defaultValue: [CGRect] = []
    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ReadItemBounds: ViewModifier {
    func body(content: Content) -> some View {
        content.background(GeometryReader { geometry in
            Color.clear.preference(key: ItemBoundsKey.self, value: [geometry.frame(in: .global)])
        })
    }
}
