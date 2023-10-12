//
//  ClipboardMonitor.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/9.
//

import Cocoa
import SQLite
import SwiftUI

extension NSNotification.Name {
    public static let NSPasteboardDidChange: NSNotification.Name = .init(rawValue: "pasteboardDidChangeNotification")
}

class ClipboardMonitor: NSObject, NSApplicationDelegate {
    
    var db: Connection!

    let table = Table("clipboard_entities")
    let id = Expression<UUID>("id")
    let appIconURL = Expression<String?>("appIconURL")
    let appName = Expression<String?>("appName")
    let content = Expression<String?>("content")
    let sizeInBytes = Expression<Int64?>("sizeInBytes")
    let timestamp = Expression<Double?>("timestamp")
    let type = Expression<String?>("type")

    override init() {
            super.init()

            // 确保 'paste' 文件夹存在
            let documentsPath = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            let pasteFolderPath = "\(documentsPath)/Paste"
            
            do {
                try FileManager.default.createDirectory(atPath: pasteFolderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating 'paste' directory: \(error)")
            }

            // 初始化数据库连接
            do {
                db = try Connection("\(pasteFolderPath)/db.sqlite3")
            } catch {
                print("Failed to create or open database: \(error)")
                return
            }

            // 创建表
            do {
                try db.run(table.create(ifNotExists: true) { t in
                    t.column(id, primaryKey: true)
                    t.column(appIconURL)
                    t.column(appName)
                    t.column(content)
                    t.column(sizeInBytes)
                    t.column(timestamp)
                    t.column(type)
                })
            } catch {
                print("Failed to create table: \(error)")
            }
        }

    var timer: Timer!
    let pasteboard: NSPasteboard = .general
    var lastChangeCount: Int = 0

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 1. 开始监听
        startListening()

        // 2. 注册通知观察者
        NotificationCenter.default.addObserver(self, selector: #selector(handlePasteboardChange), name: .NSPasteboardDidChange, object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        timer.invalidate()
    }

    func startListening() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (t) in
            if self.lastChangeCount != self.pasteboard.changeCount {
                self.lastChangeCount = self.pasteboard.changeCount
                NotificationCenter.default.post(name: .NSPasteboardDidChange, object: self.pasteboard)
            }
        }
    }
    
    func getSizeInBytes(of filePaths: [String]) -> Int64? {
        var totalSize: Int64 = 0
        for path in filePaths {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: path)
                if let size = attributes[.size] as? Int64 {
                    totalSize += size
                }
            } catch {
                print("Error retrieving file size: \(error)")
                return nil
            }
        }
        return totalSize > 0 ? totalSize : nil
    }

    @objc func handlePasteboardChange(_ notification: Notification) {
        @AppStorage("ClipboardMonitorKey") var clipboardMonitor: Bool = false
        
        if !clipboardMonitor {
            return
        }
        let newEntityId = UUID()
        var newEntityAppIconURL: String?
        var newEntityAppName: String?
        var newEntityContent: String?
        var newEntitySizeInBytes: Int64?
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

                if contentType == .image || contentType == .file || contentType == .multipleFiles {
                    let paths = content.split(separator: ",").map { String($0) }
                    let size = getSizeInBytes(of: paths) ?? 0
                    newEntitySizeInBytes = size
                } else {
                    newEntitySizeInBytes = Int64(content.count)
                }
            }
            
            do {
                let insert = table.insert(
                    id <- newEntityId,
                    appIconURL <- newEntityAppIconURL,
                    appName <- newEntityAppName,
                    content <- newEntityContent,
                    sizeInBytes <- newEntitySizeInBytes,
                    timestamp <- newEntityTimestamp,
                    type <- newEntityType
                )
                try db.run(insert)
                print("保存成功")
            } catch {
                print("Failed to save item to database: \(error)")
            }
        }
    }
}
