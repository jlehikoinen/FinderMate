//
//  CreateTextFileExtension.swift
//  FinderMate Extension
//
//  Created by Janne Lehikoinen on 23/08/2019.
//  Copyright © 2019 Janne Lehikoinen. All rights reserved.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    
    // Shared group preferences required
    let sharedDefaults = UserDefaults.init(suiteName: "DAQCN465V5.com.github.jlehikoinen.FinderMate")
    
    // MARK: IBActions
    @IBAction func menuClicked(_ sender: AnyObject?) {
        let target = FIFinderSyncController.default().targetedURL()
        
        createFile(target!)
        
        let item = sender as! NSMenuItem
        NSLog("menuClicked method: menu item: %@, target = %@", item.title as NSString, target!.path as NSString)
    }
    
    // MARK: Helper methods
    func getFilesIn(folder: URL) -> [URL] {
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folder.path)
            let urls = contents.map { folder.appendingPathComponent($0) }.filter { !$0.hasDirectoryPath }
            return urls
        } catch let error as NSError {
            NSLog("Failed to get folder contents: %@", error.description as NSString)
            return []
        }
    }
    
    func validateFileName(_ fileUrl: URL) -> URL {
        
        // Get default file name from preferences
        let defaultFileName = sharedDefaults!.string(forKey: "DefaultFileName")!
        
        var counter = 1
        var targetFileName = fileUrl.appendingPathComponent(defaultFileName)
        let originalFileName = targetFileName.deletingPathExtension().lastPathComponent
        let filePaths = getFilesIn(folder: fileUrl)
        
        while filePaths.contains(targetFileName) {
            var newFileName = ""
            let fileExt = targetFileName.pathExtension
            newFileName = "\(originalFileName) \(counter).\(fileExt)"
            targetFileName = fileUrl.appendingPathComponent(newFileName)
            counter += 1
        }
        
        return targetFileName
    }
    
    func createFile(_ target: URL) {
        
        let placeholderString = ""
        let targetFileName: URL = validateFileName(target)
        
        do {
            try placeholderString.write(to: targetFileName, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            NSLog("Failed to create file: %@", error.description as NSString)
            return
        }
        
        NSLog("Created new file: %@", targetFileName.absoluteString as NSString)
        
        // Open file in app if enabled in preferences
        if sharedDefaults!.bool(forKey: "OpenAppAfterFileCreation") {
            NSWorkspace.shared.open(targetFileName)
        }
    }
    
    // MARK: Override methods
    override init() {
        super.init()
        
        NSLog("CreateTextFile launched from %@", Bundle.main.bundlePath as NSString)
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        // Produce a menu for the extension.
        let menu = NSMenu(title: "")
        menu.addItem(withTitle: "📄 New Text File", action: #selector(menuClicked(_:)), keyEquivalent: "")
        return menu
    }
}

