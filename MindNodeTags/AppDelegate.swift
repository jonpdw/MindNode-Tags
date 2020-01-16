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
    
    lazy var preferencesWindowController: NSWindowController? = {
            let storyboard: NSStoryboard? = NSStoryboard(name: "Preferences", bundle: nil)
            var windowController = storyboard?.instantiateController(withIdentifier: "PreferenceWindowController") as! NSWindowController
            return windowController
    }()
    
    @IBAction func showPreferences(_ sender: Any) {
        preferencesWindowController?.showWindow(sender)
        
    }
    
    let documentController = CustomNSDocumentController()
    
    let mNoDocumentAlert = noDocumentAlert()
    
    let noDocCounter = 0
    
    // the reason we store this is that we don't want the app to open in the background while the alert is still active. i.e you give permissions then click onn the app icon which launches the app
    var appHasAccessabiltyPermissions = false
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        accessabilityCheck()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        PFMoveToApplicationsFolderIfNecessary()
        tryOpenCurrentMindNodeFile()
        //comment for life
        
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        tryOpenCurrentMindNodeFile()
    }
    
    
     func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    // When the user clicks on the icon. In most cases applicationDidBecomeActive would activate at the same time as this but when the user closes the last window and then clicks on the icon applicationDidBecomeActive is not called
        tryOpenCurrentMindNodeFile()
        return true
    }


    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func tryOpenCurrentMindNodeFile() {
        if appHasAccessabiltyPermissions == true {
            if  let openMindNodeFileName = getMindNodeOpenFileUrlMaster() {
                
                // only keep the tags document matching the current MindNode document open
                for tagsDocument in documentController.documents {
                    // document.fileURL includes /.contents.xml but openFileName doesn't. This standardises them
                    if tagsDocument.fileURL!.deletingLastPathComponent() != openMindNodeFileName {tagsDocument.close()}
                }
                
                let contentsXML_URL = openMindNodeFileName.appendingPathComponent("contents.xml")
                documentController.openDocument(withContentsOf: contentsXML_URL, display: true, completionHandler:{ _,_,_  in })
                // When applicationDidFinishLaunching calls this addNewTagstoTagList is probably not needed. But it is important to call when applicationDidBecomeActive calls this function
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addNewTagstoTagList"), object: nil)
                #warning("Change the name from 'No MindNode Doc' to something better. As it is called in the no mindnode case and the other case")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "No MindNode Doc"), object: nil)
            } else {
                if documentController.documents.count == 0 {
                    // for situation where there is not instance of my app open e.g. the app just started and there are no MindNode docuemnts. A notification will not be recived because its part of the window lifecycle
                    mNoDocumentAlert.run()
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "No MindNode Doc"), object: nil)
                }
                
                
                
            }
        }
        
    }
    
    func accessabilityCheck() {
        if AXIsProcessTrusted() == false {
            
            let alert = NSAlert()
            alert.messageText = "No Accessability Permissions"
            alert.informativeText = "MindNode Tags needs accessability permissions to run.\n\nIf you have just updated the app refresh the permissions by disabling then enableing the them\n"
            alert.addButton(withTitle: "Quit App")
            alert.addButton(withTitle: "Show Me How To Fix It")
            alert.addButton(withTitle: "Recheck")
            
            let modalResult = alert.runModal()
            
            switch modalResult {
            case .alertFirstButtonReturn: // Quit
                NSApplication.shared.terminate(self)
            case .alertSecondButtonReturn: // Get Help
                let url = URL(string: "https://v.usetapes.com/vjkxYbaIHE")!
                NSWorkspace.shared.open(url)
            case .alertThirdButtonReturn: // Recheck
                if AXIsProcessTrusted() == false {
                    accessabilityCheck()
                } else {
                    appHasAccessabiltyPermissions = true
                    tryOpenCurrentMindNodeFile()
                }
                
                
            default:
                print("Something Else Clicked")
            }
        } else {
            appHasAccessabiltyPermissions = true
        }
    }
    
}


class noDocumentAlert {
    var noDocumentAlertCounter = 0
    
    func run() {
        // the reason we only want to allow another run after the users has pressed the button
        
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
        if self.noDocumentAlertCounter == 0 {
            self.noDocumentAlertCounter += 1
            let alert = NSAlert()
            alert.messageText = "No MindNode Document Can be Found"
            let modalResult = alert.runModal()
            switch modalResult {
            case .cancel:
                DispatchQueue.main.asyncAfter(deadline: .now()+5, execute: { self.noDocumentAlertCounter = 0 })
            default: break
                
            }
        }
    })
    }
}


