//
//  ClipboardEntity.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/12.
//
//

import Foundation
import SwiftData

@Model public class ClipboardEntity: Identifiable {
    public var id: UUID?  // 注意这里我们添加了 'public'
    var appIconURL: String?
    var appName: String?
    var content: String?
    var sizeInBytes: Int64? = 0
    var timestamp: Double? = 0.0
    var type: String?

    public init() { }
}
