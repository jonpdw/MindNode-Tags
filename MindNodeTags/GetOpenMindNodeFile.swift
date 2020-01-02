//
//  GetOpenMindNodeFile.swift
//  MindNodeTags
//
//  Created by Jonathan on 5/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation
import Cocoa

func getMindNodeOpenFileUrlMaster() -> URL? {
    if let urlOfMindNode2Doc = getMindNodeOpenFileUrl(identifier: "com.ideasoncanvas.MindNodeMac") {
        return urlOfMindNode2Doc
    }
    if let urlOfMindNode6Doc = getMindNodeOpenFileUrl(identifier: "com.ideasoncanvas.mindnode.macos") {
        return urlOfMindNode6Doc
    }
    return nil
}

func getMindNodeOpenFileUrl(identifier: String) -> URL? {
    // https://stackoverflow.com/questions/49076103/swift-get-file-path-of-currently-opened-document-in-another-application
    
    if AXIsProcessTrusted() == false {
        print("No Accesability Permissions")
        return nil
    }
    
    let mindNodeIdentifier = identifier
    
    let MindNodeApp: NSRunningApplication? = NSRunningApplication
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
            
//            let filePath = "\(result)"
            
            let filePath = String(describing: result)
            let filePathURL = URL(string: filePath)
            return filePathURL
        }
    }
    return nil
}
