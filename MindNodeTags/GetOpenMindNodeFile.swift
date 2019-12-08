//
//  GetOpenMindNodeFile.swift
//  MindNodeTags
//
//  Created by Jonathan on 5/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation
import Cocoa

func getMindNodeOpenFileUrl() -> URL? {
    // https://stackoverflow.com/questions/49076103/swift-get-file-path-of-currently-opened-document-in-another-application
    
    if AXIsProcessTrusted() == false {
        print("No Accesability Permissions")
        return nil
    }
    let mindNodeIdentifier = "com.ideasoncanvas.MindNodeMac"
    let MindNodeApp : NSRunningApplication? = NSRunningApplication
        .runningApplications(withBundleIdentifier: mindNodeIdentifier).last as NSRunningApplication?
    
    if let pid = MindNodeApp?.processIdentifier {
        
        var result = [AXUIElement]()
        var windowList: AnyObject? = nil // [AXUIElement]
        
        let appRef = AXUIElementCreateApplication(pid)
        
        if AXUIElementCopyAttributeValue(appRef, "AXWindows" as CFString, &windowList) == .success {
            result = windowList as! [AXUIElement]
        }
        
        var docRef: AnyObject? = nil
        guard let result_first = result.first else { return nil }
        if AXUIElementCopyAttributeValue(result_first, "AXDocument" as CFString, &docRef) == .success {
            let result = docRef as! AXUIElement
            //                NSLog("Found Document: \(result)")
            let filePath = result as! String
            let filePathURL = URL(string: filePath)
            return filePathURL
        }
    }
    return nil
}
