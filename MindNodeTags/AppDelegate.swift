//
//  AppDelegate.swift
//  MindNodeTags3
//
//  Created by Jonathan on 25/11/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let documentController = NSDocumentController.shared

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        tryOpenCurrentMindNodeFile()
        
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
//            nsc.documents[0].addWindowController(MyWindowController(window: NSApplication.shared.mainWindow!))
        tryOpenCurrentMindNodeFile()
        
    }
    
    func applicationWillUnhide(_ notification: Notification) {
        print("UnHide")
    }
    
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func tryOpenCurrentMindNodeFile() {
        if let openFileName = getMindNodeOpenFileUrl() {
            let openURL = openFileName.appendingPathComponent("contents.xml")
            documentController.openDocument(withContentsOf: openURL, display: true, completionHandler:{ _,_,_  in })
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refeshTagsList"), object: nil)
        } else {
            print("Unable to find MindNode document to open")
        }
        
    }
    
}


