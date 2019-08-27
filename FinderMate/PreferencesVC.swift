//
//  PreferencesVC.swift
//  FinderMate
//
//  Created by Janne Lehikoinen on 25/08/2019.
//  Copyright © 2019 Janne Lehikoinen. All rights reserved.
//

/*
 TODO:
 - Relaunch app if createFileSucceeded flag var needs reset?
 - Constraints: Fixed width constraints may cause clipping.
 - cfprefsd warning
 */

import Cocoa
import FinderSync

class PreferencesVC: NSViewController {

    // Shared group preferences required
    let sharedDefaults = UserDefaults.init(suiteName: "DAQCN465V5.com.github.jlehikoinen.FinderMate")
    
    // MARK: IBOutlets
    @IBOutlet weak var openAppCheckbox: NSButton!
    @IBOutlet weak var defaultDocumentNameField: NSTextField!
    @IBOutlet weak var alertLabel: NSTextField!
    
    // MARK: IBActions
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        // Checkbox state
        if openAppCheckbox.state == NSControl.StateValue.on {
            sharedDefaults!.set(true, forKey: AppPreferences.openAppAfterFileCreationKey)
        } else {
            sharedDefaults!.set(false, forKey: AppPreferences.openAppAfterFileCreationKey)
        }
        
        // Default file name, if empty use placeholder defined in AppPreferences
        if defaultDocumentNameField.stringValue != "" {
            
            sharedDefaults!.set(defaultDocumentNameField.stringValue, forKey: AppPreferences.defaultFileNameKey)
            
            // Mark first launch done
            sharedDefaults!.set(true, forKey: AppPreferences.firstLaunchDone)
            
            // Open Sys Prefs > Extensions if extension is disabled
            if !FIFinderSyncController.isExtensionEnabled {
                FIFinderSyncController.showExtensionManagementInterface()
            }
            
            // Quit app
            NSApplication.shared.terminate(self)
            
        } else {
            defaultDocumentNameField.stringValue = AppPreferences.defaultFileName
        }
    }
    
    // MARK: Helper methods
    func setupPreferences() {
        
        // First launch done
        if sharedDefaults!.bool(forKey: AppPreferences.firstLaunchDone) {
            refreshUI()
        } else {
            defaultDocumentNameField.stringValue = AppPreferences.defaultFileName
            
            if AppPreferences.openAppAfterFileCreation {
                openAppCheckbox.state = NSControl.StateValue.on
            } else {
                openAppCheckbox.state = NSControl.StateValue.off
            }
        }
    }
    
    func setupAlertLabel() {
        
        if FIFinderSyncController.isExtensionEnabled {
            alertLabel.isHidden = true
        } else {
            alertLabel.isHidden = false
        }
        
    }
    
    func refreshUI() {
        
        defaultDocumentNameField.stringValue = sharedDefaults!.string(forKey: AppPreferences.defaultFileNameKey)!
        
        if sharedDefaults!.bool(forKey: AppPreferences.openAppAfterFileCreationKey) {
            openAppCheckbox.state = NSControl.StateValue.on
        } else {
            openAppCheckbox.state = NSControl.StateValue.off
        }
    }
    
    // MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSApp.activate(ignoringOtherApps: true)
        setupPreferences()
        setupAlertLabel()
    }
}
