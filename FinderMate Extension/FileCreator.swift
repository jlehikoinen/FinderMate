//
//  FileCreator.swift
//  FinderMate
//
//  Created by Janne Lehikoinen on 27/08/2019.
//  Copyright © 2019 Janne Lehikoinen. All rights reserved.
//

import Cocoa

class FileCreator {
    
    // Flag for checking if folder polling and file creation was successful
    var createFileSucceeded = true
    
    // Shared group preferences required
    let sharedDefaults = UserDefaults.init(suiteName: "DAQCN465V5.com.github.jlehikoinen.FinderMate")
    
    func getFilesIn(folder: URL) -> [URL] {
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folder.path)
            let urls = contents.map { folder.appendingPathComponent($0) }.filter { !$0.hasDirectoryPath }
            return urls
        } catch let error as NSError {
            NSLog("Failed to get folder contents: %@", error.description as NSString)
            self.createFileSucceeded = false
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
            self.createFileSucceeded = false
            return
        }
        
        NSLog("Created new file: %@", targetFileName.absoluteString as NSString)
        
        openDefaultApp(fileUrl: targetFileName)
    }
    
    func openDefaultApp(fileUrl: URL) {
        // Open file in app if enabled in preferences and if the flag var is true
        // In certain scenarios, opening the app when folder polling or file creation failed would erase/overwrite existing file contents
        if sharedDefaults!.bool(forKey: "OpenAppAfterFileCreation") && self.createFileSucceeded {
            NSWorkspace.shared.open(fileUrl)
        }
    }
}
