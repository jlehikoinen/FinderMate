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
    
    // Instance of FileCreator
    let fileCreator = FileCreator()
    
    // MARK: IBActions
    @IBAction func menuClicked(_ sender: AnyObject?) {
        let target = FIFinderSyncController.default().targetedURL()
        
        fileCreator.createFile(target!)
        
        let item = sender as! NSMenuItem
        NSLog("menuClicked method: menu item: %@, target = %@", item.title as NSString, target!.path as NSString)
    }
    
    // MARK: Override methods
    override init() {
        super.init()
        
        NSLog("FinderMate Extension launched from %@", Bundle.main.bundlePath as NSString)
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        // Produce a menu for the extension.
        let menu = NSMenu(title: "")
        menu.addItem(withTitle: "📄 New Text File", action: #selector(menuClicked(_:)), keyEquivalent: "")
        return menu
    }
}

