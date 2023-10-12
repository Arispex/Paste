//
//  DatabaseSchema.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/12.
//

import SQLite
import SwiftUI

let table = Table("clipboard_entities")
let id = Expression<UUID>("id")
let appIconURL = Expression<String?>("appIconURL")
let appName = Expression<String?>("appName")
let content = Expression<String?>("content")
let sizeInBytes = Expression<Int64?>("sizeInBytes")
let timestamp = Expression<Double?>("timestamp")
let type = Expression<String?>("type")
