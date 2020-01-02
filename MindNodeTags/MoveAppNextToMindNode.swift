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
    
    guard var mindNodeBounds: CGRect = getBoundsOfWindow(withname: "MindNode") else {
        print("Abort Moving Window. Can't find document")
        return
    }
    let widthOfMindNodeTags: CGFloat = getBoundsOfWindow(withname: "MindNode Tags")?.size.width ?? 200
    
    // Move MindNode
    if let mindNodeWindow = getFirstWindow(withname: "MindNode") {
        let mainScreenBounds = NSScreen.main!.frame
        let mainScreenWidth = mainScreenBounds.size.width
        let widthOfMainScreen = mainScreenBounds.origin.x + mainScreenWidth
        
        if (mindNodeBounds.origin.x + mindNodeBounds.size.width + widthOfMindNodeTags > widthOfMainScreen) {
            let  newPoint = CGPoint(x: mindNodeBounds.origin.x, y: mindNodeBounds.origin.y)
            let amountToAdjustWidth = mindNodeBounds.size.width + mindNodeBounds.origin.x - widthOfMainScreen + widthOfMindNodeTags
            let newSize = CGSize(width: mindNodeBounds.size.width-amountToAdjustWidth, height: mindNodeBounds.size.height)
            
            mindNodeBounds = CGRect(x: mindNodeBounds.origin.x, y: mindNodeBounds.origin.y, width: mindNodeBounds.size.width-amountToAdjustWidth, height: mindNodeBounds.size.height)
            
            setWindowSize(window: mindNodeWindow, size1: newSize)
            setWindowPosition(window: mindNodeWindow, position1: newPoint)
        }
    }
    
    
    // Move "Mind Node Tags"
    if let mindNodeTagsWindow = getFirstWindow(withname: "MindNode Tags") {
        let  newPoint = CGPoint(x: mindNodeBounds.origin.x+mindNodeBounds.size.width, y: mindNodeBounds.origin.y)
        let newSize = CGSize(width: widthOfMindNodeTags, height: mindNodeBounds.size.height)
        
        setWindowSize(window: mindNodeTagsWindow, size1: newSize)
        setWindowPosition(window: mindNodeTagsWindow, position1: newPoint)
    }
    
}

func getBoundsOfWindow(withname windowname: String) -> CGRect! {
    let typeOfWindowsToGet = CGWindowListOption.optionOnScreenOnly
    let listOfWindowsVisaible = CGWindowListCopyWindowInfo(typeOfWindowsToGet, kCGNullWindowID) as NSArray? as? [[String: AnyObject]]
    
    // get width of mindNodeTagsDocument
    for window  in listOfWindowsVisaible! {
        let owner = window[kCGWindowOwnerName as String] as! String
        if owner == windowname {
            return CGRect(dictionaryRepresentation: window[kCGWindowBounds as String] as! CFDictionary)!
        }
    }
    return nil
}

func getFirstWindow(withname windowname: String) -> AXUIElement? {
    
    let typeOfWindowsToGet = CGWindowListOption.optionOnScreenOnly
    let listOfWindowsVisaible = CGWindowListCopyWindowInfo(typeOfWindowsToGet, kCGNullWindowID) as NSArray? as? [[String: AnyObject]]
    
    for window in listOfWindowsVisaible! {
        let AppThatCreatedWindow = window[kCGWindowOwnerName as String] as! String
        let pid = window[kCGWindowOwnerPID as String] as? Int32
        
        if AppThatCreatedWindow == windowname {
            let appRef = AXUIElementCreateApplication(pid!);  //TopLevel Accessability Object of PID
            var value: AnyObject?
            _ = AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value) // result
            
            if let windowList = value as? [AXUIElement] {
                return windowList.first
            }
        }
    }
    return nil
}

func setWindowPosition(window: AXUIElement, position1: CGPoint) {
    var position2 = position1
    let position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!,&position2)!;
    AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position);
}

func setWindowSize(window: AXUIElement, size1: CGSize) {
    var size2 = size1
    let size = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!,&size2)!;
    AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, size);
}
