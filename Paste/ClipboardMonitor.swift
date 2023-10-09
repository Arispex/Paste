//
//  ClipboardMonitor.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/9.
//

import Cocoa
import CoreData
import SwiftUI

extension NSNotification.Name {
    public static let NSPasteboardDidChange: NSNotification.Name = .init(rawValue: "pasteboardDidChangeNotification")
}

class ClipboardMonitor: NSObject, NSApplicationDelegate {
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Paste") // 使用您的数据模型名称替换 "YourModelName"
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var context: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
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
        saveContext()
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
        let clipboardEntity = ClipboardEntity(context: self.context)
        if let contentType = PasteboardHelper.shared.getCurrentType() {
            clipboardEntity.id = UUID()
            clipboardEntity.type = contentType.rawValue
            clipboardEntity.timestamp = Date().timeIntervalSince1970

            if let frontmostApp = NSWorkspace.shared.frontmostApplication {
                let appName = frontmostApp.localizedName
                let appURL = frontmostApp.bundleURL?.path

                clipboardEntity.appName = appName
                clipboardEntity.appIconURL = appURL
            }

            if let content = PasteboardHelper.shared.getCurrentContent() {
                clipboardEntity.content = content

                if contentType == .image || contentType == .file || contentType == .multipleFiles {
                    let paths = content.split(separator: ",").map { String($0) }
                    let size = getSizeInBytes(of: paths) ?? 0
                    clipboardEntity.sizeInBytes = size
                } else {
                    clipboardEntity.sizeInBytes = Int64(content.count)
                }
            }
            
            do {
                try context.save()
                print("保存成功")
            } catch {
                print("Failed to save item to Core Data: \(error)")
            }
        }
    }
}
