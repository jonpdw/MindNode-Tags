//
//  ChangeScreenPosition.swift
//  MindNodeTags
//
//  Created by Jonathan on 5/12/19.
//  Copyright © 2019 Jonathan. All rights reserved.
//

import Foundation
import Cocoa

func moveAppNextToOpenMindNodeDocument(){
    
    if AXIsProcessTrusted() == false {
        print("No Accesability Permissions")
        return
    }
    
    if getMindNodeOpenFileUrlMaster() == nil {
        print("getMindNodeOpenFileUrlMaster() nil")
        return
    }
    
    let openFileName = getMindNodeOpenFileUrlMaster()!.deletingPathExtension().lastPathComponent
    var mindNodeBounds = CGRect(x: 0, y: 0, width: 300, height: 500)
    if let windowList = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: AnyObject]] {
        for window in windowList {
            let bounds = CGRect(dictionaryRepresentation: window[kCGWindowBounds as String] as! CFDictionary)!
            let name = window[kCGWindowName as String] as? String ?? ""
            if name == openFileName {
                mindNodeBounds = bounds
                break
            }
        }
    }
    
    
    let type = CGWindowListOption.optionOnScreenOnly
    let windowList = CGWindowListCopyWindowInfo(type, kCGNullWindowID) as NSArray? as? [[String: AnyObject]]
    
    for entry  in windowList!
    {
        let owner = entry[kCGWindowOwnerName as String] as! String
        _ = entry[kCGWindowBounds as String] as? [String: Int] // bounds
        let pid = entry[kCGWindowOwnerPID as String] as? Int32
        
        if owner == "MindNode"
        {
            let appRef = AXUIElementCreateApplication(pid!);  //TopLevel Accessability Object of PID
            
            var value: AnyObject?
            _ = AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value) // result
            
            if let windowList = value as? [AXUIElement]
            {
                if windowList.first != nil
                {
                    let mainScreenRect = NSScreen.main!.frame
                    let screenWidth = mainScreenRect.size.width
                    let maxWidth = mainScreenRect.origin.x + screenWidth
                    if (mindNodeBounds.origin.x + mindNodeBounds.size.width + 200 > maxWidth) {
                        var position : CFTypeRef
                        var size : CFTypeRef
                        var  newPoint = CGPoint(x: mindNodeBounds.origin.x, y: mindNodeBounds.origin.y)
                    
                        let amountToAdjustWidth = mindNodeBounds.size.width + mindNodeBounds.origin.x - maxWidth + 200
                        var newSize = CGSize(width: mindNodeBounds.size.width-amountToAdjustWidth, height: mindNodeBounds.size.height)
                        
                        
                        
                        
                        
                        mindNodeBounds = CGRect(x: mindNodeBounds.origin.x, y: mindNodeBounds.origin.y, width: mindNodeBounds.size.width-amountToAdjustWidth, height: mindNodeBounds.size.height)
                        
                        position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
                        AXUIElementSetAttributeValue(windowList.first!, kAXPositionAttribute as CFString, position);
                        
                        size = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!,&newSize)!;
                        AXUIElementSetAttributeValue(windowList.first!, kAXSizeAttribute as CFString, size);
                    }
                }
            }
        }
        
    }
    
    
    for entry  in windowList!
    {
        let owner = entry[kCGWindowOwnerName as String] as! String
        _ = entry[kCGWindowBounds as String] as? [String: Int] // bounds
        let pid = entry[kCGWindowOwnerPID as String] as? Int32
        
        if owner == "MindNode Tags"
        {
            let appRef = AXUIElementCreateApplication(pid!);  //TopLevel Accessability Object of PID
            
            var value: AnyObject?
            _ = AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value) // result
            
            if let windowList = value as? [AXUIElement]
            {
//                if let window = windowList.first
//                {
                    
                    var position : CFTypeRef
                    var size : CFTypeRef
                    var  newPoint = CGPoint(x: mindNodeBounds.origin.x+mindNodeBounds.size.width, y: mindNodeBounds.origin.y)
                    var newSize = CGSize(width: 200, height: mindNodeBounds.size.height)
                    
                    position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&newPoint)!;
                    AXUIElementSetAttributeValue(windowList.first!, kAXPositionAttribute as CFString, position);
                    
                    size = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!,&newSize)!;
                    AXUIElementSetAttributeValue(windowList.first!, kAXSizeAttribute as CFString, size);
//                }
            }
        }
    }
}


struct RuntimeError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}
