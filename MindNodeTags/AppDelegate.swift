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
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        if AXIsProcessTrusted() == false {
            
            let alert = NSAlert()
            alert.messageText = "No Accessability Permissions"
            alert.informativeText = "MindNode Tags needs accessability permissions to run.\n\nIf you have just updated the app refresh the permissions by disabling then enableing the them\n"
            alert.addButton(withTitle: "Quit App")
            alert.addButton(withTitle: "Show Me How To Fix It")
            
            let modalResult = alert.runModal()
            
            switch modalResult {
            case .alertFirstButtonReturn: // NSApplication.ModalResponse.alertFirstButtonReturn
                NSApplication.shared.terminate(self)
            case .alertSecondButtonReturn:
                let url = URL(string: "https://v.usetapes.com/vjkxYbaIHE")!
                NSWorkspace.shared.open(url)
            default:
                print("Something Else Clicked")
            }
            
            
            
    }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        PFMoveToApplicationsFolderIfNecessary()
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
        if let openFileName = getMindNodeOpenFileUrlMaster() {
            let openURL = openFileName.appendingPathComponent("contents.xml")
            documentController.openDocument(withContentsOf: openURL, display: true, completionHandler:{ _,_,_  in })
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refeshTagsList"), object: nil)
        } else {
            print("Unable to find MindNode document to open")
        }
        
    }
    
}


