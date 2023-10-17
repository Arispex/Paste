//
//  ClipboardManager.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/15.
//

import Cocoa
import Combine
import SQLite
import SwiftUI

extension NSNotification.Name {
    public static let NSPasteboardDidChange: NSNotification.Name = .init(rawValue: "pasteboardDidChangeNotification")
}

class ClipboardManager: NSObject, ObservableObject, NSApplicationDelegate {
    @Published var items: [ClipboardItem] = []
    
    private var db: Connection!
    private var timer: Timer!
    private var lastChangeCount: Int = 0
    private let pasteboard: NSPasteboard = .general
    
    let table = Table("clipboard_entities")
    let id = Expression<UUID>("id")
    let appIconURL = Expression<String?>("appIconURL")
    let appName = Expression<String?>("appName")
    let content = Expression<String?>("content")
    let timestamp = Expression<Double?>("timestamp")
    let type = Expression<String?>("type")
    
    override init() {
        super.init()
        setupDatabase()
        startListening()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePasteboardChange), name: .NSPasteboardDidChange, object: nil)
        loadItemsFromDatabase()
    }
    
    func setupDatabase() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        let pasteFolderPath = "\(documentsPath)/Paste"
        
        let path = "\(pasteFolderPath)/db.sqlite3"
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: pasteFolderPath) {
            try? fileManager.createDirectory(atPath: pasteFolderPath, withIntermediateDirectories: true, attributes: nil)
        }
        do {
            db = try Connection(path)
            
            // 创建表的逻辑
            let createTable = table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(appIconURL)
                t.column(appName)
                t.column(content)
                t.column(timestamp)
                t.column(type)
            }
            
            try db.run(createTable)
        } catch {
            print("Failed to create or connect to database: \(error)")
        }
    }
    
    func startListening() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (t) in
            if self.lastChangeCount != self.pasteboard.changeCount {
                self.lastChangeCount = self.pasteboard.changeCount
                NotificationCenter.default.post(name: .NSPasteboardDidChange, object: self.pasteboard)
            }
        }
    }
    
    func loadItemsFromDatabase() {
        do {
            self.items.removeAll()
            let query = table.order(timestamp.desc)
            for row in try db.prepare(query) {
                let item = ClipboardItem(
                    id: row[id],
                    appName: row[appName] ?? "",
                    timestamp: row[timestamp] ?? 0.0,
                    content: row[content] ?? "",
                    appIconURL: URL(string: row[appIconURL] ?? "")!,
                    type: ClipboardItemType(rawValue: row[type] ?? "") ?? .text
                )
                self.items.append(item)
            }
        } catch {
            print("Failed to fetch items from database: \(error)")
        }
    }

    func cleanOldItemsIfNeeded() {
        @AppStorage("MaxClipboardItemsKey") var maxClipboardItems: Int = 100
        do {
            // 获取当前数据库中的条目数
            let rowCount = try db.scalar(table.count)
            if rowCount > maxClipboardItems {
                // 超过上限, 查找最早的项
                let earliestItemQuery = table.order(timestamp.asc).limit(1)
                if let earliestItem = try? db.pluck(earliestItemQuery) {
                    // 删除这个最早的项
                    try db.run(table.filter(id == earliestItem[id]).delete())
                    print("Deleted oldest item to make space.")
                }
            }
        } catch {
            print("Failed to clean old items: \(error)")
        }
    }
    
    
    @objc func handlePasteboardChange(_ notification: Notification) {
        @AppStorage("ClipboardMonitorKey") var clipboardMonitor: Bool = false
        @AppStorage("SoundReminderWhenCopyingKey") var soundReminderWhenCopying: Bool = false
        @AppStorage("AutoCleanOldItemsKey") var autoCleanOldItems: Bool = false
        
        if !clipboardMonitor {
            return
        }
        
        let newEntityId = UUID()
        var newEntityAppIconURL: String?
        var newEntityAppName: String?
        var newEntityContent: String?
        var newEntityTimestamp = Date().timeIntervalSince1970
        var newEntityType: String?
        
        if let contentType = PasteboardHelper.shared.getCurrentType() {
            newEntityType = contentType.rawValue
            
            if let frontmostApp = NSWorkspace.shared.frontmostApplication {
                let appName = frontmostApp.localizedName
                let appURL = frontmostApp.bundleURL?.path
                
                newEntityAppName = appName
                newEntityAppIconURL = appURL
            }
            
            if let content = PasteboardHelper.shared.getCurrentContent() {
                newEntityContent = content
            }
            
            // Check if item with the same content already exists
            let existingItemQuery = table.filter(content == newEntityContent!)
            if let existingItem = try? db.pluck(existingItemQuery) {
                // Update timestamp of the existing item
                let updateTimestamp = existingItemQuery.update(timestamp <- newEntityTimestamp)
                try? db.run(updateTimestamp)
                print("Timestamp updated")
            } else {
                // Insert a new item
                let insert = table.insert(
                    id <- newEntityId,
                    appIconURL <- newEntityAppIconURL,
                    appName <- newEntityAppName,
                    content <- newEntityContent,
                    timestamp <- newEntityTimestamp,
                    type <- newEntityType
                )
                try? db.run(insert)
                print("保存成功")
                if autoCleanOldItems {
                    cleanOldItemsIfNeeded()
                }
            }
            if soundReminderWhenCopying {
                playSound()
            }
            loadItemsFromDatabase()
        }
    }
    func playSound() {
        @AppStorage("SoundKey") var sound: String = "Tink"
        if let sound = NSSound(named: NSSound.Name(sound)) { // "Tink"是macOS内置的一个声音效果
            sound.play()
        }
    }
    func deleteItem(with uuid: UUID) {
        let itemToDelete = table.filter(id == uuid)
        do {
            let deletedRowCount = try db.run(itemToDelete.delete())
            if deletedRowCount > 0 {
                print("删除成功")
                // 在删除数据库项之后重新加载内容
                loadItemsFromDatabase()
            } else {
                print("未找到指定的项进行删除")
            }
        } catch {
            print("删除失败: \(error)")
        }
    }

}
